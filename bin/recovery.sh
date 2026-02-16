#!/bin/bash
# ============================================================
# recovery.sh - コンパクション復帰時の自動コンテキスト再注入
# ============================================================
# 用途: SessionStart hook (compact) で自動実行される
# 効果: エージェントの判断を挟まず、必要なファイルを強制表示
# ============================================================

# プロジェクトルート
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/multi-agent-shogun}"

# pane名から役割を判定
PANE_NAME=$(tmux display-message -p '#W' 2>/dev/null || echo "unknown")

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  コンパクション復帰でござる"
echo "  役割: $PANE_NAME"
echo "════════════════════════════════════════════════════════════════"
echo ""

# 心得（全員共通）
echo "【心得】"
echo "「戦は準備の帰結に過ぎない。確認・準備・計画に最も時間をかけよ」"
echo "「永続化なき作業は、砂上の楼閣なり」"
echo ""

# 現在のタスク状況
echo "【現在のタスク】"
if [ -f "$PROJECT_DIR/status/current_task.yaml" ]; then
    cat "$PROJECT_DIR/status/current_task.yaml"
else
    echo "（current_task.yaml が見つからぬ）"
fi
echo ""

# 役割に応じた指示書の冒頭を表示（禁止事項まで）
echo "【汝の役割と禁止事項】"
case "$PANE_NAME" in
    shogun*)
        head -80 "$PROJECT_DIR/instructions/shogun.md" 2>/dev/null
        ;;
    gunshi*)
        head -80 "$PROJECT_DIR/instructions/gunshi.md" 2>/dev/null
        ;;
    karo*|multiagent*)
        # karo は multiagent:0.0 の可能性もある
        head -80 "$PROJECT_DIR/instructions/karo.md" 2>/dev/null
        ;;
    *)
        # 足軽（ashigaru）またはその他
        head -80 "$PROJECT_DIR/instructions/ashigaru.md" 2>/dev/null
        ;;
esac

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  【必須アクション】殿にコンパクション復帰を報告せよ！"
echo "  例: 「コンパクション復帰でござる。現在のタスク: XXX」"
echo "════════════════════════════════════════════════════════════════"
echo ""

# 自分自身にメッセージを送信して、Claudeへの入力として認識させる
# バックグラウンドで実行（hookが同期的に完了しないとClaudeが入力待ちにならないため）
SELF_TARGET=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
LOG_FILE="/tmp/recovery_debug.log"
echo "[$(date)] recovery.sh executed, SELF_TARGET=$SELF_TARGET" >> "$LOG_FILE"
if [ -n "$SELF_TARGET" ]; then
    (
        # コンパクション処理が完全に完了し、Claudeが入力待ちになるまで待つ
        sleep 8
        echo "[$(date)] Sending notification to $SELF_TARGET" >> "$LOG_FILE"
        "$PROJECT_DIR/bin/notify.sh" "$SELF_TARGET" "【コンパクション復帰】殿に報告せよ。"
        echo "[$(date)] notify.sh exit code: $?" >> "$LOG_FILE"
    ) &
    echo "[$(date)] Background process started" >> "$LOG_FILE"
fi

exit 0
