# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際のClaude Code (claude.ai/code)へのガイダンスを提供します。

## プロジェクト概要

これは**Ultimate Mac Developer Environment Setup Script** - 新しいMacに完全な開発環境を自動的にセットアップする包括的なbashスクリプトです。

## 主要情報

- **メインスクリプト**: `mac-setup-modular.sh` (約600行)
- **目的**: macOSでの開発ツール、アプリケーション、設定のモジュラー式セットアップ
- **対応環境**: macOS Big Sur (11.0)以降、Apple SiliconとIntelアーキテクチャの両方に対応
- **特徴**: 基本/カスタム/フルの3つのセットアップモードを提供

## コマンド

### スクリプトの実行

```bash
# スクリプトに実行権限を付与
chmod +x mac-setup-modular.sh

# スクリプトを実行
./mac-setup-modular.sh
```

### 変更のテスト

これはシステムセットアップスクリプトなので、テストは慎重に行う必要があります：
- 可能な限りテスト用のMacまたはVMを使用
- 他の部分をコメントアウトして個別の関数をテスト
- 実行前に既存の設定を必ずバックアップ

## アーキテクチャと構造

スクリプトはモジュラー構造で、以下の主要な関数で構成されています：

1. **基本機能**:
   - `check_macos_version()`: macOSバージョンのチェック
   - `detect_architecture()`: Apple Silicon/Intelの検出
   - `install_xcode_cli()`: Xcode CLTのインストール
   - `install_homebrew()`: Homebrewのインストール

2. **インストール関数**:
   - `install_basic_tools()`: 基本ツール（全員必須）
   - `install_programming_languages()`: プログラミング言語（選択式）
   - `install_databases()`: データベース（選択式）
   - `install_dev_tools()`: 開発ツール（選択式）
   - `install_modern_cli()`: モダンCLIツール（選択式）
   - `install_productivity_tools()`: 生産性ツール（選択式）

3. **設定関数**:
   - `setup_oh_my_zsh()`: Oh My Zshのセットアップ
   - `create_basic_config()`: 基本的な設定ファイルの作成
   - `generate_ssh_key()`: SSH鍵の生成

4. **メニューシステム**:
   - `show_menu()`: メインメニュー表示
   - `checkbox_menu()`: チェックボックス選択UI
   - `custom_setup()`: カスタムセットアップのサブメニュー

## 重要な考慮事項

- `set -e`によるエラーハンドリング - コマンドの失敗で実行が停止
- 既存の設定ファイルは`.backup`拡張子でバックアップされる
- GitHubメールアドレスと続行確認の対話的プロンプトが表示される
- アーキテクチャ検出でApple SiliconとIntel Macを異なる方法で処理
- カラー出力とプログレスインジケーターで実行中のフィードバックを提供

## 開発ガイドライン

- 可能な限り冪等性を維持 - スクリプトは複数回実行しても安全であるべき
- 既存の`print_error`関数を使用した一貫性のあるエラーハンドリングパターンを使用
- 出力メッセージには既存のカラースキームに従う
- 新しいツールを追加する前にbrewフォーミュラの利用可能性をテスト
- 設定ファイルは読みやすく、適切にコメントを付ける