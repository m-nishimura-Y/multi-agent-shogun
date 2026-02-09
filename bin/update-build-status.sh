#!/bin/bash
# ============================================================
# update-build-status.sh
# ビルドステータス共有ファイルを更新するツール
# ============================================================
# 使用例:
#   ./bin/update-build-status.sh backend ok
#   ./bin/update-build-status.sh frontend error "Module not found: xxx"
#   ./bin/update-build-status.sh working ashigaru3 "frontend/src/pages/Foo.tsx"
#   ./bin/update-build-status.sh done ashigaru3
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
STATUS_FILE="$BASE_DIR/status/build_status.yaml"
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo -e "${CYAN}使用方法:${NC}"
    echo "  $0 <command> [args...]"
    echo ""
    echo -e "${CYAN}コマンド:${NC}"
    echo "  backend ok|error|building [error_message]  - バックエンドのステータス更新"
    echo "  frontend ok|error|building [error_message] - フロントエンドのステータス更新"
    echo "  working <worker> <module>                   - 作業中モジュールを登録"
    echo "  done <worker>                               - 作業完了を登録"
    echo "  assign <target> <worker>                    - エラー対応担当を割り当て"
    echo "  status                                      - 現在のステータスを表示"
    echo ""
    echo -e "${CYAN}例:${NC}"
    echo "  $0 frontend ok"
    echo "  $0 frontend error \"Module not found: @mui/icons-material\""
    echo "  $0 working ashigaru3 \"frontend/src/pages/ProductListPage.tsx\""
    echo "  $0 done ashigaru3"
    exit 1
}

# ステータスファイル存在確認
check_file() {
    if [[ ! -f "$STATUS_FILE" ]]; then
        echo -e "${RED}[ERROR]${NC} $STATUS_FILE が存在しません"
        exit 1
    fi
}

# タイムスタンプ更新
update_timestamp() {
    sed -i "s/^last_updated:.*/last_updated: \"$TIMESTAMP\"/" "$STATUS_FILE"
}

# backend/frontend ステータス更新
update_build_status() {
    local target="$1"
    local status="$2"
    local error_msg="${3:-null}"
    
    check_file
    
    # statusが有効か確認
    if [[ ! "$status" =~ ^(ok|error|building)$ ]]; then
        echo -e "${RED}[ERROR]${NC} statusは ok, error, building のいずれかを指定"
        exit 1
    fi
    
    # エラーメッセージの処理
    if [[ "$error_msg" != "null" ]]; then
        error_msg="\"$error_msg\""
    fi
    
    # 一時ファイルで処理
    local tmpfile=$(mktemp)
    local in_target=false
    local target_found=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*${target}: ]]; then
            in_target=true
            target_found=true
            echo "$line" >> "$tmpfile"
        elif [[ "$in_target" == true ]]; then
            if [[ "$line" =~ ^[[:space:]]*status: ]]; then
                echo "    status: $status" >> "$tmpfile"
            elif [[ "$line" =~ ^[[:space:]]*last_check: ]]; then
                echo "    last_check: \"$TIMESTAMP\"" >> "$tmpfile"
            elif [[ "$line" =~ ^[[:space:]]*error_message: ]]; then
                echo "    error_message: $error_msg" >> "$tmpfile"
            elif [[ "$line" =~ ^[[:space:]]*assigned_to: ]]; then
                echo "$line" >> "$tmpfile"
                in_target=false
            else
                echo "$line" >> "$tmpfile"
            fi
        else
            echo "$line" >> "$tmpfile"
        fi
    done < "$STATUS_FILE"
    
    mv "$tmpfile" "$STATUS_FILE"
    update_timestamp
    
    # エラーの場合、recent_errorsに追加
    if [[ "$status" == "error" && "$error_msg" != "null" ]]; then
        add_recent_error "$target" "$error_msg"
    fi
    
    local color="$GREEN"
    [[ "$status" == "error" ]] && color="$RED"
    [[ "$status" == "building" ]] && color="$YELLOW"
    
    echo -e "${color}[${status^^}]${NC} $target のステータスを更新しました"
}

# エラー履歴に追加（最大5件）
add_recent_error() {
    local target="$1"
    local message="$2"
    
    # YAMLのrecent_errorsに追加する処理は複雑なため、簡易実装
    # 本格的にはyqなどを使うべき
    echo -e "${YELLOW}[INFO]${NC} エラー履歴に追加: $target - $message"
}

