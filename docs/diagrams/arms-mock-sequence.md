# arms-mock シーケンス図

> 作成日: 2026-02-13
> 作成者: 軍師 (cmd_025)

## 1. 認証フロー（ログイン）

```mermaid
sequenceDiagram
    autonumber
    participant C as Client<br>(Frontend)
    participant AC as AuthController
    participant AS as AuthService
    participant JWT as JwtService

    Note over C,JWT: POST /api/auth/login

    C->>+AC: login(LoginDto)
    Note right of C: { userId, password }

    AC->>+AS: login(loginDto)

    AS->>AS: ユーザー検索<br>(mockUsersから)

    alt ユーザー不在
        AS-->>AC: UnauthorizedException
        AC-->>C: 401 Unauthorized
    else パスワード不一致
        AS-->>AC: UnauthorizedException
        AC-->>C: 401 Unauthorized
    else 認証成功
        AS->>AS: JwtPayload作成<br>{sub, userId, name, role}
        AS->>+JWT: sign(payload)
        JWT-->>-AS: accessToken
        AS-->>-AC: LoginResponseDto
        Note left of AS: { access_token, user }
        AC-->>-C: 200 OK
    end
```

## 2. 認証済みAPI呼び出しフロー

```mermaid
sequenceDiagram
    autonumber
    participant C as Client<br>(Frontend)
    participant G as JwtAuthGuard
    participant JS as JwtStrategy
    participant Ctrl as Controller<br>(任意のAPI)

    Note over C,Ctrl: GET /api/auth/profile 等

    C->>+G: リクエスト<br>Authorization: Bearer {token}

    G->>+JS: validate(payload)

    JS->>JS: トークン検証<br>(署名・有効期限)

    alt トークン無効
        JS-->>G: UnauthorizedException
        G-->>C: 401 Unauthorized
    else トークン有効
        JS-->>-G: user情報
        G->>+Ctrl: リクエスト<br>(req.userに付与)
        Ctrl-->>-G: レスポンス
        G-->>-C: 200 OK + data
    end
```

## 3. 原稿エクスポートフロー

```mermaid
sequenceDiagram
    autonumber
    participant C as Client<br>(Frontend)
    participant MEC as ManuscriptExport<br>Controller
    participant MES as ManuscriptExport<br>Service
    participant DB as Database<br>(TypeORM)

    Note over C,DB: GET /api/manuscript-export?format=excel

    C->>+MEC: exportManuscript(dto)
    Note right of C: { catalogId, format }

    MEC->>+MES: export(dto)

    MES->>+DB: カタログ情報取得
    DB-->>-MES: Catalog

    MES->>+DB: 商品一覧取得<br>(ProductEntry)
    DB-->>-MES: entries[]

    MES->>MES: データ変換<br>(ManuscriptItem[])

    alt format = EXCEL
        MES->>MES: Excel生成<br>(xlsx)
    else format = CSV
        MES->>MES: CSV生成<br>(Shift-JIS)
    else format = TAB
        MES->>MES: タブ区切り生成<br>(Shift-JIS)
    end

    MES-->>-MEC: { buffer, contentType, extension }

    MEC->>MEC: レスポンスヘッダー設定<br>Content-Disposition

    MEC-->>-C: ファイルダウンロード
```

## 4. ログアウトフロー

```mermaid
sequenceDiagram
    autonumber
    participant C as Client<br>(Frontend)
    participant AC as AuthController
    participant LS as LocalStorage

    Note over C,LS: POST /api/auth/logout

    C->>+AC: logout()
    AC-->>-C: 200 OK<br>{ status: "success" }

    C->>LS: トークン削除
    Note right of C: JWT方式のため<br>サーバー側は<br>無効化処理なし
```

---

## 補足

### エンドポイント一覧（認証関連）

| エンドポイント | メソッド | 認証 | 説明 |
|---------------|---------|------|------|
| `/api/auth/login` | POST | 不要 | ログイン・JWT発行 |
| `/api/auth/profile` | GET | 必要 | ユーザー情報取得 |
| `/api/auth/verify` | GET | 必要 | トークン有効性確認 |
| `/api/auth/logout` | POST | 不要 | ログアウト |

### エンドポイント一覧（原稿エクスポート）

| エンドポイント | メソッド | 認証 | 説明 |
|---------------|---------|------|------|
| `/api/manuscript-export` | GET | 不要* | 汎用エクスポート |
| `/api/manuscript-export/excel` | GET | 不要* | Excel形式 |
| `/api/manuscript-export/csv` | GET | 不要* | CSV形式 |
| `/api/manuscript-export/tab` | GET | 不要* | タブ区切り形式 |
| `/api/manuscript-export/preview` | GET | 不要* | プレビュー（JSON） |

*モック環境のため認証不要（bug_036対応）

### ユーザーロール

| ロール | 説明 |
|--------|------|
| `admin` | システム管理者 |
| `editor` | 編集者 |
| `viewer` | 閲覧者 |
| `approver` | 承認者 |
| `operator` | オペレーター |
