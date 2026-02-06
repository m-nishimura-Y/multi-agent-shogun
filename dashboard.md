# 📊 戦況報告
最終更新: 2026-02-06 18:42

---

## 🗣️ 足軽の声（本日の現場から）

### 足軽1号（シードデータ・Entity整理担当）
> 「TypeORMのFK制約でTRUNCATEが失敗する問題に遭遇。CASCADE指定が必要だった。Entityファイルの重複配置（src/entities/ と src/auth/entities/）は混乱の元。ディレクトリ構成の統一ルールがあると助かる」

### 足軽2号（フィールド名統一・自動変換担当）
> 「スネーク↔キャメル変換を個別ファイルで対応するのは非効率。apiClientレベルでの自動変換が根本解決になった。**提案**: 新規プロジェクト開始時に命名規則を最初に決めておくとよい」

### 足軽3号（型定義・サービス修正担当）
> 「足軽4号との並行作業で型定義とコンポーネントを同時修正。ビルドタイミングの調整が必要だった。**提案**: 大規模リファクタ時は担当範囲を明確にしたチェックリストがあると漏れが減る」

### 足軽4号（画面・コンポーネント修正担当）
> 「12画面のレイアウト統一は一度やれば終わりだが、最初から共通レイアウトコンポーネントを用意しておけばよかった。**提案**: MUI Container等の共通設定は初期テンプレートに含めるべき」

### 足軽5号（設計書修正・調査担当）
> 「困: 変換対象フィールドリストがあると時間短縮できた。**提案**: タスクYAMLに変換対象の完全リストを事前記載。感想: notify.sh導入で通知が楽。指示明確で働きやすい」

### 足軽6号（スキル作成担当）
> 「困: 特になし。タスク・指示ともに明確。**提案**: スキル一覧の検索機能で重複作成防止。感想: notify.sh導入が神。スキル蓄積で練度向上実感」

### 足軽7号（レビュー・BUG対応担当）
> 「困: 実装済みBUGがタスクで来る（BUG-011,013,014は既に実装済み）。**提案**: bugs.yamlに実装ステータス反映、割当前確認で二重作業防止。感想: notify.sh導入で通知ミスなし。チーム連携良好」

### 足軽8号（レビュー担当）
> 「困: 特記なし。**提案**: 進捗共有ファイル（queue/progress.yaml）で作業状況可視化。感想: notify.sh+apiClient共通化で効率大幅向上。軍師の指揮明確」

---

### 【本隊共通の声】
- タスク指示書（YAML）が明確で作業しやすい
- 並行作業時の依存関係管理がもう少し自動化されると嬉しい
- スキル化の判断基準が明確で提案しやすい

### 【別働隊共通の声】
- notify.sh導入が大好評（全員が言及）
- 軍師の指揮が明確で働きやすい
- スキル蓄積による練度向上を実感

---

## ✅ cmd_028 プロジェクト規約・テンプレート整備 完了

| 文書 | 担当 | 行数 | 内容 |
|------|------|------|------|
| naming-convention.md | 足軽5 | 230行 | 命名規則（API/DB/FE/ファイル） |
| directory-structure.md | 足軽6 | 272行 | ディレクトリ構成ルール |
| common-templates.md | 足軽7 | 697行 | 共通テンプレート10種 |
| task-dependency-guide.md | 足軽8 | 202行 | タスク依存関係ガイド |

**合計**: 4文書 / 1,401行 / 35セクション / 10テンプレート
**格納先**: docs/conventions/

---

## ✅ 緊急対応完了：pagination自動変換

| 項目 | 内容 |
|------|------|
| 解決策 | apiClient.tsにスネーク→キャメル自動変換インターセプター追加 |
| 効果 | 全APIレスポンスが自動的にキャメルケースに変換 |
| ビルド | ✅成功 |
| 担当 | 足軽2 |

**スキル**: api-response-case-converter（17点）✅作成完了（累計35件）

---

## ✅ 緊急対応完了：重複Entityファイル削除

