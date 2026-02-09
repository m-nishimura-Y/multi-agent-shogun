#!/bin/bash
# ============================================================
# generate-report.sh - 報告書テンプレート自動生成スクリプト
# ============================================================
# 用途: 足軽の報告書テンプレートを自動生成
# 背景: cmd_045で3名が希望した改善提案
# 作成: cmd_046
# ============================================================

set -euo pipefail

# デフォルト値
TYPE="implementation"
OUTPUT=""
TASK_ID=""
PARENT_CMD=""

# 使い方表示
usage() {
    cat << 'EOF'
Usage: generate-report.sh <足軽番号> [OPTIONS]

ARGUMENTS:
  足軽番号              1-8 の数字

OPTIONS:
  --task-id ID          タスクID（例: cmd_046_imp）
  --parent-cmd CMD      親コマンド（例: cmd_046）
  --type TYPE           テンプレート種別（default: implementation）
                        implementation - 実装タスク用
                        research       - 調査・分析用
                        feedback       - フィードバック用
  --output FILE         出力ファイル（省略時は標準出力）
  -h, --help            このヘルプを表示

EXAMPLES:
  # 標準出力にテンプレート表示
  ./bin/generate-report.sh 1

  # タスクID指定でファイル出力
  ./bin/generate-report.sh 5 --task-id cmd_046_impl --parent-cmd cmd_046 --output queue/reports/ashigaru5_report.yaml

  # 調査タスク用テンプレート
  ./bin/generate-report.sh 3 --type research

EOF
    exit 0
}

# 引数がない場合
if [ $# -lt 1 ]; then
    usage
fi

# 最初の引数が-hまたは--helpの場合
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

# 足軽番号取得
ASHIGARU_NUM="$1"
shift

# 足軽番号の検証
if ! [[ "$ASHIGARU_NUM" =~ ^[1-8]$ ]]; then
    echo "Error: 足軽番号は 1-8 の数字で指定してください" >&2
    exit 1
fi

# オプション解析
while [ $# -gt 0 ]; do
    case "$1" in
        --task-id)
            TASK_ID="$2"
            shift 2
            ;;
        --parent-cmd)
            PARENT_CMD="$2"
            shift 2
            ;;
        --type)
            TYPE="$2"
            if [[ ! "$TYPE" =~ ^(implementation|research|feedback)$ ]]; then
                echo "Error: --type は implementation, research, feedback のいずれかを指定" >&2
                exit 1
            fi
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: 不明なオプション: $1" >&2
            exit 1
            ;;
    esac
done

# タイムスタンプ生成
TIMESTAMP=$(date "+%Y-%m-%dT%H:%M:%S")

# テンプレート生成関数
generate_implementation_template() {
    cat << EOF
# ============================================================
# 足軽${ASHIGARU_NUM} 報告書（${PARENT_CMD:-cmd_XXX}: タスク概要をここに記載）
# ============================================================
worker_id: ashigaru${ASHIGARU_NUM}
task_id: ${TASK_ID:-${PARENT_CMD:-cmd_XXX}_task_name}
parent_cmd: ${PARENT_CMD:-cmd_XXX}
timestamp: "${TIMESTAMP}"
status: pending

result:
  summary: |
    【完了】実装内容の概要をここに記載。

  # ============================================================
  # 実装内容
  # ============================================================
  implementation:
    files_modified: []
    files_created: []
    description: |
      実装の詳細をここに記載。

  # ============================================================
  # 動作確認
  # ============================================================
  verification:
    method: ""
    result: ""

# ═══════════════════════════════════════════════════════════════
# 【必須】スキル化候補の検討
# ═══════════════════════════════════════════════════════════════
skill_candidate:
  found: false
  name: null
  description: null
  reason: |
    スキル化対象外の理由、または候補の場合は推薦理由を記載。

# ═══════════════════════════════════════════════════════════════
# 【必須】次のアクション
# ═══════════════════════════════════════════════════════════════
next_action: "次タスク待機中"
EOF
}

generate_research_template() {
    cat << EOF
# ============================================================
# 足軽${ASHIGARU_NUM} 報告書（${PARENT_CMD:-cmd_XXX}: 調査タスク概要）
# ============================================================
worker_id: ashigaru${ASHIGARU_NUM}
task_id: ${TASK_ID:-${PARENT_CMD:-cmd_XXX}_research}
parent_cmd: ${PARENT_CMD:-cmd_XXX}
timestamp: "${TIMESTAMP}"
status: pending

result:
  summary: |
    【完了】調査結果の概要をここに記載。

  # ============================================================
  # 調査結果
  # ============================================================
  research:
    objective: |
      調査目的をここに記載。

    findings:
      - finding: ""
        details: ""
        evidence: ""

    conclusion: |
      結論・推奨事項をここに記載。

  # ============================================================
  # 参照資料
  # ============================================================
  references:
    files_read: []
    external_sources: []

# ═══════════════════════════════════════════════════════════════
# 【必須】スキル化候補の検討
# ═══════════════════════════════════════════════════════════════
skill_candidate:
  found: false
  name: null
  description: null
  reason: |
    調査タスク。スキル化対象外。

# ═══════════════════════════════════════════════════════════════
# 【必須】次のアクション
# ═══════════════════════════════════════════════════════════════
next_action: "次タスク待機中"
EOF
}

generate_feedback_template() {
    cat << EOF
# ============================================================
# 足軽${ASHIGARU_NUM} 報告書（${PARENT_CMD:-cmd_XXX}: フィードバック）
# ============================================================
worker_id: ashigaru${ASHIGARU_NUM}
task_id: ${TASK_ID:-${PARENT_CMD:-cmd_XXX}_feedback}
parent_cmd: ${PARENT_CMD:-cmd_XXX}
timestamp: "${TIMESTAMP}"
status: pending

result:
  summary: |
    【完了】フィードバック提出完了。

  # ============================================================
  # フィードバック回答
  # ============================================================
  feedback:
    # セクション1
    section1:
      question1:
        answer: "Yes/No"
        comment: |
          回答の詳細をここに記載。

    # セクション2
    section2:
      question1:
        answer: "Yes/No"
        comment: |
          回答の詳細をここに記載。

  # ============================================================
  # 改善提案
  # ============================================================
  improvement_proposals:
    - proposal: ""
      reason: ""
      priority: "high/medium/low"

# ═══════════════════════════════════════════════════════════════
# 【必須】スキル化候補の検討
# ═══════════════════════════════════════════════════════════════
skill_candidate:
  found: false
  name: null
  description: null
  reason: |
    フィードバック回答タスク。スキル化対象外。

# ═══════════════════════════════════════════════════════════════
# 【必須】次のアクション
# ═══════════════════════════════════════════════════════════════
next_action: "次タスク待機中"
EOF
}

# テンプレート生成
generate_template() {
    case "$TYPE" in
        implementation)
            generate_implementation_template
            ;;
        research)
            generate_research_template
            ;;
        feedback)
            generate_feedback_template
            ;;
    esac
}

# 出力
if [ -n "$OUTPUT" ]; then
    generate_template > "$OUTPUT"
    echo "報告書テンプレートを生成しました: $OUTPUT"
else
    generate_template
fi
