#!/bin/bash
# self-compact.sh
# 自分のpaneに対して /compact を送る
#
# 使い方: タスク完了時に残量15%以下なら実行
# ~/multi-agent-shogun/bin/self-compact.sh

# 自分のpane IDを環境変数から取得（%0, %1, %9 など）
MY_PANE="$TMUX_PANE"

if [ -z "$MY_PANE" ]; then
  echo "Error: TMUX_PANE environment variable not set"
  exit 1
fi

echo "Compacting context for pane $MY_PANE ..."

# /compact を自分に送る
tmux send-keys -t "$MY_PANE" '/compact' Enter
