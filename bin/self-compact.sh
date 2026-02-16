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

# バックグラウンドで /compact を送る（Claude Code が入力待ちになってから送るため遅延実行）
(
  sleep 1  # Claude Code が入力待ちになるまで待つ
  tmux send-keys -t "$MY_PANE" '/compact'
  sleep 0.3
  tmux send-keys -t "$MY_PANE" Enter
) &

echo "Scheduled /compact for pane $MY_PANE (will execute in 1 second)"