# 作業中モジュール登録
add_working() {
    local worker="$1"
    local module="$2"
    
    check_file
    
    if [[ -z "$worker" || -z "$module" ]]; then
        echo -e "${RED}[ERROR]${NC} worker と module を指定してください"
        exit 1
    fi
    
    # working_on:の後に追加
    local tmpfile=$(mktemp)
    local added=false
    
    while IFS= read -r line; do
        echo "$line" >> "$tmpfile"
        if [[ "$line" =~ ^working_on: && "$added" == false ]]; then
            echo "  - worker: $worker" >> "$tmpfile"
            echo "    module: \"$module\"" >> "$tmpfile"
            echo "    started_at: \"$TIMESTAMP\"" >> "$tmpfile"
            added=true
        fi
    done < "$STATUS_FILE"
    
    mv "$tmpfile" "$STATUS_FILE"
    update_timestamp
    
    echo -e "${CYAN}[WORKING]${NC} $worker が $module の作業を開始"
}

# 作業完了
remove_working() {
    local worker="$1"
    
    check_file
    
    if [[ -z "$worker" ]]; then
        echo -e "${RED}[ERROR]${NC} worker を指定してください"
        exit 1
    fi
    
    # 該当workerの行を削除（簡易実装）
    local tmpfile=$(mktemp)
    local skip_count=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*worker:[[:space:]]*${worker} ]]; then
            skip_count=3  # worker, module, started_at の3行をスキップ
            continue
        fi
        if [[ $skip_count -gt 0 ]]; then
            ((skip_count--))
            continue
        fi
        echo "$line" >> "$tmpfile"
    done < "$STATUS_FILE"
    
    mv "$tmpfile" "$STATUS_FILE"
    update_timestamp
    
    echo -e "${GREEN}[DONE]${NC} $worker の作業を完了"
}

# 担当割り当て
assign_worker() {
    local target="$1"
    local worker="$2"
    
    check_file
    
    if [[ ! "$target" =~ ^(backend|frontend)$ ]]; then
        echo -e "${RED}[ERROR]${NC} target は backend または frontend を指定"
        exit 1
    fi
    
    # 一時ファイルで処理
    local tmpfile=$(mktemp)
    local in_target=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*${target}: ]]; then
            in_target=true
            echo "$line" >> "$tmpfile"
        elif [[ "$in_target" == true && "$line" =~ ^[[:space:]]*assigned_to: ]]; then
            echo "    assigned_to: $worker" >> "$tmpfile"
            in_target=false
        else
            echo "$line" >> "$tmpfile"
        fi
    done < "$STATUS_FILE"
    
    mv "$tmpfile" "$STATUS_FILE"
    update_timestamp
    
    echo -e "${CYAN}[ASSIGN]${NC} $target のエラー対応を $worker に割り当て"
}

# ステータス表示
show_status() {
    check_file
    
    echo -e "${CYAN}=== ビルドステータス ===${NC}"
    echo ""
    
    # YAMLから簡易パース
    local be_status=$(grep -A4 "^  backend:" "$STATUS_FILE" | grep "status:" | head -1 | sed 's/.*status: //' | tr -d ' ')
    local fe_status=$(grep -A4 "^  frontend:" "$STATUS_FILE" | grep "status:" | head -1 | sed 's/.*status: //' | tr -d ' ')
    
    # 色分け
    local be_color="$GREEN"
    local fe_color="$GREEN"
    [[ "$be_status" == "error" ]] && be_color="$RED"
    [[ "$be_status" == "building" ]] && be_color="$YELLOW"
    [[ "$fe_status" == "error" ]] && fe_color="$RED"
    [[ "$fe_status" == "building" ]] && fe_color="$YELLOW"
    
    echo -e "Backend:  ${be_color}${be_status}${NC}"
    echo -e "Frontend: ${fe_color}${fe_status}${NC}"
    echo ""
    
    # 作業中
    echo -e "${CYAN}作業中:${NC}"
    grep -A2 "^  - worker:" "$STATUS_FILE" 2>/dev/null | grep -E "(worker|module):" | sed 's/^  /  /' || echo "  (なし)"
}

# メイン処理
case "${1:-}" in
    backend|frontend)
        update_build_status "$1" "${2:-}" "${3:-}"
        ;;
    working)
        add_working "$2" "$3"
        ;;
    done)
        remove_working "$2"
        ;;
    assign)
        assign_worker "$2" "$3"
        ;;
    status)
        show_status
        ;;
    *)
        usage
        ;;
esac
