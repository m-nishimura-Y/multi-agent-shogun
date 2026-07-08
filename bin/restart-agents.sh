#!/bin/bash
# ============================================================
# restart-agents.sh - エージェント再起動スクリプト
# ============================================================
# 用途: 指定したエージェントまたは全軍を一括再起動
# v1.0: 初版（cmd_074）
# ============================================================

set -uo pipefail

# 設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESTART_INTERVAL=2  # 各エージェント間の待機秒数
STARTUP_WAIT=3      # Claude Code起動待ち秒数

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# エージェント定義
declare -A AGENTS=(
    ["shogun"]="shogun:0"
    ["gunshi"]="gunshi:0"
    ["bugyo"]="bugyo:0"
    ["karo"]="multiagent:0.0"
    ["ashigaru1"]="multiagent:0.1"
    ["ashigaru2"]="multiagent:0.2"
    ["ashigaru3"]="multiagent:0.3"
    ["ashigaru4"]="multiagent:0.4"
    ["ashigaru5"]="multiagent:0.5"
    ["ashigaru6"]="multiagent:0.6"
    ["ashigaru7"]="multiagent:0.7"
    ["ashigaru8"]="multiagent:0.8"
)

# effort設定: 上位(将軍・軍師・奉行・家老)=max、足軽=high
declare -A EFFORT_LEVELS=(
    ["shogun"]="max"
    ["gunshi"]="max"
    ["bugyo"]="max"
    ["karo"]="max"
    ["ashigaru1"]="high"
    ["ashigaru2"]="high"
    ["ashigaru3"]="high"
    ["ashigaru4"]="high"
    ["ashigaru5"]="high"
    ["ashigaru6"]="high"
    ["ashigaru7"]="high"
    ["ashigaru8"]="high"
)

# model設定（API負荷対策 2026-07-03・殿決定）
#   将軍=判断層 / 軍師=判断層 / 家老=判断層 / 足軽=実装・レビュー実働 → Opus 維持
#   奉行=報告集約・清書が主 → Sonnet に軽量化（本日の律速層）
declare -A MODEL_LEVELS=(
    ["shogun"]="opus"
    ["gunshi"]="opus"
    ["bugyo"]="sonnet"
    ["karo"]="opus"
    ["ashigaru1"]="opus"
    ["ashigaru2"]="opus"
    ["ashigaru3"]="opus"
    ["ashigaru4"]="opus"
    ["ashigaru5"]="opus"
    ["ashigaru6"]="opus"
    ["ashigaru7"]="opus"
    ["ashigaru8"]="opus"
)

# グループ定義
HONTAI=("ashigaru1" "ashigaru2" "ashigaru3" "ashigaru4")
BETSUDOUTAI=("ashigaru5" "ashigaru6" "ashigaru7" "ashigaru8")
ALL_ASHIGARU=("${HONTAI[@]}" "${BETSUDOUTAI[@]}")
ALL_AGENTS=("shogun" "gunshi" "bugyo" "karo" "${ALL_ASHIGARU[@]}")

# ============================================================
# ヘルプ表示
# ============================================================
show_help() {
    echo "Usage: $0 [OPTIONS] [TARGETS...]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help      このヘルプを表示"
    echo "  -f, --force     確認なしで実行"
    echo "  -q, --quiet     静かに実行（進捗表示のみ）"
    echo ""
    echo "TARGETS:"
    echo "  all             全軍（将軍・軍師・家老・足軽1-8）"
    echo "  ashigaru        足軽全員（1-8）"
    echo "  hontai          本隊（足軽1-4）"
    echo "  betsudoutai     別働隊（足軽5-8）"
    echo "  shogun          将軍のみ"
    echo "  gunshi          軍師のみ"
    echo "  karo            家老のみ"
    echo "  ashigaru1-8     個別の足軽"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 ashigaru           # 足軽全員を再起動"
    echo "  $0 hontai             # 本隊（足軽1-4）を再起動"
    echo "  $0 ashigaru1 ashigaru2 # 足軽1と2を再起動"
    echo "  $0 all -f             # 全軍を確認なしで再起動"
    echo ""
    echo "NOTE:"
    echo "  - 再起動順序: 足軽 → 軍師 → 家老 → 将軍（指揮系統の逆順）"
    echo "  - 各エージェント間に${RESTART_INTERVAL}秒の待機を入れる"
    echo "  - 将軍の再起動は別セッションのため、通常は含まない"
    echo "  - effort設定: 上位(将軍/軍師/奉行/家老)=max、足軽=high（自動適用）"
}

