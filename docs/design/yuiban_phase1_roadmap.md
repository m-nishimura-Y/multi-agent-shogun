# YUI番 Phase1 ロードマップ — 自律巡回の北極星

> 起草: 将軍 / 2026-07-14 / cmd_335
> 用途: **将軍の自律巡回（instructions/shogun-loop.md）が毎回参照する目的地**。
>   これが無いと将軍は「次の一手」は分かっても「最終どこへ」で迷う。
> 正本: [Phase1_実装計画書_v1.md](../../yui-ban/docs/design/Phase1_実装計画書_v1.md) §3.1 順序 / §6 完了基準。
>   本書はそれを巡回用に集約した"地図"。詳細の正本は実装計画書、進捗の正本は Linear。

---

## 第1階層：北極星（Why・1文）

```
██████████████████████████████████████████████████████████████████████
█  YUI番 入退社台帳 PoC（Phase1）を完成させる。                       █
█  = 入社1件が submit→gate承認→claim→issuing→issued まで通り、       █
█    INV-01〜08 が DB で守られ、監査が辿れ、CLI だけで全フロー回る。   █
█  これが番頭MVP（入退社自動化）へ繋ぐ土台になる。                    █
██████████████████████████████████████████████████████████████████████
```

巡回での使い方：ある作業に迷ったら「**これは北極星（PoC完成）に向かうか**」で判定。
向かわぬ枝葉（除外項目 §7：IAP/RBAC本番・番頭実装・外部アンカー等）は今やらない。

---

## 第2階層：Phase1 完成の定義（DoD・§6）

**この17基準が全て ✅ になったら Phase1 完了**（将軍が自律判定する終着点）。
※ ISSUE-PP として殿の最終確認待ちだが、軍師案＝実質のDoDとして採用。

- **機能 F-1〜F-5**: 主経路が通る / 二重submit 409 / hash衝突隔離 / 版ずれ再承認 / lease失効復帰
- **不変 I-1〜I-5**: audit UPDATE/DELETE不可 / 並列claim1件のみ / approved整合 / gate open1件 / C-16 import 0
- **監査 A-1〜A-3**: execution_trace辿れる / payload_hash再計算一致 / chain日次検証
- **業務 B-1〜B-4**: 月次5件発行成功 / 二重発行0 / 無承認発行0 / CLIで全フロー

→ 巡回では「今どの基準が未達か」を見て、それを埋める Step を次の一手に選ぶ。

---

## 第3階層：Step 順序表（§3.1・依存と並列）

```
Step 1 DBスキーマ構築       ✅ 完了（0001〜0003適用・GRANT・cmd_332/333）
Step 2 共通基盤             ✅ 完了（2.1〜2.5・将軍レビュー全合格・cmd_334）
─────────────────────────── ここまで到達済み ───────────────────────────
Step 3 登録系(subject+submit) ◀ 今ここ・発注中（cmd_336）
        3.1 subjects.py(POST/GET) / 3.2 progress submit(TX-1) /
        3.3 identifier_hash canonicalization v1 / 3.4 first_gate.py
Step 4 承認系(gate)          ← Step3 と【並列開発可】（§3.2）
        4.1 gates.py(approve TX-2/reject) / 4.2 gate_preview UI / 4.3 generation整合
Step 5 claim+second_gate     ← Step6 と直列推奨（同 progress モジュール）
        5.1 claim(TX-3) / 5.2 second_gate_check(TX-4) / 5.3 second_gate_client
Step 6 発行系(issuing・C-16)  ← Step5 の後
        6.1 mark_issuing_started(TX-5) / 6.2 payload_hash照合 / 6.3 issuance_result(TX-6)
        6.4 heartbeat / 6.5 CI: master_loader import禁止チェック
Step 7 Cloud Run Jobs        ← 各Job独立・並列可
        7.1 lease_sweeper / 7.2 escalator / 7.3 master_update / 7.4 chain_integrity_check
Step 8 CLI                   ← issuing 完了後（全フローを叩くため）
        8.1 submit.py / 8.2 list_pending.py
Step 9 統合テスト            ← 実装出揃い後
        9.1 主経路 / 9.2 版ずれ / 9.3 cross-record検知 / 9.4 lease失効
Step 10 PoC完了確認(§6の17基準を検証) → Phase1 DONE
```

**並列の指針**：Step3 ∥ Step4 は並列可。Step5→6 は直列。Step7 の各Jobは並列可。
→ 巡回で別働隊に手が空いたら、依存が解けている Step を並列発注してよい（可逆・自律範囲）。

---

## 第4階層：各Stepの受入基準（実装完了→要求達成の線引き）

各 Step は **A+B（実体＋commit）で「実装完了」、対応する§6基準で「要求達成」**。
将軍レビュー（別起源確認）は「その Step が満たすべき §6 基準」を物差しにする。例：
- Step3 → F-2(二重submit 409) の素地・INV-01系 CHECK が効くか
- Step4 → I-3(approved整合)・I-4(gate open1件)
- Step5 → I-2(並列claim1件)・F-5(lease失効)
- Step6 → I-5(C-16 import0)・B-3(無承認発行0)
- Step9 → F-1〜F-5 の e2e

---

## 停止線（ここに達したら殿へ・不可逆/外向き）

巡回で自律してよいのは第3階層の実装発注まで。**次は殿の判断**：
- **git push / PR マージ**（掟）
- **Cloud Run 実デプロイ**（NIS-2/3 窓口確認後・課金/外部）
- **番頭 MVP との実接続**（Phase1 は §5 境界定義まで。実接続は殿判断）
- **PoC完了宣言**（§6 全基準達成時、Phase1 DONE を殿に上申し本番移行判断を仰ぐ）
- **DoD の最終確定**（ISSUE-PP：§6 を正式 DoD とするか殿確認）

---

## 巡回での使い方（1行手順）

```
巡回で「次の一手」に迷ったら:
  1. 北極星に向かうか？（枝葉は捨てる）
  2. §6 で未達の基準は？ → それを埋める Step を順序表で特定
  3. その Step の依存は解けたか？ 並列可か？ → 系統経由で発注
  4. 完了は A+B＋対応§6基準で判定（実装完了≠要求達成）
  5. 停止線に達したら家老経由で dashboard 要対応へ
```

---

## 未確定（殿に確認したい点）

- **ISSUE-PP**: §6 の17基準を Phase1 の正式 DoD として確定してよいか（今は軍師案）
- Step3 ∥ Step4 並列を今 走らせるか、Step3 完成を待って直列にするか（別働隊の余力次第）
