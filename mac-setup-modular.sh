#!/bin/bash

# Mac Developer Environment Setup Script - Modular Version
# Version: 3.0
# Last Updated: 2025-01-15
# 
# このスクリプトは新しいMacを開発環境として完全にセットアップします
# 基本的なツールは自動インストール、追加ツールは選択可能です

set -e  # エラーが発生したら即座に終了

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ログ関数
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# プログレスバー関数
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '.'
    printf "] %d%%" $percentage
}

# メニュー表示関数
show_menu() {
    echo -e "\n${CYAN}=== Mac Setup Menu ===${NC}"
    echo "1) 基本セットアップのみ（推奨）"
    echo "2) カスタムセットアップ（オプション選択）"
    echo "3) フルセットアップ（すべてインストール）"
    echo "4) 終了"
    echo -n "選択してください [1-4]: "
}

# チェックボックスメニュー関数
checkbox_menu() {
    local options_var=$1
    local selected_var=$2
    local title=$3
    local current=0
    
    # 配列を変数名経由で参照
    eval "local options=(\"\${${options_var}[@]}\")"
    
    while true; do
        clear
        echo -e "${CYAN}=== $title ===${NC}"
        echo -e "${YELLOW}操作方法:${NC}"
        echo "  ↑/↓ または j/k: カーソル移動"
        echo "  スペース または Enter: 選択/解除"
        echo "  a: すべて選択  n: すべて解除"
        echo "  d: 選択完了  q: キャンセル"
        echo -e "${YELLOW}─────────────────────────────${NC}"
        
        for i in "${!options[@]}"; do
            if [ $i -eq $current ]; then
                echo -n "▶ "
            else
                echo -n "  "
            fi
            
            # 選択状態を確認
            eval "local selected_items=(\"\${${selected_var}[@]}\")"
            local is_selected=false
            for sel in "${selected_items[@]}"; do
                if [[ "$sel" == "$i" ]]; then
                    is_selected=true
                    break
                fi
            done
            
            if $is_selected; then
                echo -e "${GREEN}[✓]${NC} ${options[$i]}"
            else
                echo -e "[ ] ${options[$i]}"
            fi
        done
        
        echo ""
        read -n 1 -s key
        
        case $key in
            q|Q) 
                eval "${selected_var}=()"
                break 
                ;;
            d|D) break ;;
            a|A) 
                local all_selected=()
                for i in "${!options[@]}"; do
                    all_selected+=("$i")
                done
                eval "${selected_var}=(\"\${all_selected[@]}\")"
                ;;
            n|N) 
                eval "${selected_var}=()"
                ;;
            k|K|A) # 上矢印
                ((current > 0)) && ((current--))
                ;;
            j|J|B) # 下矢印
                ((current < ${#options[@]} - 1)) && ((current++))
                ;;
            " "|"") # スペースまたはEnter
                eval "local selected_items=(\"\${${selected_var}[@]}\")"
                local new_selected=()
                local found=false
                
                for sel in "${selected_items[@]}"; do
                    if [[ "$sel" == "$current" ]]; then
                        found=true
                    else
                        new_selected+=("$sel")
                    fi
                done
                
                if ! $found; then
                    new_selected+=("$current")
                fi
                
                eval "${selected_var}=(\"\${new_selected[@]}\")"
                ;;
            [1-9])
                idx=$((key-1))
                if [ $idx -lt ${#options[@]} ]; then
                    current=$idx
                    eval "local selected_items=(\"\${${selected_var}[@]}\")"
                    local new_selected=()
                    local found=false
                    
                    for sel in "${selected_items[@]}"; do
                        if [[ "$sel" == "$idx" ]]; then
                            found=true
                        else
                            new_selected+=("$sel")
                        fi
                    done
                    
                    if ! $found; then
                        new_selected+=("$idx")
                    fi
                    
                    eval "${selected_var}=(\"\${new_selected[@]}\")"
                fi
                ;;
        esac
    done
}

# macOSバージョンチェック
check_macos_version() {
    log "macOSバージョンをチェックしています..."
    
    os_version=$(sw_vers -productVersion)
    major_version=$(echo "$os_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 11 ]; then
        error "macOS 11.0 (Big Sur) 以降が必要です。現在: $os_version"
        exit 1
    fi
    
    info "macOS $os_version を検出しました ✓"
}

# アーキテクチャの検出
detect_architecture() {
    log "システムアーキテクチャを検出しています..."
    
    arch=$(uname -m)
    if [ "$arch" = "arm64" ]; then
        HOMEBREW_PREFIX="/opt/homebrew"
        info "Apple Silicon (M1/M2/M3) を検出しました ✓"
    else
        HOMEBREW_PREFIX="/usr/local"
        info "Intel Mac を検出しました ✓"
    fi
}

# Xcodeコマンドラインツールのインストール
install_xcode_cli() {
    log "Xcode Command Line Toolsをチェックしています..."
    
    if ! xcode-select -p &> /dev/null; then
        info "Xcode Command Line Toolsをインストールしています..."
        xcode-select --install
        
        # インストール完了を待つ
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
    else
        info "Xcode Command Line Tools は既にインストールされています ✓"
    fi
}

# Homebrewのインストール
install_homebrew() {
    log "Homebrewをチェックしています..."
    
    if ! command -v brew &> /dev/null; then
        info "Homebrewをインストールしています..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # パスを設定
        if [ "$arch" = "arm64" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        info "Homebrewは既にインストールされています ✓"
    fi
    
    # Homebrewをアップデート
    log "Homebrewをアップデートしています..."
    brew update
}

# 基本ツールのインストール（誰でも使うもの）
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
        "fd"                  # better find
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
        
        # 圧縮・解凍（macOS標準のunzipでは不十分なもの）
        "p7zip"
    )
    
    # 基本的なGUIアプリ
    local basic_casks=(
        # ターミナル
        "iterm2"
        
        # エディタ
        "visual-studio-code"
        
        # ブラウザ
        "google-chrome"       # 開発者向け標準ブラウザ
        
        # 生産性ツール
        "rectangle"           # ウィンドウ管理
        
        # ユーティリティ
        "the-unarchiver"      # 解凍ツール
    )
    
    # Brewfileを作成
    local brewfile="/tmp/Brewfile.basic"
    {
        echo '# Basic tools'
        for tool in "${basic_tools[@]}"; do
            echo "brew \"$tool\""
        done
        echo ""
        echo '# Basic GUI apps'
        for cask in "${basic_casks[@]}"; do
            echo "cask \"$cask\""
        done
    } > "$brewfile"
    
    info "基本ツールをインストールしています..."
    brew bundle install --file="$brewfile"
    rm -f "$brewfile"
}

# プログラミング言語のオプション
install_programming_languages() {
    local languages=(
        "Node.js (nvm, npm, yarn, pnpm)"
        "Python (pyenv, pip, pipenv)"
        "Go"
        "Rust"
        "Ruby (rbenv)"
        "Java (OpenJDK)"
        "PHP"
        "Kotlin"
        "Swift"
    )
    
    local selected=()
    checkbox_menu "languages" "selected" "プログラミング言語を選択"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) # Node.js
                brew install nvm node yarn pnpm
                ;;
            1) # Python
                brew install python@3.12 pyenv pipenv pipx
                pipx ensurepath
                ;;
            2) # Go
                brew install go
                ;;
            3) # Rust
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                ;;
            4) # Ruby
                brew install rbenv ruby-build
                ;;
            5) # Java
                brew install openjdk
                ;;
            6) # PHP
                brew install php composer
                ;;
            7) # Kotlin
                brew install kotlin
                ;;
            8) # Swift
                # Xcodeに含まれている
                info "SwiftはXcodeに含まれています"
                ;;
        esac
    done
}

