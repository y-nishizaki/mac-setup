# プログラミング言語機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

プログラミング言語機能は、開発者が必要とする言語環境を選択的にインストールし、バージョン管理を含む包括的な開発環境を構築する。各言語は独立してインストール可能で、相互に干渉しない設計とする。

## インターフェース設計

### チェックボックスメニュー

```bash
=== プログラミング言語の選択 ===
操作方法:
  ↑/↓ または j/k: カーソル移動
  スペース または Enter: 選択/解除
  a: すべて選択  n: すべて解除
  d: 選択完了  q: キャンセル
─────────────────────────────
  [✓] Python 3.11 (pyenv + pipx)
  [ ] Node.js LTS (nvm)
  [ ] Ruby 3.2 (rbenv)
  [ ] Go (最新版)
  [ ] Rust (rustup)
  [ ] Java (OpenJDK)
  [ ] その他の言語
```

## 関数設計

### 1. メイン制御関数

```bash
install_programming_languages() {
    local languages=()
    local selected=()
    
    # 言語リスト定義
    languages=(
        "python:Python 3.11 (pyenv + pipx)"
        "node:Node.js LTS (nvm)"
        "ruby:Ruby 3.2 (rbenv)"
        "go:Go言語"
        "rust:Rust (rustup)"
        "java:Java (OpenJDK)"
        "others:その他の言語"
    )
    
    # チェックボックスメニュー表示
    checkbox_menu languages selected "プログラミング言語の選択"
    
    # 選択された言語をインストール
    for idx in "${selected[@]}"; do
        local lang="${languages[$idx]%%:*}"
        case "$lang" in
            python) install_python ;;
            node) install_nodejs ;;
            ruby) install_ruby ;;
            go) install_go ;;
            rust) install_rust ;;
            java) install_java ;;
            others) install_other_languages ;;
        esac
    done
}
```

### 2. Python環境構築

```bash
install_python() {
    log "Python環境をセットアップ中..."
    
    # pyenvインストール
    if ! command -v pyenv &>/dev/null; then
        brew install pyenv
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
        echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
        echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    fi
    
    # Python 3.11インストール
    local python_version="3.11.7"
    pyenv install -s "$python_version"
    pyenv global "$python_version"
    
    # pipxインストールと設定
    python -m pip install --upgrade pip
    python -m pip install --user pipx
    python -m pipx ensurepath
    
    # 開発ツールインストール
    local tools=(
        "poetry"      # 依存関係管理
        "black"       # コードフォーマッター
        "flake8"      # リンター
        "mypy"        # 型チェッカー
        "pytest"      # テストフレームワーク
        "ipython"     # 拡張REPL
    )
    
    for tool in "${tools[@]}"; do
        pipx install "$tool" || warning "$tool のインストールに失敗しました"
    done
    
    log "Python環境のセットアップが完了しました"
}
```

### 3. Node.js環境構築

```bash
install_nodejs() {
    log "Node.js環境をセットアップ中..."
    
    # nvmインストール
    if ! command -v nvm &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # シェル設定追加
        cat >> ~/.zshrc <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
        
        # 現在のシェルで有効化
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Node.js LTSインストール
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*
    
    # パッケージマネージャー設定
    npm install -g npm@latest
    npm install -g yarn pnpm
    
    # グローバルツール
    local tools=(
        "typescript"     # TypeScript
        "ts-node"       # TypeScript実行環境
        "nodemon"       # 自動再起動
        "pm2"           # プロセスマネージャー
        "eslint"        # リンター
        "prettier"      # フォーマッター
    )
    
    for tool in "${tools[@]}"; do
        npm install -g "$tool" || warning "$tool のインストールに失敗しました"
    done
}
```

### 4. Ruby環境構築

```bash
install_ruby() {
    log "Ruby環境をセットアップ中..."
    
    # 依存関係インストール
    brew install openssl readline libyaml
    
    # rbenvインストール
    if ! command -v rbenv &>/dev/null; then
        brew install rbenv ruby-build
        echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
        eval "$(rbenv init - zsh)"
    fi
    
    # Ruby最新安定版インストール
    local ruby_version="3.2.2"
    rbenv install -s "$ruby_version"
    rbenv global "$ruby_version"
    
    # 基本gem
    gem install bundler
    gem install rubocop
    gem install pry
    gem install rails
}
```

### 5. バージョン管理統合関数

```bash
setup_version_managers() {
    # プロンプトにバージョン情報表示
    cat >> ~/.zshrc <<'EOF'

# プログラミング言語バージョン表示
show_versions() {
    echo "=== 言語バージョン ==="
    command -v python &>/dev/null && echo "Python: $(python --version 2>&1)"
    command -v node &>/dev/null && echo "Node.js: $(node --version)"
    command -v ruby &>/dev/null && echo "Ruby: $(ruby --version)"
    command -v go &>/dev/null && echo "Go: $(go version)"
    command -v rustc &>/dev/null && echo "Rust: $(rustc --version)"
}
EOF
}
```

## データ構造

### 言語設定マッピング

```bash
declare -A LANGUAGE_CONFIG=(
    ["python"]="version=3.11.7,manager=pyenv"
    ["node"]="version=lts,manager=nvm"
    ["ruby"]="version=3.2.2,manager=rbenv"
    ["go"]="version=latest,manager=brew"
    ["rust"]="version=stable,manager=rustup"
)
```

### インストール状態管理

```bash
# インストール済み言語の記録
INSTALLED_LANGUAGES_FILE="$HOME/.mac-setup/installed-languages.txt"

record_language_install() {
    local lang="$1"
    local version="$2"
    echo "$lang:$version:$(date +%Y%m%d)" >> "$INSTALLED_LANGUAGES_FILE"
}
```

## エラーハンドリング

### リトライメカニズム

```bash
install_with_retry() {
    local command="$1"
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if eval "$command"; then
            return 0
        else
            warning "インストール失敗 (試行 $attempt/$max_attempts)"
            ((attempt++))
            sleep 5
        fi
    done
    
    error "インストールに失敗しました: $command"
    return 1
}
```

### 依存関係チェック

```bash
check_language_dependencies() {
    local lang="$1"
    
    case "$lang" in
        python)
            # ビルド依存
            check_or_install "openssl"
            check_or_install "readline"
            check_or_install "sqlite3"
            ;;
        ruby)
            check_or_install "openssl"
            check_or_install "readline"
            check_or_install "libyaml"
            ;;
    esac
}
```

## パフォーマンス最適化

### 並列インストール

```bash
install_languages_parallel() {
    local -a pids=()
    
    for lang in "$@"; do
        install_language_async "$lang" &
        pids+=($!)
    done
    
    # すべての非同期処理を待機
    for pid in "${pids[@]}"; do
        wait "$pid" || warning "言語インストールの一部が失敗しました"
    done
}
```

### キャッシュ活用

```bash
# pyenvビルドキャッシュ
export PYTHON_BUILD_CACHE_PATH="$HOME/.pyenv/cache"

# nvmダウンロードミラー設定（中国など）
export NVM_NODEJS_ORG_MIRROR=https://nodejs.org/dist
```

## セキュリティ考慮事項

1. **ダウンロード検証**
   - 公式ソースからのみダウンロード
   - 可能な限りチェックサム検証

2. **権限管理**
   - グローバルインストールの最小化
   - ユーザー権限での実行

3. **環境分離**
   - 仮想環境の活用推奨
   - プロジェクト別の依存管理