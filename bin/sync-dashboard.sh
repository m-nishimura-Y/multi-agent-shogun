#!/bin/bash
# ============================================================
# sync-dashboard.sh
# progress.yamlの内容をdashboard.mdの「全軍ステータス」に反映
# ============================================================
# 使用方法: ./bin/sync-dashboard.sh
#
# 機能:
#   1. queue/progress.yaml を読み取り
#   2. 本隊/別働隊の作業状況を集計
#   3. dashboard.md の「🏯 全軍ステータス」セクションを更新
#   4. 最終更新時刻を更新
#
# 冪等性: 何度実行しても同じ結果になる
# ============================================================

set -euo pipefail

# パス設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
PROGRESS_FILE="$BASE_DIR/queue/progress.yaml"
DASHBOARD_FILE="$BASE_DIR/dashboard.md"
TEMP_FILE=$(mktemp)

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# ログ関数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# クリーンアップ
cleanup() {
    rm -f "$TEMP_FILE" 2>/dev/null || true
}
trap cleanup EXIT

# ============================================================
# progress.yaml パース関数
# ============================================================

# 足軽情報を抽出（セクション: honntai または betsudoutai）
parse_ashigaru_section() {
    local section="$1"
    local in_section=false
    local current_id=""
    local current_task=""
    local task_id=""
    local progress=""
    local blocked_by=""

    while IFS= read -r line; do
        # セクション開始検出
        if [[ "$line" =~ ^${section}: ]]; then
            in_section=true
            continue
        fi

        # 別セクション開始で終了
        if $in_section && [[ "$line" =~ ^[a-z]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
            # 最後のエントリを出力
            if [[ -n "$current_id" ]]; then
                echo "$current_id|$current_task|$task_id|$progress|$blocked_by"
            fi
            break
        fi

        if $in_section; then
            # 新しいエントリ開始
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*id:[[:space:]]*([0-9]+) ]]; then
                # 前のエントリを出力
                if [[ -n "$current_id" ]]; then
                    echo "$current_id|$current_task|$task_id|$progress|$blocked_by"
                fi
                current_id="${BASH_REMATCH[1]}"
                current_task=""
                task_id=""
                progress="0"
                blocked_by=""
            elif [[ "$line" =~ current_task:[[:space:]]*(.+) ]]; then
                current_task="${BASH_REMATCH[1]}"
                # null/~/"null" を空に
                [[ "$current_task" == "null" || "$current_task" == "~" || "$current_task" == "\"null\"" ]] && current_task=""
            elif [[ "$line" =~ task_id:[[:space:]]*(.+) ]]; then
                task_id="${BASH_REMATCH[1]}"
                [[ "$task_id" == "null" || "$task_id" == "~" || "$task_id" == "\"null\"" ]] && task_id=""
            elif [[ "$line" =~ progress:[[:space:]]*([0-9]+) ]]; then
                progress="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ blocked_by:[[:space:]]*(.*) ]]; then
                blocked_by="${BASH_REMATCH[1]}"
                # null, ~, 空, クォート付きnull を空に変換
                blocked_by=$(echo "$blocked_by" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                [[ "$blocked_by" == "null" || "$blocked_by" == "~" || "$blocked_by" == "\"null\"" || "$blocked_by" == "'null'" || -z "$blocked_by" ]] && blocked_by=""
            fi
        fi
    done < "$PROGRESS_FILE"

    # 最後のエントリを出力（EOFで終わった場合）
    if $in_section && [[ -n "$current_id" ]]; then
        echo "$current_id|$current_task|$task_id|$progress|$blocked_by"
    fi
}

# ============================================================
# ステータス集計関数
# ============================================================

# 本隊ステータス生成
generate_honntai_status() {
    local working=0
    local blocked=0
    local idle=0
    local details=""

    while IFS='|' read -r id task task_id progress blocked_by; do
        [[ -z "$id" ]] && continue

        if [[ -n "$blocked_by" && "$blocked_by" != "" ]]; then
            ((blocked++))
            [[ -n "$details" ]] && details+=", "
            details+="足軽${id}:blocked"
        elif [[ -n "$task" && "$task" != "" ]]; then
            ((working++))
            [[ -n "$details" ]] && details+=", "
            # task_idからcmd部分を抽出
            local cmd_part=""
            if [[ "$task_id" =~ (cmd_[0-9]+) ]]; then
                cmd_part="${BASH_REMATCH[1]}"
            else
                cmd_part="$task"
            fi
            details+="足軽${id}:${cmd_part}(${progress}%)"
        else
            ((idle++))
        fi
    done < <(parse_ashigaru_section "honntai")

    local status=""
    if [[ $working -gt 0 ]]; then
        status="**${working}名作業中**"
    elif [[ $blocked -gt 0 ]]; then
        status="**${blocked}名ブロック中**"
    else
        status="待機中"
    fi

    [[ -z "$details" ]] && details="全員idle"

    echo "$status|$details"
}

# 別働隊ステータス生成
generate_betsudoutai_status() {
    local working=0
    local blocked=0
    local idle=0
    local details=""

    while IFS='|' read -r id task task_id progress blocked_by; do
        [[ -z "$id" ]] && continue

        if [[ -n "$blocked_by" && "$blocked_by" != "" ]]; then
            ((blocked++))
            [[ -n "$details" ]] && details+=", "
            details+="足軽${id}:blocked"
        elif [[ -n "$task" && "$task" != "" ]]; then
            ((working++))
            [[ -n "$details" ]] && details+=", "
            local cmd_part=""
            if [[ "$task_id" =~ (cmd_[0-9]+) ]]; then
                cmd_part="${BASH_REMATCH[1]}"
            else
                cmd_part="$task"
            fi
            details+="足軽${id}:${cmd_part}(${progress}%)"
        else
            ((idle++))
        fi
    done < <(parse_ashigaru_section "betsudoutai")

    local status=""
    if [[ $working -gt 0 ]]; then
        status="**${working}名作業中**"
    elif [[ $blocked -gt 0 ]]; then
        status="**${blocked}名ブロック中**"
    else
        status="待機中"
    fi

    [[ -z "$details" ]] && details="全員idle"

    echo "$status|$details"
}

# ============================================================
# dashboard.md 更新関数
# ============================================================

update_dashboard() {
    local honntai_result=$(generate_honntai_status)
    local betsudoutai_result=$(generate_betsudoutai_status)

    local honntai_status=$(echo "$honntai_result" | cut -d'|' -f1)
    local honntai_details=$(echo "$honntai_result" | cut -d'|' -f2)
    local betsudoutai_status=$(echo "$betsudoutai_result" | cut -d'|' -f1)
    local betsudoutai_details=$(echo "$betsudoutai_result" | cut -d'|' -f2)

    local timestamp=$(date '+%Y-%m-%d %H:%M')

    # dashboard.md を更新
    local in_status_section=false
    local status_updated=false
    local header_updated=false

    while IFS= read -r line; do
        # 最終更新時刻の更新
        if [[ "$line" =~ ^最終更新: ]]; then
            echo "最終更新: $timestamp"
            header_updated=true
            continue
        fi

        # 全軍ステータスセクション検出
        if [[ "$line" == "## 🏯 全軍ステータス" ]]; then
            in_status_section=true
            echo "$line"
            continue
        fi

        # 次のセクション開始で終了
        if $in_status_section && [[ "$line" =~ ^##[[:space:]] ]] && [[ "$line" != "## 🏯 全軍ステータス" ]]; then
            in_status_section=false
        fi

        # ステータステーブル行の更新
        if $in_status_section; then
            if [[ "$line" =~ ^\|[[:space:]]*本隊 ]]; then
                echo "| 本隊（1-4） | $honntai_status | $honntai_details |"
                status_updated=true
                continue
            elif [[ "$line" =~ ^\|[[:space:]]*別働隊 ]]; then
                echo "| 別働隊（5-8） | $betsudoutai_status | $betsudoutai_details |"
                continue
            fi
        fi

        echo "$line"
    done < "$DASHBOARD_FILE" > "$TEMP_FILE"

    # 結果をdashboard.mdに書き戻し
    mv "$TEMP_FILE" "$DASHBOARD_FILE"

    log_info "dashboard.md 更新完了"
    log_info "  本隊: $honntai_status ($honntai_details)"
    log_info "  別働隊: $betsudoutai_status ($betsudoutai_details)"
    log_info "  最終更新: $timestamp"
}

# ============================================================
# メイン処理
# ============================================================

main() {
    log_info "sync-dashboard.sh 開始"

    # ファイル存在確認
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        log_error "progress.yaml が見つかりません: $PROGRESS_FILE"
        exit 1
    fi

    if [[ ! -f "$DASHBOARD_FILE" ]]; then
        log_error "dashboard.md が見つかりません: $DASHBOARD_FILE"
        exit 1
    fi

    # 更新実行
    update_dashboard

    log_info "sync-dashboard.sh 完了"
}

main "$@"