# データベースのオプション
install_databases() {
    local databases=(
        "PostgreSQL"
        "MySQL"
        "Redis"
        "MongoDB"
        "SQLite"
        "Elasticsearch"
        "Cassandra"
        "Neo4j"
    )
    
    local selected=()
    checkbox_menu "databases" "selected" "データベースを選択"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) brew install postgresql@16 ;;
            1) brew install mysql ;;
            2) brew install redis ;;
            3) brew tap mongodb/brew && brew install mongodb-community ;;
            4) brew install sqlite ;;
            5) brew install elasticsearch ;;
            6) brew install cassandra ;;
            7) brew install neo4j ;;
        esac
    done
}

# 開発ツールのオプション
install_dev_tools() {
    local tools=(
        "Docker Desktop"
        "Kubernetes (kubectl, minikube, helm)"
        "Terraform"
        "Ansible"
        "AWS CLI"
        "Azure CLI"
        "Google Cloud SDK"
        "Vercel CLI - フロントエンドデプロイ"
        "Supabase CLI - BaaS開発"
        "Render CLI - クラウドプラットフォーム"
        "Claude Code CLI - AI開発支援"
        "Gemini CLI - Google AI"
        "Postman"
        "Insomnia"
        "TablePlus"
        "JetBrains Toolbox"
        "Sublime Text"
    )
    
    local selected=()
    checkbox_menu "tools" "selected" "開発ツールを選択"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) brew install --cask docker ;;
            1) brew install kubectl minikube helm ;;
            2) brew install terraform ;;
            3) brew install ansible ;;
            4) brew install awscli ;;
            5) brew install azure-cli ;;
            6) brew install --cask google-cloud-sdk ;;
            7) npm install -g vercel ;;
            8) npm install -g supabase ;;
            9) npm install -g @render/cli ;;
            10) npm install -g @anthropic/claude-code ;;
            11) npm install -g @google/generative-ai-cli ;;
            12) brew install --cask postman ;;
            13) brew install --cask insomnia ;;
            14) brew install --cask tableplus ;;
            15) brew install --cask jetbrains-toolbox ;;
            16) brew install --cask sublime-text ;;
        esac
    done
}


