# データベース機能 要件仕様書

**作成日**: 2025-07-23
**最終更新**: 2025-07-23
**ステータス**: Draft

## 機能概要

開発者が必要とする各種データベースシステムとクライアントツールを選択的にインストールし、開発環境に適した設定を行う。ローカル開発に最適化された構成で、データの永続性とセキュリティを確保する。

## ユーザーストーリー

### US-DB-001: PostgreSQLのセットアップ
**As a** バックエンド開発者
**I want** PostgreSQLとその管理ツールをインストールする
**So that** リレーショナルデータベースを使用した開発ができる

**受け入れ基準:**
- GIVEN データベース選択メニュー
- WHEN PostgreSQLを選択
- THEN PostgreSQL最新安定版がインストールされる
- AND 開発用のデフォルトユーザーが作成される
- AND 自動起動が設定される

### US-DB-002: MySQLのセットアップ
**As a** Web開発者
**I want** MySQLをローカルにインストールする
**So that** LAMP/LEMPスタックの開発ができる

**受け入れ基準:**
- GIVEN データベース選択メニュー
- WHEN MySQLを選択
- THEN MySQL 8.0がインストールされる
- AND rootパスワードが安全に設定される
- AND 文字セットがUTF-8に設定される

### US-DB-003: Redisのセットアップ
**As a** アプリケーション開発者
**I want** Redisをキャッシュ/セッションストアとして使用する
**So that** 高速なデータアクセスが実現できる

**受け入れ基準:**
- GIVEN データベース選択メニュー
- WHEN Redisを選択
- THEN Redis最新版がインストールされる
- AND 永続化設定が有効化される
- AND 基本的なセキュリティ設定が適用される

### US-DB-004: MongoDBのセットアップ
**As a** NoSQL開発者
**I want** MongoDBをインストールする
**So that** ドキュメント指向データベースの開発ができる

**受け入れ基準:**
- GIVEN データベース選択メニュー
- WHEN MongoDBを選択
- THEN MongoDB Community Editionがインストールされる
- AND レプリカセット設定が準備される
- AND 開発用の認証が設定される

### US-DB-005: データベースクライアントツール
**As a** データベース管理者
**I want** GUIクライアントツールをインストールする
**So that** データベースを視覚的に管理できる

**受け入れ基準:**
- GIVEN クライアントツール選択
- WHEN ツールを選択
- THEN 対応するGUIツールがインストールされる
- AND 接続設定が自動的に構成される

## 機能仕様

### データベースシステム

1. **PostgreSQL**
   - バージョン: 15.x (最新安定版)
   - 拡張機能: pgAdmin, psql
   - 設定: 開発向け最適化
   - ポート: 5432

2. **MySQL**
   - バージョン: 8.0.x
   - 管理ツール: MySQL Workbench
   - 設定: UTF-8デフォルト
   - ポート: 3306

3. **Redis**
   - バージョン: 7.x
   - 永続化: AOF有効
   - クライアント: redis-cli
   - ポート: 6379

4. **MongoDB**
   - バージョン: 6.x Community
   - ツール: MongoDB Compass
   - 設定: WiredTigerエンジン
   - ポート: 27017

5. **SQLite**
   - バージョン: 最新
   - ツール: DB Browser for SQLite
   - 用途: 軽量データベース

### クライアントツール

1. **GUIツール**
   - TablePlus (有料/無料版)
   - DBeaver Community Edition
   - Sequel Pro (MySQL専用)
   - Postico (PostgreSQL専用)

2. **CLIツール**
   - mycli (MySQL拡張CLI)
   - pgcli (PostgreSQL拡張CLI)
   - redis-cli
   - mongosh

### 共通設定

1. **セキュリティ**
   - ローカルホストのみからの接続
   - 開発用の緩い権限設定
   - デフォルトパスワードの変更促進

2. **パフォーマンス**
   - 開発環境向けメモリ設定
   - ログレベルの調整
   - 自動バックアップの無効化

3. **データ管理**
   - データディレクトリの統一管理
   - 簡易バックアップスクリプト
   - サンプルデータベースの作成

## 非機能要件

### パフォーマンス要件
- 各データベースは5分以内にインストール完了
- 起動時間は10秒以内
- メモリ使用量は合計2GB以内

### セキュリティ要件
- 本番環境とは異なる開発用設定
- パスワードは環境変数で管理
- 外部からの接続はデフォルトで無効

### 可用性要件
- macOS起動時の自動起動オプション
- クラッシュ時の自動再起動
- ログローテーション設定

### 互換性要件
- Apple Silicon ネイティブ対応
- Rosetta 2での動作保証
- 各言語のORMとの互換性確保

## 依存関係

### 前提機能
- 基本セットアップ完了
- Homebrew インストール済み
- 十分なディスク容量（10GB以上）

### 影響を受ける機能
- プログラミング言語（データベースドライバー）
- 開発ツール（IDE/エディタの接続設定）
- Dockerコンテナとの共存

## 制約事項

1. **リソース制約**
   - 同時起動するデータベース数の制限
   - メモリとCPU使用量の考慮
   - ディスクI/Oの競合回避

2. **ポート競合**
   - デフォルトポートの使用確認
   - Dockerとの競合回避
   - 複数バージョンの共存考慮

3. **データ永続性**
   - アップグレード時のデータ移行
   - バックアップの自己責任

## 検証基準

### インストール検証
```bash
# PostgreSQL
psql --version
pg_isready

# MySQL
mysql --version
mysqladmin ping

# Redis
redis-cli ping

# MongoDB
mongod --version
```

### 接続検証
- 各データベースへのローカル接続確認
- 基本的なCRUD操作の実行
- クライアントツールからの接続確認