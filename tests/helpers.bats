#!/usr/bin/env bats
#
# mac-setup-modular.sh の関数単位テスト（bats）
#
# 実行: bats tests/
# 前提: brew install bats-core shellcheck
#
# スクリプトを source して関数だけを読み込むため MAC_SETUP_SOURCED=1 を設定する。
# bats のテスト名は ASCII のみ（マルチバイト名は一部バージョンで壊れるため）。

SCRIPT="${BATS_TEST_DIRNAME}/../mac-setup-modular.sh"

setup() {
    # 一時ディレクトリに state ファイルを隔離（副作用なし）
    TMPDIR_TEST="$(mktemp -d)"
    export MAC_SETUP_STATE_FILE="${TMPDIR_TEST}/state.json"
    export MAC_SETUP_LOG_DIR="${TMPDIR_TEST}/logs"

    # main を実行させずに関数定義のみ読み込む
    export MAC_SETUP_SOURCED=1
    # shellcheck disable=SC1090
    source "$SCRIPT"

    # state/dry-run の既定値を明示的にリセット
    DRY_RUN=false
    RESUME=false
}

teardown() {
    rm -rf "$TMPDIR_TEST"
}

# --- brew_install_if_missing ---

@test "brew_install_if_missing installs a missing package" {
    # brew をスタブ化：list は常に失敗（=未インストール）、install は印を残す
    brew() {
        case "$1" in
            list) return 1 ;;
            install) echo "INSTALLED:$2" >> "${TMPDIR_TEST}/installed.txt"; return 0 ;;
        esac
    }
    export -f brew
    run brew_install_if_missing foo
    [ "$status" -eq 0 ]
    grep -q "INSTALLED:foo" "${TMPDIR_TEST}/installed.txt"
}

@test "brew_install_if_missing skips an already-installed package" {
    brew() {
        case "$1" in
            list) return 0 ;;
            install) echo "INSTALLED:$2" >> "${TMPDIR_TEST}/installed.txt"; return 0 ;;
        esac
    }
    export -f brew
    run brew_install_if_missing bar
    [ "$status" -eq 0 ]
    [ ! -f "${TMPDIR_TEST}/installed.txt" ]
}

@test "brew_install_if_missing processes multiple packages" {
    brew() {
        case "$1" in
            list) return 1 ;;
            install) echo "$2" >> "${TMPDIR_TEST}/installed.txt"; return 0 ;;
        esac
    }
    export -f brew
    run brew_install_if_missing a b c
    [ "$status" -eq 0 ]
    [ "$(wc -l < "${TMPDIR_TEST}/installed.txt" | tr -d ' ')" -eq 3 ]
}

# --- brew_tap_if_missing ---

@test "brew_tap_if_missing taps a missing tap" {
    brew() {
        case "$1" in
            tap)
                if [ $# -eq 1 ]; then
                    echo "homebrew/core"   # 既存 tap 一覧
                else
                    echo "TAPPED:$2" >> "${TMPDIR_TEST}/tapped.txt"
                fi
                ;;
        esac
    }
    export -f brew
    run brew_tap_if_missing mongodb/brew
    [ "$status" -eq 0 ]
    grep -q "TAPPED:mongodb/brew" "${TMPDIR_TEST}/tapped.txt"
}

@test "brew_tap_if_missing skips an existing tap" {
    brew() {
        case "$1" in
            tap)
                if [ $# -eq 1 ]; then
                    echo "mongodb/brew"
                else
                    echo "TAPPED:$2" >> "${TMPDIR_TEST}/tapped.txt"
                fi
                ;;
        esac
    }
    export -f brew
    run brew_tap_if_missing mongodb/brew
    [ "$status" -eq 0 ]
    [ ! -f "${TMPDIR_TEST}/tapped.txt" ]
}

# --- state 永続化 ---

@test "init_state_file creates an empty JSON" {
    init_state_file
    [ -f "$MAC_SETUP_STATE_FILE" ]
    grep -q '"steps"' "$MAC_SETUP_STATE_FILE"
}

@test "set_step_status and get_step_status round-trip" {
    set_step_status "demo" "success"
    [ "$(get_step_status demo)" = "success" ]
}

@test "set_step_status does not duplicate the same step" {
    set_step_status "demo" "failed"
    set_step_status "demo" "success"
    [ "$(get_step_status demo)" = "success" ]
    [ "$(grep -c '"demo"' "$MAC_SETUP_STATE_FILE")" -eq 1 ]
}

# --- track_step ---

@test "track_step records success on a passing function" {
    ok_fn() { return 0; }
    run track_step "s_ok" ok_fn
    [ "$status" -eq 0 ]
    [ "$(get_step_status s_ok)" = "success" ]
}

@test "track_step records failed on a failing function" {
    bad_fn() { return 7; }
    run track_step "s_bad" bad_fn
    [ "$status" -eq 7 ]
    [ "$(get_step_status s_bad)" = "failed" ]
}

@test "track_step skips an already-successful step with --resume" {
    set_step_status "s_done" "success"
    RESUME=true
    should_not_run() { echo "RAN" >> "${TMPDIR_TEST}/ran.txt"; return 1; }
    run track_step "s_done" should_not_run
    [ "$status" -eq 0 ]
    [ ! -f "${TMPDIR_TEST}/ran.txt" ]
}

@test "track_step does not write state in --dry-run" {
    DRY_RUN=true
    any_fn() { return 0; }
    run track_step "s_dry" any_fn
    [ "$status" -eq 0 ]
    [ ! -f "$MAC_SETUP_STATE_FILE" ]
}

# --- parse_args ---

@test "parse_args parses --resume and --dry-run" {
    parse_args --resume --dry-run
    [ "$RESUME" = true ]
    [ "$DRY_RUN" = true ]
}

@test "parse_args exits 1 on an unknown option" {
    run parse_args --does-not-exist
    [ "$status" -eq 1 ]
}