# 生産性ツールのオプション
install_productivity_tools() {
    while true; do
        clear
        echo -e "${CYAN}=== 生産性＆メディアツール ===${NC}"
        echo "1) 生産性ツール（無料）"
        echo "2) 生産性ツール（有料版あり）"
        echo "3) エンターテイメント＆メディア"
        echo "4) 戻る"
        echo -n "選択してください [1-4]: "
        
        read choice
        case $choice in
            1) install_free_productivity_tools ;;
            2) install_paid_productivity_tools ;;
            3) install_entertainment_tools ;;
            4) break ;;
            *) warning "無効な選択です" ;;
        esac
    done
}

# 無料の生産性ツール
install_free_productivity_tools() {
    local tools=(
        "Raycast - 高機能ランチャー（無料版）"
        "Discord - チャット（無料版）"
        "Slack - ビジネスチャット（無料版）"
        "Obsidian - ノートアプリ（個人利用無料）"
    )
    
    local selected=()
    checkbox_menu "tools" "selected" "無料の生産性ツールを選択"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) brew install --cask raycast ;;
            1) brew install --cask discord ;;
            2) brew install --cask slack ;;
            3) brew install --cask obsidian ;;
        esac
    done
}

# エンターテイメント＆メディアツール
install_entertainment_tools() {
    local tools=(
        "VLC - 万能メディアプレイヤー"
        "Spotify - 音楽ストリーミング（無料版）"
        "IINA - macOS向けモダンメディアプレイヤー"
        "HandBrake - 動画変換ツール"
        "Audacity - オーディオ編集"
    )
    
    local selected=()
    checkbox_menu "tools" "selected" "エンターテイメント＆メディアツールを選択"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) brew install --cask vlc ;;
            1) brew install --cask spotify ;;
            2) brew install --cask iina ;;
            3) brew install --cask handbrake ;;
            4) brew install --cask audacity ;;
        esac
    done
}

# 追加ブラウザの選択（Chromeは基本セットアップに含まれます）
install_browser() {
    log "追加のブラウザを選択してください"
    
    local browsers=(
        "Firefox - プライバシー重視のオープンソースブラウザ"
        "Brave - 広告ブロック内蔵のプライバシー重視ブラウザ"
        "Arc - 新しいコンセプトのブラウザ（招待制）"
        "Safari - macOS標準（既にインストール済み）"
    )
    
    echo -e "${YELLOW}注意: Google Chromeは基本セットアップでインストール済みです${NC}"
    echo -e "${YELLOW}注意: Safariは既にmacOSに含まれています${NC}"
    echo "追加でブラウザが必要な場合のみ選択してください"
    echo ""
    
    local selected=()
    checkbox_menu "browsers" "selected" "追加ブラウザを選択（複数選択可能ですが、通常は不要）"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) brew install --cask firefox ;;
            1) brew install --cask brave-browser ;;
            2) brew install --cask arc ;;
            3) info "Safariは既にインストールされています" ;;
        esac
    done
}

