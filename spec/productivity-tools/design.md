# 生産性ツール機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

生産性ツール機能は、無料ツールと有料ツール（試用版含む）を分けて提示し、ユーザーが必要なツールを選択的にインストールできる設計とする。各ツールの特徴と制限を明確に表示する。

## インターフェース設計

### メインメニュー

```bash
=== 生産性＆メディアツール ===
1) 生産性ツール（無料）
2) 生産性ツール（有料版あり）
3) エンターテイメント＆メディア
4) 戻る
選択してください [1-4]: 
```

## 関数設計

### 1. メイン制御関数

```bash
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
```

### 2. 無料生産性ツール

```bash
install_free_productivity_tools() {
    local tools=()
    local selected=()
    
    tools=(
        "raycast:Raycast - 高機能ランチャー"
        "rectangle:Rectangle - ウィンドウ管理"
        "maccy:Maccy - クリップボード履歴"
        "discord:Discord - チャット（無料版）"
        "slack:Slack - ビジネスチャット（無料版）"
        "obsidian:Obsidian - ノートアプリ（個人利用無料）"
        "shottr:Shottr - スクリーンショット"
        "hiddenbar:Hidden Bar - メニューバー管理"
    )
    
    checkbox_menu tools selected "無料の生産性ツールを選択"
    
    for idx in "${selected[@]}"; do
        local tool="${tools[$idx]%%:*}"
        case "$tool" in
            raycast) install_raycast ;;
            rectangle) brew install --cask rectangle ;;
            maccy) brew install --cask maccy ;;
            discord) brew install --cask discord ;;
            slack) brew install --cask slack ;;
            obsidian) install_obsidian ;;
            shottr) brew install --cask shottr ;;
            hiddenbar) brew install --cask hiddenbar ;;
        esac
    done
}
```

### 3. 有料生産性ツール

```bash
install_paid_productivity_tools() {
    local tools=()
    local selected=()
    
    tools=(
        "alfred:Alfred - 高機能ランチャー（Powerpack有料）"
        "1password:1Password - パスワード管理（サブスク）"
        "notion:Notion - ワークスペース（無料版制限あり）"
        "zoom:Zoom - ビデオ会議（無料版40分制限）"
        "cleanshot:CleanShot X - プロ向けスクリーンショット"
        "paste:Paste - 高機能クリップボード"
        "bartender:Bartender - メニューバー管理"
    )
    
    checkbox_menu tools selected "有料の生産性ツールを選択"
    
    warning "これらのツールは有料版があります。無料試用版から始めることができます。"
    
    for idx in "${selected[@]}"; do
        local tool="${tools[$idx]%%:*}"
        case "$tool" in
            alfred) install_alfred ;;
            1password) install_1password ;;
            notion) brew install --cask notion ;;
            zoom) brew install --cask zoom ;;
            cleanshot) brew install --cask cleanshot ;;
            paste) brew install --cask paste ;;
            bartender) brew install --cask bartender ;;
        esac
    done
}
```

### 4. 個別インストール関数

```bash
install_raycast() {
    log "Raycastをインストール中..."
    brew install --cask raycast
    
    # 基本設定
    info "Raycastの推奨設定:"
    info "1. ホットキーを Cmd+Space に設定"
    info "2. Spotlightのホットキーを無効化"
    info "3. 拡張機能ストアから必要な機能を追加"
}

install_obsidian() {
    log "Obsidianをインストール中..."
    brew install --cask obsidian
    
    # Vault設定の案内
    info "Obsidianの初期設定:"
    info "1. ~/Documents/ObsidianVault を作成することを推奨"
    info "2. iCloud同期またはObsidian Syncを検討"
    info "3. コミュニティプラグインを探索"
}

install_alfred() {
    log "Alfredをインストール中..."
    brew install --cask alfred
    
    warning "Alfred Powerpack（有料）で以下の機能が使えます:"
    info "- ワークフロー作成"
    info "- クリップボード履歴"
    info "- スニペット展開"
    info "- ファイル操作の拡張"
}

install_1password() {
    log "1Passwordをインストール中..."
    brew install --cask 1password
    brew install --cask 1password-cli
    
    info "1Passwordセットアップ:"
    info "1. アカウントを作成または既存アカウントでサインイン"
    info "2. ブラウザ拡張機能をインストール"
    info "3. SSH鍵管理機能を有効化（開発者向け）"
}
```

### 5. 設定適用関数

```bash
configure_productivity_tools() {
    # Raycast設定
    if [[ -d "/Applications/Raycast.app" ]]; then
        # Spotlight無効化の提案
        info "Spotlightのホットキーを無効化することを推奨します"
        info "システム環境設定 > キーボード > ショートカット > Spotlight"
    fi
    
    # Rectangle設定
    if [[ -d "/Applications/Rectangle.app" ]]; then
        defaults write com.knollsoft.Rectangle launchOnLogin -bool true
    fi
    
    # Maccy設定
    if [[ -d "/Applications/Maccy.app" ]]; then
        defaults write org.p0deje.Maccy historySize -int 200
        defaults write org.p0deje.Maccy showInStatusBar -bool true
    fi
}
```

## エラーハンドリング

```bash
install_with_license_check() {
    local app_name=$1
    local cask_name=$2
    local license_info=$3
    
    warning "$app_name は有料ライセンスが必要です"
    info "$license_info"
    
    read -p "インストールを続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install --cask "$cask_name"
    else
        info "$app_name のインストールをスキップしました"
    fi
}
```

## 統合機能

```bash
setup_productivity_integrations() {
    # アプリ間の連携設定
    
    # Alfred + 1Password
    if [[ -d "/Applications/Alfred 5.app" ]] && [[ -d "/Applications/1Password 7.app" ]]; then
        info "Alfred と 1Password の連携が可能です"
        info "Alfred Preferences > Features > 1Password で設定"
    fi
    
    # Raycast + その他のツール
    if [[ -d "/Applications/Raycast.app" ]]; then
        info "Raycast Extensions をインストールして機能を拡張できます"
    fi
}
```

## 設定のバックアップ

```bash
backup_productivity_settings() {
    local backup_dir="$HOME/.mac-setup/productivity-backups"
    mkdir -p "$backup_dir"
    
    # 各アプリの設定をバックアップ
    [[ -f "$HOME/Library/Preferences/com.raycast.macos.plist" ]] && \
        cp "$HOME/Library/Preferences/com.raycast.macos.plist" "$backup_dir/"
    
    [[ -f "$HOME/Library/Preferences/com.knollsoft.Rectangle.plist" ]] && \
        cp "$HOME/Library/Preferences/com.knollsoft.Rectangle.plist" "$backup_dir/"
    
    log "生産性ツールの設定をバックアップしました: $backup_dir"
}
```