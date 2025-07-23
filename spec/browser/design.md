# ブラウザ機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

ブラウザ機能は、基本セットアップでインストールされるGoogle Chrome以外の追加ブラウザを選択的にインストールする。各ブラウザの特徴を明確に提示し、適切な選択を支援する。

## インターフェース設計

### ブラウザ選択画面

```bash
追加のブラウザを選択してください

注意: Google Chromeは基本セットアップでインストール済みです
注意: Safariは既にmacOSに含まれています
追加でブラウザが必要な場合のみ選択してください

=== 追加ブラウザを選択（複数選択可能ですが、通常は不要） ===
操作方法:
  ↑/↓ または j/k: カーソル移動
  スペース または Enter: 選択/解除
  a: すべて選択  n: すべて解除
  d: 選択完了  q: キャンセル
─────────────────────────────
  [ ] Firefox - プライバシー重視のオープンソースブラウザ
  [ ] Brave - 広告ブロック内蔵のプライバシー重視ブラウザ
  [ ] Arc - 新しいコンセプトのブラウザ（招待制）
  [ ] Safari - macOS標準（既にインストール済み）
```

## 関数設計

### 1. メイン制御関数

```bash
install_browser() {
    log "追加のブラウザを選択してください"
    
    local browsers=()
    local selected=()
    
    # ブラウザリスト定義
    browsers=(
        "firefox:Firefox - プライバシー重視のオープンソースブラウザ"
        "brave:Brave - 広告ブロック内蔵のプライバシー重視ブラウザ"
        "arc:Arc - 新しいコンセプトのブラウザ（招待制）"
        "safari:Safari - macOS標準（既にインストール済み）"
    )
    
    # 注意事項表示
    echo -e "${YELLOW}注意: Google Chromeは基本セットアップでインストール済みです${NC}"
    echo -e "${YELLOW}注意: Safariは既にmacOSに含まれています${NC}"
    echo "追加でブラウザが必要な場合のみ選択してください"
    echo ""
    
    # チェックボックスメニュー
    checkbox_menu browsers selected "追加ブラウザを選択（複数選択可能ですが、通常は不要）"
    
    # 選択されたブラウザをインストール
    for idx in "${selected[@]}"; do
        local browser="${browsers[$idx]%%:*}"
        case "$browser" in
            firefox) install_firefox ;;
            brave) install_brave ;;
            arc) install_arc ;;
            safari) info "Safariは既にインストールされています" ;;
        esac
    done
    
    # インストール後の設定
    [[ ${#selected[@]} -gt 0 ]] && configure_browsers
}
```

### 2. Firefox インストール

```bash
install_firefox() {
    log "Firefoxをインストール中..."
    
    brew install --cask firefox
    
    info "Firefox開発者向け推奨設定:"
    info "1. about:config で以下を設定:"
    info "   - devtools.theme: dark"
    info "   - devtools.chrome.enabled: true"
    info "2. 開発者ツールを F12 で開く"
    info "3. プライバシー設定を「厳格」に設定"
    
    # 開発者向け拡張機能の推奨
    suggest_firefox_extensions
}

suggest_firefox_extensions() {
    info "推奨される開発者向け拡張機能:"
    info "- React Developer Tools"
    info "- Vue.js devtools"
    info "- Redux DevTools"
    info "- uBlock Origin（広告ブロック）"
    info "- Multi-Account Containers"
}
```

### 3. Brave インストール

```bash
install_brave() {
    log "Brave Browserをインストール中..."
    
    brew install --cask brave-browser
    
    info "Brave開発者向け推奨設定:"
    info "1. brave://flags で実験的機能を有効化"
    info "2. Shields設定を確認（広告ブロック）"
    info "3. 開発者モードを有効化"
    info "4. Chrome拡張機能との互換性あり"
}
```

### 4. Arc インストール

```bash
install_arc() {
    log "Arcをインストール中..."
    
    warning "Arcは招待制の可能性があります"
    read -p "インストールを続行しますか？ (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install --cask arc
        
        info "Arc の特徴:"
        info "- スペース機能でプロジェクトを整理"
        info "- 縦型タブバー"
        info "- ブースト機能でサイトをカスタマイズ"
        info "- Command Bar（Cmd+T）で高速ナビゲーション"
    else
        info "Arcのインストールをスキップしました"
    fi
}
```

### 5. ブラウザ設定関数

```bash
configure_browsers() {
    log "ブラウザの共通設定を適用中..."
    
    # デフォルトブラウザの確認
    check_default_browser
    
    # 開発者向け設定の適用
    apply_developer_settings
    
    # ブラウザプロファイルの作成提案
    suggest_browser_profiles
}

check_default_browser() {
    info "デフォルトブラウザの設定:"
    info "システム環境設定 > 一般 > デフォルトのWebブラウザ"
    
    # 現在のデフォルトブラウザを表示
    local default_browser=$(defaults read com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers | grep -B 1 'https' | grep 'LSHandlerRoleAll' -A 1 | tail -1 | cut -d '"' -f 4)
    
    if [[ -n "$default_browser" ]]; then
        info "現在のデフォルトブラウザ: $default_browser"
    fi
}

apply_developer_settings() {
    # 各ブラウザの開発者設定を適用
    
    # Chromeの開発者設定（既にインストール済み）
    if [[ -d "/Applications/Google Chrome.app" ]]; then
        # Chrome開発者フラグの設定
        defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
    fi
}

suggest_browser_profiles() {
    info "ブラウザプロファイルの活用を推奨:"
    info "- 開発用プロファイル（拡張機能あり）"
    info "- テスト用プロファイル（クリーン環境）"
    info "- 個人用プロファイル"
}
```

## エラーハンドリング

```bash
verify_browser_installation() {
    local browser_name=$1
    local app_path=$2
    
    if [[ -d "$app_path" ]]; then
        info "✓ $browser_name が正常にインストールされました"
        return 0
    else
        error "✗ $browser_name のインストールに失敗しました"
        return 1
    fi
}
```

## 統合機能

```bash
setup_browser_sync() {
    info "ブラウザ間の同期オプション:"
    info "1. ブックマークの同期"
    info "2. パスワードマネージャーの統合"
    info "3. 拡張機能の共有（可能な場合）"
}

create_browser_shortcuts() {
    # 各ブラウザへのクイックアクセス設定
    cat >> ~/.zshrc <<'EOF'

# ブラウザエイリアス
alias chrome='open -a "Google Chrome"'
alias firefox='open -a "Firefox"'
alias brave='open -a "Brave Browser"'
alias arc='open -a "Arc"'
alias safari='open -a "Safari"'

# 開発用ブラウザ起動（シークレットモード）
alias chrome-dev='open -a "Google Chrome" --args --incognito'
alias firefox-dev='open -a "Firefox" --args --private-window'
EOF
}
```