# 有料の生産性ツール（無料版があるものも含む）
install_paid_productivity_tools() {
    local tools=(
        "Alfred - 高機能ランチャー（Powerpackは有料）"
        "1Password - パスワード管理（サブスクリプション）"
        "Notion - オールインワンワークスペース（無料版は制限あり）"
        "Zoom - ビデオ会議（無料版は40分制限）"
        "Spotify - 音楽ストリーミング（無料版は広告あり）"
    )
    
    local selected=()
    checkbox_menu "tools" "selected" "有料の生産性ツールを選択（無料版があるものも含む）"
    
    for idx in "${selected[@]}"; do
        case $idx in
            0) brew install --cask alfred ;;
            1) brew install --cask 1password ;;
            2) brew install --cask notion ;;
            3) brew install --cask zoom ;;
            4) brew install --cask spotify ;;
        esac
    done
}

# Oh My Zshのセットアップ（基本）
setup_oh_my_zsh() {
    log "Oh My Zshをセットアップしています..."
    
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Oh My Zshをインストールしています..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "Oh My Zshは既にインストールされています ✓"
    fi
}

# 基本的な設定ファイルの作成
create_basic_config() {
    log "基本的な設定ファイルを作成しています..."
    
    # 既存ファイルのバックアップ
    for file in .zshrc .gitconfig; do
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$HOME/$file.backup"
            info "$file をバックアップしました → $file.backup"
        fi
    done
    
    # 基本的な.zshrc
    cat > "$HOME/.zshrc" << 'EOF'
# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# Language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor
export EDITOR='vim'
export VISUAL='vim'

# Modern CLI aliases (replacing traditional commands)
alias cat='bat'
alias ls='eza'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2'
alias find='fd'
alias grep='rg'
alias du='dust'
alias df='duf'
alias ps='procs'
alias top='btm'
# Remove cd alias - zoxide will handle it via eval

# Basic aliases
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases  
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Reload
alias reload='source ~/.zshrc'

# Modern CLI tool initialization
# FZF (if installed)
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# Zoxide (better cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Load local config if exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
EOF

    # Git設定の確認と作成
    local git_name git_email current_name current_email update_git
    
    # 既存のGit設定を確認
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        echo -e "${YELLOW}既存のGit設定が見つかりました:${NC}"
        echo "  user.name = $current_name"
        echo "  user.email = $current_email"
        echo ""
        echo -n "この設定を変更しますか？ [y/N]: "
        read update_git
        
        if [[ "$update_git" =~ ^[Yy]$ ]]; then
            echo -n "user.name [$current_name]: "
            read git_name
            git_name=${git_name:-$current_name}
            
            echo -n "user.email [$current_email]: "
            read git_email
            git_email=${git_email:-$current_email}
        else
            git_name="$current_name"
            git_email="$current_email"
            info "既存のGit設定を使用します"
        fi
    else
        echo -n "user.name: "
        read git_name
        echo -n "user.email: "
        read git_email
    fi
    
    cat > "$HOME/.gitconfig" << EOF
[user]
    name = $git_name
    email = $git_email

[core]
    editor = vim
    autocrlf = input

[init]
    defaultBranch = main

[pull]
    rebase = true

[push]
    default = current

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --oneline --graph --decorate

[credential]
    helper = osxkeychain
EOF
}

