# git-uclone
## 概要

git-ucloneは、複数のgitアカウントを所持するユーザが、リポジトリのクローンを効率化するためのgitサブコマンドである。

## インストール方法

```sh
chmod +x src/git-uclone.sh
sudo cp src/git-uclone.sh /usr/local/bin/git-uclone
```

## 設定作成

以下のコマンドを使用して、SSHプロファイルとGitユーザー設定をセットアップする:
```sh
git uclone --setup --user <USERNAME> --key <PRIVATE_KEY_PATH> [--email <EMAIL>]
```

必須引数
- `--user <USERNAME>`: Gitユーザー名
- `--key <PRIVATE_KEY_PATH>`: SSH秘密鍵のパス

オプション引数
- `--email <EMAIL>`: Gitユーザーのメールアドレス
    - 設定すると、`git uclone`後に`.git/config`への設定も実施する。

コマンド例:
```sh
git uclone --setup --user git-user --key ~/.ssh/id_rsa --email user@example.com
```

## リポジトリのクローン作成

以下のコマンドを使用して、SSHプロファイルを利用してリポジトリをクローンし、Gitユーザー設定を適用する:
```sh
git uclone <USERNAME> <REPO_URL> [additional git clone options]
```

必須引数
- `<USERNAME>`: セットアップしたGitユーザー名
- `<REPO_URL>`: クローンするリポジトリのURL

コマンド例:
```sh
git uclone git-user git@github.com:owner/repo.git
```

## ヘルプの表示

```sh
git uclone --help
## or
git uclone help
```
