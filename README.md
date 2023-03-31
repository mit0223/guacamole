# Guacamole デモ環境

Azure 上に  Guacamole デモ環境を構築するための ansible スクリプトである（プロキューブ社内向け）

## インストール

python 仮想環境を作成し、以下でツールを導入する。

```bash
git clone procube@procube.git.backlog.jp:/INTR/win-builder.git
cd win-builder
pip install ansible-core
ansible-galaxy collection install -r requirements.yml -p collections
pip install -r collections/ansible_collections/azure/azcollection/requirements-azure.txt
```
## Azure認証情報の設定

~/.azure/credentials に以下の形式で認証情報を作成してください。

```ini
[default]
subscription_id=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
client_id=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
secret=xxxxxxxxxxxxxxxxx
tenant=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## インベントリ

hosts.yml のインベントリを編集してください。
ホスト名はそのまま Windows のコンピュータ名となるので、Windows computer name cannot be more than 15 characters long, be entirely numeric, or contain the following characters: ` ~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \\ | ; : . ' \" , < > / ?. に従うようにしてください。

| 変数名 | 意味 |
| --- | --- |
| username | ログインするときのユーザ名|
| vm_image | 起動する VM のイメージ|

vm_image のデフォルト値は以下の通りである。

```
      offer: windows-11
      publisher: MicrosoftWindowsDesktop
      sku: 'win11-22h2-pro'
      version: latest
```

その他、以下のイメージを起動できることを確認している。

Windows Server

```
    offer: WindowsServer
    publisher: MicrosoftWindowsServer
    # sku: '2012-Datacenter'
    # sku: '2016-Datacenter'
    sku: '2019-Datacenter'
    # sku: '2022-Datacenter'
    version: latest
```

Windows 10

``` 
    offer: windows-10
    publisher: MicrosoftWindowsDesktop
    sku: 'win10-21h2-pro'
    version: latest
```

Visual Studio インストール済み

```    
    offer: visualstudio2022
    publisher: microsoftvisualstudio
    sku: 'vs-2022-ent-latest-ws2022'
    version: latest
```

## 実行方法

hosts に登録済みの全ホストを起動する場合、

```
 ansible-playbook main.yml
```

hosts に登録されているホストのうち一部（ex. mitsuru-test）のみを起動する場合

```
ansible-playbook  main.yml -l mitsuru-test --tags=jumpserver,debug
```

## サーバ証明書の取得

以下でサーバ証明書を取得してください。

```
ssh -F ssh_config guacamole
cd docker-compose
docker-compose stop nginx
mkdir /tmp/{etc,var}-certbot
docker run -it --rm -p 80:80 -p 443:443 -v /tmp/etc-certbot:/etc/letsencrypt -v /tmp/var-certbot:/var/lib/letsencrypt certbot/certbot certonly --standalone -d guacamole-procube.japaneast.cloudapp.azure.com
sudo chown guacamole:guacamole -R /tmp/{etc,var}-certbot
cp /tmp/etc-certbot/archive/guacamole-procube.japaneast.cloudapp.azure.com/fullcain1.pem nginx/ssl/self.cert
cp /tmp/etc-certbot/archive/guacamole-procube.japaneast.cloudapp.azure.com/privkey1.pem nginx/ssl/self-ssl.key
docker-compose start nginx
```

## アクセス方法

https://guacamole-procube.japaneast.cloudapp.azure.com にアクセスし、ID guacadmin, password guacaadmin でログインし、すぐにパスワードを変更してください。

## 接続設定

### 踏み台サーバ

（未執筆）

### ssh-test

（未執筆）

### ブラウザ

（未執筆）

## Windows の設定

初回接続時の設定について説明します。

### Windows 11 ウイザード

初回起動時は  Windows 11 では設定ウィザードが起動します。「Next」を２回クリックした後、「Accept」をクリックしてください。

### タイムゾーンと言語の設定

英語版が起動するので、「Settings」の 「Time & Language」でタイムゾーンと言語の設定を行ってください。
言語は  Add Language で日本語用ソフトウェアをインストールする必要があります。Add Language の言語の選択はスクロールするより検索に japan と入力したほうが早いです。
設定後、一旦サインアウトしてログインしなおす必要があります。

### ドメインの構築

ドメインを構築する場合は、以下の設定を行ってください。
1. https://www.rem-system.com/win2019-adsetup/ を参考にドメインコントローラをセットアップしてください。Windows Server で役割に AD DS を追加するときに、同時にAD CS を追加してはいけません。セットアップできなくなります。）
1. https://labo.azpower.co.jp/2019/12/419 の「3.DNSサーバーの指定はAzure Portalから」を参考にドメインコントローラのIPアドレスを仮想ネットワークのDNSに指定してください。
1. 「Active Directory ユーザとコンピュータ」の procube-demo.jp/Users にクライアントにログインするためのユーザを追加してください。このとき、「次回ログイン時にパスワードを変更する」はチェックしないでください。クライアントコンピュータのドメイン参加時にこのチェックが入っているとドメイン参加に失敗します。

### クライアントのドメインへの参加

ドメインを構築する場合は、以下の設定を行ってください。
1. ドメインに参加させるクライアントにログインしてください。
1. 「設定」アプリケーションの「アカウント」→「職場または学校にアクセスする」→「接続」で接続画面を開きます。
1. 「このデバイスをローカルの Active Directory に参加させるをクリック
1. ドメインに参加でドメインのFQDNを入力(ex. procube-demo.jp)しておいて UPN(ex. fujisawa@procube-demo.jp) でログイン
1. 「アカウントを追加する」のダイアログでユーザをコンピュータに追加するときは、デフォルトでUPN(ex. fujisawa@procube-demo.jp)が表示されていますが、NetBIOS名(ex. procube-demo¥fujisawa)に変更してください。
1. 「今すぐ再起動する」を選択し、再起動してもう一度ローカルアカウントでログインしてください。
1. RDPからログインできなくなった場合は、Azure Portal から VM を再起動してください。
1. 「設定」の「システム」→「リモートデスクトップ」を開き、「リモートデスクトップユーザ」をクリックしてください。
1. 「追加」ボタンをクリックし、「ユーザ または グループの選択」で「選択するオブジェクト名を入力してください」の欄にユーザ名(ex. fujisawa)を入力して「名前の確認」ボタンを押してください。
1. ログイン画面が表示されるので、UPN(ex. fujisawa@procube-demo.jp) でログインしてください。
1. 「ユーザ または グループの選択」ダイアログに戻るので、「OK」ボタンを押してください。
1. リモートデスクトップユーザ」ダイアログに戻るので、ユーザが追加されていることを確認して、「OK」ボタンを押してください。

1. リモートデスクトップからサインアウトし、認証情報をUPNに変えてログインしなおしてください。NetBIOS名のドメインを付加する必要はありません。
1. 言語の設定がリセットされていますので、やりなおしてください。

## VMの削除方法

Azure ポータルから以下の4つのリソースを削除してください。${HOST}をVM名に読み替えてください。

|名称パターン|種別     |
|--------- | ------ |
|${HOST}   | ディスク|
|${HOST}   | 仮想マシン|
|${HOST}-gip| パブリック IP アドレス|
|${HOST}-primary| ネットワーク インターフェイス|
