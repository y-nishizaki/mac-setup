# Ultimate Mac Developer Environment Setup Script 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

本プロジェクトは、モジュラー構造のbashスクリプトとして実装される。各機能は独立した関数として実装し、メニューシステムを通じて選択的に実行可能とする。エラーハンドリング、進捗表示、ロギング機能を統合し、ユーザーフレンドリーなセットアップ体験を提供する。

## アーキテクチャ設計

### スクリプト構造

```
mac-setup-modular.sh
├── 初期設定・定数定義
├── ユーティリティ関数群
├── システムチェック関数群
├── インストール関数群
├── 設定関数群
├── メニューシステム
└── メイン実行フロー
```

### 主要コンポーネント

#### 1. ユーティリティ関数
```bash
# ロギング関数
log()         # 一般的なログ出力
error()       # エラーメッセージ出力
warning()     # 警告メッセージ出力
info()        # 情報メッセージ出力

# 進捗表示
show_progress()  # プログレスバー表示

# ファイル操作
backup_file()    # 既存ファイルのバックアップ
```

#### 2. システムチェック関数
```bash
check_macos_version()    # macOSバージョン確認
detect_architecture()    # CPU アーキテクチャ検出
check_sudo_access()     # sudo権限確認
check_internet()        # インターネット接続確認
```

#### 3. インストール関数
```bash
# 基本インストール
install_xcode_cli()      # Xcode CLT
install_homebrew()       # Homebrew
install_basic_tools()    # 必須ツール

# カテゴリ別インストール
install_programming_languages()
install_databases()
install_dev_tools()
install_productivity_tools()
install_entertainment_tools()
```

#### 4. 設定関数
```bash
setup_oh_my_zsh()        # Oh My Zsh設定
configure_macos_settings() # macOS最適化
setup_environment()      # 環境変数設定
generate_ssh_key()       # SSH鍵生成
```

## データ構造

### インストール対象定義
```bash
# 基本ツール配列
BASIC_TOOLS=(
    "git"
    "curl"
    "wget"
    # ...
)

# カテゴリ別ツール配列
PROGRAMMING_LANGUAGES=(
    "python@3.11:Python 3.11"
    "node:Node.js"
    "go:Go言語"
    # ...
)
```

### 選択状態管理
```bash
# 選択されたアイテムのインデックス配列
SELECTED_LANGUAGES=()
SELECTED_DATABASES=()
SELECTED_DEV_TOOLS=()
```

## インターフェース設計

### メニューシステム
1. **メインメニュー**
   - 基本セットアップ
   - カスタムセットアップ
   - フルセットアップ
   - 終了

2. **チェックボックスメニュー**
   - 矢印キーでナビゲーション
   - スペースキーで選択/解除
   - 一括選択/解除機能
   - 選択完了/キャンセル

### コマンドライン引数
```bash
./mac-setup-modular.sh [OPTIONS]
  --basic      基本セットアップを実行
  --full       フルセットアップを実行
  --no-backup  バックアップをスキップ
  --silent     確認プロンプトをスキップ
```

## エラーハンドリング

### エラー処理戦略
1. **set -e** によるエラー時の即座終了
2. **trap** によるクリーンアップ処理
3. コマンド実行結果の検証
4. リトライ機能（ネットワークエラー時）

### エラーコード
```bash
EXIT_SUCCESS=0
EXIT_GENERAL_ERROR=1
EXIT_MACOS_VERSION=2
EXIT_SUDO_REQUIRED=3
EXIT_NETWORK_ERROR=4
EXIT_USER_CANCEL=5
```

## セキュリティ設計

### 権限管理
- sudo実行が必要な操作の最小化
- パスワード入力回数の削減
- 一時ファイルの安全な処理

### バックアップ戦略
```bash
# バックアップファイル命名規則
${original_file}.backup-$(date +%Y%m%d-%H%M%S)
```

## パフォーマンス最適化

### 並列処理
- Homebrew formulaの並列インストール
- 独立したツールの同時セットアップ

### キャッシュ活用
- Homebrewキャッシュの利用
- ダウンロード済みファイルの再利用

## 設定ファイル

### 生成される設定ファイル
1. **~/.zshrc**
   - エイリアス定義
   - PATH設定
   - プロンプト設定

2. **~/.gitconfig**
   - ユーザー情報
   - エイリアス
   - デフォルト設定

3. **~/.ssh/config**
   - SSH設定のテンプレート

## 実装方針

1. **モジュラー設計**
   - 各機能を独立した関数として実装
   - 関数間の依存を最小化

2. **冪等性の確保**
   - 複数回実行しても安全
   - 既存のインストールをスキップ

3. **ユーザーエクスペリエンス**
   - 明確な進捗表示
   - わかりやすいエラーメッセージ
   - インタラクティブな選択UI

4. **拡張性**
   - 新しいツールの追加が容易
   - カスタマイズポイントの提供