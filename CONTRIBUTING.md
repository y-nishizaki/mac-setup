# Contributing to Mac Developer Environment Setup Script

このプロジェクトへの貢献をありがとうございます！以下のガイドラインに従って貢献してください。

## 貢献の方法

### 1. Issues

以下の場合はIssueを作成してください：

- **バグ報告**: スクリプトの動作不良や予期しない結果
- **機能要求**: 新しいツールの追加や機能改善の提案
- **質問**: スクリプトの使用方法に関する質問

#### バグ報告のテンプレート

```
## 環境
- macOS バージョン: 
- アーキテクチャ: (Apple Silicon / Intel)
- 実行したセットアップモード: (基本/カスタム/フル)

## 問題の説明
[問題の詳細な説明]

## 再現手順
1. 
2. 
3. 

## 期待される動作
[期待していた結果]

## 実際の動作
[実際に起こった結果]

## エラーメッセージ
[あれば貼り付け]
```

### 2. Pull Requests

#### 新しいツールの追加

新しいツールを追加する場合：

1. **適切なカテゴリに追加**
   - プログラミング言語: `install_programming_languages()`
   - データベース: `install_databases()`
   - 開発ツール: `install_dev_tools()`
   - 生産性ツール: `install_productivity_tools()`

2. **インストール方法の確認**
   - Homebrew: `brew install package-name`
   - Homebrew Cask: `brew install --cask app-name`
   - npm: `npm install -g package-name`

3. **テスト**
   - 新しいMacまたはクリーンな環境でテスト
   - エラーハンドリングの確認

#### コードスタイル

- **シェルスクリプト**: Bash best practicesに従う
- **関数名**: 動詞_対象 の形式（例: `install_basic_tools`）
- **変数名**: スネークケース（例: `basic_tools`）
- **コメント**: 日本語で説明
- **エラーハンドリング**: 適切な警告メッセージ

#### READMEの更新

新しいツールを追加した場合は、READMEの該当セクションも更新してください。

### 3. 開発環境

#### 必要なもの

- macOS Big Sur (11.0) 以降
- Bash 4.0+（Homebrew推奨）
- テスト用の仮想環境またはクリーンなMac

#### テスト方法

```bash
# スクリプトの構文チェック
bash -n mac-setup-modular.sh

# テスト実行（カスタムセットアップ推奨）
./mac-setup-modular.sh
```

## プルリクエストの流れ

1. **Fork** このリポジトリ
2. **ブランチ作成** (`git checkout -b feature/new-tool`)
3. **変更の実装**
4. **テスト実行**
5. **コミット** (`git commit -m 'feat: Add new tool'`)
6. **プッシュ** (`git push origin feature/new-tool`)
7. **Pull Request作成**

## コミットメッセージ

Conventional Commitsに従ってください：

- `feat:` 新機能
- `fix:` バグ修正
- `docs:` ドキュメントのみの変更
- `style:` コードの動作に影響しない変更
- `refactor:` バグ修正でも新機能でもないコード変更
- `test:` テストの追加や修正
- `chore:` その他の変更

例:
```
feat: Add Claude Code CLI support
fix: Resolve Docker installation issue on Apple Silicon
docs: Update README with new tool descriptions
```

## よくある追加要求

### 新しいツールカテゴリ

現在対応していないツールカテゴリがある場合は、Issueで提案してください。例：

- デザインツール
- 動画編集ツール
- ゲーム開発ツール

### macOS設定

新しいmacOS設定の提案も歓迎します：

- 開発効率向上設定
- セキュリティ設定
- アクセシビリティ設定

## 質問

何か質問がある場合は、Issueを作成するか、プルリクエストでディスカッションしてください。

貢献をお待ちしています！🚀