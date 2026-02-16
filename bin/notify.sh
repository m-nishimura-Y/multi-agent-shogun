#!/bin/bash
# ============================================================
# notify.sh - エージェント間通知スクリプト
# ============================================================
# 用途: tmux send-keys + Enter を確実に実行する
# 背景: Enter忘れによる通知未達問題を根本解決
# v1.1: エイリアス対応（shogun, gunshi, karo, ashigaru1-8）
# v1.2: エラーハンドリング・リトライ機能追加（cmd_062）
# ============================================================

set -uo pipefail

# 設定
MAX_RETRIES=3
RETRY_INTERVAL=1

# エイリアスをペイン番号に変換
resolve_target() {
    local alias="$1"
    case "$alias" in
        shogun)     echo "shogun:0" ;;
        gunshi)     echo "gunshi:0" ;;
        karo)       echo "multiagent:0.0" ;;
        ashigaru1)  echo "multiagent:0.1" ;;
        ashigaru2)  echo "multiagent:0.2" ;;
        ashigaru3)  echo "multiagent:0.3" ;;
        ashigaru4)  echo "multiagent:0.4" ;;
        ashigaru5)  echo "multiagent:0.5" ;;
        ashigaru6)  echo "multiagent:0.6" ;;
        ashigaru7)  echo "multiagent:0.7" ;;
        ashigaru8)  echo "multiagent:0.8" ;;
        # 短縮形
        a1) echo "multiagent:0.1" ;;
        a2) echo "multiagent:0.2" ;;
        a3) echo "multiagent:0.3" ;;
        a4) echo "multiagent:0.4" ;;
        a5) echo "multiagent:0.5" ;;
        a6) echo "multiagent:0.6" ;;
        a7) echo "multiagent:0.7" ;;
        a8) echo "multiagent:0.8" ;;
        # そのまま返す（従来のペイン指定）
        *)  echo "$alias" ;;
    esac
}

# リトライ付きsend-keys関数
send_with_retry() {
    local target="$1"
    local message="$2"
    local attempt=1

    while [ $attempt -le $MAX_RETRIES ]; do
        # メッセージ送信
        if tmux send-keys -t "$target" "$message" 2>/dev/null; then
            sleep 0.3
            # Enter送信
            if tmux send-keys -t "$target" Enter 2>/dev/null; then
                return 0  # 成功
            fi
        fi

        # 失敗した場合
        if [ $attempt -lt $MAX_RETRIES ]; then
            echo "[notify] Attempt $attempt failed, retrying in ${RETRY_INTERVAL}s..." >&2
            sleep $RETRY_INTERVAL
        fi
        attempt=$((attempt + 1))
    done

    # 全リトライ失敗
    return 1
}

# 引数チェック
if [ $# -lt 2 ]; then
    echo "Usage: $0 <TARGET> <MESSAGE>"
    echo ""
    echo "TARGET (エイリアス):"
    echo "  shogun              - 将軍"
    echo "  gunshi              - 軍師"
    echo "  karo                - 家老"
    echo "  ashigaru1 (or a1)   - 足軽1"
    echo "  ashigaru5 (or a5)   - 足軽5"
    echo ""
    echo "TARGET (従来形式も使用可):"
    echo "  gunshi:0, multiagent:0.0, etc."
    echo ""
    echo "Example:"
    echo "  $0 gunshi '軍師、家老より指示。'"
    echo "  $0 a5 '足軽5、任務を実行せよ。'"
    exit 1
fi

TARGET_ALIAS="$1"
shift
MESSAGE="$*"

# エイリアス解決
TARGET=$(resolve_target "$TARGET_ALIAS")

# リトライ付きで送信
if send_with_retry "$TARGET" "$MESSAGE"; then
    # 成功ログ（デバッグ用、必要に応じてコメントアウト解除）
    # echo "[notify] Sent to $TARGET ($TARGET_ALIAS): $MESSAGE"
    exit 0
else
    echo "[notify] ERROR: Failed to send message to $TARGET after $MAX_RETRIES attempts" >&2
    echo "[notify] Target: $TARGET_ALIAS -> $TARGET" >&2
    echo "[notify] Message: $MESSAGE" >&2
    exit 1
fi
