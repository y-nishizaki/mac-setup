# データベース機能 設計仕様書

**作成日**: 2025-07-23
**関連要件**: [requirements.md](./requirements.md)

## 設計概要

データベース機能は、各種データベースシステムを選択的にインストールし、開発環境に最適化された設定を自動的に適用する。サービス管理、セキュリティ設定、クライアントツールのインストールを統合的に処理する。

## インターフェース設計

### データベース選択メニュー

```bash
=== データベースの選択 ===
操作方法:
  ↑/↓ または j/k: カーソル移動
  スペース または Enter: 選択/解除
  a: すべて選択  n: すべて解除
  d: 選択完了  q: キャンセル
─────────────────────────────
  [✓] PostgreSQL 15
  [ ] MySQL 8.0
  [ ] Redis 7
  [ ] MongoDB 6
  [ ] SQLite
  [ ] データベースGUIクライアント
```

## 関数設計

### 1. メイン制御関数

```bash
install_databases() {
    local databases=()
    local selected=()
    
    # データベースリスト定義
    databases=(
        "postgresql:PostgreSQL 15"
        "mysql:MySQL 8.0"
        "redis:Redis 7"
        "mongodb:MongoDB 6"
        "sqlite:SQLite"
        "clients:データベースGUIクライアント"
    )
    
    # チェックボックスメニュー表示
    checkbox_menu databases selected "データベースの選択"
    
    # 選択されたデータベースをインストール
    for idx in "${selected[@]}"; do
        local db="${databases[$idx]%%:*}"
        case "$db" in
            postgresql) install_postgresql ;;
            mysql) install_mysql ;;
            redis) install_redis ;;
            mongodb) install_mongodb ;;
            sqlite) install_sqlite ;;
            clients) install_db_clients ;;
        esac
    done
    
    # 共通設定の適用
    setup_database_common_config
}
```

### 2. PostgreSQL インストール

```bash
install_postgresql() {
    log "PostgreSQLをインストール中..."
    
    # PostgreSQLインストール
    brew install postgresql@15
    
    # サービス登録
    brew services start postgresql@15
    
    # 初期設定
    if ! psql -U postgres -c '\l' &>/dev/null; then
        createuser -s postgres || true
        createdb postgres || true
    fi
    
    # 開発用設定
    cat > ~/Library/LaunchAgents/postgresql.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>KeepAlive</key>
    <true/>
    <key>Label</key>
    <string>postgresql</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/opt/postgresql@15/bin/postgres</string>
        <string>-D</string>
        <string>/opt/homebrew/var/postgresql@15</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>/opt/homebrew/var/log/postgresql@15.log</string>
    <key>StandardOutPath</key>
    <string>/opt/homebrew/var/log/postgresql@15.log</string>
</dict>
</plist>
EOF
    
    # 環境変数設定
    echo 'export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"' >> ~/.zshrc
    
    # pgcliインストール（拡張CLI）
    pip3 install pgcli || pipx install pgcli
    
    log "PostgreSQLのインストールが完了しました"
}
```

### 3. MySQL インストール

```bash
install_mysql() {
    log "MySQLをインストール中..."
    
    # MySQLインストール
    brew install mysql
    
    # サービス開始
    brew services start mysql
    
    # セキュリティ設定
    log "MySQLの初期設定を行います..."
    
    # 初期パスワード設定スクリプト
    cat > /tmp/mysql_secure_install.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'dev_password';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
    
    mysql -u root < /tmp/mysql_secure_install.sql 2>/dev/null || {
        warning "MySQL初期設定をスキップしました（既に設定済み）"
    }
    rm -f /tmp/mysql_secure_install.sql
    
    # 設定ファイル作成
    mkdir -p ~/.my.cnf.d
    cat > ~/.my.cnf <<EOF
[client]
user = root
password = dev_password
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4
EOF
    chmod 600 ~/.my.cnf
    
    # mycliインストール
    pip3 install mycli || pipx install mycli
    
    log "MySQLのインストールが完了しました"
}
```

### 4. Redis インストール

```bash
install_redis() {
    log "Redisをインストール中..."
    
    # Redisインストール
    brew install redis
    
    # 設定ファイルカスタマイズ
    local redis_conf="/opt/homebrew/etc/redis.conf"
    if [[ -f "$redis_conf" ]]; then
        # バックアップ
        backup_file "$redis_conf"
        
        # 永続化設定
        sed -i '' 's/^# save /save /' "$redis_conf"
        sed -i '' 's/^appendonly no/appendonly yes/' "$redis_conf"
        
        # セキュリティ設定（開発環境用）
        echo "requirepass dev_redis_pass" >> "$redis_conf"
    fi
    
    # サービス開始
    brew services start redis
    
    # 接続確認
    sleep 2
    redis-cli -a dev_redis_pass ping || warning "Redis接続確認に失敗しました"
    
    # エイリアス設定
    echo 'alias redis-cli="redis-cli -a dev_redis_pass"' >> ~/.zshrc
    
    log "Redisのインストールが完了しました"
}
```

