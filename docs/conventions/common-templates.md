# 共通テンプレート集

> **Version**: 1.0.0
> **Last Updated**: 2026-02-06
> **Purpose**: コピペで使える実装テンプレート

---

## 目次

1. [ページコンポーネント](#1-ページコンポーネント)
2. [APIサービス](#2-apiサービス)
3. [型定義ファイル](#3-型定義ファイル)
4. [NestJSコントローラー](#4-nestjsコントローラー)
5. [カスタムフック](#5-カスタムフック)

---

## 1. ページコンポーネント

### 1.1 基本ページ（シンプル）

```tsx
/**
 * Xxxページ
 * 用途の説明
 */
import { Container, Typography, Paper, Box } from '@mui/material';

export const XxxPage = () => {
  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        ページタイトル
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        ページの説明文
      </Typography>

      <Paper sx={{ p: 3 }}>
        {/* コンテンツ */}
      </Paper>
    </Container>
  );
};

export default XxxPage;
```

### 1.2 一覧ページ（検索 + テーブル）

```tsx
/**
 * Xxx一覧ページ
 * 検索・一覧表示
 */
import { useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Box,
  Container,
  Typography,
  TextField,
  Button,
  Paper,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Alert,
  CircularProgress,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import AddIcon from '@mui/icons-material/Add';

import { xxxService } from '../services/xxxService';
import type { XxxSearchParams } from '../types/xxx';

const DEFAULT_PAGE_SIZE = 20;

export const XxxListPage = () => {
  const navigate = useNavigate();

  // 検索条件
  const [searchParams, setSearchParams] = useState<XxxSearchParams>({
    page: 1,
    perPage: DEFAULT_PAGE_SIZE,
  });

  // データ取得
  const { data, isLoading, error } = useQuery({
    queryKey: ['xxxList', searchParams],
    queryFn: () => xxxService.getAll(searchParams),
  });

  // 検索実行
  const handleSearch = useCallback(() => {
    setSearchParams((prev) => ({ ...prev, page: 1 }));
  }, []);

  // 新規作成
  const handleCreate = useCallback(() => {
    navigate('/xxx/new');
  }, [navigate]);

  return (
    <Container maxWidth="xl" sx={{ py: 3 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        Xxx一覧
      </Typography>

      {/* 検索フォーム */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
          <TextField label="検索キーワード" size="small" />
          <Button variant="contained" startIcon={<SearchIcon />} onClick={handleSearch}>
            検索
          </Button>
          <Button variant="outlined" startIcon={<AddIcon />} onClick={handleCreate}>
            新規作成
          </Button>
        </Box>
      </Paper>

      {/* エラー表示 */}
      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error instanceof Error ? error.message : 'エラーが発生しました'}
        </Alert>
      )}

      {/* ローディング */}
      {isLoading ? (
        <Box display="flex" justifyContent="center" py={4}>
          <CircularProgress />
        </Box>
      ) : (
        /* 一覧テーブル */
        <Paper>
          {/* テーブルコンポーネント */}
        </Paper>
      )}
    </Container>
  );
};

export default XxxListPage;
```

### 1.3 詳細ページ（フォーム）

```tsx
/**
 * Xxx詳細/編集ページ
 */
import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Container,
  Typography,
  Paper,
  Box,
  TextField,
  Button,
  Alert,
  CircularProgress,
} from '@mui/material';
import SaveIcon from '@mui/icons-material/Save';

import { xxxService } from '../services/xxxService';
import type { Xxx, XxxInput } from '../types/xxx';

export const XxxDetailPage = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const isNew = id === 'new';

  // フォーム状態
  const [formData, setFormData] = useState<XxxInput>({
    name: '',
  });

  // データ取得（編集時のみ）
  const { data, isLoading } = useQuery({
    queryKey: ['xxx', id],
    queryFn: () => xxxService.getById(Number(id)),
    enabled: !isNew && !!id,
  });

  // データをフォームに反映
  useEffect(() => {
    if (data) {
      setFormData({ name: data.name });
    }
  }, [data]);

  // 保存
  const mutation = useMutation({
    mutationFn: (input: XxxInput) =>
      isNew ? xxxService.create(input) : xxxService.update(Number(id), input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['xxxList'] });
      navigate('/xxx');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    mutation.mutate(formData);
  };

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" py={4}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="md" sx={{ py: 3 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        {isNew ? 'Xxx新規作成' : 'Xxx編集'}
      </Typography>

      {mutation.error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {mutation.error instanceof Error ? mutation.error.message : '保存に失敗しました'}
        </Alert>
      )}

      <Paper sx={{ p: 3 }}>
        <Box component="form" onSubmit={handleSubmit}>
          <TextField
            fullWidth
            label="名前"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            required
            sx={{ mb: 2 }}
          />

          <Box sx={{ display: 'flex', gap: 2 }}>
            <Button
              type="submit"
              variant="contained"
              startIcon={<SaveIcon />}
              disabled={mutation.isPending}
            >
              保存
            </Button>
            <Button variant="outlined" onClick={() => navigate('/xxx')}>
              キャンセル
            </Button>
          </Box>
        </Box>
      </Paper>
    </Container>
  );
};

export default XxxDetailPage;
```

---

## 2. APIサービス

### 2.1 クラス形式（推奨）

```typescript
/**
 * XxxAPIクライアント
 * api_schema.md準拠
 */
import { apiClient } from './apiClient';
import type {
  Xxx,
  XxxInput,
  XxxSearchParams,
  XxxListResponse,
  ApiResponse,
} from '../types/xxx';

class XxxService {
  private client = apiClient;

  /**
   * 一覧取得
   */
  async getAll(params: XxxSearchParams = {}): Promise<XxxListResponse> {
    const response = await this.client.get<ApiResponse<XxxListResponse>>(
      '/xxx',
      { params }
    );

    if (response.data.status === 'error' || !response.data.data) {
      throw new Error(response.data.error?.message || '一覧の取得に失敗しました');
    }

    return response.data.data;
  }

  /**
   * 詳細取得
   */
  async getById(id: number): Promise<Xxx> {
    const response = await this.client.get<ApiResponse<Xxx>>(`/xxx/${id}`);

    if (response.data.status === 'error' || !response.data.data) {
      throw new Error(response.data.error?.message || '詳細の取得に失敗しました');
    }

    return response.data.data;
  }

  /**
   * 新規作成
   */
  async create(data: XxxInput): Promise<{ id: number }> {
    const response = await this.client.post<ApiResponse<{ id: number }>>('/xxx', data);

    if (response.data.status === 'error' || !response.data.data) {
      throw new Error(response.data.error?.message || '作成に失敗しました');
    }

    return response.data.data;
  }

  /**
   * 更新
   */
  async update(id: number, data: XxxInput): Promise<void> {
    const response = await this.client.put<ApiResponse<{ id: number }>>(
      `/xxx/${id}`,
      data
    );

    if (response.data.status === 'error') {
      throw new Error(response.data.error?.message || '更新に失敗しました');
    }
  }

  /**
   * 削除
   */
  async delete(id: number): Promise<void> {
    const response = await this.client.delete<ApiResponse<null>>(`/xxx/${id}`);

    if (response.data.status === 'error') {
      throw new Error(response.data.error?.message || '削除に失敗しました');
    }
  }
}

export const xxxService = new XxxService();
export default xxxService;
```

### 2.2 オブジェクト形式（簡易版）

```typescript
/**
 * XxxAPIクライアント（簡易版）
 */
import { apiClient } from './apiClient';
import type { Xxx, XxxInput } from '../types/xxx';

export const xxxService = {
  getAll: () => apiClient.get<{ data: Xxx[] }>('/xxx'),
  getById: (id: number) => apiClient.get<{ data: Xxx }>(`/xxx/${id}`),
  create: (data: XxxInput) => apiClient.post('/xxx', data),
  update: (id: number, data: XxxInput) => apiClient.put(`/xxx/${id}`, data),
  delete: (id: number) => apiClient.delete(`/xxx/${id}`),
};
```

---

## 3. 型定義ファイル

### 3.1 基本構造

```typescript
/**
 * Xxx型定義
 * table_structure.md準拠
 */

// ============================================================
// 定数・ラベル
// ============================================================

export type XxxStatus = 'draft' | 'active' | 'archived';

export const XXX_STATUS_LABELS: Record<XxxStatus, string> = {
  draft: '下書き',
  active: '有効',
  archived: 'アーカイブ',
};

export const XXX_STATUS_COLORS: Record<XxxStatus, 'default' | 'primary' | 'secondary'> = {
  draft: 'default',
  active: 'primary',
  archived: 'secondary',
};

// ============================================================
// エンティティ
// ============================================================

/** Xxx詳細 */
export interface Xxx {
  id: number;
  name: string;
  status: XxxStatus;
  createdAt: string;
  updatedAt: string;
}

/** Xxx一覧アイテム（サブセット） */
export interface XxxListItem {
  id: number;
  name: string;
  status: XxxStatus;
}

// ============================================================
// リクエスト/レスポンス
// ============================================================

/** 検索パラメータ */
export interface XxxSearchParams {
  name?: string;
  status?: XxxStatus;
  page?: number;
  perPage?: number;
}

/** 作成/更新リクエスト */
export interface XxxInput {
  name: string;
  status?: XxxStatus;
}

/** 一覧レスポンス */
export interface XxxListResponse {
  items: XxxListItem[];
  pagination: Pagination;
}

// ============================================================
// 共通型
// ============================================================

/** ページネーション */
export interface Pagination {
  currentPage: number;
  perPage: number;
  totalCount: number;
  totalPages: number;
}

/** API共通レスポンス */
export interface ApiResponse<T> {
  status: 'success' | 'error';
  data: T | null;
  error: ApiError | null;
  meta: {
    timestamp: string;
    requestId: string;
  };
}

/** エラー詳細 */
export interface ApiError {
  code: string;
  message: string;
  details?: Array<{
    field?: string;
    message: string;
  }>;
}
```

---

## 4. NestJSコントローラー

### 4.1 基本CRUD

```typescript
/**
 * Xxxコントローラー
 */
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Query,
  Body,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { v4 as uuidv4 } from 'uuid';
import { Public } from '../auth/decorators/public.decorator';

// モックデータ
const ITEMS = [
  { id: 1, name: 'Item 1', status: 'active' },
  { id: 2, name: 'Item 2', status: 'draft' },
];

@ApiTags('xxx')
@Controller('xxx')
export class XxxController {
  @Get()
  @Public()
  @ApiOperation({ summary: '一覧取得' })
  @ApiQuery({ name: 'name', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'per_page', required: false })
  async findAll(
    @Query('name') name?: string,
    @Query('page') page?: string,
    @Query('per_page') perPage?: string,
  ) {
    let filtered = [...ITEMS];
    if (name) {
      filtered = filtered.filter((i) => i.name.includes(name));
    }

    const pageNum = page ? parseInt(page, 10) : 1;
    const perPageNum = perPage ? parseInt(perPage, 10) : 20;
    const total = filtered.length;
    const paged = filtered.slice((pageNum - 1) * perPageNum, pageNum * perPageNum);

    return {
      status: 'success',
      data: {
        items: paged,
        pagination: {
          current_page: pageNum,
          per_page: perPageNum,
          total_count: total,
          total_pages: Math.ceil(total / perPageNum),
        },
      },
      error: null,
      meta: { timestamp: new Date().toISOString(), request_id: uuidv4() },
    };
  }

  @Get(':id')
  @Public()
  @ApiOperation({ summary: '詳細取得' })
  @ApiParam({ name: 'id', description: 'ID' })
  async findOne(@Param('id', ParseIntPipe) id: number) {
    const item = ITEMS.find((i) => i.id === id);

    if (!item) {
      return {
        status: 'error',
        data: null,
        error: { code: 'E004', message: '見つかりません' },
        meta: { timestamp: new Date().toISOString(), request_id: uuidv4() },
      };
    }

    return {
      status: 'success',
      data: item,
      error: null,
      meta: { timestamp: new Date().toISOString(), request_id: uuidv4() },
    };
  }
}
```

### 4.2 ファイルエクスポート

```typescript
/**
 * エクスポートコントローラー
 */
import { Controller, Get, Query, Res, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiProduces, ApiResponse } from '@nestjs/swagger';
import type { Response } from 'express';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('xxx-export')
@Controller('xxx-export')
export class XxxExportController {
  @Get('excel')
  @Public()
  @ApiOperation({ summary: 'Excelエクスポート' })
  @ApiProduces('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
  @ApiResponse({ status: 200, description: 'ファイルダウンロード成功' })
  async exportExcel(@Res() res: Response) {
    // Excelバッファ生成（exceljs等を使用）
    const buffer = Buffer.from('dummy');
    const contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    const timestamp = new Date().toISOString().replace(/[-:]/g, '').slice(0, 15);
    const filename = `export_${timestamp}.xlsx`;

    res.setHeader('Content-Type', contentType);
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${filename}"; filename*=UTF-8''${encodeURIComponent(filename)}`,
    );
    res.status(HttpStatus.OK).send(buffer);
  }
}
```

---

## 5. カスタムフック

### 5.1 データ取得フック

```typescript
/**
 * Xxxデータ取得フック
 */
import { useQuery } from '@tanstack/react-query';
import { xxxService } from '../services/xxxService';
import type { XxxSearchParams } from '../types/xxx';

export const useXxxList = (params: XxxSearchParams = {}) => {
  return useQuery({
    queryKey: ['xxxList', params],
    queryFn: () => xxxService.getAll(params),
    staleTime: 5 * 60 * 1000, // 5分
  });
};

export const useXxx = (id: number | undefined) => {
  return useQuery({
    queryKey: ['xxx', id],
    queryFn: () => xxxService.getById(id!),
    enabled: !!id,
  });
};
```

### 5.2 ミューテーションフック

```typescript
/**
 * Xxx更新フック
 */
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { xxxService } from '../services/xxxService';
import type { XxxInput } from '../types/xxx';

export const useCreateXxx = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: XxxInput) => xxxService.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['xxxList'] });
    },
  });
};

export const useUpdateXxx = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: XxxInput }) =>
      xxxService.update(id, data),
    onSuccess: (_, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['xxxList'] });
      queryClient.invalidateQueries({ queryKey: ['xxx', id] });
    },
  });
};
```

---

## 使用上の注意

1. **Xxx を実際の名前に置換** - 例: Product, Media, Vendor
2. **型定義は types/ に配置** - サービスからインポート
3. **apiClient を使用** - 認証・エラーハンドリング共通化
4. **@Public() デコレータ** - 認証不要なエンドポイントに付与
5. **uuid で request_id 生成** - API レスポンスに必須
