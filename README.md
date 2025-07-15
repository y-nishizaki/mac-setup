# Ultimate Mac Developer Environment Setup Script

新しいMacを完璧な開発環境に変える、モジュラー式の自動セットアップスクリプト 🚀

## 概要

このスクリプトは、新しいMacに開発者向けの環境を自動的に構築します。**バージョン3.0**からは、誰でも使う基本的なツールは自動インストール、人によって必要性が異なるツールは選択可能なモジュラー方式を採用しています。

## 特徴

- 🎯 **モジュラー方式**: 基本ツールは自動、追加ツールは選択可能
- 🏗️ **柔軟性**: 必要なものだけをインストール
- 🔧 **3つのセットアップモード**: 基本/カスタム/フル
- 🍎 **Apple Silicon対応**: M1/M2/M3 Macにも完全対応
- 🔒 **安全**: 既存の設定ファイルは自動的にバックアップ
- 🎨 **インタラクティブUI**: わかりやすいメニューシステム

## セットアップモード

### 1. 基本セットアップ（推奨）
誰でも使う基本的なツールのみをインストール：
- **Git & GitHub CLI**: バージョン管理
- **基本エディタ**: Vim, VS Code
- **基本CLI**: curl, wget, jq, tree
- **モダンCLI**: bat, eza, fd, ripgrep, fzf, zoxide, delta, lazygit等
- **iTerm2**: 高機能ターミナル
- **Google Chrome**: 開発者向け標準ブラウザ
- **Rectangle**: ウィンドウ管理
- **Oh My Zsh**: Zshフレームワーク

### 2. カスタムセットアップ
基本ツールに加えて、以下から必要なものを選択：

#### 追加ブラウザ
- Firefox、Brave、Arc（Chrome、Safariは既にインストール済み）

#### プログラミング言語
- Node.js, Python, Go, Rust, Ruby, Java, PHP, Kotlin, Swift

#### データベース
- PostgreSQL, MySQL, Redis, MongoDB, SQLite, Elasticsearch, Cassandra, Neo4j

#### 開発ツール
- Docker, Kubernetes, Terraform, AWS CLI, Postman, JetBrains Toolbox等

#### 生産性ツール

**無料ツール:**
- Raycast（無料版）、VLC、Discord（無料版）、Slack（無料版）、Obsidian（個人利用無料）

**有料ツール（無料版あり）:**
- Alfred（Powerpackは有料）、1Password（サブスク）、Notion（無料版は制限あり）、Zoom（無料版は40分制限）、Spotify（無料版は広告あり）

### 3. フルセットアップ
すべてのツールを一括インストール（従来の動作）

## 必要条件

- macOS Big Sur (11.0) 以降
- 管理者権限
- インターネット接続
- 約50GBの空きディスク容量

## 使い方

### 方法1: ワンライナーで直接実行（推奨）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-nishizaki/mac-setup/main/mac-setup-modular.sh)
```

### 方法2: クローンして実行

1. リポジトリをクローン:
```bash
git clone https://github.com/y-nishizaki/mac-setup.git
cd mac-setup
```

2. スクリプトに実行権限を付与:
```bash
chmod +x mac-setup-modular.sh
```

3. スクリプトを実行:
```bash
./mac-setup-modular.sh
```

4. メインメニューから選択:
   - **1) 基本セットアップのみ**: 最小限の必須ツールのみ
   - **2) カスタムセットアップ**: 必要なツールを選択してインストール
   - **3) フルセットアップ**: すべてのツールをインストール（従来の全部入りと同等）

### カスタムセットアップでのツール選択方法

カスタムセットアップでは、以下の操作でツールを選択できます：

- **↑/↓ または j/k**: カーソルを上下に移動
- **スペース または Enter**: 現在のアイテムを選択/解除
- **数字キー（1-9）**: 直接その番号のアイテムにジャンプして選択/解除
- **a**: すべてのアイテムを選択
- **n**: すべての選択を解除
- **d**: 選択を確定して次へ進む
- **q**: 選択をキャンセルして前のメニューに戻る

## 実行時間

- **基本セットアップ**: 約10-15分
- **カスタムセットアップ**: 選択内容により15-45分
- **フルセットアップ**: 約60-90分

## カスタマイズ

### モジュラー版のカスタマイズ

`mac-setup-modular.sh`を編集して、ツールのカテゴリや選択肢を追加・変更できます：

- **基本ツール**: `install_basic_tools()`関数
- **言語オプション**: `install_programming_languages()`関数
- **データベース**: `install_databases()`関数
- **開発ツール**: `install_dev_tools()`関数
- **CLIツール**: `install_modern_cli()`関数
- **生産性ツール**: `install_productivity_tools()`関数

## バックアップ

スクリプトは既存の設定ファイルを自動的にバックアップします:
- `.zshrc` → `.zshrc.backup`
- `.gitconfig` → `.gitconfig.backup`
- `.tmux.conf` → `.tmux.conf.backup`

## トラブルシューティング

### Homebrewのインストールが失敗する
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```
を実行してから再度スクリプトを実行してください。

### 特定のアプリケーションのインストールをスキップしたい
スクリプトを編集して、該当する行をコメントアウトしてください。

### エラーで中断した場合
スクリプトは`set -e`を使用しているため、エラーが発生すると停止します。問題を解決してから再実行してください。

## 注意事項

- 基本セットアップは最小限のツールのみをインストールします
- カスタムセットアップでは、必要なツールを慎重に選択してください
- 一部のアプリケーションは手動での追加設定が必要な場合があります
- システム設定の変更には再起動が必要な場合があります

## バージョン履歴

- **v3.0** (2025-01-15): モジュラー方式を採用、基本/カスタム/フルの3モード実装
- **v2.0** (2025-01-15): 包括的な自動セットアップスクリプト
- **v1.0**: 初期バージョン

## ライセンス

MIT License

## 貢献

プルリクエストを歓迎します！新しいツールの追加や改善案がある場合は、ぜひ貢献してください。

## 作者

あなたの名前 (@yourusername)

---

⭐ このプロジェクトが役に立ったら、スターをお願いします！