### 5. MongoDB インストール

```bash
install_mongodb() {
    log "MongoDBをインストール中..."
    
    # MongoDB tap追加
    brew tap mongodb/brew
    
    # MongoDB Community Editionインストール
    brew install mongodb-community
    
    # データディレクトリ作成
    mkdir -p ~/data/mongodb
    
    # 設定ファイル作成
    cat > /opt/homebrew/etc/mongod.conf <<EOF
systemLog:
  destination: file
  path: /opt/homebrew/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: ~/data/mongodb
net:
  bindIp: 127.0.0.1
  port: 27017
security:
  authorization: disabled  # 開発環境用
EOF
    
    # サービス開始
    brew services start mongodb-community
    
    # mongoshインストール
    brew install mongosh
    
    log "MongoDBのインストールが完了しました"
}
```

### 6. データベースクライアント

```bash
install_db_clients() {
    log "データベースクライアントツールをインストール中..."
    
    local clients=()
    local selected_clients=()
    
    clients=(
        "tableplus:TablePlus (無料版あり)"
        "dbeaver:DBeaver Community Edition"
        "sequel-ace:Sequel Ace (MySQL向け)"
        "postico:Postico 2 (PostgreSQL向け)"
        "db-browser-for-sqlite:DB Browser for SQLite"
        "mongodb-compass:MongoDB Compass"
    )
    
    checkbox_menu clients selected_clients "データベースクライアントの選択"
    
    for idx in "${selected_clients[@]}"; do
        local client="${clients[$idx]%%:*}"
        case "$client" in
            tableplus)
                brew install --cask tableplus
                ;;
            dbeaver)
                brew install --cask dbeaver-community
                ;;
            sequel-ace)
                brew install --cask sequel-ace
                ;;
            postico)
                brew install --cask postico
                ;;
            db-browser-for-sqlite)
                brew install --cask db-browser-for-sqlite
                ;;
            mongodb-compass)
                brew install --cask mongodb-compass
                ;;
        esac
    done
}
```

### 7. 共通設定関数

```bash
setup_database_common_config() {
    # データベース管理スクリプト作成
    cat > ~/bin/db-manager <<'EOF'
#!/bin/bash

case "$1" in
    start)
        brew services start postgresql@15
        brew services start mysql
        brew services start redis
        brew services start mongodb-community
        ;;
    stop)
        brew services stop postgresql@15
        brew services stop mysql
        brew services stop redis
        brew services stop mongodb-community
        ;;
    status)
        brew services list | grep -E "(postgresql|mysql|redis|mongodb)"
        ;;
    *)
        echo "Usage: db-manager {start|stop|status}"
        ;;
esac
EOF
    
    chmod +x ~/bin/db-manager
    
    # 接続情報ファイル作成
    cat > ~/.database-connections.json <<EOF
{
  "postgresql": {
    "host": "localhost",
    "port": 5432,
    "user": "postgres",
    "password": ""
  },
  "mysql": {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "dev_password"
  },
  "redis": {
    "host": "localhost",
    "port": 6379,
    "password": "dev_redis_pass"
  },
  "mongodb": {
    "host": "localhost",
    "port": 27017,
    "auth": false
  }
}
EOF
}
```

## エラーハンドリング

### サービス起動エラー

```bash
start_database_service() {
    local service=$1
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if brew services start "$service"; then
            return 0
        else
            warning "サービス起動失敗 (試行 $attempt/$max_attempts)"
            brew services stop "$service" 2>/dev/null
            sleep 5
            ((attempt++))
        fi
    done
    
    error "$service の起動に失敗しました"
    return 1
}
```

### ポート競合チェック

```bash
check_port_availability() {
    local port=$1
    local service=$2
    
    if lsof -i :$port &>/dev/null; then
        error "ポート $port は既に使用されています ($service)"
        return 1
    fi
    return 0
}
```

## セキュリティ設計

### 開発環境用設定

1. **アクセス制限**
   - localhost/127.0.0.1のみ許可
   - ファイアウォール設定不要

2. **認証設定**
   - 開発用の簡易パスワード
   - 環境変数での管理推奨

3. **データ保護**
   - 自動バックアップは無効
   - 手動バックアップスクリプト提供