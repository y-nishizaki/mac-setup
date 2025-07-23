# エンターテイメント機能 設計仕様書

**作成日**: 2025-01-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

エンターテイメント機能は、メディアプレイヤー、音楽ストリーミング、メディア編集ツールを選択的にインストールする。開発者の用途に応じて、必要なツールのみを選択できる設計とする。

## インターフェース設計

### ツール選択画面

```bash
=== エンターテイメント＆メディアツールを選択 ===
操作方法:
  ↑/↓ または j/k: カーソル移動
  スペース または Enter: 選択/解除
  a: すべて選択  n: すべて解除
  d: 選択完了  q: キャンセル
─────────────────────────────
  [ ] VLC - 万能メディアプレイヤー
  [ ] Spotify - 音楽ストリーミング（無料版）
  [ ] IINA - macOS向けモダンメディアプレイヤー
  [ ] HandBrake - 動画変換ツール
  [ ] Audacity - オーディオ編集
```

## 関数設計

### 1. メイン制御関数

```bash
install_entertainment_tools() {
    local tools=()
    local selected=()
    
    # ツールリスト定義
    tools=(
        "vlc:VLC - 万能メディアプレイヤー"
        "spotify:Spotify - 音楽ストリーミング（無料版）"
        "iina:IINA - macOS向けモダンメディアプレイヤー"
        "handbrake:HandBrake - 動画変換ツール"
        "audacity:Audacity - オーディオ編集"
    )
    
    # チェックボックスメニュー表示
    checkbox_menu tools selected "エンターテイメント＆メディアツールを選択"
    
    # 選択されたツールをインストール
    for idx in "${selected[@]}"; do
        local tool="${tools[$idx]%%:*}"
        case "$tool" in
            vlc) install_vlc ;;
            spotify) install_spotify ;;
            iina) install_iina ;;
            handbrake) install_handbrake ;;
            audacity) install_audacity ;;
        esac
    done
    
    # インストール後の設定
    [[ ${#selected[@]} -gt 0 ]] && configure_media_tools
}
```

### 2. VLC インストール

```bash
install_vlc() {
    log "VLCをインストール中..."
    
    brew install --cask vlc
    
    info "VLCの特徴:"
    info "- ほぼすべての動画・音声形式に対応"
    info "- ネットワークストリーミング対応"
    info "- 動画変換機能内蔵"
    info "- コマンドラインインターフェース利用可能"
    
    # 開発者向け設定
    setup_vlc_developer_settings
}

setup_vlc_developer_settings() {
    info "開発者向けVLC活用:"
    info "1. ストリーミングテスト: メディア > ネットワークストリームを開く"
    info "2. コーデック情報: ツール > コーデック情報"
    info "3. CLI使用: /Applications/VLC.app/Contents/MacOS/VLC --help"
}
```

### 3. Spotify インストール

```bash
install_spotify() {
    log "Spotifyをインストール中..."
    
    brew install --cask spotify
    
    info "Spotify無料版の制限:"
    info "- 広告が再生される"
    info "- オフライン再生不可"
    info "- 高音質再生制限"
    
    # システム設定
    configure_spotify_settings
}

configure_spotify_settings() {
    # メニューバーから起動しないように設定
    defaults write com.spotify.client AutoStartSettingIsHidden -bool false
    
    info "推奨設定:"
    info "- 設定 > 音質 > 自動調整"
    info "- 設定 > プライバシー > プライベートセッション"
}
```

### 4. IINA インストール

```bash
install_iina() {
    log "IINAをインストール中..."
    
    brew install --cask iina
    
    info "IINAの特徴:"
    info "- macOSネイティブデザイン"
    info "- Touch Bar対応"
    info "- Picture-in-Picture機能"
    info "- mpv ベースの高性能再生エンジン"
    
    # ファイル関連付け設定
    suggest_file_associations
}

suggest_file_associations() {
    info "ファイル関連付けの設定:"
    info "1. 動画ファイルを右クリック"
    info "2. 情報を見る > このアプリケーションで開く"
    info "3. IINAを選択 > すべてを変更"
}
```

### 5. HandBrake インストール

```bash
install_handbrake() {
    log "HandBrakeをインストール中..."
    
    brew install --cask handbrake
    
    info "HandBrakeの用途:"
    info "- 動画フォーマット変換"
    info "- 動画圧縮・最適化"
    info "- バッチ処理対応"
    info "- プリセットによる簡単変換"
    
    # 開発者向けプリセット
    create_developer_presets
}

create_developer_presets() {
    info "開発者向け推奨プリセット:"
    info "- Web最適化: MP4, H.264, Web最適化ON"
    info "- デモ動画: 1080p, 30fps, 中品質"
    info "- スクリーンキャスト: H.265, 可変フレームレート"
}
```

### 6. Audacity インストール

```bash
install_audacity() {
    log "Audacityをインストール中..."
    
    brew install --cask audacity
    
    info "Audacityの用途:"
    info "- 音声録音・編集"
    info "- ノイズ除去"
    info "- エフェクト処理"
    info "- 形式変換"
    
    # 初回起動時の設定
    setup_audacity_preferences
}

setup_audacity_preferences() {
    info "推奨初期設定:"
    info "- 品質設定: 44100 Hz, 32-bit float"
    info "- プラグイン: FFmpegライブラリ"
    info "- ショートカット: スペースで再生/停止"
}
```

### 7. 共通設定関数

```bash
configure_media_tools() {
    log "メディアツールの共通設定を適用中..."
    
    # QuickLookプラグインの提案
    suggest_quicklook_plugins
    
    # ファイルタイプ関連付け
    configure_file_associations
    
    # システムオーディオ設定
    check_audio_settings
}

suggest_quicklook_plugins() {
    info "QuickLookプラグインを追加すると便利です:"
    info "brew install --cask qlvideo qlimagesize qlmarkdown"
}

configure_file_associations() {
    info "ファイル関連付けのヒント:"
    info "- duti コマンドでプログラム的に設定可能"
    info "- RCDefaultApp で GUI 設定も可能"
}

check_audio_settings() {
    # 現在のオーディオデバイスを確認
    local audio_device=$(system_profiler SPAudioDataType | grep "Default Output Device" | head -1)
    info "現在のオーディオ出力: $audio_device"
}
```

## エラーハンドリング

```bash
verify_media_tool_installation() {
    local tool_name=$1
    local app_path=$2
    local test_command=$3
    
    if [[ -d "$app_path" ]]; then
        info "✓ $tool_name が正常にインストールされました"
        
        # 追加の検証
        if [[ -n "$test_command" ]]; then
            eval "$test_command" &>/dev/null && \
                info "  動作確認: OK" || \
                warning "  動作確認: 要確認"
        fi
    else
        error "✗ $tool_name のインストールに失敗しました"
    fi
}
```

## 統合機能

```bash
create_media_aliases() {
    # メディアツール用エイリアス
    cat >> ~/.zshrc <<'EOF'

# メディアツールエイリアス
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'
alias play='open -a "IINA"'

# 便利な関数
# 動画情報を表示
vinfo() {
    ffprobe -v quiet -print_format json -show_format -show_streams "$1" | jq .
}

# 音声を抽出
extract-audio() {
    ffmpeg -i "$1" -vn -acodec copy "${1%.*}.m4a"
}
EOF
}
```