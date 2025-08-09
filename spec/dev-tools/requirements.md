# 開発ツール機能 要件仕様書

**作成日**: 2025-07-23
**最終更新**: 2025-08-09
**ステータス**: Draft

## 機能概要

開発者の生産性を向上させる各種開発ツール、IDE、エディタ、ターミナル、API開発ツール、コンテナ技術、AI開発ツールなどを選択的にインストールし、最適な開発環境を構築する。

## ユーザーストーリー

### US-DT-001: Visual Studio Codeのセットアップ
**As a** モダンな開発者
**I want** VS Codeと必須拡張機能をインストールする
**So that** 効率的なコード編集環境を構築できる

**受け入れ基準:**
- GIVEN 開発ツール選択メニュー
- WHEN VS Codeを選択
- THEN VS Code最新版がインストールされる
- AND コマンドラインツールが設定される
- AND 推奨拡張機能リストが提供される

### US-DT-002: Dockerのセットアップ
**As a** コンテナ技術を使う開発者
**I want** Docker Desktopをインストールする
**So that** コンテナベースの開発ができる

**受け入れ基準:**
- GIVEN 開発ツール選択メニュー
- WHEN Dockerを選択
- THEN Docker Desktopがインストールされる
- AND docker-composeが利用可能になる
- AND 基本的な設定が適用される

### US-DT-003: ターミナルエミュレータ
**As a** CLI重視の開発者
**I want** 高機能なターミナルをインストールする
**So that** 快適なコマンドライン環境で作業できる

**受け入れ基準:**
- GIVEN ターミナル選択オプション
- WHEN ターミナルを選択
- THEN 選択したターミナルがインストールされる
- AND 基本的な設定とテーマが適用される
- AND シェル統合が設定される

### US-DT-004: API開発ツール
**As a** API開発者
**I want** API開発・テストツールをインストールする
**So that** APIの開発とテストが効率的にできる

**受け入れ基準:**
- GIVEN API開発ツール選択
- WHEN ツールを選択
- THEN Postman/Insomniaがインストールされる
- AND 基本的な設定が適用される

### US-DT-005: Git GUIクライアント
**As a** ビジュアル重視の開発者
**I want** Git GUIクライアントをインストールする
**So that** Gitを視覚的に操作できる

**受け入れ基準:**
- GIVEN Git GUI選択メニュー
- WHEN クライアントを選択
- THEN 選択したGUIツールがインストールされる
- AND 既存のGit設定と統合される

### US-DT-006: ローカルLLM環境
**As a** AIアプリケーション開発者
**I want** LM StudioをインストールしてローカルLLMを実行する
**So that** プライバシーを保ちながらAI開発ができる

**受け入れ基準:**
- GIVEN 開発ツール選択メニュー
- WHEN LM Studioを選択
- THEN LM Studioがインストールされる
- AND ローカルLLMの実行環境が整う

## 機能仕様

### エディタ・IDE

1. **Visual Studio Code**
   - 最新安定版
   - コマンドラインツール統合
   - 設定同期サポート
   - 拡張機能推奨リスト

2. **JetBrains Toolbox**
   - 統合管理ツール
   - ライセンス管理
   - IDE自動更新

3. **Sublime Text**
   - Package Control
   - 基本パッケージ
   - テーマ設定

4. **Vim/Neovim**
   - プラグインマネージャー
   - 基本設定ファイル
   - LSP統合

### コンテナ・仮想化

1. **Docker Desktop**
   - 最新版
   - リソース設定
   - Kubernetes統合
   - docker-compose

2. **Podman Desktop**
   - Docker代替
   - ルートレス動作
   - 互換性レイヤー

3. **仮想マシン**
   - UTM (Apple Silicon)
   - VirtualBox (Intel)
   - Vagrant

### ターミナル

1. **iTerm2**
   - カスタムプロファイル
   - Oh My Zsh統合
   - カラースキーム
   - ホットキー設定

2. **Warp**
   - AI機能統合
   - モダンUI
   - チーム共有機能

3. **Alacritty**
   - GPU高速化
   - 設定ファイル
   - クロスプラットフォーム

### API開発

1. **Postman**
   - ワークスペース設定
   - 環境変数
   - コレクション管理

2. **Insomnia**
   - プラグインサポート
   - GraphQL対応
   - 環境管理

3. **HTTPie**
   - CLI HTTPクライアント
   - シンタックスハイライト

### バージョン管理

1. **Git GUIクライアント**
   - GitHub Desktop
   - SourceTree
   - GitKraken
   - Tower

2. **マージツール**
   - Beyond Compare
   - Kaleidoscope
   - P4Merge

### 開発支援ツール

1. **デバッグツール**
   - Charles Proxy
   - Proxyman
   - LLDB拡張

2. **パフォーマンス分析**
   - Instruments
   - Activity Monitor拡張

3. **ドキュメント**
   - Dash
   - DevDocs Desktop

4. **AI開発ツール**
   - LM Studio（ローカルLLM実行環境）

## 非機能要件

### パフォーマンス要件
- 各ツールは5分以内にインストール完了
- 起動時間は妥当な範囲内
- システムリソースの効率的な使用

### セキュリティ要件
- 公式ソースからのダウンロード
- 署名検証の実施
- プライバシー設定の尊重

### 可用性要件
- オフラインでの基本動作
- アップデート通知機能
- 設定のバックアップ/復元

### 互換性要件
- Apple Silicon最適化
- macOS最新版対応
- 既存ツールとの共存

## 依存関係

### 前提機能
- 基本セットアップ完了
- プログラミング言語環境
- Git設定済み

### 影響を受ける機能
- プロジェクトテンプレート
- CI/CD設定
- チーム共有設定

## 制約事項

1. **ライセンス**
   - 有料ツールのライセンス確認
   - 試用期間の明示
   - オープンソース優先

2. **ディスク容量**
   - Docker Desktopは10GB以上
   - IDEは各2-5GB
   - 仮想マシンイメージ

3. **システム要件**
   - メモリ8GB以上推奨
   - SSD推奨
   - macOS Big Sur以降

## 検証基準

### インストール検証
```bash
# VS Code
code --version

# Docker
docker --version
docker-compose --version

# ターミナル
echo $TERM_PROGRAM
```

### 機能検証
- 各ツールの起動確認
- 基本操作の動作確認
- 統合機能のテスト