# macOSシステム設定の最適化
configure_macos_settings() {
    log "macOSシステム設定を最適化しています..."
    
    echo -n "開発者向けのmacOS設定を適用しますか？ [Y/n]: "
    read apply_settings
    
    if [[ ! "$apply_settings" =~ ^[Nn]$ ]]; then
        info "macOS設定を適用中..."
        
        # スリープ設定
        info "スリープ設定を調整中..."
        sudo pmset -c sleep 0                    # AC電源接続時はスリープしない
        sudo pmset -c displaysleep 30            # ディスプレイは30分でスリープ
        sudo pmset -b sleep 15                   # バッテリー時は15分でスリープ
        sudo pmset -b displaysleep 5             # バッテリー時ディスプレイは5分でスリープ
        
        # Dock設定
        info "Dock設定を調整中..."
        defaults write com.apple.dock tilesize -int 40                       # Dockサイズを小さく
        defaults write com.apple.dock minimize-to-application -bool true     # アプリケーションアイコンに最小化
        
        # Dockの自動的に隠す設定（選択制）
        echo -n "Dockを自動的に隠すように設定しますか？ [y/N]: "
        read hide_dock
        if [[ "$hide_dock" =~ ^[Yy]$ ]]; then
            defaults write com.apple.dock autohide -bool true
            info "Dockを自動的に隠すように設定しました"
        else
            info "Dockの表示設定はそのままにします"
        fi
        
        # 最近使用アプリの表示設定（選択制）
        echo -n "Dockで最近使用したアプリを非表示にしますか？ [y/N]: "
        read hide_recents
        if [[ "$hide_recents" =~ ^[Yy]$ ]]; then
            defaults write com.apple.dock show-recents -bool false
            info "最近使用アプリを非表示に設定しました"
        else
            info "最近使用アプリの表示設定はそのままにします"
        fi
        
        # Finder設定
        info "Finder設定を調整中..."
        defaults write com.apple.finder ShowPathbar -bool true               # パスバーを表示
        defaults write com.apple.finder ShowStatusBar -bool true             # ステータスバーを表示
        defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"  # 検索時は現在のフォルダを対象
        defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false # 拡張子変更の警告を無効
        defaults write com.apple.finder AppleShowAllFiles -bool true         # 隠しファイルを表示
        
        # スクリーンショット設定
        info "スクリーンショット設定を調整中..."
        defaults write com.apple.screencapture type -string "png"            # PNG形式で保存
        defaults write com.apple.screencapture disable-shadow -bool true     # 影を無効化
        
        # スクリーンショット保存場所の選択
        echo ""
        echo "スクリーンショットの保存場所を選択してください:"
        echo "1) デスクトップ（現在のmacOSデフォルト）"
        echo "2) ~/Pictures/Screenshots（整理しやすい）"
        echo -n "選択 [1-2, デフォルト: 1]: "
        read screenshot_location
        
        case $screenshot_location in
            2)
                mkdir -p ~/Pictures/Screenshots
                defaults write com.apple.screencapture location ~/Pictures/Screenshots
                info "スクリーンショット保存場所を ~/Pictures/Screenshots に設定しました"
                ;;
            *)
                defaults write com.apple.screencapture location ~/Desktop
                info "スクリーンショット保存場所をデスクトップに設定しました"
                ;;
        esac
        
        # キーボード設定
        info "キーボード設定を調整中..."
        defaults write NSGlobalDomain KeyRepeat -int 2                       # キーリピート速度を最速に
        defaults write NSGlobalDomain InitialKeyRepeat -int 15               # キーリピート開始を早く
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false   # 長押しアクセント文字を無効
        
        # トラックパッド設定
        info "トラックパッド設定を調整中..."
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true # タップでクリック
        defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        
        # メニューバー設定
        info "メニューバー設定を調整中..."
        defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  HH:mm:ss"  # 時計表示を詳細に
        defaults write com.apple.menuextra.clock ShowSeconds -bool true                     # 秒を表示
        defaults write com.apple.menuextra.clock FlashDateSeparators -bool true             # コロンを点滅
        
        # セキュリティ設定
        info "セキュリティ設定を調整中..."
        defaults write com.apple.screensaver askForPassword -int 1           # スクリーンセーバー後パスワード要求
        defaults write com.apple.screensaver askForPasswordDelay -int 0      # 即座にパスワード要求
        
        # 設定の反映
        info "設定を反映中..."
        killall Dock 2>/dev/null || true
        killall Finder 2>/dev/null || true
        killall SystemUIServer 2>/dev/null || true
        
        info "macOS設定の最適化が完了しました ✓"
        warning "一部の設定は再起動後に反映されます"
    else
        info "macOS設定の変更をスキップしました"
    fi
}

