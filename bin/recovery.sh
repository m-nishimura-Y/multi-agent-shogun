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
echo "  上記を確認してから作業を再開せよ"
echo "════════════════════════════════════════════════════════════════"
echo ""

exit 0
