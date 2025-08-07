# 変更履歴

このファイルは、mac-setup-modular.shスクリプトとそのスペックの重要な変更を記録します。

## [Unreleased]

### 2025-08-07

#### 削除
- `fd`コマンド（better find）を基本ツールリストから削除
  - 理由: 標準の`find`コマンドで十分な機能を提供できるため
  - 影響: FZFは標準の`find`コマンドを使用するように設定変更

#### 変更
- FZFのデフォルトコマンドを標準の`find`コマンドに変更
  - 旧: `fd`を使用
  - 新: `find . -type f -not -path "*/\.git/*"`
- `.zshrc`から`find`のエイリアス設定を削除
- `grep`のエイリアスを無効化（標準grepの動作を保持）

#### 追加
- `spec/modern-cli/`ディレクトリとスペックドキュメントを新規作成
  - requirements.md: モダンCLIツールの要件定義
  - design.md: 実装設計と設定詳細
  - tasks.md: 実装タスクと変更履歴

### 2025-07-23

#### 追加
- スペック駆動開発システムの導入
- `spec/`ディレクトリ構造の作成
- 基本的なスペックドキュメントの作成

## 移行ガイド

### fdコマンドからの移行

以前`fd`コマンドを使用していた場合は、以下の方法で標準の`find`コマンドに移行してください：

```bash
# fdでの検索
fd pattern

# findでの代替
find . -name "*pattern*" -type f

# より高度な検索
find . -type f -name "*.txt" -not -path "*/node_modules/*"

# FZFとの組み合わせ
find . -type f | fzf
```

### パフォーマンスの考慮

大規模なディレクトリで`find`を使用する場合：
- `-maxdepth`オプションで検索深度を制限
- `-prune`オプションで特定のディレクトリを除外
- 必要に応じて`locate`コマンドの使用を検討