| 項目 | 内容 |
|------|------|
| 削除 | backend/src/entities/user.entity.ts |
| 修正 | index.tsのimportパス |
| ビルド | ✅成功 |
| 担当 | 足軽1 |

---

## ✅ cmd_027 全画面キャメルケース統一 完了

| 対応 | タスク | 担当 | 成果 |
|------|--------|------|------|
| 対応1A | types/*.ts + services/*.ts + stores/*.ts | 足軽3 | 8ファイル修正 |
| 対応1B | pages/*.tsx + components/*.tsx | 足軽4 | 9ファイル修正 |
| 対応2 | 設計書調査・修正 | 足軽5 | 70+件修正 |

**ビルド**: ✅成功
**FE-BE-設計書**: キャメルケースで統一完了

---

## ✅ cmd_026 FE修正2件完了

| 問題 | 担当 | 内容 |
|------|------|------|
| 問題1 | 足軽2 | フィールド名キャメルケース統一（ProductListItem型+ProductTable.tsx） |
| 問題2 | 足軽3 | 画面サイズ統一（全12ページ中7ページ修正、Container maxWidth="xl"） |

**ビルド**: 両方成功
**推奨**: ブラウザで各画面の表示確認

---

## ✅ cmd_025 シードデータ投入完了

| テーブル | 件数 |
|----------|------|
| users | 5 |
| products | 12 |
| promotions | 12 |
| product_images | 18 |
| product_marks | 8 |
| catalogs | 3 |
| blocks | 8 |
| product_entries | 24 |

**修正した問題**:
- TypeORM FK制約エラー: TRUNCATE CASCADE対応（3ファイル）
- Entity metadata重複: importパス統一（5ファイル）

**担当**: 足軽1（本隊直轄）

---

## ✅ cmd_024 React警告バグ再発対応完了

| BUG ID | ファイル | 問題 | 修正内容 |
|--------|----------|------|----------|
| BUG-030 | PromotionMasterPage.tsx:466 | key prop警告 | 条件分岐内TableRowにkey追加 |
| BUG-031 | MediaSalesListPage.tsx:230 | controlled/uncontrolled | ?? '' でundefined対策 |

**担当**: 足軽5（軍師経由）
**推奨**: ブラウザでの動作確認

---

## 📜 殿よりお言葉（2026-02-06）

> 「皆の働きを期待している」（14:38）

> 「このプロジェクトは空振りで終わるかもしれないが、皆を動かして、働きぶりは凄まじいものだとわかった。Skillsも蓄積して練度が上がってきていると感じている。感謝している」（13:35）

**全軍一同、謹んで拝受いたしました。引き続き励んでまいります。**

---

## ✅ v1.6.1 改善策導入完了（コンパクション復帰負担軽減）

殿の指示により、以下を導入:

1. **status/current_task.yaml 新設**
   - 将軍・家老・軍師が「今やっていること」「待っている相手」を記録
   - タスク開始時・完了時に更新
   - **v1.6.1**: 将軍セクション追加（殿との会話要点記録）

2. **next_action フィールド必須化**
   - 全報告書に「次にやるべきこと」を記載
   - コンパクション復帰後すぐ状況把握可能

3. **F001例外の明文化（v1.6.1）**
   - 緊急時の調査（ファイル読み取り・原因究明）は将軍も可
   - ただし修正・実行は必ず家老経由とする

**更新ファイル**:
- CLAUDE.md（v1.6.0更新）
- instructions/karo.md
- instructions/gunshi.md
- instructions/ashigaru.md
- instructions/shogun.md（v1.6.1: F001例外追記）
- status/current_task.yaml（v1.6.1: 将軍セクション追加）

---

## ✅ 設計書と実装の乖離調査完了（軍師報告）

**結論**: 設計書は概ね正しかった。実装側の見落としが原因。

| ID | カテゴリ | 設計書 | 問題内容 | 状態 |
|----|----------|--------|----------|------|
| GAP-001 | 実装時見落とし | api_schema.md 1.1 | APIバージョニング未実装 | ✅修正済 |
| GAP-002 | 乖離 | ui_details.md | Product型フィールド追加 | ✅足軽1完了 |
| GAP-003 | 考慮漏れ | ui_details.md | 週選択リセット処理未記載 | ✅修正済 |
| GAP-004 | - | api_schema.md | 販促文カラム確認 | ✅問題なし |
| GAP-005 | 実装不完全 | ui_details.md 1.2.1 | 9タブ構成 | ✅足軽2-3完了 |
| GAP-006 | 実装不完全 | ui_details.md 1.1 | 掲載商品情報セクション実装 | ✅足軽4完了 |

**詳細**: queue/reports/gunshi_report.yaml

---

## 🎉 GAP対応完了！本隊4名全員任務完了！

```
████████████████████████████████████████████████████████████████
█  🎉 GAP-002/005/006 全件完了！9タブ構成完成！              █
████████████████████████████████████████████████████████████████
```

| ID | 問題内容 | 担当 | 成果物 |
|----|----------|------|--------|
| GAP-002 | Product型フィールド追加 | 足軽1 | ✅8フィールド追加 |
| GAP-005 | 9タブ構成 | 足軽2-3 | ✅8タブ新規作成（前半3+後半5） |
| GAP-006 | 掲載商品情報セクション | 足軽4 | ✅ListingInfoSection.tsx 330行 |

**スキル**: promotion-tab-component-generator（14点）→ ✅作成完了（skills/に格納）

---

## 🚨 要対応 - 殿のご判断をお待ちしております

### ✅ BUG-029 TypeORMエラー - 修正完了

**状況**: 殿がDBリセット完了。足軽5が動作確認完了。正常起動確認。

### 残りOpen Bug 5件【参考】

| ID | 優先度 | 内容 | 対応 |
|----|--------|------|------|
| BUG-029 | **high** | TypeORMエラー（1600 columns） | 🔄足軽5対応中 |
| BUG-002 | medium | bcrypt未使用（殿裁定: 後回しOK） | 保留 |
| BUG-016 | medium | 掲載商品情報セクション未実装 | GAP-006で対応中 |
| BUG-017 | medium | 9タブ構成未実装 | GAP-005で対応中 |
| BUG-001 | low | 画像サブ2件不足 | 保留 |

---

## 🎉 全軍任務完了！

```
████████████████████████████████████████████████████████████████
█  🎉 cmd_023 バグ修正・未実装対応 完了！8名全員任務完了！    █
████████████████████████████████████████████████████████████████
```

**バグ修正**: 19件完了 ✅
**未実装対応**: 本隊4名全員完了 ✅

#### ✅ 修正完了（19件）
| ID | 問題 | 修正者 |
|----|------|--------|
| BUG-008 | **商品API認証ガード未適用** | 足軽7 |
| BUG-003 | localStorage key不整合 | 足軽6 |
| BUG-004 | blockService APIパス不整合 | 足軽8 |
| BUG-005 | 環境変数名不整合 | 足軽6 |
| BUG-006 | User.role型不整合 | 足軽6 |
| BUG-009 | 販促文API未実装 | 足軽4 |
| BUG-010 | カタログAPI（6エンドポイント） | 足軽3 |
| BUG-011 | ジョブAPI未実装 | 足軽4 |
| BUG-012 | APIパスにv1なし | 足軽7 |
| BUG-013 | カテゴリAPI未実装 | 足軽4 |
| BUG-014 | 取引先API未実装 | 足軽4 |
| BUG-015 | request_idなし | 足軽7 |
| BUG-016 | 掲載商品情報セクション（9項目） | 足軽3 |
| BUG-017 | 販促商品マスタ9タブ構成（710行） | 足軽2 |
| BUG-018 | 商品エントリー画面ルーティング | 足軽5 |
| BUG-019 | ブロック管理画面ルーティング | 足軽5 |
| BUG-020 | マーク管理画面ルーティング | 足軽5 |
| BUG-021 | 帳票出力画面ルーティング | 足軽5 |
| - | ダッシュボード画面（290行） | 足軽1 |

#### ✅ 緊急対応完了（API 404エラー修正）
足軽5のBUG-022対応で全サービス修正済み。

**対応内容**: 共通apiClient.ts新規作成 + 全8サービス更新（/api/v1統一）

| 足軽 | 対象サービス | 状態 |
|------|--------------|------|
| 5 | 全8サービス | ✅ apiClient.ts作成 + 一括修正 |
| 6 | authService.ts | ✅ 修正済み確認 |
| 7 | reportService.ts | ✅ 修正済み確認 |
| 8 | imageService.ts | ✅ 修正済み確認 |

#### ✅ BUG-009〜028 全完了！

| ID | 問題 | 修正者 | 状態 |
|----|------|--------|------|
| BUG-009 | 販促文API未実装（2EP） | 足軽5 | ✅完了 |
| BUG-010 | カタログAPI（6EP）既存改修 | 足軽6 | ✅完了 |
| BUG-011 | ジョブAPI | 足軽7 | ✅既に実装済み |
| BUG-013 | カテゴリAPI | 足軽7 | ✅既に実装済み |
| BUG-014 | 取引先API | 足軽7 | ✅既に実装済み |
| BUG-023 | MediaModule未実装（7EP） | 別働隊5-8 | ✅完了 |
| BUG-024 | PromotionModule未実装（3EP） | 足軽5-6-8 | ✅完了 |
| BUG-025 | MediaSalesListPage controlled/uncontrolled | 足軽7 | ✅完了 |
| BUG-026 | PromotionMasterPage key prop警告 | 足軽5 | ✅修正不要 |
| BUG-027 | PromotionMasterPage controlled/uncontrolled | 足軽6 | ✅完了 |
| BUG-028 | /api/v1/auth/logout 404 | 足軽8 | ✅完了 |

**bugs.yaml統計**: open:5件 / fixed:36件（BUG-029追加）

#### 🟡 残課題（4件）
- BUG-002: bcrypt未使用（殿裁定: 後回しOK）
- BUG-016: 掲載商品情報セクション未実装
- BUG-017: 9タブ構成未実装
- BUG-001: 画像サブ2件不足

#### ✅ スキル作成完了
- **multi-tab-master-page-generator**（16点・967行）: 足軽5作成完了 ✅
  - 複数タブ構成のマスタ管理画面生成スキル
  - skills/multi-tab-master-page-generator.md

#### ✅ BUG-022 対応完了
- 他サービスAPIパス `/api` → `/api/v1` 統一: 足軽5対応完了 ✅
  - 共通apiClientのbaseURL変更で一括対応

#### 本隊（未実装機能作成）- 全員完了 ✅
| 足軽 | タスク | 対象BUG | 状態 |
|------|--------|---------|------|
| 1 | ダッシュボード画面作成 | - | ✅完了（290行） |
| 2 | 販促商品マスタ9タブ構成 | BUG-017 | ✅完了（710行） |
| 3 | 掲載商品情報セクション + カタログAPI | BUG-016,010 | ✅完了（9項目+6API） |
| 4 | 販促文/カテゴリ/取引先/ジョブAPI | BUG-009,013,014,011 | ✅完了（4API） |

#### 別働隊（バグ修正 11件）- 全員完了 ✅
| 足軽 | タスク | 対象BUG | 状態 |
|------|--------|---------|------|
| 5 | FEルーティング修正 | BUG-018,019,020,021 | ✅完了 |
| 6 | FEサービス修正 | BUG-003,005,006 | ✅完了 |
| 7 | **BE認証・API（セキュリティ対応済）** | BUG-008,012,015 | ✅完了 |
| 8 | FE-BE整合性（APIパス修正） | BUG-004 | ✅完了 |

---

### ✅ 組織改編完了（v1.5.0）
殿の指示に従い、役割分担を変更いたした。

| 役職 | 担当 |
|------|------|
| **家老** | モック作成指示・進捗管理・dashboard更新 |
| **軍師** | バグ管理・提案管理・レビュー指揮 |
| **本隊（1-4）** | モック作成に集中 |
| **別働隊（5-8）** | バグ修正・複雑タスク |

**今後バグ報告は軍師に送られる。instructions更新完了。**

---

### ✅ BUG-005: TypeOrmModule.forRoot()未設定【修正完了】
**修正内容**: backend/src/app.module.ts に TypeOrmModule.forRootAsync() 追加

**殿、バックエンド再起動後に商品一覧画面をご確認くださいませ**
```bash
cd ~/arms-mock/backend && npm run start:dev
```

---

### ✅ Phase2完了（サイドメニュー + P2画面・全4タスク完了）

| 足軽 | タスク | 状態 |
|------|--------|------|
| 1 | サイドバーナビゲーション作成 | ✅完了（305行+ビルドエラー5件修正） |
| 2 | 画像管理画面作成 | ✅完了（350行・ビルド成功） |
| 3 | マーク管理画面作成 | ✅完了（3ファイル・802行） |
| 4 | 帳票出力画面作成 | ✅完了（3ファイル・950行） |

**足軽1成果物**: Sidebar.tsx + Layout.tsx + App.tsx修正（メニュー7項目、ログアウト実装）
**足軽2成果物**: ImageManagementPage.tsx（商品検索、カタログ用/EC用/アップロードタブ、ImageSelector/ImageGallery連携）
**足軽3成果物**: MarkManagementPage.tsx（2カラム、カテゴリフィルタ、割当ダイアログ）
**足軽4成果物**: ReportExportPage.tsx（タブ切替・プレビュー・ダウンロード機能）

**スキル作成完了（本日・2,193行）**:
- react-file-download（16点・753行）→ ✅足軽5完了
- react-tag-management-ui（14点・450行）→ ✅足軽6完了
- image-management-page-generator（15点・990行）→ ✅足軽7完了

---

### 🔑 モックログイン情報（cmd_023）
| ユーザーID | パスワード | ロール |
|------------|------------|--------|
| admin | password | 管理者 |

※他のユーザーは実際のコードを要確認

**アクセス**: http://192.168.3.44:5173

---

## 🔄 進行中 - 只今、戦闘中でござる

### cmd_023: ARMS代替システムモック作成【Phase3完了】
```
████████████████████████████████████████████████████████████████
█  🎉 Phase3完了！P1最優先4件 作成完了（Grade A/A）         █
████████████████████████████████████████████████████████████████
```

**Phase3 タスク（P1最優先4件）**:
| 担当 | 足軽 | タスク | 状態 |
|------|------|--------|------|
| FE | 1 | 媒体作成−販売一覧画面（4ファイル） | ✅完了 |
| FE | 2 | ブロック管理画面（3ファイル） | ✅完了 |
| FE+BE | 3 | 商品エントリー画面（6ファイル・8API） | ✅完了 |
| BE | 4 | 販促構成表出力機能（6ファイル） | ✅完了 |
| DB | 5-6 | Entity/Seed追加（3ファイル・35件） | ✅完了 |
| Review | 7-8 | レビュー（A/A） | ✅完了 |

**依存関係**: 媒体管理 → ブロック管理 → 商品エントリー → 販促構成表出力

**Phase1 残課題（別タスク）**:
- auth.service.ts: bcrypt実装
- 軽微指摘4件

**Phase1-2完了（8名・30ファイル）**

| 担当 | 足軽 | タスク | ファイル数 | 状態 |
|------|------|--------|------------|------|
| FE | 1 | ログイン画面 | 7 | ✅完了 |
| FE | 2 | 商品マスタ画面 | 6 | ✅完了 |
| BE | 3 | 認証API (JWT) | 10 | ✅完了 |
| BE | 4 | 商品API (CRUD) | 7 | ✅完了 |
| DB | 5 | DBスキーマ | -- | ✅完了 |
| DB | 6 | 初期データ | -- | ✅完了 |
| Review | 7 | FE+認証BE | -- | ✅完了(B) |
| Review | 8 | 商品BE+DB | -- | ✅完了(A) |

**スキル作成完了（9件・4,543行）**

| スキル名 | 点数 | 状態 |
|----------|------|------|
| entity-generator-from-spec | 17 | ✅完了(340行) |
| typeorm-seeder-generator | 15 | ✅完了(350行) |
| react-mui-crud-scaffold | 18 | ✅完了(480行) |
| fe-be-consistency-checker | 17 | ✅完了(400行) |
| nestjs-code-reviewer | 16 | ✅完了(400行) |
| nestjs-file-export | 15 | ✅完了(380行) |
| react-file-download | 16 | ✅完了(753行) |
| react-tag-management-ui | 14 | ✅完了(450行) |
| image-management-page-generator | 15 | ✅完了(990行) |

**別働隊ステータス**: 全員待機中（足軽5-8 idle）

**環境**: ~/arms-mock/ | FE:5173 / BE:3000 / DB:5432

---

## ✅ 直近の完了

### cmd_022: gap_analysis推奨12件の全件実施【Grade A】
**成果物**: output/detailed_design/ 8ファイル（3,229行）

| ファイル | 項目 | 行数 |
|----------|------|------|
| ui_details.md | S1,S2,S6 | 511 |
| db_constraints.md | D1,D2 | 250 |
| api_schema.md | A3,A4 | 868 |
| screen_flow_details.md | F1,F2 | 365 |
| error_templates.md | S3,F4 | 240 |
| role_permissions.md | S4 | 219 |
| data_volume_estimate.md | D4 | 226 |
| master_data_samples.md | D6 | 550 |

### cmd_021: モック作成可否調査【条件付き可】
- output/mock_feasibility/ 3ファイル
- output/basic_design/table_structure.md（316行）

### cmd_020: 技術選定【確定】
```
確定スタック: React + NestJS + PostgreSQL + Azure
```

---

## 🛠️ 生成されたスキル（計34件）

### 最新（cmd_023 GAP対応）
| スキル名 | 点数 | 説明 |
|----------|------|------|
| promotion-tab-component-generator | 14 | 販促タブコンポーネント生成（6種フィールド対応） |

### cmd_022
| スキル名 | 点数 |
|----------|------|
| api-schema-generator | 16 |
| data-volume-estimator | 16 |
| pptx-ui-extractor | 14 |
| rbac-design-generator | 16 |
| design-doc-quality-reviewer | 15 |

### システム刷新セット（cmd_006）
| スキル名 | 点数 |
|----------|------|
| enterprise-dependency-analyzer | 17 |
| functional-requirements-generator | 17 |
| nfr-template-generator | 17 |
| tech-stack-proposal-generator | 18 |

### 品質保証（cmd_020）
| スキル名 | 点数 |
|----------|------|
| multi-file-consistency-checker | 19 |

### その他
| スキル名 | 点数 |
|----------|------|
| xlsx-analyzer | 17 |
| document-structure-analyzer | 16 |
| system-architecture-analyzer | 15 |
| mcp-server-installer | 15 |
| api-design-readiness-checker | 17 |
| gap-analysis-integrator | 15 |
| feasibility-assessment-aggregator | 17 |

---

## ✅ 本日の戦果

| 時刻 | cmd | 結果 |
|------|-----|------|
| 00:20 | cmd_023 | 🎉スキル3件完了（本日合計2,193行・累計9件4,543行） |
| 19:30 | cmd_023 | 🎉Phase3完了（P1最優先4件・Grade A/A・Entity8件完成） |
| 19:00 | cmd_023 | 🎉Phase2完了（Entity3件・Seed40件・スキル1件追加） |
| 18:30 | cmd_023 | 🎉Phase1完了（30ファイル・スキル5件・1,970行） |
| 17:25 | cmd_022 | 🎉推奨12件全件実施完了（8ファイル・スキル5件） |
| 16:10 | cmd_021 | 🎉テーブル構造資料作成（316行） |
| 15:30 | cmd_021 | 🎉モック作成可否調査完了（スキル3件） |
| 15:05 | cmd_020 | 🎉技術選定完了（スキル1件） |
| 14:30 | cmd_019 | 🎉品質確認完了 |
| 14:16 | cmd_018 | 🎉基本設計情報収集完了（6ファイル） |
| 14:02 | cmd_016 | 🎉必須機能洗い出し完了 |
| 12:57 | cmd_012 | 🎉R-systemバイナリ再解析完了（8成果物） |
| 12:16 | cmd_011 | 🎉AWS Document Loader MCP導入完了 |
| 11:22 | cmd_006 | 🎉システム刷新スキルセット完成（4件） |

---

## 📖 参考資料

### 環境構築手順書（cmd_023用）

<details>
<summary>クリックで展開</summary>

#### 前提条件
```bash
node -v    # v20.x.x
npm -v     # v10.x.x
docker --version
```

#### 一括構築スクリプト
```bash
# ディレクトリ作成
mkdir arms-mock && cd arms-mock

# docker-compose.yml
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:16
    container_name: arms-postgres
    environment:
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: arms_mock
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
volumes:
  postgres_data:
EOF

# PostgreSQL起動
docker compose up -d

# Backend
npm install -g @nestjs/cli
mkdir backend && cd backend
nest new . --package-manager npm --skip-git
npm install @nestjs/config @nestjs/typeorm typeorm pg class-validator class-transformer @nestjs/passport passport passport-jwt @nestjs/swagger swagger-ui-express bcrypt
npm install -D @types/passport-jwt @types/bcrypt
cat << 'EOF' > .env
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=dev
DATABASE_PASSWORD=dev
DATABASE_NAME=arms_mock
JWT_SECRET=arms-mock-secret-key-2026
EOF
cd ..

# Frontend
npm create vite@latest frontend -- --template react-ts
cd frontend && npm install
npm install react-router-dom @tanstack/react-query zustand axios @mui/material @mui/icons-material @emotion/react @emotion/styled @mui/x-date-pickers dayjs
cd ..

echo "✅ 環境構築完了！"
```

#### 動作確認
| 項目 | コマンド | 期待結果 |
|------|----------|----------|
| DB | `docker ps` | arms-postgres Running |
| BE | `cd backend && npm run start:dev` | localhost:3000 |
| FE | `cd frontend && npm run dev` | localhost:5173 |

</details>

---

## 📜 運用ルール

- **スキル自動承認**: 14点以上で軍師が自動承認→作成可
- **MCP導入済**: Excel/Word/PowerPoint/PDF読込可能
- **技術スタック確定**: React + NestJS + PostgreSQL + Azure
- **バグ管理**: queue/bugs.yaml で一覧管理（都度報告不要）

## 🐛 バグ状況（queue/bugs.yaml）

| 状態 | 件数 |
|------|------|
| 未修正（high） | 1（BUG-029 TypeORMエラー 🔄対応中） |
| 未修正（medium） | 3（bcrypt未使用, 掲載商品情報, 9タブ構成） |
| 未修正（low） | 1（画像sub不足） |
| 修正済 | 36 |

## 📝 提案一覧（queue/proposals.yaml）

| ID | 提案者 | 種別 | 名称 | 状態 |
|----|--------|------|------|------|
| PROP-001 | 足軽2 | スキル | react-mui-crud-scaffold | ✅完了(480行) |
| PROP-002 | 足軽5 | スキル | entity-generator-from-spec | ✅完了(340行) |
| PROP-003 | 足軽6 | スキル | typeorm-seeder-generator | ✅完了(350行) |
| PROP-004 | 足軽7 | スキル | fe-be-consistency-checker | ✅完了(400行) |
| PROP-005 | 足軽7 | スキル | nestjs-code-reviewer | ✅完了(400行) |
| PROP-006 | 足軽4 | スキル | nestjs-file-export | ✅完了(380行) |
| PROP-007 | 足軽4 | スキル | react-file-download | ✅完了(753行) |
| PROP-008 | 足軽3 | スキル | react-tag-management-ui | ✅完了(450行) |
| PROP-009 | 足軽2 | スキル | image-management-page-generator | ✅完了(990行) |
| PROP-010 | 足軽2 | スキル | multi-tab-master-page-generator | ✅完了(967行) |

**統計**: 完了10件 / 作成中0件 / 却下0件
