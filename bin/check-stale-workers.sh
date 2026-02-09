#!/bin/bash
# ============================================================
# check-stale-workers.sh - 長時間更新なし足軽への自動確認
# ============================================================
# 用途: progress.yamlを監視し、一定時間更新がない足軽に確認メッセージ送信
# 背景: 足軽8号より「更新リマインド」の提案（cmd_034）
# ============================================================

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# 設定
PROGRESS_FILE="${BASE_DIR}/queue/progress.yaml"
NOTIFY_SCRIPT="${SCRIPT_DIR}/notify.sh"
THRESHOLD_MINUTES="${1:-30}"  # デフォルト30分

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ============================================================
# 使用方法
# ============================================================
usage() {
    echo "Usage: $0 [THRESHOLD_MINUTES]"
    echo ""
    echo "長時間更新がない作業中の足軽に進捗確認メッセージを送信する。"
    echo ""
    echo "Arguments:"
    echo "  THRESHOLD_MINUTES  閾値（分）。デフォルト: 30"
    echo ""
    echo "Examples:"
    echo "  $0        # 30分以上更新なしの足軽に確認"
    echo "  $0 60     # 60分以上更新なしの足軽に確認"
    echo "  $0 15     # 15分以上更新なしの足軽に確認"
    exit 0
}

# ヘルプオプション
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

# ============================================================
# 前提条件チェック
# ============================================================
if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo -e "${RED}エラー: progress.yamlが見つかりません: $PROGRESS_FILE${NC}"
    exit 1
fi

if [[ ! -x "$NOTIFY_SCRIPT" ]]; then
    echo -e "${RED}エラー: notify.shが見つからないか実行権限がありません: $NOTIFY_SCRIPT${NC}"
    exit 1
fi

# ============================================================
# 現在時刻（Unix epoch秒）
# ============================================================
NOW=$(date +%s)

# ============================================================
# 足軽の更新時刻をチェック
# ============================================================
echo "=========================================="
echo "長時間更新なし足軽チェック"
echo "閾値: ${THRESHOLD_MINUTES}分"
echo "現在時刻: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

STALE_COUNT=0

# YAMLをパースして足軽情報を取得
# 本隊（1-4）と別働隊（5-8）を処理
for i in 1 2 3 4 5 6 7 8; do
    # 足軽のupdated_atとcurrent_taskを取得
    # grepとsedで簡易的にYAMLをパース（インデント形式に対応）
    WORKER_BLOCK=$(grep -A 8 "id: $i\$" "$PROGRESS_FILE" | head -8)

    if [[ -z "$WORKER_BLOCK" ]]; then
        continue
    fi

    # updated_at を抽出（シングルクォート/ダブルクォート両対応）
    UPDATED_AT=$(echo "$WORKER_BLOCK" | grep "updated_at:" | sed "s/.*updated_at: *['\"]\\{0,1\\}\\([^'\"]*\\)['\"]\\{0,1\\}/\\1/" | tr -d ' ' | head -1)

    # current_task を抽出（nullかどうか）
    CURRENT_TASK=$(echo "$WORKER_BLOCK" | grep "current_task:" | sed 's/.*current_task: *//' | tr -d ' ' | head -1)

    # 作業中でない（current_task: null）場合はスキップ
    if [[ "$CURRENT_TASK" == "null" || -z "$CURRENT_TASK" ]]; then
        echo "足軽${i}: 待機中（スキップ）"
        continue
    fi

    # updated_at が空の場合はスキップ
    if [[ -z "$UPDATED_AT" ]]; then
        echo -e "${YELLOW}足軽${i}: updated_at が取得できません${NC}"
        continue
    fi

    # ISO 8601形式をUnix epoch秒に変換
    # macOSとLinuxで互換性のある方法
    if date --version >/dev/null 2>&1; then
        # GNU date (Linux)
        UPDATED_EPOCH=$(date -d "$UPDATED_AT" +%s 2>/dev/null || echo "0")
    else
        # BSD date (macOS)
        UPDATED_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$UPDATED_AT" +%s 2>/dev/null || echo "0")
    fi

    if [[ "$UPDATED_EPOCH" == "0" ]]; then
        echo -e "${YELLOW}足軽${i}: 日時パースエラー（$UPDATED_AT）${NC}"
        continue
    fi

    # 経過時間（分）を計算
    ELAPSED_SECONDS=$((NOW - UPDATED_EPOCH))
    ELAPSED_MINUTES=$((ELAPSED_SECONDS / 60))

    # 閾値超過チェック
    if [[ $ELAPSED_MINUTES -ge $THRESHOLD_MINUTES ]]; then
        echo -e "${RED}足軽${i}: ${ELAPSED_MINUTES}分経過 ← 閾値超過！${NC}"
        echo "  タスク: $CURRENT_TASK"
        echo "  最終更新: $UPDATED_AT"

        # 報告先を決定（本隊は家老、別働隊は軍師）
        if [[ $i -le 4 ]]; then
            REPORT_TARGET="karo"
        else
            REPORT_TARGET="gunshi"
        fi

        # 確認メッセージを送信
        MESSAGE="【進捗確認】${THRESHOLD_MINUTES}分以上更新がありませぬ。作業状況をprogress.yamlに記録されたし。"

        echo "  → ashigaru${i} に確認メッセージ送信中..."
        "$NOTIFY_SCRIPT" "ashigaru${i}" "$MESSAGE"

        STALE_COUNT=$((STALE_COUNT + 1))
    else
        echo -e "${GREEN}足軽${i}: ${ELAPSED_MINUTES}分経過（OK）${NC}"
    fi
done

echo "=========================================="
if [[ $STALE_COUNT -gt 0 ]]; then
    echo -e "${YELLOW}結果: ${STALE_COUNT}名の足軽に確認メッセージを送信${NC}"
else
    echo -e "${GREEN}結果: 全員問題なし${NC}"
fi
echo "=========================================="

exit 0
