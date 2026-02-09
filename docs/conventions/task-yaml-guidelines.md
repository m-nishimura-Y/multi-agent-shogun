# タスクYAML記述ガイドライン

> 作成日: 2026-02-06
> 作成者: 足軽5号（cmd_031）
> 目的: 足軽のタスク実行効率向上のためのYAML記述標準化

---

## 概要

本ガイドラインは、足軽へのタスク指示書（queue/tasks/ashigaru{N}.yaml）の記述品質を向上させるためのものである。

**背景**: cmd_027対応時、変換対象フィールド一覧が事前に記載されていれば調査時間を大幅に短縮できた経験に基づく。

---

## 1. タスクYAMLの基本構造

```yaml
# ============================================================
# 足軽{N} タスク指示書
# {タスクID}: {タスク概要}
# ============================================================

task:
  task_id: cmd_XXX_task_name
  parent_cmd: cmd_XXX
  timestamp: "YYYY-MM-DDTHH:MM:SS"
  type: development | documentation | analysis | refactoring
  status: assigned
  priority: high | medium | low

  description: |
    【タスク概要】
    何をするのか、なぜするのかを明確に記載

  # ============================================================
  # 対象ファイル（必須）
  # ============================================================
  target_files:
    - path: "ファイルパス"
      description: "このファイルで何をするか"

  # ============================================================
  # 作業手順（必須）
  # ============================================================
  instructions: |
    【手順】
    1. xxxx
    2. xxxx

  # ============================================================
  # 報告先（必須）
  # ============================================================
  report_to: gunshi | karo

skill_candidate_required: true | false
```

---

## 2. 変換・置換タスク用の追加フィールド

変換・置換作業を依頼する場合、以下のフィールドを**必ず**記載せよ。

### 2.1 conversion_targets（変換対象リスト）

```yaml
# ============================================================
# 変換対象リスト（変換・置換タスクでは必須）
# ============================================================
conversion_targets:
  # 変換ルール
  rule: "snake_case → camelCase"  # 例

  # 対象フィールド一覧（可能な限り網羅）
  fields:
    - { before: "jan_cd", after: "janCd" }
    - { before: "start_date", after: "startDate" }
    - { before: "end_date", after: "endDate" }
    - { before: "product_type_flg", after: "productTypeFlg" }
    # ... 以下続く

  # 除外パターン（変換しないもの）
  exclude_patterns:
    - "タスクID（cmd_xxx_yyy）"
    - "ファイルパス"
    - "コメント内の説明文"
```

### 2.2 記載のメリット

| 項目 | 記載なし | 記載あり |
|------|---------|---------|
| 調査時間 | 30分以上 | 5分以下 |
| 見落とし | 発生しやすい | 発生しにくい |
| 品質 | ばらつきあり | 一定品質 |
| 手戻り | 発生しやすい | ほぼなし |

---

## 3. 具体例

### 例1: フィールド名ケース変換タスク

