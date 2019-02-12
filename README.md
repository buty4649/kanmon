# kanmon
OpenStackのSecurityGroupにルールを追加するツール

## Usage

kanmon.yml に登録先のSecurity GroupのUUIDを記述します。

```yaml
$ cat kanmon.yml
security_group: 11122233-4444-5555-6666-777788889999
```

または、SSHでアクセスしたいサーバーのUUIDを記述することも可能です。サーバーのUUIDを記述した場合、新規にSecurityGroupを作成し、指定したサーバーに追加します。

```yaml
➤ cat kanmon.yml
server: 11122233-4444-5555-6666-777788889999
```

もし、kanmon.yaml で複数のターゲットを管理したい場合、次のように書くこともできます。

```yaml
➤ cat kanmon.yml
targetA:
  security_group: 11122233-4444-5555-6666-777788889999
targetB:
  server: 33344444-5555-6666-7777-888800000000
```

実行する環境の IP で追加・削除したくないものがあれば、予め exclude\_ips にリストを記載しておくことで除外できます。

```yaml
$ cat kanmon.yml
security_group: 11122233-4444-5555-6666-777788889999
exclude_ips:
  - 203.0.113.0
```

開くポートはTCP/22ですが、変更することもできます。以下の例ではTCP/443を開いています。

```
$ cat kanmon.yml
security_group: 11122233-4444-5555-6666-777788889999
port: 443
```


環境変数を設定します。

```
$ export OS_USERNAME=username
$ export OS_PASSWORD=password
$ export OS_TENANT_NAME=tenant
$ export OS_AUTH_URL=http://example.com/auth/v3/
$ export OS_IDENTITY_API_VERSION=3
$ export OS_USER_DOMAIN_NAME=default
$ export OS_PROJECT_DOMAIN_NAME=default
```

自分のIPをSecurity Groupに追加します。

```
$ kanmon open
```

kanmon.yaml に複数のターゲットを記述した場合、下記のようにします。

```
$ kanmon open --target targetA
$ kanmon open --target targetB
```

追加したSecurity Groupのルールを削除します。

```
$ kanmon close
```

複数のターゲットがある場合、下記のようになります。

```
$ kanmon close --target targetA
$ kanmon close --target targetB
```
