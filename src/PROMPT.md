AIによって、以下のプロンプトで作成したものを編集して作成した。

```md
gitのサブコマンドをbashにより作成せよ。以下の仕様を想定している。 

1. セットアップ
    1. 以下の情報を入力とする
    - ユーザの秘密鍵へのパス
        - 例: `~/.ssh/ex-secret`
    - Git上でのユーザ名
        - 例: `git-user`

    2. ユーザは上記のパラメータを用いconfigのセットアップ用のコマンドを入力する。
    3. `~/.ssh/config`に以下のような設定を追記する
    ```
    Host github.com.git-user
            HostName github.com
            User git
            Port 22
            IdentityFile ~/.ssh/ex-secret
            TCPKeepAlive yes
            IdentitiesOnly yes
    ```
2. `git uclone`コマンドを実行する。`git uclone`は`git clone`コマンドと同じオプションを持つが、第一引数には 1 で作成したユーザ名を取る。  
    例: 

    `git-user`のプロファイルを用いて、`git@github.com:git-repo-user/sample.git`をcloneする。  

        git uclone git-user git@github.com:git-repo-user/sample.git
    
    上記は、以下と同値の結果を示す
    
        git clone git@github.com.git-user:git-repo-user/sample.git

上記の1,2ともに`git uclone`コマンドで実装する。セットアップも`git uclone`のサブコマンドとして実行できるようにせよ。
```

```md
作成されたスクリプトでは、`git uclone`コマンドを実行した際にエラーが出てしまった。存在しないコマンドを実行した場合にヘルプが出るようにしてほしい。
```


```md
ucloneコマンド実行時にパラメータが不足している場合にはエラーとし、エラーメッセージとヘルプを表示できるようにせよ。
```

```md
ucloningの際にUSERNAMEが存在しない場合のエラーハンドリングを追加せよ。
```

```md
setupコマンドについて、パラメータは引数ではなくパラメータで指定できるようにせよ。例えば以下のように。
    ```sh
    git uclone --setup --user git-user --key ~/.ssh/path
    ```
```

```md
さらに、git clone後の `.git/config`にユーザ設定も追加できるようにしたい。
`--setup`コマンドにオプションのパラメータ`email`を設定できるようにし、ユーザ名と紐づける形で本スクリプト用の設定を作成せよ
`--setup`時に作成した設定を参照し、`git clone`後に以下を`.git/config`に追記せよ。
    ```
    [user]
            email = <setupで作成されたemailパラメータ>
            name = <setupで作成した--user名>
    ```
指定したユーザにおいて、emailパラメータがない場合は上記の操作は実施しないすること。
```

```md
上記について、OSS公開を前提のREADME.mdを作成せよ
```