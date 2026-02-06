#!/bin/bash
# ============================================================
# status.sh - 全エージェント状態一覧表示
# ============================================================
# 用途: 各エージェントの状態（idle/working/STUCK）を表示
# - idle: プロンプト待ち（入力可能）
# - working: 処理中（thinking, Effecting等）
# - STUCK: プロンプトにメッセージが残存（Enter未送信の可能性）
# ============================================================

set -euo pipefail

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# エージェント定義
declare -A AGENTS=(
    ["shogun"]="shogun:0"
    ["karo"]="multiagent:0.0"
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

# エージェントの順序
AGENT_ORDER=("shogun" "karo" "gunshi" "ashigaru1" "ashigaru2" "ashigaru3" "ashigaru4" "ashigaru5" "ashigaru6" "ashigaru7" "ashigaru8")

# ペインの状態を判定
check_status() {
    local pane="$1"
    local output

    # ペインが存在するか確認
    if ! tmux has-session -t "${pane%:*}" 2>/dev/null; then
        echo "OFFLINE"
        return
    fi

    # ペインの内容を取得（最後の20行）
    output=$(tmux capture-pane -t "$pane" -p 2>/dev/null | tail -20)

    if [ -z "$output" ]; then
        echo "OFFLINE"
        return
    fi

    # 処理中かどうか判定
    if echo "$output" | grep -qE "(thinking|Inferring|Effecting|Boondoggling|Puzzling|Esc to interrupt)"; then
        echo "working"
        return
    fi

    # プロンプト待ち（idle）かどうか判定
    local last_lines=$(echo "$output" | tail -10)

    # プロンプト「❯」が表示されているか確認（Unicode対応）
    if echo "$last_lines" | grep -q "❯"; then
        # プロンプト行を取得
        local prompt_line=$(echo "$last_lines" | grep "❯" | tail -1)

        # プロンプト後に長いテキスト（10文字以上）があればSTUCK
        # 短いテキスト（スペースのみ等）はidle
        local after_prompt=$(echo "$prompt_line" | sed 's/.*❯//')
        local text_len=${#after_prompt}

        if [ "$text_len" -gt 10 ]; then
            echo "STUCK"
        else
            echo "idle"
        fi
    elif echo "$last_lines" | grep -q "bypass permissions on"; then
        # bypass permissions表示があればidle
        echo "idle"
    else
        # プロンプトが見つからない場合はworking扱い
        echo "working"
    fi
}

# ヘッダー出力
echo "=============================================="
echo " Multi-Agent Shogun - Status Dashboard"
echo " $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="
echo ""
printf "%-12s %-18s %s\n" "AGENT" "PANE" "STATUS"
echo "----------------------------------------------"

# 各エージェントの状態を表示
for agent in "${AGENT_ORDER[@]}"; do
    pane="${AGENTS[$agent]}"
    status=$(check_status "$pane")

    # 状態に応じて色分け
    case "$status" in
        idle)
            status_colored="${GREEN}idle${NC}"
            ;;
        working)
            status_colored="${BLUE}working${NC}"
            ;;
        STUCK)
            status_colored="${RED}STUCK${NC}"
            ;;
        OFFLINE)
            status_colored="${YELLOW}OFFLINE${NC}"
            ;;
        *)
            status_colored="$status"
            ;;
    esac

    printf "%-12s %-18s " "$agent" "$pane"
    echo -e "$status_colored"
done

echo "----------------------------------------------"
echo ""
echo "Legend:"
echo -e "  ${GREEN}idle${NC}    - プロンプト待ち（入力可能）"
echo -e "  ${BLUE}working${NC} - 処理中"
echo -e "  ${RED}STUCK${NC}   - メッセージ残存（要確認）"
echo -e "  ${YELLOW}OFFLINE${NC} - セッション未起動"
