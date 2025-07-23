# macOS設定機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

macOS設定機能は、`defaults`コマンドを中心に各種システム設定を自動化する。設定はカテゴリごとに関数化し、選択的に適用可能とする。

## 関数設計

### 1. メイン制御関数

```bash
configure_macos_settings() {
    log "macOS設定を最適化中..."
    
    # 設定適用前の確認
    warning "この操作により既存の設定が変更されます"
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    # カテゴリ別設定
    configure_finder
    configure_dock
    configure_keyboard_trackpad
    configure_security
    configure_developer_settings
    
    # 設定反映
    killall Finder
    killall Dock
    
    log "macOS設定の最適化が完了しました"
}
```

### 2. Finder設定

```bash
configure_finder() {
    log "Finder設定を適用中..."
    
    # 隠しファイル表示
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # 拡張子表示
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # パスバー表示
    defaults write com.apple.finder ShowPathbar -bool true
    
    # ステータスバー表示
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # デフォルトビュー（リスト表示）
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    # .DS_Store無効化（ネットワークドライブ）
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
}
```

### 3. Dock設定

```bash
configure_dock() {
    log "Dock設定を適用中..."
    
    # サイズ設定
    defaults write com.apple.dock tilesize -int 36
    
    # 自動的に隠す
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # 最近使用したアプリ非表示
    defaults write com.apple.dock show-recents -bool false
    
    # 拡大無効
    defaults write com.apple.dock magnification -bool false
}
```

### 4. キーボード・トラックパッド設定

```bash
configure_keyboard_trackpad() {
    log "キーボード・トラックパッド設定を適用中..."
    
    # キーリピート速度
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10
    
    # トラックパッド設定
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # 3本指ドラッグ
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
}
```

### 5. メニューバー時計設定

```bash
configure_menubar_clock() {
    log "メニューバー時計設定を適用中..."
    
    # 秒表示を有効化
    defaults write com.apple.menuextra.clock ShowSeconds -bool true
    
    # コロンを点滅させる
    defaults write com.apple.menuextra.clock FlashDateSeparators -bool true
    
    # 時計を再起動して設定を反映
    killall SystemUIServer
}
```

## エラーハンドリング

```bash
apply_setting_safely() {
    local command="$1"
    local description="$2"
    
    if eval "$command"; then
        info "✓ $description"
    else
        warning "✗ $description の適用に失敗しました"
    fi
}
```

## 設定バックアップ

```bash
backup_macos_settings() {
    local backup_dir="$HOME/.mac-setup/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # 主要な設定をエクスポート
    defaults read com.apple.finder > "$backup_dir/finder.plist"
    defaults read com.apple.dock > "$backup_dir/dock.plist"
    defaults read NSGlobalDomain > "$backup_dir/global.plist"
    
    log "設定をバックアップしました: $backup_dir"
}
```