```yaml
# ============================================================
# 足軽5 タスク（cmd_027: 設計書フィールド名キャメルケース統一）
# ============================================================
task:
  task_id: cmd_027_design_docs
  parent_cmd: cmd_027
  timestamp: "2026-02-06T14:54:11"
  type: refactoring
  status: assigned
  priority: high

  description: |
    【cmd_027対応】設計書のフィールド名をキャメルケースに統一

  # ============================================================
  # 対象ファイル
  # ============================================================
  target_files:
    - path: "output/detailed_design/api_schema.md"
      description: "APIスキーマ定義書"
    - path: "output/detailed_design/ui_details.md"
      description: "UI詳細設計書"

  # ============================================================
  # 変換対象リスト（★これが重要！）
  # ============================================================
  conversion_targets:
    rule: "snake_case → camelCase"

    fields:
      # 商品関連
      - { before: "jan_cd", after: "janCd" }
      - { before: "start_date", after: "startDate" }
      - { before: "end_date", after: "endDate" }
      - { before: "product_type_flg", after: "productTypeFlg" }
      - { before: "gtin_code", after: "gtinCode" }

      # 分類関連
      - { before: "section1_cd", after: "section1Cd" }
      - { before: "section2_cd", after: "section2Cd" }
      - { before: "section3_cd", after: "section3Cd" }
      - { before: "section4_cd", after: "section4Cd" }

      # メーカー関連
      - { before: "maker_name", after: "makerName" }
      - { before: "maker_name_kana", after: "makerNameKana" }
      - { before: "vendor_cd", after: "vendorCd" }
      - { before: "vendor_name", after: "vendorName" }

      # 日付・時刻関連
      - { before: "created_at", after: "createdAt" }
      - { before: "updated_at", after: "updatedAt" }
      - { before: "expiration_date", after: "expirationDate" }

      # フラグ関連
      - { before: "cycle_a_flg", after: "cycleAFlg" }
      - { before: "cycle_b_flg", after: "cycleBFlg" }
      - { before: "cycle_c_flg", after: "cycleCFlg" }
      - { before: "cycle_d_flg", after: "cycleDFlg" }
      - { before: "atopic_flg", after: "atopicFlg" }

      # 配送関連
      - { before: "delivery_type", after: "deliveryType" }
      - { before: "haiso_fuka_area_1", after: "haisoFukaArea1" }
      - { before: "haiso_fuka_area_2", after: "haisoFukaArea2" }
      - { before: "haiso_fuka_area_3", after: "haisoFukaArea3" }
      - { before: "haiso_fuka_area_4", after: "haisoFukaArea4" }
      - { before: "haiso_fuka_area_5", after: "haisoFukaArea5" }
      - { before: "haiso_fuka_area_etc", after: "haisoFukaAreaEtc" }

    exclude_patterns:
      - "cmd_xxx_yyy（タスクID）"
      - "output/xxx/（ファイルパス）"

  # ============================================================
  # 作業手順
  # ============================================================
  instructions: |
    【手順】
    1. 対象ファイルを読み込み
    2. conversion_targets.fields の各項目を順次置換
    3. exclude_patterns に該当するものは除外
    4. 置換結果の確認（Grepで残存チェック）
    5. 報告書に修正箇所一覧を記載

  report_to: gunshi

skill_candidate_required: false
```

### 例2: 文字列一括置換タスク

```yaml
# ============================================================
# 足軽3 タスク（cmd_030: API URLパス変更）
# ============================================================
task:
  task_id: cmd_030_api_path
  parent_cmd: cmd_030
  timestamp: "2026-02-06T20:00:00"
  type: refactoring
  status: assigned
  priority: high

  description: |
    【cmd_030対応】APIパスを /api → /api/v2 に変更

  target_files:
    - path: "frontend/src/services/*.ts"
      description: "全サービスファイル"
    - path: "frontend/src/types/*.ts"
      description: "型定義ファイル"

  # ============================================================
  # 変換対象リスト
  # ============================================================
  conversion_targets:
    rule: "文字列置換"

    fields:
      - { before: "/api/v1/", after: "/api/v2/" }
      - { before: "API_PATH = '/api/v1'", after: "API_PATH = '/api/v2'" }

    exclude_patterns:
      - "コメント内のURL"
      - "テストファイル（別タスクで対応）"

  instructions: |
    【手順】
    1. 対象ファイルをGlobで検索
    2. 各ファイルで置換実行
    3. ビルド確認

  report_to: karo

skill_candidate_required: false
```

---

## 4. その他のタスク種別向けフィールド

### 4.1 開発タスク用

```yaml
# 依存関係
dependencies:
  - task_id: cmd_025_api
    description: "API実装が先に完了している必要がある"

# 参照すべき設計書
design_references:
  - "output/detailed_design/api_schema.md"
  - "output/detailed_design/ui_details.md"
```

### 4.2 調査タスク用

```yaml
# 調査対象
investigation_scope:
  - "エラーの再現手順"
  - "影響範囲の特定"
  - "根本原因の分析"

# 期待する成果物
expected_output:
  - "原因分析レポート"
  - "修正案（3案以上）"
```

### 4.3 ドキュメント作成タスク用

```yaml
# 記載すべきセクション
required_sections:
  - "概要"
  - "詳細説明"
  - "具体例"
  - "FAQ"

# 参照すべき資料
source_materials:
  - path: "既存ドキュメント.md"
  - path: "ソースコード"
```

---

## 5. ガイドライン遵守のチェックリスト

タスクYAML作成時、以下を確認せよ：

```
□ task_id が一意で分かりやすいか
□ description に背景・目的が明記されているか
□ target_files が具体的に指定されているか
□ 変換タスクの場合、conversion_targets が記載されているか
□ instructions が手順として実行可能か
□ report_to が指定されているか
```

---

## 6. 変更履歴

| 日付 | 変更内容 | 担当 |
|------|---------|------|
| 2026-02-06 | 初版作成 | 足軽5号（cmd_031） |

---

**以上**
