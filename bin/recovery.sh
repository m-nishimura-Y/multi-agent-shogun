#!/bin/bash
# ============================================================
# recovery.sh - コンパクション復帰時の自動コンテキスト再注入
# ============================================================
# 用途: SessionStart hook (compact) で自動実行される
# 効果: エージェントの判断を挟まず、必要なファイルを強制表示
# ============================================================

# プロジェクトルート
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/multi-agent-shogun}"

# セッション名から役割を判定（window名は「claude」になることがあるため使わない）
SESSION_NAME=$(tmux display-message -p '#S' 2>/dev/null || echo "unknown")
PANE_INDEX=$(tmux display-message -p '#{pane_index}' 2>/dev/null || echo "0")

# 役割を判定
case "$SESSION_NAME" in
    shogun)
        ROLE="将軍"
        INSTRUCTION_FILE="shogun.md"
        ;;
    gunshi)
        ROLE="軍師"
        INSTRUCTION_FILE="gunshi.md"
        ;;
    multiagent)
        if [ "$PANE_INDEX" = "0" ]; then
            ROLE="家老"
            INSTRUCTION_FILE="karo.md"
        else
            ROLE="足軽$PANE_INDEX"
            INSTRUCTION_FILE="ashigaru.md"
        fi
        ;;
    *)
        ROLE="不明（$SESSION_NAME）"
        INSTRUCTION_FILE="ashigaru.md"
        ;;
esac

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  コンパクション復帰でござる"
echo "  セッション: $SESSION_NAME / pane: $PANE_INDEX"
echo "  役割: $ROLE"
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
head -80 "$PROJECT_DIR/instructions/$INSTRUCTION_FILE" 2>/dev/null

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
        "$PROJECT_DIR/bin/notify.sh" "$SELF_TARGET" "/recovery"
        echo "[$(date)] notify.sh exit code: $?" >> "$LOG_FILE"
    ) &
    echo "[$(date)] Background process started" >> "$LOG_FILE"
fi

exit 0
