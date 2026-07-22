#!/bin/bash
# ============================================================
# safe-clear.sh - 永続化を確認してから /clear を送る安全弁
# ============================================================
# 用途: コンテキスト逼迫時（X≥400k 等）に /clear で全消去する前に、
#       役職ごとの永続化先ファイルが「最近・中身入りで」更新済みかを
#       機械チェックし、【未永続化なら /clear を拒否】する。
#
# 背景: /compact（self-compact.sh）は文脈を要約して残すため無防備でも
#       比較的安全。だが /clear は【全消去】ゆえ、永続化を怠って打つと
#       砂上の楼閣が崩れる。この安全弁で「準備なしクリア」を止める。
#
# 使い方（各役職が自分で実行）:
#   ~/multi-agent-shogun/bin/safe-clear.sh           # 検証してから /clear
#   ~/multi-agent-shogun/bin/safe-clear.sh --force   # 検証を飛ばして強制 /clear（緊急用）
#   ~/multi-agent-shogun/bin/safe-clear.sh --check    # 検証のみ（/clear は送らない）
#
# ★このスクリプトは「機械的な鮮度チェック（mtime/サイズ）」まで。
#   永続化の【中身が本当に最新か】の意味検証は safe-clear スキル側が担う。
#   スクリプト単体でも最低限の安全弁になるが、スキル経由が本筋。
# ============================================================

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/multi-agent-shogun}"
FRESH_SECONDS=600   # 永続化先が「最近更新された」とみなす秒数（既定10分）
MIN_BYTES=200       # 永続化先が「中身入り」とみなす最小バイト数

FORCE=false
CHECK_ONLY=false
for arg in "$@"; do
    case "$arg" in
        -f|--force) FORCE=true ;;
        --check)    CHECK_ONLY=true ;;
    esac
done

# ---- 役職判定（recovery.sh と同じ方式: #S セッション名 + TMUX_PANE 逆引き）----
if [ -z "${TMUX_PANE:-}" ]; then
    echo "Error: TMUX_PANE 環境変数が無い。tmux ペイン内で実行せよ。" >&2
    exit 1
fi
SESSION_NAME=$(tmux display-message -p '#S' 2>/dev/null || echo "unknown")
PANE_INDEX=$(tmux display -t "$TMUX_PANE" -p "#{pane_index}" 2>/dev/null || echo "0")
MY_PANE="$TMUX_PANE"

# ---- 役職ごとの永続化先ファイル（recovery が復帰時に読む対象と対にする）----
# current_task.yaml は全役職共通の「現在タスク」。加えて役職別 context.yaml。
declare -a PERSIST_FILES=()
case "$SESSION_NAME" in
    shogun)
        ROLE="将軍"
        PERSIST_FILES=("status/current_task.yaml")
        ;;
    gunshi)
        ROLE="軍師"
        PERSIST_FILES=("status/gunshi_context.yaml" "status/current_task.yaml")
        ;;
    bugyo)
        ROLE="奉行"
        PERSIST_FILES=("queue/reports/bugyo_summary.yaml")
        ;;
    multiagent)
        if [ "$PANE_INDEX" = "0" ]; then
            ROLE="家老"
            PERSIST_FILES=("status/karo_context.yaml" "status/current_task.yaml")
        else
            ROLE="足軽$PANE_INDEX"
            # 足軽は自分のタスク/報告ファイルが永続化先
            PERSIST_FILES=("queue/reports/ashigaru${PANE_INDEX}_report.yaml")
        fi
        ;;
    *)
        ROLE="不明（$SESSION_NAME）"
        PERSIST_FILES=("status/current_task.yaml")
        ;;
esac

echo "════════════════════════════════════════════════════════════════"
echo "  safe-clear：永続化を確認してから /clear（役割: $ROLE）"
echo "════════════════════════════════════════════════════════════════"

# ---- 鮮度チェック（--force でスキップ）----
now=$(date +%s)
STALE=false
if [ "$FORCE" = "true" ]; then
    echo "⚠ --force 指定：永続化チェックを飛ばして強制 /clear する。"
else
    for rel in "${PERSIST_FILES[@]}"; do
        f="$PROJECT_DIR/$rel"
        if [ ! -f "$f" ]; then
            echo "✗ 永続化先が無い: $rel"
            STALE=true
            continue
        fi
        bytes=$(stat -c%s "$f" 2>/dev/null || echo 0)
        mtime=$(stat -c%Y "$f" 2>/dev/null || echo 0)
        age=$(( now - mtime ))
        if [ "$bytes" -lt "$MIN_BYTES" ]; then
            echo "✗ 中身が薄い（${bytes}B < ${MIN_BYTES}B）: $rel"
            STALE=true
        elif [ "$age" -gt "$FRESH_SECONDS" ]; then
            mins=$(( age / 60 ))
            echo "✗ 更新が古い（${mins}分前・閾値$(( FRESH_SECONDS / 60 ))分）: $rel"
            STALE=true
        else
            echo "✓ 永続化 新鮮（$(( age / 60 ))分前・${bytes}B）: $rel"
        fi
    done
fi

if [ "$STALE" = "true" ]; then
    echo ""
    echo "🛑 /clear を【中止】した。永続化が古い/薄い/無い。"
    echo "   → 先に current_task.yaml / context.yaml を今の状況で更新せよ。"
    echo "   → 更新後に再実行。緊急で捨ててよいなら --force。"
    echo "   （永続化なき /clear は砂上の楼閣なり）"
    exit 2
fi

if [ "$CHECK_ONLY" = "true" ]; then
    echo ""
    echo "✅ 永続化は新鮮。--check ゆえ /clear は送らず終了。"
    exit 0
fi

# ---- /clear 送信（self-compact.sh と同じ遅延送信の型）----
echo ""
echo "✅ 永続化 確認済。/clear を送る（pane $MY_PANE・復帰は /recovery）..."
(
  sleep 1  # Claude Code が入力待ちになるまで待つ
  tmux send-keys -t "$MY_PANE" '/clear'
  sleep 0.3
  tmux send-keys -t "$MY_PANE" Enter
) &

echo "Scheduled /clear for pane $MY_PANE (will execute in 1 second)"
