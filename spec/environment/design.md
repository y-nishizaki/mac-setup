# 環境設定機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

環境設定機能は、シェル環境、設定ファイル、SSH、macOS設定を統合的に管理する。既存設定のバックアップを必須とし、段階的な適用を可能にする設計とする。

## インターフェース設計

### メインメニュー

```bash
=== 設定・環境構築 ===
1) Oh My Zshをセットアップ
2) 基本設定ファイルを作成
3) SSH鍵を生成
4) macOSシステム設定を最適化
5) すべての設定を適用
6) 戻る
選択してください [1-6]: 
```

## 関数設計

### 1. メイン制御関数

```bash
setup_environment() {
    while true; do
        clear
        echo -e "${CYAN}=== 設定・環境構築 ===${NC}"
        echo "1) Oh My Zshをセットアップ"
        echo "2) 基本設定ファイルを作成"
        echo "3) SSH鍵を生成"
        echo "4) macOSシステム設定を最適化"
        echo "5) すべての設定を適用"
        echo "6) 戻る"
        echo -n "選択してください [1-6]: "
        
        read choice
        case $choice in
            1) setup_oh_my_zsh ;;
            2) create_basic_config ;;
            3) generate_ssh_key ;;
            4) configure_macos_settings ;;
            5) apply_all_settings ;;
            6) break ;;
            *) warning "無効な選択です" ;;
        esac
    done
}
```

### 2. Oh My Zsh セットアップ

```bash
setup_oh_my_zsh() {
    log "Oh My Zshをセットアップ中..."
    
    # 既存確認
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        warning "Oh My Zshは既にインストールされています"
        read -p "再インストールしますか？ (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 0
    fi
    
    # .zshrcバックアップ
    backup_config_file "$HOME/.zshrc"
    
    # Oh My Zshインストール
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Powerlevel10kテーマ
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # プラグインインストール
    install_zsh_plugins
    
    # 設定適用
    apply_zsh_config
    
    # フォント案内
    info "Nerd Fontのインストールを推奨します:"
    info "brew install --cask font-meslo-lg-nerd-font"
}

install_zsh_plugins() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$plugin_dir/zsh-autosuggestions"
    
    # zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
        "$plugin_dir/zsh-syntax-highlighting"
    
    # zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-history-substring-search \
        "$plugin_dir/history-substring-search"
}
```

### 3. 設定ファイル作成

```bash
create_basic_config() {
    log "基本設定ファイルを作成中..."
    
    # .zshrc
    create_zshrc
    
    # .gitconfig
    create_gitconfig
    
    # .ssh/config
    create_ssh_config
    
    # その他
    create_optional_configs
}

create_zshrc() {
    backup_config_file "$HOME/.zshrc"
    
    cat > "$HOME/.zshrc" <<'EOF'
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

# PATH設定
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# エイリアス
alias ll="ls -la"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias dc="docker-compose"
alias k="kubectl"

# 環境変数
export EDITOR="vim"
export LANG="ja_JP.UTF-8"

# Oh My Zsh読み込み
source $ZSH/oh-my-zsh.sh

# 追加設定
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
EOF
}

create_gitconfig() {
    if [[ -f "$HOME/.gitconfig" ]]; then
        backup_config_file "$HOME/.gitconfig"
    fi
    
    # ユーザー情報取得
    read -p "Gitで使用する名前を入力してください: " git_name
    read -p "Gitで使用するメールアドレスを入力してください: " git_email
    
    cat > "$HOME/.gitconfig" <<EOF
[user]
    name = $git_name
    email = $git_email
[init]
    defaultBranch = main
[core]
    editor = vim
    autocrlf = input
[pull]
    rebase = false
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    last = log -1 HEAD
    unstage = reset HEAD --
    visual = !gitk
[color]
    ui = auto
EOF
}
```

### 4. SSH鍵生成

```bash
generate_ssh_key() {
    log "SSH鍵を生成します..."
    
    # 既存鍵確認
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        warning "SSH鍵は既に存在します"
        info "既存の公開鍵:"
        cat "$HOME/.ssh/id_ed25519.pub"
        return 0
    fi
    
    # メール取得
    read -p "SSH鍵に関連付けるメールアドレス: " ssh_email
    
    # 鍵生成
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""
    
    # 権限設定
    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/id_ed25519"
    chmod 644 "$HOME/.ssh/id_ed25519.pub"
    
    # ssh-agent設定
    setup_ssh_agent
    
    # 公開鍵表示
    info "公開鍵が生成されました:"
    cat "$HOME/.ssh/id_ed25519.pub"
    info "この鍵をGitHub/GitLab等に登録してください"
}

setup_ssh_agent() {
    # ssh-agent自動起動設定
    cat >> "$HOME/.zshrc" <<'EOF'

# SSH Agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
EOF
}
```

### 5. macOS設定最適化

```bash
configure_macos_settings() {
    log "macOSシステム設定を最適化しています..."
    
    warning "この操作はシステム設定を変更します"
    read -p "続行しますか？ [y/N]: " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && return 0
    
    # スリープ設定
    configure_power_settings
    
    # Dock設定
    configure_dock_settings
    
    # Finder設定
    configure_finder_settings
    
    # その他の開発者設定
    configure_developer_settings
    
    # 設定反映
    killall Finder
    killall Dock
}

configure_power_settings() {
    info "電源管理設定を調整中..."
    sudo pmset -c sleep 0              # AC電源時スリープなし
    sudo pmset -c displaysleep 30      # ディスプレイ30分
    sudo pmset -b sleep 15             # バッテリー時15分
    sudo pmset -b displaysleep 5       # バッテリー時ディスプレイ5分
}
```

## バックアップ機能

```bash
backup_config_file() {
    local file="$1"
    local backup_dir="$HOME/.mac-setup/backups/$(date +%Y%m%d)"
    
    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        local filename=$(basename "$file")
        local backup_file="$backup_dir/${filename}.$(date +%H%M%S)"
        cp "$file" "$backup_file"
        info "バックアップ作成: $backup_file"
    fi
}

restore_config_file() {
    local file="$1"
    local backup_dir="$HOME/.mac-setup/backups"
    
    # 最新のバックアップを検索
    local latest_backup=$(find "$backup_dir" -name "$(basename $file).*" -type f | sort -r | head -1)
    
    if [[ -n "$latest_backup" ]]; then
        cp "$latest_backup" "$file"
        info "設定を復元しました: $file"
    else
        error "バックアップが見つかりません: $file"
    fi
}
```

## エラーハンドリング

```bash
apply_setting_with_check() {
    local command="$1"
    local description="$2"
    local require_sudo="$3"
    
    if [[ "$require_sudo" == "true" ]]; then
        if sudo -n true 2>/dev/null; then
            eval "sudo $command"
        else
            warning "管理者権限が必要です: $description"
            return 1
        fi
    else
        eval "$command"
    fi
    
    if [[ $? -eq 0 ]]; then
        info "✓ $description"
    else
        error "✗ $description の適用に失敗しました"
    fi
}
```