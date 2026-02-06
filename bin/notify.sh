#!/bin/bash
# ============================================================
# notify.sh - エージェント間通知スクリプト
# ============================================================
# 用途: tmux send-keys + Enter を確実に実行する
# 背景: Enter忘れによる通知未達問題を根本解決
# v1.1: エイリアス対応（shogun, gunshi, karo, ashigaru1-8）
# ============================================================

set -euo pipefail

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

# send-keys + Enter を実行（2回に分けて確実に送信）
tmux send-keys -t "$TARGET" "$MESSAGE"
sleep 0.1  # tmuxが処理する時間を確保
tmux send-keys -t "$TARGET" Enter

# 成功ログ（デバッグ用、必要に応じてコメントアウト）
# echo "[notify] Sent to $TARGET ($TARGET_ALIAS): $MESSAGE"
