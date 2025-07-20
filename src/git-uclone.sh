#!/bin/bash

CONFIG_FILE=~/.ssh/config
PROFILE_DIR=~/.git-uclone-users

# ヘルプの表示
print_help() {
    echo "Usage:"
    echo ""
    echo "  git uclone --setup --user <USERNAME> --key <PRIVATE_KEY_PATH> [--email <EMAIL>]"
    echo "      - Set up SSH config and Git user profile."
    echo ""
    echo "  git uclone <USERNAME> <REPO_URL> [additional git clone options]"
    echo "      - Clone repository using SSH profile and apply Git user settings."
    echo ""
    echo "Examples:"
    echo "  git uclone --setup --user git-user --key ~/.ssh/id_rsa --email user@example.com"
    echo "  git uclone git-user git@github.com:owner/repo.git"
}

# --setup 引数のパース
parse_setup_params() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --user)
                USERNAME="$2"
                shift 2
                ;;
            --key)
                PRIVATE_KEY="$2"
                shift 2
                ;;
            --email)
                EMAIL="$2"
                shift 2
                ;;
            *)
                echo "❌ Error: Unknown parameter '$1'"
                echo ""
                print_help
                exit 1
                ;;
        esac
    done

    if [[ -z "$USERNAME" || -z "$PRIVATE_KEY" ]]; then
        echo "❌ Error: --user and --key are required for setup."
        echo ""
        print_help
        exit 1
    fi
}

# SSHとGitユーザ設定の保存
setup() {
    parse_setup_params "$@"
    HOST_ALIAS="github.com.$USERNAME"
    PROFILE_FILE="$PROFILE_DIR/$USERNAME"

    mkdir -p "$PROFILE_DIR"

    {
        echo "USER=$USERNAME"
        echo "KEY=$PRIVATE_KEY"
        [[ -n "$EMAIL" ]] && echo "EMAIL=$EMAIL"
    } > "$PROFILE_FILE"

    if ! grep -q "Host $HOST_ALIAS" "$CONFIG_FILE" 2>/dev/null; then
        {
            echo ""
            echo "Host $HOST_ALIAS"
            echo "    HostName github.com"
            echo "    User git"
            echo "    Port 22"
            echo "    IdentityFile $PRIVATE_KEY"
            echo "    TCPKeepAlive yes"
            echo "    IdentitiesOnly yes"
        } >> "$CONFIG_FILE"
        echo "✅ SSH config for '$USERNAME' added to $CONFIG_FILE"
    else
        echo "✔️ SSH config for '$HOST_ALIAS' already exists."
    fi

    echo "📦 Git profile saved: $PROFILE_FILE"
}

# clone 実行後に `.git/config` へGitユーザー設定を追加
ucloning() {
    if [[ "$#" -lt 2 ]]; then
        echo "❌ Error: Missing arguments for cloning."
        echo ""
        print_help
        exit 1
    fi

    USERNAME="$1"
    shift
    REPO_URL="$1"
    shift
    HOST_ALIAS="github.com.$USERNAME"
    PROFILE_FILE="$PROFILE_DIR/$USERNAME"

    if ! grep -q "Host $HOST_ALIAS" "$CONFIG_FILE" 2>/dev/null; then
        echo "❌ Error: SSH config for '$USERNAME' not found."
        echo "Run: git uclone --setup --user <USERNAME> --key <PRIVATE_KEY_PATH> [--email <EMAIL>]"
        exit 1
    fi

    if [[ ! -f "$PROFILE_FILE" ]]; then
        echo "❌ Error: Git profile for '$USERNAME' not found."
        exit 1
    fi

    MODIFIED_REPO=$(echo "$REPO_URL" | sed "s/github\.com/$HOST_ALIAS/")

    git clone "$MODIFIED_REPO" "$@"
    CLONE_DIR=$(basename "$REPO_URL" .git)

    if [[ -d "$CLONE_DIR/.git" ]]; then
        GIT_EMAIL=$(grep "^EMAIL=" "$PROFILE_FILE" | cut -d'=' -f2)
        if [[ -n "$GIT_EMAIL" ]]; then
            GIT_NAME=$(grep "^USER=" "$PROFILE_FILE" | cut -d'=' -f2)
            git -C "$CLONE_DIR" config user.name "$GIT_NAME"
            git -C "$CLONE_DIR" config user.email "$GIT_EMAIL"
            echo "🔧 Git user info applied to '$CLONE_DIR/.git/config'"
        else
            echo "ℹ️ No email configured for '$USERNAME'; skipping Git config injection."
        fi
    fi
}

# コマンド分岐
if [[ "$1" == "--help" || "$1" == "help" ]]; then
    print_help
    exit 0
elif [[ "$1" == "--setup" ]]; then
    shift
    setup "$@"
elif [[ "$#" -ge 2 ]]; then
    ucloning "$@"
else
    echo "❌ Error: Unknown or insufficient arguments."
    echo ""
    print_help
    exit 1
fi
