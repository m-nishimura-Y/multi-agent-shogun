# Claude Code ネイティブ版への移行手順

> npm 版から Anthropic 公式ネイティブ版への移行ガイド

## 背景

npm 版はサプライチェーン攻撃のリスクがあるため、Anthropic 公式のネイティブバイナリに切り替えることでセキュリティを向上させる。

## 事前確認

現在のインストール方式を確認:

```bash
which claude && file $(which claude)
```

**npm 版の場合:**
```
/home/username/.nvm/versions/node/v20.x.x/bin/claude
/home/username/.nvm/versions/node/v20.x.x/bin/claude: symbolic link to ../lib/node_modules/@anthropic-ai/claude-code/cli.js
```

**ネイティブ版の場合:**
```
/home/username/.local/bin/claude
/home/username/.local/bin/claude: ELF 64-bit LSB pie executable, x86-64...
```

---

## 移行手順

### Step 1: マルチエージェントを停止

```bash
# 全 tmux セッションを終了
tmux kill-session -t shogun 2>/dev/null
tmux kill-session -t gunshi 2>/dev/null
tmux kill-session -t bugyo 2>/dev/null
tmux kill-session -t multiagent 2>/dev/null

# 確認
tmux ls
# → "no server running on /tmp/tmux-xxxx/default" と表示されれば OK
```

### Step 2: npm 版をアンインストール

```bash
npm uninstall -g @anthropic-ai/claude-code

# 確認（claude コマンドが見つからなければ OK）
which claude
```

### Step 3: ネイティブ版をインストール

```bash
curl -fsSL https://console.anthropic.com/install.sh | sh
```

インストール完了後、パスを通す（.bashrc / .zshrc に追記済みでない場合）:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Step 4: インストール確認

```bash
# パスとバイナリ形式を確認
which claude && file $(which claude)
# 期待: ELF 64-bit LSB pie executable...

# バージョン確認
claude --version
```

### Step 5: マルチエージェントを再起動

```bash
cd ~/multi-agent-shogun
./shutsujin_departure.sh
```

### Step 6: 動作確認

```bash
# shogun セッションに接続
tmux attach -t shogun

# 将軍が応答するか確認（例: 「状況を報告せよ」と入力）
```

---

## トラブルシューティング

### `claude: command not found`

パスが通っていない可能性:

```bash
# パスを確認
echo $PATH | grep -o "$HOME/.local/bin"

# なければ追加
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 古い npm 版が残っている

```bash
# npm のグローバルパッケージ一覧を確認
npm list -g --depth=0 | grep claude

# 残っていれば削除
npm uninstall -g @anthropic-ai/claude-code
```

### tmux セッションが残っている

```bash
# 強制終了
tmux kill-server

# 再起動
./shutsujin_departure.sh
```

---

## ロールバック（npm 版に戻す場合）

```bash
# ネイティブ版を削除
rm -f ~/.local/bin/claude

# npm 版を再インストール
npm install -g @anthropic-ai/claude-code

# 確認
which claude && file $(which claude)
```

---

## 関連ファイル

| ファイル | 変更内容 |
|----------|----------|
| `first_setup.sh` | STEP 4 をネイティブインストールに変更 |
| `README_ja.md` | インストールコマンドを変更 |
| `README.md` | インストールコマンドを変更（英語版） |

---

**Last Updated**: 2026-04-02
**Author**: 軍師
