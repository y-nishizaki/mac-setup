# プログラミング言語機能 要件仕様書

**作成日**: 2025-07-23
**最終更新**: 2025-07-23
**ステータス**: Draft

## 機能概要

開発者が必要とする各種プログラミング言語の実行環境を選択的にインストールし、適切に設定する。バージョン管理ツールを活用し、複数バージョンの共存と切り替えを可能にする。

## ユーザーストーリー

### US-PL-001: Python環境のセットアップ
**As a** Python開発者
**I want** Pythonの最新安定版と仮想環境ツールをインストールする
**So that** Pythonプロジェクトの開発ができる

**受け入れ基準:**
- GIVEN プログラミング言語選択メニュー
- WHEN Pythonを選択
- THEN pyenv経由でPython 3.11以降がインストールされる
- AND pipxで必要なツールがインストールされる
- AND 仮想環境の作成方法が設定される

### US-PL-002: Node.js環境のセットアップ
**As a** JavaScript/TypeScript開発者
**I want** Node.jsとnpmツールチェーンをインストールする
**So that** モダンなWeb開発ができる

**受け入れ基準:**
- GIVEN プログラミング言語選択メニュー
- WHEN Node.jsを選択
- THEN nvm経由でNode.js LTS版がインストールされる
- AND npm, yarn, pnpmが利用可能になる
- AND グローバルツールが適切に設定される

### US-PL-003: Ruby環境のセットアップ
**As a** Ruby開発者
**I want** Rubyと関連ツールをインストールする
**So that** Rails開発やスクリプト作成ができる

**受け入れ基準:**
- GIVEN プログラミング言語選択メニュー
- WHEN Rubyを選択
- THEN rbenv経由で最新安定版がインストールされる
- AND bundlerが自動的にインストールされる
- AND 必要なネイティブ拡張がビルドできる

### US-PL-004: Go言語環境のセットアップ
**As a** Go開発者
**I want** Go言語の開発環境をセットアップする
**So that** Go言語でのシステム開発ができる

**受け入れ基準:**
- GIVEN プログラミング言語選択メニュー
- WHEN Goを選択
- THEN 最新のGo安定版がインストールされる
- AND GOPATHとGO111MODULEが適切に設定される
- AND 基本的な開発ツールが利用可能になる

### US-PL-005: Rust環境のセットアップ
**As a** Rust開発者
**I want** Rustツールチェーンをインストールする
**So that** システムプログラミングができる

**受け入れ基準:**
- GIVEN プログラミング言語選択メニュー
- WHEN Rustを選択
- THEN rustup経由でRustがインストールされる
- AND cargoが利用可能になる
- AND rust-analyzerがインストールされる

## 機能仕様

### サポート言語と管理ツール

1. **Python**
   - バージョン管理: pyenv
   - デフォルトバージョン: 3.11.x (最新)
   - ツール: pipx, poetry, black, flake8, mypy
   - 仮想環境: venv

2. **Node.js**
   - バージョン管理: nvm
   - デフォルトバージョン: LTS (20.x)
   - パッケージマネージャー: npm, yarn, pnpm
   - グローバルツール: typescript, nodemon, pm2

3. **Ruby**
   - バージョン管理: rbenv
   - デフォルトバージョン: 3.2.x (最新安定版)
   - ツール: bundler, rubocop, pry
   - ビルド依存: openssl, readline

4. **Go**
   - インストール方法: Homebrew
   - バージョン: 最新安定版
   - ツール: gopls, golangci-lint
   - 環境変数: GOPATH, GO111MODULE

5. **Rust**
   - バージョン管理: rustup
   - チャンネル: stable
   - ツール: clippy, rustfmt, rust-analyzer
   - ビルドツール: cargo

6. **その他の言語**
   - Java: OpenJDK (Temurin)
   - Kotlin: kotlin compiler
   - Swift: Xcode付属
   - PHP: Homebrew版
   - Perl: システムデフォルト

### 共通設定項目

1. **PATH設定**
   - 各言語のバイナリパスを追加
   - バージョン管理ツールの初期化
   - 優先順位の適切な設定

2. **環境変数**
   - 言語固有の環境変数設定
   - エディタ統合用の変数
   - デバッグ用の設定

3. **シェル統合**
   - 自動補完の設定
   - プロンプトへの情報表示
   - エイリアスの定義

## 非機能要件

### パフォーマンス要件
- 各言語のインストールは10分以内
- バージョン切り替えは1秒以内
- 初回起動のオーバーヘッドを最小化

### セキュリティ要件
- 公式リポジトリからのみインストール
- 署名検証の実施（可能な場合）
- 適切な権限でのインストール

### 可用性要件
- オフラインでのバージョン切り替え
- 部分的な失敗での継続動作
- ロールバック可能な設定

### 互換性要件
- Apple Silicon ネイティブ対応
- Rosetta 2での動作保証
- 既存プロジェクトとの互換性

## 依存関係

### 前提機能
- 基本セットアップ完了
- Homebrew インストール済み
- Xcode CLT インストール済み

### 影響を与える機能
- 開発ツール（エディタ、IDE）
- データベース接続ライブラリ
- プロジェクトテンプレート

## 制約事項

1. **ディスク容量**
   - 各言語で1-5GBの容量が必要
   - 複数バージョンでさらに増加

2. **ビルド時間**
   - 一部の言語はソースからビルドが必要
   - 初回インストールに時間がかかる

3. **システムライブラリ**
   - 一部の言語は追加のシステムライブラリが必要
   - macOSバージョンによる制限

## 検証基準

### インストール検証
```bash
# Python
python --version
pip --version

# Node.js
node --version
npm --version

# Ruby
ruby --version
gem --version

# Go
go version

# Rust
rustc --version
cargo --version
```

### 機能検証
- Hello Worldプログラムの実行
- パッケージマネージャーの動作確認
- IDE/エディタとの統合確認