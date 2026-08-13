# Decentworks::Hexdigest::Support

## 設定

ソルトを設定すると、ダイジェストの入力へ前置されます（未設定時はソルトなし）。

```ruby
::Decentworks::HexdigestSupport.configure do |config|
  config.salt = "..."
end
```

### Rails

初期化ファイルはジェネレータで生成できます。

```console
$ bin/rails generate decentworks:hexdigest_support:install
      create  config/initializers/decentworks_hexdigest_support.rb
```

生成される初期化ファイルは `credentials` からソルトを読み出します。

```console
$ bin/rails credentials:edit
```

```yaml
decentworks:
  hexdigest_support_salt: <ランダムな文字列（例: `bin/rails secret` の出力）>
```

キー名は `--salt-key` で変更できます。

```console
$ bin/rails generate decentworks:hexdigest_support:install --salt-key=custom_salt
```

> [!CAUTION]
> ソルトを変更すると、同じ値でも異なるダイジェストになります。永続化済みのダイジェストがある場合は、変更前に移行方針を検討してください。
