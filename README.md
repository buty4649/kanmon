# kanmon
OpenStackのSecurityGroupにルールを追加するツール

## Usage

kanmon.yml に登録先のSecurity GroupのUUIDを記述します。

```yaml
$ cat kanmon.yml
security_group: 11122233-4444-5555-6666-777788889999
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
