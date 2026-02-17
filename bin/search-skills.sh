#!/bin/bash
# ============================================================
# search-skills.sh - スキル検索ツール
# ============================================================
# 用途: スキル一覧の検索・表示により重複作成を防止
# 作成: 足軽6号（cmd_031対応）
#
# 使用例:
#   ./bin/search-skills.sh "generator"      # キーワード検索
#   ./bin/search-skills.sh --list           # 全スキル一覧
#   ./bin/search-skills.sh --list --verbose # 詳細一覧
#   ./bin/search-skills.sh --category       # カテゴリ別一覧
#   ./bin/search-skills.sh --help           # ヘルプ表示
# ============================================================

set -euo pipefail

# 設定
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="${SCRIPT_DIR}/../.claude/skills"

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    cat << 'EOF'
============================================================
 search-skills.sh - スキル検索ツール
============================================================

【使用方法】
  ./bin/search-skills.sh [オプション] [キーワード]

【オプション】
  --help, -h        このヘルプを表示
  --list, -l        全スキル一覧を表示
  --verbose, -v     詳細情報を表示（--listと併用）
  --category, -c    カテゴリ別に一覧表示
  --count           スキル数のみ表示

【キーワード検索】
  キーワードを指定すると、スキル名と説明文から検索

【使用例】
  ./bin/search-skills.sh generator       # "generator"を含むスキル検索
  ./bin/search-skills.sh --list          # 全スキル一覧
  ./bin/search-skills.sh --list -v       # 詳細付き一覧
  ./bin/search-skills.sh --category      # カテゴリ別一覧
  ./bin/search-skills.sh api             # "api"を含むスキル検索
  ./bin/search-skills.sh "react mui"     # 複数キーワード（AND検索）

【カテゴリ】
  - analyzer    : 分析系スキル
  - generator   : 生成系スキル
  - checker     : チェック系スキル
  - converter   : 変換系スキル
  - template    : テンプレート系スキル
  - other       : その他

============================================================
EOF
}

# スキルファイルからタイトル（1行目の#見出し）を取得
get_skill_title() {
    local file="$1"
    head -n 1 "$file" | sed 's/^#\s*//'
}

# スキルファイルから説明（概要セクション）を取得
get_skill_description() {
    local file="$1"
    # 最初の段落（空行までの内容）から概要を抽出
    sed -n '3,10p' "$file" | head -n 3 | tr '\n' ' ' | cut -c1-80
}

# カテゴリを推定
detect_category() {
    local name="$1"
    if [[ "$name" == *analyzer* ]]; then
        echo "analyzer"
    elif [[ "$name" == *generator* ]]; then
        echo "generator"
    elif [[ "$name" == *checker* ]]; then
        echo "checker"
    elif [[ "$name" == *converter* ]]; then
        echo "converter"
    elif [[ "$name" == *template* ]]; then
        echo "template"
    elif [[ "$name" == *extractor* ]]; then
        echo "analyzer"
    elif [[ "$name" == *reviewer* ]]; then
        echo "checker"
    else
        echo "other"
    fi
}

# 全スキル一覧表示
list_skills() {
    local verbose="${1:-false}"
    local count=0

    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN} スキル一覧 (.claude/skills/)${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""

    for file in "$SKILLS_DIR"/*/SKILL.md; do
        if [[ -f "$file" ]]; then
            local dir=$(dirname "$file")
            local name=$(basename "$dir")
            local title=$(get_skill_title "$file")
            count=$((count + 1))

            if [[ "$verbose" == "true" ]]; then
                local desc=$(get_skill_description "$file")
                local category=$(detect_category "$name")
                echo -e "${GREEN}[$count]${NC} ${YELLOW}$name${NC}"
                echo -e "    タイトル: $title"
                echo -e "    カテゴリ: ${BLUE}$category${NC}"
                echo -e "    説明: ${desc}..."
                echo ""
            else
                printf "${GREEN}%3d.${NC} %-40s %s\n" "$count" "$name" "$title"
            fi
        fi
    done

    echo ""
    echo -e "${CYAN}------------------------------------------------------------${NC}"
    echo -e "合計: ${GREEN}${count}${NC} スキル"
}

# カテゴリ別一覧
list_by_category() {
    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN} カテゴリ別スキル一覧${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""

    declare -A categories
    categories["analyzer"]=""
    categories["generator"]=""
    categories["checker"]=""
    categories["converter"]=""
    categories["template"]=""
    categories["other"]=""

    for file in "$SKILLS_DIR"/*/SKILL.md; do
        if [[ -f "$file" ]]; then
            local dir=$(dirname "$file")
            local name=$(basename "$dir")
            local category=$(detect_category "$name")
            categories["$category"]+="$name\n"
        fi
    done

    # 表示順
    for cat in analyzer generator checker converter template other; do
        local items="${categories[$cat]}"
        if [[ -n "$items" ]]; then
            local count=$(echo -e "$items" | grep -c . || echo 0)
            echo -e "${YELLOW}【${cat}】${NC} (${count}件)"
            echo -e "$items" | while read -r name; do
                if [[ -n "$name" ]]; then
                    echo -e "  - $name"
                fi
            done
            echo ""
        fi
    done
}

