# モダンCLIツール機能 要件仕様書

**作成日**: 2025-08-07
**最終更新**: 2025-08-07
**ステータス**: Active

## 機能概要

標準的なUNIXコマンドの代替となる、より使いやすく高機能なモダンCLIツールを提供する。生産性向上と開発効率化を目的として、厳選されたツールセットをインストールする。

## ユーザーストーリー

### US-MC-001: モダンCLIツールの導入
**As a** コマンドライン重視の開発者
**I want** 標準コマンドの高機能な代替ツールを使用する
**So that** 日常的なコマンドライン作業の効率を向上できる

**受け入れ基準:**
- GIVEN 基本セットアップ完了時
- WHEN モダンCLIツールをインストール
- THEN 各ツールが正常に動作する
- AND 既存コマンドとの共存が可能

## 機能仕様

### インストール対象ツール

1. **ファイル・ディレクトリ操作**
   - `bat` - better cat（シンタックスハイライト付き）
   - `eza` - better ls（アイコン・Git統合）
   - `dust` - better du（視覚的なディスク使用量表示）
   - `duf` - better df（見やすいディスク空き容量表示）
   - **注意**: `fd`（better find）は削除済み。標準の`find`コマンドを使用

2. **検索・フィルタリング**
   - `ripgrep` - better grep（高速な正規表現検索）
   - `fzf` - fuzzy finder（インタラクティブなファジー検索）
     - デフォルトコマンド: `find . -type f -not -path "*/\.git/*"`
     - 標準のfindコマンドを使用

3. **プロセス管理**
   - `bottom` - better top（リソースモニター）
   - `procs` - better ps（モダンなプロセス表示）

4. **Git関連**
   - `git-delta` - better diff（見やすい差分表示）
   - `lazygit` - Git TUI（ターミナルUI）

5. **その他のツール**
   - `zoxide` - better cd（スマートなディレクトリ移動）
   - `httpie` - better curl（人間に優しいHTTPクライアント）
   - `tlrc` - simplified man pages（簡潔なマニュアル）

### 設定とエイリアス

```bash
# .zshrc での設定例
# エイリアス設定
alias cat='bat'
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2'
# alias find='fd'  # 削除済み - 標準のfindコマンドを使用
# alias grep='rg'  # 無効化 - 標準grepの動作を保持

# FZF設定
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
```

## 非機能要件

### パフォーマンス要件
- 各ツールは標準コマンドと同等以上の速度
- メモリ使用量は合理的な範囲内
- 起動時間は100ms以内

### 互換性要件
- 標準コマンドとの共存
- パイプラインでの互換性維持
- スクリプトでの使用時は標準コマンドを推奨

### セキュリティ要件
- 公式リポジトリからのインストール
- 既存の権限設定を変更しない

## 依存関係

### 前提条件
- Homebrewがインストール済み
- 基本的なシェル環境が構築済み

### 影響範囲
- シェル設定ファイル（.zshrc）
- FZFを使用する他のツールやスクリプト

## 変更履歴

### 2025-08-07
- fdコマンドを削除（標準のfindコマンドを使用）
- FZFのデフォルトコマンドを標準のfindに変更
- grepエイリアスを無効化（標準grepの動作を保持）