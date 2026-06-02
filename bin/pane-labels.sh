#!/bin/bash
# ============================================================
# pane-labels.sh - tmux pane の色分け＋ラベル設定
# ============================================================
# 用途: 全paneに役割名ラベルと色を設定し、一目で誰かわかるようにする
# 実行: bash ~/multi-agent-shogun/bin/pane-labels.sh
# ============================================================

set -uo pipefail

# ============================================================
# 色定義（tmux style format）
# ============================================================
# 役割ごとの色テーマ
#   将軍: 赤金（権威）
#   家老: 金（管理）
#   奉行: 紫（司法）
#   軍師: 青（知略）
#   足軽本隊(1-4): 緑（実行）
#   足軽別働隊(5-8): シアン（特殊）

declare -A PANE_COLORS=(
    ["shogun"]="fg=colour196,bold"       # 赤
    ["karo"]="fg=colour214,bold"         # 金
    ["bugyo"]="fg=colour135,bold"        # 紫
    ["gunshi"]="fg=colour39,bold"        # 青
    ["ashigaru1"]="fg=colour40"          # 緑
    ["ashigaru2"]="fg=colour40"          # 緑
    ["ashigaru3"]="fg=colour40"          # 緑
    ["ashigaru4"]="fg=colour40"          # 緑
    ["ashigaru5"]="fg=colour51"          # シアン
    ["ashigaru6"]="fg=colour51"          # シアン
    ["ashigaru7"]="fg=colour51"          # シアン
    ["ashigaru8"]="fg=colour51"          # シアン
)

declare -A PANE_LABELS=(
    ["shogun"]="🏯 将軍"
    ["karo"]="👑 家老"
    ["bugyo"]="⚖️  奉行"
    ["gunshi"]="📘 軍師"
    ["ashigaru1"]="⚔️  足軽1 [本隊]"
    ["ashigaru2"]="⚔️  足軽2 [本隊]"
    ["ashigaru3"]="⚔️  足軽3 [本隊]"
    ["ashigaru4"]="⚔️  足軽4 [本隊]"
    ["ashigaru5"]="🗡️  足軽5 [別働隊]"
    ["ashigaru6"]="🗡️  足軽6 [別働隊]"
    ["ashigaru7"]="🗡️  足軽7 [別働隊]"
    ["ashigaru8"]="🗡️  足軽8 [別働隊]"
)

# tmux target（セッション:ウィンドウ.ペイン）
declare -A PANE_TARGETS=(
    ["shogun"]="shogun:0"
    ["karo"]="multiagent:0.0"
    ["bugyo"]="bugyo:0"
    ["gunshi"]="gunshi:0"
    ["ashigaru1"]="multiagent:0.1"
    ["ashigaru2"]="multiagent:0.2"
    ["ashigaru3"]="multiagent:0.3"
    ["ashigaru4"]="multiagent:0.4"
    ["ashigaru5"]="multiagent:0.5"
    ["ashigaru6"]="multiagent:0.6"
    ["ashigaru7"]="multiagent:0.7"
    ["ashigaru8"]="multiagent:0.8"
)

# ============================================================
# メイン処理
# ============================================================

echo "🎨 pane ラベル＋色分け設定開始..."

# 保険: allow-rename off（window 名の自動上書き禁止。pane title には効かぬが念のため）
# ※ pane title は Claude Code 等が OSC で乗っ取るのを tmux 側で完全には防げぬため、
#   下記の pane-border-format は #{pane_title} を使わず pane_index ベースの固定マップで書く
tmux set-option -g allow-rename off 2>/dev/null

for session in shogun multiagent bugyo gunshi; do
    if tmux has-session -t "$session" 2>/dev/null; then
        tmux set-option -t "$session" allow-rename off 2>/dev/null
        tmux set-option -t "$session" pane-border-status top 2>/dev/null
    fi
done

# 各paneにラベルと色を設定（pane_title 自体も保険で更新するが、border は別系統で固定表示）
for role in "${!PANE_TARGETS[@]}"; do
    target="${PANE_TARGETS[$role]}"
    label="${PANE_LABELS[$role]}"

    if tmux list-panes -t "${target%.*}" 2>/dev/null | grep -q .; then
        tmux select-pane -t "$target" -T "$label" 2>/dev/null
        echo "  ✅ $role → $label"
    else
        echo "  ⏭️  $role: session not found, skipping"
    fi
done

# ============================================================
# pane-border-format: pane_index ベースの固定マップ
# ------------------------------------------------------------
# Claude Code が pane_title を上書きしてもボーダー表示が崩れぬよう、
# #{pane_title} ではなく pane_index で分岐させて固定ラベルを描画する。
# ============================================================

# multiagent: 9ペイン (0=家老 / 1-4=本隊 / 5-8=別働隊)
build_multiagent_border() {
    local fmt=""
    for i in 0 1 2 3 4 5 6 7 8; do
        local color label
        case $i in
            0) color="fg=colour214,bold"; label="👑 家老" ;;
            1|2|3|4) color="fg=colour40"; label="⚔️  足軽${i} [本隊]" ;;
            5|6|7|8) color="fg=colour51"; label="🗡️  足軽${i} [別働隊]" ;;
        esac
        fmt+="#{?#{==:#{pane_index},${i}},#[${color}] ${label} #[default],"
    done
    fmt+="unknown"
    for _ in 0 1 2 3 4 5 6 7 8; do fmt+="}"; done
    printf '%s' "$fmt"
}

tmux set-option -t multiagent pane-border-format "$(build_multiagent_border)" 2>/dev/null

tmux set-option -t shogun pane-border-format \
    "#[fg=colour196,bold] 🏯 将軍 #[default]" 2>/dev/null

tmux set-option -t bugyo pane-border-format \
    "#[fg=colour135,bold] ⚖️  奉行 #[default]" 2>/dev/null

tmux set-option -t gunshi pane-border-format \
    "#[fg=colour39,bold] 📘 軍師 #[default]" 2>/dev/null

echo ""
echo "✨ 完了！全paneにラベルと色を設定した。"
echo "   確認: tmux の各セッションを見てみてください。"