# ============================================================
# エージェント再起動関数
# ============================================================
restart_agent() {
    local name="$1"
    local target="${AGENTS[$name]}"
    local quiet="${2:-false}"

    if [ -z "$target" ]; then
        echo -e "${RED}[ERROR] Unknown agent: $name${NC}" >&2
        return 1
    fi

    # ペイン存在確認
    if ! tmux list-panes -t "${target%.*}" 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}[SKIP] Session not found: $target${NC}"
        return 0
    fi

    if [ "$quiet" != "true" ]; then
        echo -e "${BLUE}[RESTART] $name ($target)${NC}"
    fi

    # Step 1: /exit 送信（コマンドとEnterを分けて確実に送信）
    tmux send-keys -t "$target" "/exit" 2>/dev/null
    sleep 0.3
    tmux send-keys -t "$target" Enter 2>/dev/null
    sleep 5  # /exit完了を待つ（Claude Code終了に時間がかかる）

    # Step 2: claude コマンド送信（再起動）
    # --dangerously-skip-permissions で自動承認モードで起動
    # --model は役職別（MODEL_LEVELS）。起動時 shutsujin_departure.sh と配分を揃える
    local model="${MODEL_LEVELS[$name]:-opus}"
    tmux send-keys -t "$target" "claude --model $model --dangerously-skip-permissions" 2>/dev/null
    sleep 0.3
    tmux send-keys -t "$target" Enter 2>/dev/null
    sleep 5  # Claude Code起動完了を待つ

    # Step 3: /effort 設定（起動直後に設定）
    local effort="${EFFORT_LEVELS[$name]:-high}"
    tmux send-keys -t "$target" "/effort $effort" 2>/dev/null
    sleep 0.3
    tmux send-keys -t "$target" Enter 2>/dev/null
    sleep 2

    # Step 4: /recovery 呼び出し（コンテキスト再注入）
    tmux send-keys -t "$target" "/recovery" 2>/dev/null
    sleep 0.3
    tmux send-keys -t "$target" Enter 2>/dev/null
    sleep 1

    if [ "$quiet" != "true" ]; then
        echo -e "${GREEN}[DONE] $name restarted (model: $model, effort: $effort)${NC}"
    fi

    return 0
}

# ============================================================
# 対象リスト展開
# ============================================================
expand_targets() {
    local targets=()

    for arg in "$@"; do
        case "$arg" in
            all)
                # 将軍以外の全員（将軍は別セッションなので除外推奨）
                targets+=("${ALL_ASHIGARU[@]}" "gunshi" "karo")
                ;;
            all-with-shogun)
                targets+=("${ALL_AGENTS[@]}")
                ;;
            ashigaru)
                targets+=("${ALL_ASHIGARU[@]}")
                ;;
            hontai)
                targets+=("${HONTAI[@]}")
                ;;
            betsudoutai)
                targets+=("${BETSUDOUTAI[@]}")
                ;;
            -f|--force|-q|--quiet|-h|--help)
                # オプションはスキップ
                ;;
            *)
                targets+=("$arg")
                ;;
        esac
    done

    # 重複除去して出力
    printf '%s\n' "${targets[@]}" | awk '!seen[$0]++'
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local force=false
    local quiet=false
    local targets=()

    # オプション解析
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                force=true
                ;;
            -q|--quiet)
                quiet=true
                ;;
        esac
    done

    # 対象がない場合
    if [ $# -eq 0 ] || { [ $# -eq 1 ] && [[ "$1" =~ ^- ]]; }; then
        show_help
        exit 1
    fi

    # 対象を展開
    mapfile -t targets < <(expand_targets "$@")

    if [ ${#targets[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR] No valid targets specified${NC}" >&2
        exit 1
    fi

    # 確認
    if [ "$force" != "true" ]; then
        echo -e "${YELLOW}以下のエージェントを再起動します:${NC}"
        printf '  - %s\n' "${targets[@]}"
        echo ""
        read -p "続行しますか？ [y/N]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "キャンセルしました。"
            exit 0
        fi
    fi

    # 再起動実行
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  全軍再起動開始${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    local success=0
    local failed=0

    for agent in "${targets[@]}"; do
        if restart_agent "$agent" "$quiet"; then
            ((success++))
        else
            ((failed++))
        fi

        # 最後のエージェント以外は待機
        if [ "$agent" != "${targets[-1]}" ]; then
            sleep $RESTART_INTERVAL
        fi
    done

    # 結果表示
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  再起動完了: ${success}名成功 / ${failed}名失敗${NC}"
    echo -e "${GREEN}========================================${NC}"

    # paneラベル＋色分け再適用
    if [ -x "$SCRIPT_DIR/pane-labels.sh" ]; then
        echo ""
        "$SCRIPT_DIR/pane-labels.sh"
    fi

    if [ $failed -gt 0 ]; then
        exit 1
    fi
}

# 実行
main "$@"
