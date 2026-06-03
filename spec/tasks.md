# Ultimate Mac Developer Environment Setup Script 実装タスク

**関連仕様**: [requirements.md](./requirements.md) | [design.md](./design.md)
**最終更新**: 2026-06-03

## プロジェクト全体進捗

### 完了済みタスク ✅
- [x] 基本スクリプト構造の実装
- [x] メニューシステムの実装
- [x] 基本インストール機能の実装
- [x] カスタムセットアップ機能の実装

### 進行中タスク 🚧
- [ ] スペック駆動開発ドキュメントの整備
- [x] テストフレームワークの導入（bats 関数単位テスト 14 件、CI 統合）

### 未着手タスク 📋
- [x] エラーハンドリングの強化（`set -euo pipefail` + ERR trap + ログ保存 + state/resume）
- [ ] パフォーマンス最適化
- [x] CI/CDパイプラインの構築（shellcheck warning fail + bats を `.github/workflows/test.yml` に統合）

## Phase 1: ドキュメント整備 (Current)

### スペック文書作成
- [x] spec/requirements.md - 全体要件仕様書
- [x] spec/design.md - 全体設計仕様書
- [x] spec/tasks.md - 全体タスク管理
- [ ] spec/architecture.md - システムアーキテクチャ
- [ ] 各機能フォルダのrequirements.md
- [ ] 各機能フォルダのdesign.md
- [ ] 各機能フォルダのtasks.md

### 機能別ドキュメント優先順位
1. [x] basic-setup/ - 基本セットアップ機能
2. [ ] programming-languages/ - プログラミング言語
3. [ ] dev-tools/ - 開発ツール
4. [ ] macos-settings/ - macOS設定
5. [ ] databases/ - データベース
6. [ ] productivity-tools/ - 生産性ツール
7. [ ] environment/ - 環境設定
8. [ ] browser/ - ブラウザ
9. [ ] entertainment/ - エンターテイメント
10. [x] modern-cli/ - モダンCLIツール (新規追加)

## Phase 2: テスト基盤構築

### テストフレームワーク導入
- [x] batsテストフレームワークの導入（`tests/helpers.bats`）
- [x] テストディレクトリ構造の作成（`tests/`）
- [x] テスト実行スクリプトの作成（`bats tests/`）
- [x] GitHub Actionsでのテスト自動化（`bats` ジョブを追加）

### ユニットテスト作成
- [x] ユーティリティ関数のテスト（brew 冪等ヘルパー / state 永続化 / parse_args）
- [ ] システムチェック関数のテスト
- [x] インストール関数のモックテスト（`brew` スタブで brew_install_if_missing / brew_tap_if_missing を検証）
- [ ] メニューシステムのテスト（対話的なため未対応）

## Phase 3: 機能改善

### エラーハンドリング強化
- [ ] リトライメカニズムの実装
- [x] 詳細なエラーログの実装（`~/Library/Logs/mac-setup-YYYYMMDD.log` へ tee、ERR trap で失敗行を明示）
- [ ] ロールバック機能の追加
- [ ] エラー通知システムの統合
- [x] Homebrew 冪等ヘルパー導入（brew_install_if_missing / brew_install_cask_if_missing / brew_tap_if_missing で再実行安全性を確保）

### パフォーマンス最適化
- [ ] 並列インストールの実装
- [ ] キャッシュシステムの改善
- [ ] 依存関係の最適化
- [ ] プログレス表示の改善

### ユーザビリティ向上
- [ ] 設定プロファイルのサポート
- [x] ドライランモードの実装（`--dry-run` で副作用なく実行予定を表示）
- [x] 詳細ログ出力オプション（全出力をログファイルへ tee）
- [x] インストール済みツールの検出改善（brew 冪等ヘルパー）
- [x] 失敗時 resume / state 永続化（`--resume` + `~/.mac-setup-state.json` に各ステップの success/failed を記録）

## Phase 4: 品質保証

### 統合テスト
- [ ] 基本セットアップの統合テスト
- [ ] カスタムセットアップの統合テスト
- [ ] フルセットアップの統合テスト
- [ ] エラーケースのテスト

### ドキュメント改善
- [ ] README.mdの更新
- [ ] トラブルシューティングガイド
- [ ] 貢献者ガイドライン
- [ ] 変更履歴の整備

## Phase 5: 運用準備

### リリース準備
- [ ] バージョニング戦略の決定
- [ ] リリースノートテンプレート
- [ ] 自動リリースワークフロー
- [ ] アップデート通知機能

### 監視・分析
- [ ] 使用統計の収集（オプトイン）
- [ ] エラーレポートシステム
- [ ] パフォーマンスメトリクス
- [ ] ユーザーフィードバック収集

## 優先度マトリクス

| タスク | 重要度 | 緊急度 | 推定工数 |
|--------|--------|--------|----------|
| スペック文書完成 | 高 | 高 | 4h |
| テスト基盤構築 | 高 | 中 | 8h |
| エラーハンドリング | 高 | 中 | 6h |
| パフォーマンス最適化 | 中 | 低 | 12h |
| ドキュメント改善 | 中 | 中 | 4h |

## 最近の更新

### 2026-06-03
- [x] Homebrew 冪等ヘルパー（`brew_install_if_missing` / `brew_install_cask_if_missing` / `brew_tap_if_missing`）を導入し、全 `brew install` / `brew tap` を置換
- [x] 失敗時 resume / state 永続化（`--resume` / `--dry-run` / `~/.mac-setup-state.json` / `track_step`）
- [x] 厳格 bash 化（`set -euo pipefail`）+ ログ保存（`~/Library/Logs/mac-setup-YYYYMMDD.log`）+ ERR trap で失敗行明示
- [x] `.shellcheckrc` 追加（eval 間接参照による誤検知のみホワイトリスト化）
- [x] CI: shellcheck を `-S warning` で fail させ、bats ジョブ（14 テスト）を追加。`|| true` を削除

### 2025-08-09
- [x] LM Studioを開発ツールリストに追加
- [x] カスタムセットアップの動作変更（基本ツール自動インストールを削除）
- [x] カスタムセットアップメニューに基本開発ツール選択を追加

### 2025-08-07
- [x] modern-cli/機能のスペック作成
- [x] fdコマンド削除に伴うスペック更新
- [x] FZF設定の標準findコマンドへの移行を文書化

## 次のアクション

1. **即座に実行**
   - [ ] architecture.mdの作成
   - [x] basic-setup機能のスペック作成

2. **今週中に実行**
   - [ ] 主要3機能のスペック完成
   - [ ] batsテストフレームワークの導入

3. **今月中に実行**
   - [ ] 全機能のスペック完成
   - [ ] 基本的なテストカバレッジ達成