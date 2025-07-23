# 開発ツール機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

開発ツール機能は、エディタ、IDE、コンテナ技術、ターミナル、API開発ツールなど、開発者の生産性を向上させるツールを選択的にインストールする。各ツールは独立してインストール可能で、設定の自動化を重視する。

## インターフェース設計

### 開発ツール選択メニュー

```bash
=== 開発ツールの選択 ===
操作方法:
  ↑/↓ または j/k: カーソル移動
  スペース または Enter: 選択/解除
  a: すべて選択  n: すべて解除
  d: 選択完了  q: キャンセル
─────────────────────────────
  [✓] Visual Studio Code
  [ ] Docker Desktop
  [ ] iTerm2
  [ ] Postman
  [ ] Git GUIクライアント
  [ ] その他の開発ツール
```

## 関数設計

### 1. メイン制御関数

```bash
install_dev_tools() {
    local tools=()
    local selected=()
    
    # ツールリスト定義
    tools=(
        "vscode:Visual Studio Code"
        "docker:Docker Desktop"
        "terminal:ターミナルエミュレータ"
        "api:API開発ツール"
        "git-gui:Git GUIクライアント"
        "others:その他の開発ツール"
    )
    
    # チェックボックスメニュー表示
    checkbox_menu tools selected "開発ツールの選択"
    
    # 選択されたツールをインストール
    for idx in "${selected[@]}"; do
        local tool="${tools[$idx]%%:*}"
        case "$tool" in
            vscode) install_vscode ;;
            docker) install_docker ;;
            terminal) install_terminals ;;
            api) install_api_tools ;;
            git-gui) install_git_clients ;;
            others) install_other_dev_tools ;;
        esac
    done
}

### 2. Visual Studio Code インストール

```bash
install_vscode() {
    log "Visual Studio Codeをインストール中..."
    
    # VS Codeインストール
    brew install --cask visual-studio-code
    
    # コマンドラインツール設定
    if [[ -d "/Applications/Visual Studio Code.app" ]]; then
        # PATHに追加
        echo 'export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"' >> ~/.zshrc
    fi
    
    # 基本設定ファイル作成
    mkdir -p ~/Library/Application\ Support/Code/User
    
    # 推奨拡張機能リスト
    cat > ~/.vscode-extensions.txt <<EOF
# 言語サポート
ms-python.python
golang.go
rust-lang.rust-analyzer
ms-vscode.cpptools

# 開発支援
eamodio.gitlens
esbenp.prettier-vscode
dbaeumer.vscode-eslint
EOF
    
    info "推奨拡張機能リストを ~/.vscode-extensions.txt に作成しました"
}

### 3. Docker Desktop インストール

```bash
install_docker() {
    log "Docker Desktopをインストール中..."
    
    # Docker Desktopインストール
    brew install --cask docker
    
    # インストール後の指示
    info "Docker Desktopを起動してセットアップを完了してください"
    info "メモリ割り当ては Settings > Resources で調整できます"
}

### 4. ターミナルエミュレータ

```bash
install_terminals() {
    local terminals=()
    local selected_terminals=()
    
    terminals=(
        "iterm2:iTerm2"
        "warp:Warp"
        "alacritty:Alacritty"
    )
    
    checkbox_menu terminals selected_terminals "ターミナルエミュレータの選択"
    
    for idx in "${selected_terminals[@]}"; do
        local term="${terminals[$idx]%%:*}"
        case "$term" in
            iterm2) install_iterm2 ;;
            warp) brew install --cask warp ;;
            alacritty) install_alacritty ;;
        esac
    done
}

install_iterm2() {
    brew install --cask iterm2
    
    # 基本設定
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false
}

install_alacritty() {
    brew install --cask alacritty
    
    # 設定ファイル作成
    mkdir -p ~/.config/alacritty
    cat > ~/.config/alacritty/alacritty.yml <<EOF
# Alacritty設定
window:
  padding:
    x: 10
    y: 10
  decorations: buttonless

font:
  size: 14

colors:
  primary:
    background: '#1e1e1e'
    foreground: '#d4d4d4'
EOF
}
```

## エラーハンドリング

### インストール失敗時の処理

```bash
install_with_fallback() {
    local cask_name=$1
    local app_name=$2
    
    if ! brew install --cask "$cask_name"; then
        error "$app_name のインストールに失敗しました"
        return 1
    fi
    return 0
}
```