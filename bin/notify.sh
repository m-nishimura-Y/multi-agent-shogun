#!/bin/bash
# ============================================================
# notify.sh - エージェント間通知スクリプト
# ============================================================
# 用途: tmux send-keys + Enter を確実に実行する
# 背景: Enter忘れによる通知未達問題を根本解決
# ============================================================

set -euo pipefail

# 引数チェック
if [ $# -lt 2 ]; then
    echo "Usage: $0 <TARGET> <MESSAGE>"
    echo ""
    echo "TARGET examples:"
    echo "  gunshi:0       - 軍師"
    echo "  multiagent:0.0 - 家老"
    echo "  multiagent:0.1 - 足軽1"
    echo "  multiagent:0.5 - 足軽5"
    echo ""
    echo "Example:"
    echo "  $0 gunshi:0 '軍師、家老より指示。BUG-024を確認せよ。'"
    exit 1
fi

TARGET="$1"
shift
MESSAGE="$*"

# send-keys + Enter を実行（2回に分けて確実に送信）
tmux send-keys -t "$TARGET" "$MESSAGE"
sleep 0.1  # tmuxが処理する時間を確保
tmux send-keys -t "$TARGET" Enter

# 成功ログ（デバッグ用、必要に応じてコメントアウト）
# echo "[notify] Sent to $TARGET: $MESSAGE"
