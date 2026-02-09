#!/bin/bash
# ============================================================
# update-progress.sh
# 足軽の進捗をprogress.yamlに自動更新するスクリプト
# cmd_034対応
# ============================================================
# 使用例:
#   ./bin/update-progress.sh 1 50 "cmd_034実装中"    # 進捗50%
#   ./bin/update-progress.sh 1 100 "cmd_034完了"     # 完了（リセット）
#   ./bin/update-progress.sh 1 0                     # 待機中にリセット
# ============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
PROGRESS_FILE="$BASE_DIR/queue/progress.yaml"

# 引数チェック
if [ $# -lt 2 ]; then
    echo "Usage: $0 <ashigaru_number> <progress> [task_description]"
    echo ""
    echo "Arguments:"
    echo "  ashigaru_number: 1-8"
    echo "  progress: 0-100 (100 = completed, resets to idle)"
    echo "  task_description: optional task summary"
    echo ""
    echo "Examples:"
    echo "  $0 1 50 'cmd_034実装中'    # 50% progress"
    echo "  $0 1 100 'cmd_034完了'     # Completed (resets)"
    echo "  $0 1 0                     # Reset to idle"
    exit 1
fi

ASHIGARU_NUM="$1"
PROGRESS="$2"
TASK_DESC="${3:-}"

# 足軽番号の検証
if ! [[ "$ASHIGARU_NUM" =~ ^[1-8]$ ]]; then
    echo "Error: ashigaru_number must be 1-8"
    exit 1
fi

# 進捗率の検証
if ! [[ "$PROGRESS" =~ ^[0-9]+$ ]] || [ "$PROGRESS" -lt 0 ] || [ "$PROGRESS" -gt 100 ]; then
    echo "Error: progress must be 0-100"
    exit 1
fi

# progress.yamlが存在するか確認
if [ ! -f "$PROGRESS_FILE" ]; then
    echo "Error: $PROGRESS_FILE not found"
    exit 1
fi

# Pythonで更新処理
python3 << PYTHON_SCRIPT
import yaml
from datetime import datetime

progress_file = "$PROGRESS_FILE"
ashigaru_num = int("$ASHIGARU_NUM")
progress = int("$PROGRESS")
task_desc = "$TASK_DESC" if "$TASK_DESC" else None

# YAMLを読み込み
with open(progress_file, 'r', encoding='utf-8') as f:
    data = yaml.safe_load(f)

# 本隊(1-4) or 別働隊(5-8)を判定
if ashigaru_num <= 4:
    team = 'honntai'
    index = ashigaru_num - 1
else:
    team = 'betsudoutai'
    index = ashigaru_num - 5

# タイムスタンプ
now = datetime.now().strftime('%Y-%m-%dT%H:%M:%S')

# 該当足軽のエントリを更新
entry = data[team][index]

if progress == 100:
    # 完了: リセット
    entry['current_task'] = None
    entry['task_id'] = None
    entry['progress'] = 0
    entry['note'] = f"completed: {task_desc}" if task_desc else None
elif progress == 0 and not task_desc:
    # 待機中にリセット
    entry['current_task'] = None
    entry['task_id'] = None
    entry['progress'] = 0
    entry['note'] = None
else:
    # 進捗更新
    if task_desc:
        entry['current_task'] = task_desc
    entry['progress'] = progress

entry['updated_at'] = now
entry['blocked_by'] = None  # ブロック解除

# 全体のlast_updatedも更新
data['last_updated'] = now

# YAMLを書き出し（既存フォーマットを維持）
class QuotedString(str):
    pass

def quoted_str_representer(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='"')

yaml.add_representer(QuotedString, quoted_str_representer)

# nullをnullとして出力
def none_representer(dumper, data):
    return dumper.represent_scalar('tag:yaml.org,2002:null', 'null')

yaml.add_representer(type(None), none_representer)

with open(progress_file, 'w', encoding='utf-8') as f:
    yaml.dump(data, f, allow_unicode=True, default_flow_style=False, sort_keys=False)

print(f"Updated ashigaru{ashigaru_num}: progress={progress}%, task={task_desc or 'idle'}")
PYTHON_SCRIPT

echo "Progress updated successfully."
