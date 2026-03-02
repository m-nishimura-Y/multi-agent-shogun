#!/bin/bash
# ============================================================
# pre-integration-test-check.sh
# 統合テスト前チェックリスト自動化スクリプト
# ============================================================
# 作成: 足軽7号 (cmd_155)
# 目的: 統合テスト実行前に確認すべき事項を自動チェック
# ============================================================

set -e

# ============================================================
# カラー定義
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# 変数
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(pwd)}"
VERBOSE="${2:-false}"

# チェック結果カウンター
PASSED=0
FAILED=0
WARNED=0

# ============================================================
# ヘルパー関数
# ============================================================
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  統合テスト前チェックリスト                                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "対象プロジェクト: $PROJECT_ROOT"
    echo "実行日時: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}────────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────────${NC}"
}

check_pass() {
    echo -e "  ${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

check_fail() {
    echo -e "  ${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNED++))
}

check_skip() {
    echo -e "  ${YELLOW}⏭️  SKIP${NC}: $1"
}

# ============================================================
# 使い方
# ============================================================
usage() {
    echo "使い方: $0 [プロジェクトパス] [--verbose]"
    echo ""
    echo "例:"
    echo "  $0 /home/nishimura/S-automation"
    echo "  $0 /home/nishimura/S-automation --verbose"
    echo ""
    echo "チェック項目:"
    echo "  1. フロントエンド ビルド状態"
    echo "  2. バックエンド ビルド状態"
    echo "  3. バックエンド 起動確認（ヘルスチェック）"
    echo "  4. データベース 接続確認"
    echo "  5. マイグレーション 適用状態"
    echo "  6. シードデータ 投入確認"
    echo "  7. 環境変数 設定確認"
    echo "  8. API エンドポイント 疎通確認"
    exit 0
}

# ============================================================
# 引数処理
# ============================================================
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [[ "$2" == "--verbose" || "$2" == "-v" ]]; then
    VERBOSE=true
fi

# ============================================================
# プロジェクト構成検出
# ============================================================
detect_project_structure() {
    print_section "プロジェクト構成検出"

    # フロントエンド検出
    if [[ -d "$PROJECT_ROOT/frontend" ]]; then
        FRONTEND_DIR="$PROJECT_ROOT/frontend"
        check_pass "フロントエンドディレクトリ検出: frontend/"
    elif [[ -f "$PROJECT_ROOT/package.json" ]] && grep -q "react\|vue\|angular" "$PROJECT_ROOT/package.json" 2>/dev/null; then
        FRONTEND_DIR="$PROJECT_ROOT"
        check_pass "フロントエンドディレクトリ検出: ./ (ルート)"
    else
        FRONTEND_DIR=""
        check_warn "フロントエンドディレクトリ未検出"
    fi

    # バックエンド検出
    if [[ -d "$PROJECT_ROOT/backend" ]]; then
        BACKEND_DIR="$PROJECT_ROOT/backend"
        check_pass "バックエンドディレクトリ検出: backend/"
    elif [[ -f "$PROJECT_ROOT/nest-cli.json" ]] || [[ -f "$PROJECT_ROOT/tsconfig.json" ]] && grep -q "nestjs\|express" "$PROJECT_ROOT/package.json" 2>/dev/null; then
        BACKEND_DIR="$PROJECT_ROOT"
        check_pass "バックエンドディレクトリ検出: ./ (ルート)"
    else
        BACKEND_DIR=""
        check_warn "バックエンドディレクトリ未検出"
    fi

    # Prisma検出
    if [[ -n "$BACKEND_DIR" ]] && [[ -f "$BACKEND_DIR/prisma/schema.prisma" ]]; then
        PRISMA_DIR="$BACKEND_DIR/prisma"
        check_pass "Prisma検出: prisma/schema.prisma"
    else
        PRISMA_DIR=""
        check_warn "Prisma未検出"
    fi

    # Docker Compose検出
    if [[ -f "$PROJECT_ROOT/docker-compose.yml" ]]; then
        DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
    elif [[ -f "$PROJECT_ROOT/docker/docker-compose.yml" ]]; then
        DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker/docker-compose.yml"
    else
        DOCKER_COMPOSE_FILE=""
        check_warn "docker-compose.yml未検出"
    fi
}

# ============================================================
# 1. フロントエンドビルド確認
# ============================================================
check_frontend_build() {
    print_section "1. フロントエンド ビルド状態"

    if [[ -z "$FRONTEND_DIR" ]]; then
        check_skip "フロントエンドディレクトリなし"
        return
    fi

    # node_modules確認
    if [[ -d "$FRONTEND_DIR/node_modules" ]]; then
        check_pass "node_modules 存在"
    else
        check_fail "node_modules 未インストール（npm install 実行が必要）"
    fi

    # ビルド成果物確認
    if [[ -d "$FRONTEND_DIR/dist" ]]; then
        FILE_COUNT=$(find "$FRONTEND_DIR/dist" -type f | wc -l)
        check_pass "dist/ ディレクトリ存在（ファイル数: $FILE_COUNT）"
    else
        check_warn "dist/ ディレクトリなし（ビルド未実行 or 開発モード）"
    fi

    # package.json scripts確認
    if grep -q '"build"' "$FRONTEND_DIR/package.json" 2>/dev/null; then
        check_pass "build スクリプト定義あり"
    else
        check_fail "build スクリプト未定義"
    fi
}

# ============================================================
# 2. バックエンドビルド確認
# ============================================================
check_backend_build() {
    print_section "2. バックエンド ビルド状態"

    if [[ -z "$BACKEND_DIR" ]]; then
        check_skip "バックエンドディレクトリなし"
        return
    fi

    # node_modules確認
    if [[ -d "$BACKEND_DIR/node_modules" ]]; then
        check_pass "node_modules 存在"
    else
        check_fail "node_modules 未インストール（npm install 実行が必要）"
    fi

    # ビルド成果物確認
    if [[ -d "$BACKEND_DIR/dist" ]]; then
        FILE_COUNT=$(find "$BACKEND_DIR/dist" -type f | wc -l)
        check_pass "dist/ ディレクトリ存在（ファイル数: $FILE_COUNT）"
    else
        check_warn "dist/ ディレクトリなし（ビルド未実行 or 開発モード）"
    fi

    # Prisma Client生成確認
    if [[ -d "$BACKEND_DIR/node_modules/.prisma/client" ]]; then
        check_pass "Prisma Client 生成済み"
    elif [[ -n "$PRISMA_DIR" ]]; then
        check_fail "Prisma Client 未生成（npx prisma generate 実行が必要）"
    fi
}

# ============================================================
# 3. バックエンド起動確認
# ============================================================
check_backend_health() {
    print_section "3. バックエンド 起動確認"

    # ポート設定（デフォルト3000）
    BACKEND_PORT="${BACKEND_PORT:-3000}"
    HEALTH_ENDPOINT="${HEALTH_ENDPOINT:-/health}"

    # プロセス確認
    if pgrep -f "node.*dist/main" > /dev/null 2>&1 || pgrep -f "nest start" > /dev/null 2>&1; then
        check_pass "NestJS プロセス稼働中"
    else
        check_warn "NestJS プロセス未検出（開発サーバーが起動していない可能性）"
    fi

    # ヘルスチェック
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$BACKEND_PORT$HEALTH_ENDPOINT" 2>/dev/null | grep -q "200"; then
        check_pass "ヘルスチェック成功（http://localhost:$BACKEND_PORT$HEALTH_ENDPOINT）"
    elif curl -s -o /dev/null -w "%{http_code}" "http://localhost:$BACKEND_PORT/" 2>/dev/null | grep -qE "200|404"; then
        check_warn "ヘルスエンドポイント未設定だがサーバー応答あり"
    else
        check_fail "バックエンドサーバー応答なし（http://localhost:$BACKEND_PORT）"
    fi
}

# ============================================================
# 4. データベース接続確認
# ============================================================
check_database_connection() {
    print_section "4. データベース 接続確認"

    # PostgreSQL接続確認（pg_isready）
    if command -v pg_isready &> /dev/null; then
        DB_HOST="${DATABASE_HOST:-localhost}"
        DB_PORT="${DATABASE_PORT:-5432}"
        DB_USER="${DATABASE_USER:-postgres}"

        if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" > /dev/null 2>&1; then
            check_pass "PostgreSQL接続成功（$DB_HOST:$DB_PORT）"
        else
            check_fail "PostgreSQL接続失敗（$DB_HOST:$DB_PORT）"
        fi
    else
        check_warn "pg_isready コマンド未インストール"
    fi

    # Docker経由の確認
    if [[ -n "$DOCKER_COMPOSE_FILE" ]] && command -v docker &> /dev/null; then
        COMPOSE_DIR=$(dirname "$DOCKER_COMPOSE_FILE")
        if docker compose -f "$DOCKER_COMPOSE_FILE" ps 2>/dev/null | grep -q "db.*running\|db.*Up"; then
            check_pass "Docker PostgreSQLコンテナ稼働中"
        else
            check_warn "Docker PostgreSQLコンテナ未稼働"
        fi
    fi
}

# ============================================================
# 5. マイグレーション状態確認
# ============================================================
check_migration_status() {
    print_section "5. マイグレーション 適用状態"

    if [[ -z "$PRISMA_DIR" ]] || [[ -z "$BACKEND_DIR" ]]; then
        check_skip "Prisma未使用"
        return
    fi

    # マイグレーションファイル存在確認
    if [[ -d "$PRISMA_DIR/migrations" ]]; then
        MIGRATION_COUNT=$(find "$PRISMA_DIR/migrations" -maxdepth 1 -type d | wc -l)
        ((MIGRATION_COUNT--))  # migrations ディレクトリ自体を除外
        check_pass "マイグレーションファイル数: $MIGRATION_COUNT"
    else
        check_warn "マイグレーションディレクトリ未作成"
    fi

    # Prisma migrate status（DBに接続できる場合のみ）
    if command -v npx &> /dev/null; then
        cd "$BACKEND_DIR"
        if npx prisma migrate status 2>&1 | grep -q "Database schema is up to date"; then
            check_pass "マイグレーション最新状態"
        elif npx prisma migrate status 2>&1 | grep -q "Following migration"; then
            check_warn "未適用マイグレーションあり"
        else
            check_warn "マイグレーション状態確認不可（DB接続エラーの可能性）"
        fi
        cd - > /dev/null
    fi
}

# ============================================================
# 6. シードデータ確認
# ============================================================
check_seed_data() {
    print_section "6. シードデータ 投入確認"

    if [[ -z "$PRISMA_DIR" ]] || [[ -z "$BACKEND_DIR" ]]; then
        check_skip "Prisma未使用"
        return
    fi

    # seed.tsファイル存在確認
    if [[ -f "$PRISMA_DIR/seed.ts" ]]; then
        check_pass "seed.ts ファイル存在"
    elif [[ -f "$PRISMA_DIR/seed.js" ]]; then
        check_pass "seed.js ファイル存在"
    else
        check_warn "シードスクリプト未作成"
    fi

    # package.jsonにseed設定があるか
    if grep -q '"seed"' "$BACKEND_DIR/package.json" 2>/dev/null; then
        check_pass "prisma.seed 設定あり"
    else
        check_warn "prisma.seed 設定なし"
    fi
}

# ============================================================
# 7. 環境変数確認
# ============================================================
check_environment_variables() {
    print_section "7. 環境変数 設定確認"

    # 共通環境変数
    REQUIRED_VARS=(
        "DATABASE_HOST"
        "DATABASE_PORT"
        "DATABASE_USER"
        "DATABASE_PASSWORD"
        "DATABASE_NAME"
    )

    # .envファイル確認
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        check_pass ".env ファイル存在（プロジェクトルート）"
    elif [[ -f "$BACKEND_DIR/.env" ]]; then
        check_pass ".env ファイル存在（バックエンド）"
    else
        check_warn ".env ファイル未作成"
    fi

    # 環境変数チェック
    MISSING_VARS=()
    for VAR in "${REQUIRED_VARS[@]}"; do
        if [[ -z "${!VAR}" ]]; then
            MISSING_VARS+=("$VAR")
        fi
    done

    if [[ ${#MISSING_VARS[@]} -eq 0 ]]; then
        check_pass "必須環境変数すべて設定済み"
    else
        check_warn "未設定環境変数: ${MISSING_VARS[*]}"
    fi
}

# ============================================================
# 8. API疎通確認
# ============================================================
check_api_endpoints() {
    print_section "8. API エンドポイント 疎通確認"

    BACKEND_PORT="${BACKEND_PORT:-3000}"
    API_BASE="http://localhost:$BACKEND_PORT"

    # テスト用エンドポイント一覧
    ENDPOINTS=(
        "/health:GET:ヘルスチェック"
        "/api/payment-slips:GET:支払伝票一覧"
        "/api/file-cases:GET:ファイルケース一覧"
        "/api/cabinets:GET:キャビネット一覧"
    )

    for ENDPOINT_INFO in "${ENDPOINTS[@]}"; do
        IFS=':' read -r ENDPOINT METHOD DESC <<< "$ENDPOINT_INFO"

        RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X "$METHOD" "$API_BASE$ENDPOINT" 2>/dev/null || echo "000")

        case "$RESPONSE_CODE" in
            200|201|204)
                check_pass "$DESC ($ENDPOINT) - HTTP $RESPONSE_CODE"
                ;;
            401|403)
                check_warn "$DESC ($ENDPOINT) - HTTP $RESPONSE_CODE（認証必要）"
                ;;
            404)
                check_warn "$DESC ($ENDPOINT) - HTTP 404（エンドポイント未実装 or パス間違い）"
                ;;
            000)
                check_fail "$DESC ($ENDPOINT) - 接続失敗（サーバー未起動）"
                ;;
            *)
                check_warn "$DESC ($ENDPOINT) - HTTP $RESPONSE_CODE"
                ;;
        esac
    done
}

# ============================================================
# 結果サマリ
# ============================================================
print_summary() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  チェック結果サマリ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN}✅ PASS${NC}: $PASSED 件"
    echo -e "  ${YELLOW}⚠️  WARN${NC}: $WARNED 件"
    echo -e "  ${RED}❌ FAIL${NC}: $FAILED 件"
    echo ""

    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  🎉 統合テスト実行準備完了！                                   ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ⚠️  統合テスト実行前に問題を解決してください                   ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# ============================================================
# メイン処理
# ============================================================
main() {
    print_header
    detect_project_structure
    check_frontend_build
    check_backend_build
    check_backend_health
    check_database_connection
    check_migration_status
    check_seed_data
    check_environment_variables
    check_api_endpoints
    print_summary
}

main "$@"