# キーワード検索
search_skills() {
    local keywords="$1"
    local found=0

    echo -e "${CYAN}============================================================${NC}"
    echo -e "${CYAN} 検索キーワード: \"$keywords\"${NC}"
    echo -e "${CYAN}============================================================${NC}"
    echo ""

    for file in "$SKILLS_DIR"/*/SKILL.md; do
        if [[ -f "$file" ]]; then
            local dir=$(dirname "$file")
            local name=$(basename "$dir")
            local match=true

            # 複数キーワードをAND検索
            for kw in $keywords; do
                # ファイル名または内容にキーワードが含まれるかチェック
                if ! (echo "$name" | grep -qi "$kw" || grep -qi "$kw" "$file" 2>/dev/null); then
                    match=false
                    break
                fi
            done

            if [[ "$match" == "true" ]]; then
                found=$((found + 1))
                local title=$(get_skill_title "$file")
                local desc=$(get_skill_description "$file")
                local category=$(detect_category "$name")

                echo -e "${GREEN}[$found]${NC} ${YELLOW}$name${NC}"
                echo -e "    タイトル: $title"
                echo -e "    カテゴリ: ${BLUE}$category${NC}"
                echo -e "    説明: ${desc}..."

                # マッチした行を表示（最大3行）
                echo -e "    ${RED}マッチ箇所:${NC}"
                for kw in $keywords; do
                    grep -n -i --color=never "$kw" "$file" 2>/dev/null | head -n 2 | while read -r line; do
                        echo -e "      $line" | cut -c1-80
                    done
                done
                echo ""
            fi
        fi
    done

    echo -e "${CYAN}------------------------------------------------------------${NC}"
    if [[ $found -eq 0 ]]; then
        echo -e "${RED}該当するスキルが見つかりませんでした${NC}"
        echo ""
        echo "ヒント: --list で全スキル一覧を確認してください"
    else
        echo -e "検索結果: ${GREEN}${found}${NC} 件"
    fi
}

# スキル数表示
show_count() {
    local count=$(ls -1d "$SKILLS_DIR"/*/SKILL.md 2>/dev/null | wc -l)
    echo -e "スキル数: ${GREEN}${count}${NC}"
}

# メイン処理
main() {
    # スキルディレクトリ存在確認
    if [[ ! -d "$SKILLS_DIR" ]]; then
        echo -e "${RED}エラー: .claude/skills/ ディレクトリが見つかりません${NC}" >&2
        exit 1
    fi

    # 引数なしの場合
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    local verbose=false
    local mode=""
    local keywords=""

    # 引数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --list|-l)
                mode="list"
                shift
                ;;
            --verbose|-v)
                verbose=true
                shift
                ;;
            --category|-c)
                mode="category"
                shift
                ;;
            --count)
                mode="count"
                shift
                ;;
            -*)
                echo -e "${RED}不明なオプション: $1${NC}" >&2
                echo "ヘルプ: $0 --help"
                exit 1
                ;;
            *)
                keywords="$keywords $1"
                shift
                ;;
        esac
    done

    # キーワードのトリム
    keywords=$(echo "$keywords" | xargs)

    # モード実行
    case "$mode" in
        list)
            list_skills "$verbose"
            ;;
        category)
            list_by_category
            ;;
        count)
            show_count
            ;;
        *)
            if [[ -n "$keywords" ]]; then
                search_skills "$keywords"
            else
                show_help
            fi
            ;;
    esac
}

main "$@"
