# 基本セットアップ機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

基本セットアップ機能は、Mac開発環境の基盤を構築する重要なモジュールである。冪等性を保ちながら、既存環境への影響を最小限に抑えつつ、必要なツールを確実にインストールする設計とする。

## 関数設計

### 1. Xcode CLT インストール関数

```bash
install_xcode_cli() {
    local xcode_path
    
    # インストール状態確認
    if xcode-select -p &>/dev/null; then
        log "Xcode Command Line Tools は既にインストールされています"
        return 0
    fi
    
    # インストール実行
    log "Xcode Command Line Tools をインストール中..."
    xcode-select --install &>/dev/null
    
    # インストール完了待機
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    
    log "Xcode Command Line Tools のインストールが完了しました"
}
```

### 2. Homebrew インストール関数

```bash
install_homebrew() {
    # インストール確認
    if command -v brew &>/dev/null; then
        log "Homebrew は既にインストールされています"
        brew update
        return 0
    fi
    
    # 公式インストーラー実行
    log "Homebrew をインストール中..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # PATH設定（アーキテクチャ別）
    if [[ "$ARCH" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}
```

### 3. 基本ツールインストール関数

```bash
install_basic_tools() {
    local tools=(
        "git"           # バージョン管理
        "curl"          # HTTP通信
        "wget"          # ファイルダウンロード
        "tree"          # ディレクトリ表示
        "jq"            # JSON処理
        "gh"            # GitHub CLI
        "htop"          # プロセス監視
        "ncdu"          # ディスク使用量
        "tldr"          # コマンド例
    )
    
    log "基本開発ツールをインストール中..."
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            info "$tool は既にインストールされています"
        else
            log "$tool をインストール中..."
            brew install "$tool" || warning "$tool のインストールに失敗しました"
        fi
    done
}
```

### 4. Oh My Zsh セットアップ関数

```bash
setup_oh_my_zsh() {
    # 既存確認
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh は既にインストールされています"
        return 0
    fi
    
    # .zshrcバックアップ
    if [[ -f "$HOME/.zshrc" ]]; then
        backup_file "$HOME/.zshrc"
    fi
    
    # インストール
    log "Oh My Zsh をインストール中..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Powerlevel10k テーマ
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # プラグインインストール
    install_zsh_plugins
    
    # 設定適用
    configure_zshrc
}
```

### 5. SSH鍵生成関数

```bash
generate_ssh_key() {
    local ssh_key="$HOME/.ssh/id_ed25519"
    
    # 既存確認
    if [[ -f "$ssh_key" ]]; then
        warning "SSH鍵は既に存在します: $ssh_key"
        return 0
    fi
    
    # メールアドレス取得
    read -p "GitHubで使用するメールアドレスを入力してください: " email
    
    # 鍵生成
    log "SSH鍵を生成中..."
    ssh-keygen -t ed25519 -C "$email" -f "$ssh_key" -N ""
    
    # 権限設定
    chmod 600 "$ssh_key"
    chmod 644 "$ssh_key.pub"
    
    # ssh-agent追加
    eval "$(ssh-agent -s)"
    ssh-add "$ssh_key"
    
    # 公開鍵表示
    info "以下の公開鍵をGitHubに登録してください:"
    cat "$ssh_key.pub"
}
```

## データ構造

### 設定テンプレート

```bash
# .zshrc テンプレート
ZSH_CONFIG_TEMPLATE='
# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# プラグイン
plugins=(
    git
    docker
    kubectl
    aws
    terraform
    zsh-autosuggestions
    zsh-syntax-highlighting
    history-substring-search
)

# エイリアス
alias ll="ls -la"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"

# PATH
export PATH="/opt/homebrew/bin:$PATH"

source $ZSH/oh-my-zsh.sh
'

# Git設定テンプレート
GIT_CONFIG_TEMPLATE='
[user]
    name = %NAME%
    email = %EMAIL%
[init]
    defaultBranch = main
[core]
    editor = vim
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
'
```

## エラーハンドリング

### エラーパターンと対処

| エラーパターン | 対処方法 |
|-------------|---------|
| ネットワークエラー | 3回までリトライ、その後スキップ |
| 権限エラー | sudoで再実行を促す |
| 既存ファイル | バックアップ後に上書き |
| コマンド不在 | 依存関係を再確認 |

### バックアップ戦略

```bash
backup_file() {
    local file="$1"
    local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
    
    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        log "バックアップ作成: $backup"
    fi
}
```

## 実装の流れ

### 基本セットアップシーケンス

```
1. システムチェック
   ├── macOSバージョン確認
   ├── アーキテクチャ検出
   └── sudo権限確認

2. Xcode CLTインストール
   ├── インストール状態確認
   ├── インストール実行
   └── 完了待機

3. Homebrewセットアップ
   ├── インストール確認
   ├── インストール実行
   ├── PATH設定
   └── 動作確認

4. 基本ツール群インストール
   ├── ツールリスト定義
   ├── 個別インストール
   └── 検証

5. シェル環境構築
   ├── Oh My Zsh インストール
   ├── テーマ設定
   ├── プラグイン設定
   └── 設定ファイル生成

6. Git/SSH設定
   ├── Git設定
   ├── SSH鍵生成（オプション）
   └── 設定確認
```

## 検証方法

### 単体テスト項目

```bash
# Xcode CLT検証
test_xcode_clt() {
    xcode-select -p && echo "PASS" || echo "FAIL"
}

# Homebrew検証
test_homebrew() {
    brew --version && echo "PASS" || echo "FAIL"
}

# 基本ツール検証
test_basic_tools() {
    local tools=("git" "curl" "wget" "jq")
    for tool in "${tools[@]}"; do
        command -v "$tool" && echo "$tool: PASS" || echo "$tool: FAIL"
    done
}
```

## セキュリティ考慮事項

1. **ファイル権限**
   - SSH鍵: 600
   - 設定ファイル: 644
   - スクリプト: 755

2. **機密情報**
   - パスワードは保存しない
   - トークンは環境変数で管理
   - メールアドレスは対話的に取得

3. **ネットワーク**
   - HTTPS通信のみ使用
   - 公式リポジトリからのみダウンロード