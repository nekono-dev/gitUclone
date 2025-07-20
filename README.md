# git-uclone
## Overview

git-uclone is a git subcommand that allows users with multiple git accounts to efficiently clone a repository.

## Installation instructions.

```sh 
chmod +x src/git-uclone.sh 
sudo cp src/git-uclone.sh /usr/local/bin/git-uclone 
```

## Create configuration

Set up an SSH profile and Git user configuration using the following command: 
```sh 
git uclone --setup --user <USERNAME> --key <PRIVATE_KEY_PATH> --key <PRIVATE_KEY_PATH> [--email <EMAIL>] 
```

Required Arguments
- `--user <USERNAME>`: Your Git user name.
- `--key <PRIVATE_KEY_PATH>`: The path to your SSH private key

Optional arguments
- `--email <EMAIL>`: The Git user's email address.
    - If set, it will also configure `.git/config` after `git uclone`.

Example command: 
```sh 
git uclone --setup --user git-user --key ~/.ssh/id_rsa --email user@example.com 
```

## Clone a repository

Use the following command to clone a repository using an SSH profile and apply Git user settings: 
```sh 
git uclone <USERNAME> <REPO_URL> [additional git clone options] 
```

Required arguments
- `<USERNAME>`: The Git user name you set up.
- `<REPO_URL>`: URL of the repository to clone.

Example command: 
```sh 
git uclone git-user git@github.com:owner/repo.git 
```

## Show help.

```sh 
git uclone --help
## or 
git uclone help 
```