# SSH鍵の生成
generate_ssh_key() {
    log "SSH鍵を生成しています..."
    
    if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        local git_email
        git_email=$(git config --global user.email)
        
        ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
        
        # SSH設定
        cat >> "$HOME/.ssh/config" << EOF

Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
        
        # 公開鍵をクリップボードにコピー
        pbcopy < "$HOME/.ssh/id_ed25519.pub"
        
        info "SSH公開鍵がクリップボードにコピーされました"
        info "GitHubの設定ページで追加してください: https://github.com/settings/keys"
    else
        info "SSH鍵は既に存在します ✓"
    fi
}

# 設定・環境構築メニュー
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
            5) 
                setup_oh_my_zsh
                create_basic_config
                generate_ssh_key
                configure_macos_settings
                ;;
            6) break ;;
            *) warning "無効な選択です" ;;
        esac
    done
}

# カスタムセットアップ
custom_setup() {
    while true; do
        clear
        echo -e "${CYAN}=== カスタムセットアップ ===${NC}"
        echo "1) 追加ブラウザ（Chrome/Safari以外が必要な場合）"
        echo "2) プログラミング言語"
        echo "3) データベース"
        echo "4) 開発ツール"
        echo "5) 生産性＆メディアツール"
        echo "6) 設定・環境構築"
        echo "7) メインメニューに戻る"
        echo -n "選択してください [1-7]: "
        
        read choice
        case $choice in
            1) install_browser ;;
            2) install_programming_languages ;;
            3) install_databases ;;
            4) install_dev_tools ;;
            5) install_productivity_tools ;;
            6) setup_environment ;;
            7) break ;;
            *) warning "無効な選択です" ;;
        esac
    done
}

# フルセットアップ
full_setup() {
    log "フルセットアップを開始します..."
    
    # すべてのツールをインストール
    brew install gh git-lfs git-flow tmux \
        bat eza fd ripgrep fzf sd dust duf broot procs bottom zoxide tlrc \
        node nvm python@3.12 pyenv pipenv go rust rbenv ruby-build \
        yarn pnpm postgresql@16 mysql redis sqlite \
        jq yq httpie wget tree ncdu htop neovim ag direnv starship \
        docker docker-compose kubectl minikube helm terraform ansible \
        awscli azure-cli gnupg pinentry-mac openssh openssl mas
    
    brew install --cask iterm2 visual-studio-code sublime-text jetbrains-toolbox \
        docker postman insomnia tableplus sequel-ace mongodb-compass redis-insight \
        rectangle raycast alfred 1password notion obsidian slack discord zoom \
        google-chrome firefox arc brave-browser \
        the-unarchiver appcleaner imageoptim handbrake vlc \
        font-meslo-lg-nerd-font font-fira-code-nerd-font font-jetbrains-mono-nerd-font
    
    # Modern deployment and AI CLIs (npm global packages)
    npm install -g vercel supabase @render/cli @anthropic/claude-code @google/generative-ai-cli
}

# メイン関数
main() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║   Mac Developer Environment Setup v3.0   ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 基本チェック
    check_macos_version
    detect_architecture
    
    # Xcode CLI Tools
    install_xcode_cli
    
    # Homebrew
    install_homebrew
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1)
                log "基本セットアップを開始します..."
                install_basic_tools
                setup_oh_my_zsh
                create_basic_config
                generate_ssh_key
                configure_macos_settings
                info "基本セットアップが完了しました！"
                ;;
            2)
                log "カスタムセットアップを開始します..."
                install_basic_tools
                custom_setup
                info "カスタムセットアップが完了しました！"
                ;;
            3)
                log "フルセットアップを開始します..."
                full_setup
                setup_oh_my_zsh
                create_basic_config
                generate_ssh_key
                configure_macos_settings
                info "フルセットアップが完了しました！"
                ;;
            4)
                info "セットアップを終了します"
                exit 0
                ;;
            *)
                warning "無効な選択です"
                ;;
        esac
        
        echo -e "\n${GREEN}セットアップが完了しました！${NC}"
        echo "続けて他のセットアップを行いますか？"
    done
}

# トラップの設定
trap 'error "エラーが発生しました。スクリプトを終了します。"' ERR

# メイン実行
main "$@"