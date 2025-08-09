# モダンCLIツール機能 設計仕様書

**作成日**: 2025-08-07
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

モダンCLIツールは基本セットアップの一部として自動的にインストールされる。各ツールは標準コマンドの代替として動作し、必要に応じてエイリアスで切り替え可能な設計とする。

## 実装設計

### インストール関数（mac-setup-modular.sh内）

```bash
install_basic_tools() {
    log "基本的な開発ツールをインストールしています..."
    
    # 基本ツールのリスト
    local basic_tools=(
        # Git関連
        "gh"                  # GitHub CLI
        
        # 基本的なCLIツール
        "wget"
        "tree"
        "jq"                  # JSON processor
        
        # モダンCLIツール（生産性向上）
        "bat"                 # better cat
        "eza"                 # better ls
        "ripgrep"             # better grep
        "fzf"                 # fuzzy finder
        "zoxide"              # better cd
        "git-delta"           # better diff
        "lazygit"             # Git UI
        "httpie"              # better curl
        "tlrc"                # simplified man pages
        "dust"                # better du
        "duf"                 # better df
        "bottom"              # better top
        "procs"               # better ps
        # 注: fd（better find）は削除済み
        
        # 圧縮・解凍
        "p7zip"
    )
    
    # Brewfileを作成してインストール
    create_brewfile "${basic_tools[@]}"
    brew bundle --file=Brewfile
}
```

### 設定ファイル生成

```bash
create_basic_config() {
    log "基本的な設定ファイルを作成しています..."
    
    # .zshrc の生成/更新
    cat >> ~/.zshrc <<'EOF'
# Modern CLI tool aliases
alias cat='bat'
alias ls='eza --icons'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2'
# findのエイリアスは削除（標準のfindコマンドを使用）
# grepのエイリアスは無効化（標準grepの動作を保持）

# FZF configuration
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# Zoxide initialization
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Git delta configuration
if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
fi
EOF
}
```

## ツール別設定詳細

### FZF（Fuzzy Finder）
- **デフォルトコマンド**: 標準の`find`コマンドを使用
- **除外パターン**: `.git`ディレクトリ
- **表示オプション**: 高さ40%、リバースレイアウト、ボーダー付き

### Eza（Better ls）
- **アイコン表示**: 有効
- **Git統合**: ステータス表示
- **エイリアス**: ls, ll, la, lt

### Bat（Better cat）
- **シンタックスハイライト**: 自動検出
- **行番号**: デフォルトで表示
- **テーマ**: システムデフォルト

### Ripgrep（Better grep）
- **エイリアス**: 無効化（標準grepの動作を保持）
- **使用方法**: `rg`コマンドで直接使用

## エラーハンドリング

```bash
# ツールのインストール確認
verify_modern_cli_tools() {
    local tools=("bat" "eza" "ripgrep" "fzf" "zoxide")
    local missing=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        warning "以下のツールがインストールされていません: ${missing[*]}"
        return 1
    fi
    
    return 0
}
```

## 移行ガイド

### fdコマンドからの移行
```bash
# 以前のfdコマンド使用例
fd pattern

# 標準のfindコマンドでの代替
find . -name "*pattern*" -type f

# FZFとの組み合わせ
find . -type f | fzf
```

### エイリアスの無効化
```bash
# grepエイリアスを一時的に無効化
\grep pattern file.txt

# または
command grep pattern file.txt
```

## テスト項目

1. **インストール確認**
   - 各ツールが正常にインストールされているか
   - バージョン情報が取得できるか

2. **エイリアス動作**
   - 設定されたエイリアスが機能するか
   - 標準コマンドへのフォールバックが可能か

3. **FZF統合**
   - findコマンドとの連携が正常か
   - パフォーマンスに問題がないか

## 注意事項

1. **標準コマンドとの共存**
   - スクリプト内では標準コマンドの使用を推奨
   - エイリアスは対話的シェルでのみ有効

2. **パフォーマンス考慮**
   - 大規模なディレクトリでのfind使用時は適切なオプションを指定
   - 必要に応じて`-maxdepth`などで検索範囲を制限