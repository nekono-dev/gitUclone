#!/bin/bash
set -e
set -o pipefail

cd "$(dirname "$0")"
sudo cp ../src/git-uclone.sh /usr/local/bin/git-uclone


echo "[INFO] Starting git uclone tests..."

# === 初期化とバックアップ ===
CONFIG=~/.ssh/config
PROFILE_DIR=~/.git-uclone-users
BACKUP_DIR=./backup_test_git_uclone
TEST_DIR=./git_uclone_test
REPO_HTTPS="https://github.com/nekono-dev/gitUclone.git"
REPO_SSH="git@github.com:nekono-dev/gitUclone.git"
USERNAME="nekono"
KEY_PATH="$HOME/.ssh/nekono_key"
EMAIL="91360587+nekono-dev@users.noreply.github.com"

echo "[INFO] Backing up SSH config and user profile..."
mkdir -p "$BACKUP_DIR"
cp "$CONFIG" "$BACKUP_DIR/config.bak" 2>/dev/null || touch "$BACKUP_DIR/config.bak"
mkdir -p "$BACKUP_DIR/users.bak"
cp -r "$PROFILE_DIR/"* "$BACKUP_DIR/users.bak/" 2>/dev/null || echo "[INFO] No profiles found to backup"

echo "[INFO] Cleaning up original config/profile..."
rm -f "$CONFIG"
touch "$CONFIG"
rm -rf "$PROFILE_DIR"
mkdir -p "$PROFILE_DIR"

# === [Positive] ユーザーセットアップ ===
echo "[Positive] Setup user profile..."
if git uclone --setup --user "$USERNAME" --key "$KEY_PATH" --email "$EMAIL"; then
    echo "✅ User setup succeeded"
else
    echo "❌ User setup failed"
    exit 1
fi

# === [Positive] HTTPS clone ===
echo "[Positive] Cloning via HTTPS..."
mkdir -p "$TEST_DIR"
pushd "$TEST_DIR" > /dev/null

if git uclone "$USERNAME" "$REPO_HTTPS"; then
    echo "✅ HTTPS clone succeeded"
else
    echo "❌ HTTPS clone failed"
    exit 1
fi

CLONE_DIR=$(basename "$REPO_HTTPS" .git)
echo "[Positive] Checking git config in HTTPS clone..."
NAME=$(git -C "$CLONE_DIR" config user.name)
MAIL=$(git -C "$CLONE_DIR" config user.email)
if [[ "$NAME" == "$USERNAME" && "$MAIL" == "$EMAIL" ]]; then
    echo "✅ HTTPS Git config OK"
else
    echo "❌ HTTPS Git config mismatch"
    exit 1
fi
rm -rf "$CLONE_DIR"

# === [Positive] SSH clone ===
echo "[Positive] Cloning via SSH..."
if git uclone "$USERNAME" "$REPO_SSH"; then
    echo "✅ SSH clone succeeded"
else
    echo "❌ SSH clone failed"
    exit 1
fi

CLONE_DIR=$(basename "$REPO_SSH" .git)
echo "[Positive] Checking git config in SSH clone..."
NAME=$(git -C "$CLONE_DIR" config user.name)
MAIL=$(git -C "$CLONE_DIR" config user.email)
if [[ "$NAME" == "$USERNAME" && "$MAIL" == "$EMAIL" ]]; then
    echo "✅ SSH Git config OK"
else
    echo "❌ SSH Git config mismatch"
    exit 1
fi
rm -rf "$CLONE_DIR"
popd > /dev/null
rm -rf "$TEST_DIR"

# === [Negative] --key 省略時のセットアップ失敗 ===
echo "[Negative] Missing --key param test"
set +e
git uclone --setup --user "baduser" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "✅ Setup failed as expected (missing key)"
else
    echo "⚠️ Unexpected success in missing key setup"
    exit 1
fi
set -e

# === [Negative] 未定義ユーザでのクローン失敗 ===
echo "[Negative] Undefined user test"
set +e
git uclone "unknown" "$REPO_HTTPS" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "✅ Clone failed as expected (unknown user)"
else
    echo "⚠️ Unexpected success in unknown user clone"
    exit 1
fi
set -e

# === 復元処理 ===
echo "[INFO] Restoring original files..."
cp "$BACKUP_DIR/config.bak" "$CONFIG"
rm -rf "$PROFILE_DIR"
mkdir -p "$PROFILE_DIR"
cp -r "$BACKUP_DIR/users.bak/"* "$PROFILE_DIR/"
echo "[DONE] All tests completed successfully ✅"
