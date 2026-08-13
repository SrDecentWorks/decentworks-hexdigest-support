# Decentworks::HexdigestSupport

> [!IMPORTANT]
> 本ライブラリは個人によって開発・保守されています。予告なく仕様変更または提供を終了する場合があります。ご利用にあたってはバージョンを固定のうえ、更新時は変更内容をご確認ください。

任意のRubyオブジェクトから、決定的なハッシュ値（16進ダイジェスト）を求めるための拡張ライブラリです。

`Object` にダイジェスト生成用のメソッドを追加し、`Array` / `Hash` / `Range` / `Struct` / `Data` / `Set` には構造を考慮した入力生成を、`Time` / `Date` / `DateTime` には正規化した入力生成を実装しています。

- **型を保持する** — `:a` と `"a"`、`1` と `"1"` は異なるダイジェストになります
- **順序に依存しない** — 配列・ハッシュは要素をソートしてから連結するため、並び順が違っても同じダイジェストになります
- **Rubyのバージョンに依存しない** — `Hash#inspect` などネイティブの文字列表現には依存せず、自前で入力を組み立てます
- **ソルトに対応** — 設定したソルトをダイジェストの入力へ前置します
- **Rails非依存** — gem本体はRailsに依存しません（ジェネレータのみRails利用時に読み込まれます）

対応アルゴリズムはMD5 / RMD160 / SHA1 / SHA256 / SHA384 / SHA512です。

## インストール

Gemfileに追加します。

```ruby
gem "decentworks-hexdigest-support"
```

```console
$ bundle install
```

Bundlerを使わない場合は次のコマンドでインストールします。

```console
$ gem install decentworks-hexdigest-support
```

読み込みは `require` で行います。

```ruby
require "decentworks/hexdigest_support"
```

必要なRubyのバージョンは `>= 4.0.0` です。

## セットアップ

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

## 使い方

### ダイジェストを求める

```ruby
"user@example.com".to_hexdigest
# => "8d3b74fd6c74d37b4abf8845a1b2e9c775510b529b0b224c87f5ee989bc2da0a"

"user@example.com".to_md5_hexdigest
# => "ccf86d256ba77a8e4a9c4b8dae6a3019"
```

アルゴリズムごとのメソッドと、系統ごとのデフォルトのエイリアスが用意されています。

| メソッド | アルゴリズム | 長さ |
| --- | --- | --- |
| `#to_md5_hexdigest` | MD5 | 32 |
| `#to_rmd160_hexdigest` | RMD160 | 40 |
| `#to_sha1_hexdigest` | SHA1 | 40 |
| `#to_sha256_hexdigest` | SHA256 | 64 |
| `#to_sha384_hexdigest` | SHA384 | 96 |
| `#to_sha512_hexdigest` | SHA512 | 128 |
| `#to_md_hexdigest` | MD5のエイリアス | 32 |
| `#to_rmd_hexdigest` | RMD160のエイリアス | 40 |
| `#to_sha_hexdigest` | SHA256のエイリアス | 64 |
| `#to_hexdigest` | SHA256のエイリアス（既定） | 64 |

### 型が保持される

```ruby
1.to_hexdigest_input   # => "Integer:\"1\""
"1".to_hexdigest_input # => "String:\"1\""

1.to_hexdigest == "1".to_hexdigest # => false
:a.to_hexdigest == "a".to_hexdigest # => false
```

### 配列・ハッシュ・範囲

要素はソートされてから連結されるため、順序が違っても同じダイジェストになります。

```ruby
[1, "a", :b].to_hexdigest == [:b, 1, "a"].to_hexdigest # => true

{ a: 1, b: 2 }.to_hexdigest == { b: 2, a: 1 }.to_hexdigest # => true

# キーの型も区別される
{ a: 1 }.to_hexdigest == { "a" => 1 }.to_hexdigest # => false

# 範囲は始端・終端・終端を含むかで決まる
(1..3).to_hexdigest == (1...3).to_hexdigest # => false

# 端点のない範囲も扱える
(1..).to_hexdigest
(..3).to_hexdigest
```

ネストした構造もそのまま扱えます。

```ruby
{ id: 1, tags: %w[a b], range: (1..3) }.to_hexdigest
```

### 構造体・集合

`Struct` / `Data` はメンバー名と値の組で決まります。`Set` は配列と同じく要素をソートしてから連結します。

```ruby
Point = Struct.new(:x, :y)
Point.new(1, 2).to_hexdigest_source # => '{Symbol:"x"=>Integer:"1",Symbol:"y"=>Integer:"2"}'

Coord = Data.define(:x, :y)
Coord.new(x: 1, y: 2).to_hexdigest

# メンバー名が違えば値が同じでも異なるダイジェストになる
Struct.new(:a, :b).new(1, 2).to_hexdigest == Struct.new(:x, :y).new(1, 2).to_hexdigest # => false

Set[1, 2].to_hexdigest == Set[2, 1].to_hexdigest # => true

# 同じ要素の配列とは異なるダイジェストになる（型で区別される）
Set[1, 2].to_hexdigest == [1, 2].to_hexdigest # => false
```

> [!NOTE]
> 定数へ代入していない無名の `Struct` / `Data` は型が `Struct` / `Data` へ丸まるため、メンバー名と値が同じであれば別々に生成したもの同士も同じダイジェストになります。型で区別したい場合は定数へ代入してください。

### 日時

`Time` / `DateTime` はUTCへ変換し、ナノ秒までの精度で正規化されます。タイムゾーンの違いはダイジェストに影響しません。

```ruby
Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest_source
# => "2026-08-13T04:05:06.000000000Z"

# 同じ瞬間を指す時刻は同じダイジェストになる
Time.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest == Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest # => true

# Dateは日付として正規化される
Date.new(2026, 8, 13).to_hexdigest_source # => "2026-08-13"
```

> [!NOTE]
> ナノ秒より細かい精度は切り捨てられます。また `Time` と `DateTime` は型が異なるため、同じ瞬間を指していても異なるダイジェストになります。

### nil・真偽値

```ruby
nil.to_hexdigest_input   # => "NilClass:\"nil\""
true.to_hexdigest_input  # => "TrueClass:\"true\""
false.to_hexdigest_input # => "FalseClass:\"false\""

# 空文字とは区別される
nil.to_hexdigest == "".to_hexdigest # => false

# ハッシュの値がnilの場合も、キーそのものがない場合と区別される
{ a: nil }.to_hexdigest == {}.to_hexdigest # => false
```

### 独自クラスのダイジェスト

既定では `#to_s` の結果が入力になります。値を明示したい場合は `#to_hexdigest_source` をオーバーライドします。型は `#to_hexdigest_input` が付与するため、オーバーライド側で型を意識する必要はありません。

```ruby
class User
  attr_reader :id, :email

  def initialize(id, email)
    @id    = id
    @email = email
  end

  def to_hexdigest_source = { id: id, email: email }.to_hexdigest_source
end

User.new(1, "user@example.com").to_hexdigest
# => "85d21188e7c1940ec71ced3b22f141677c3665b5b77f0793a3181f38bff51515"

# 値が同じなら同じダイジェストになる
User.new(1, "user@example.com").to_hexdigest == User.new(1, "user@example.com").to_hexdigest
# => true
```

### 入力の確認

デバッグ時は、ダイジェストの元になる文字列を確認できます。

```ruby
"user@example.com".to_hexdigest_input
# => "String:\"user@example.com\""

# ソルトを前置した実際の入力
"user@example.com".to_salted_hexdigest_input
# => "pepperString:\"user@example.com\""
```

## 注意事項

### ソルトの変更

> [!CAUTION]
> ソルトを変更すると、同じ値でも異なるダイジェストになります。永続化済みのダイジェストがある場合は、変更前に移行方針を検討してください。

ソルトはリポジトリに平文で置かず、Railsであれば `credentials` で管理してください。

### 用途

ダイジェストは同一性の判定や値の秘匿を目的としたものです。パスワードの保存など、総当たり耐性が必要な用途には適していません（その用途にはbcryptなどのパスワードハッシュを使ってください）。

### コアクラスの拡張

本gemは `Object` / `NilClass` / `Array` / `Hash` / `Range` / `Struct` / `Data` / `Time` と、読み込まれていれば `Set` / `Date` / `DateTime` にメソッドを追加するモンキーパッチです。`#to_hexdigest_source` などのメソッド名が他のライブラリと衝突しないか確認してください。

### Set / Date / DateTime の読み込み順

`Set` と `Date` は、利用側が使っていない場合にまで読み込みを強いないよう、**すでに読み込まれている場合にだけ**拡張します。本gemより後に `require "date"` した場合、拡張は適用されず `#to_s` にフォールバックします。

`Date#to_s` はISO 8601の日付なので気付きにくいのですが、`DateTime#to_s` はオフセットを含むため、同じ瞬間でもタイムゾーン次第でダイジェストが変わってしまいます。読み込み順を制御できない場合は明示的に適用してください。

```ruby
require "date"
::Decentworks::HexdigestSupport::OptionalExtensions.apply!
```

Railsでは `active_support` が先に読み込むため、通常は意識する必要はありません。

> [!CAUTION]
> `ActiveSupport::TimeWithZone` は本gemの対象外です。`Time` のサブクラスではないため `#to_s` にフォールバックし、オフセットを含んだ文字列がダイジェストの入力になります。Railsで日時を扱う場合は `#to_time` などで `Time` へ変換してから渡してください。

### 独自クラスのオーバーライド

`#to_hexdigest_source` の実装を変更すると、そのクラスのダイジェストも変わります。永続化済みの値がある場合は、ソルト変更と同様に移行方針が必要です。

無名クラスは名前を持つ祖先クラスまで遡って型として扱われます。

## 開発

```console
$ bin/setup            # 依存関係のインストール
$ bundle exec rake     # RSpec + RuboCop
$ bundle exec rspec    # テストのみ
$ bundle exec rubocop  # 静的解析のみ
$ bin/console          # 対話コンソール
```

テストのカバレッジはSimpleCovで計測され、`coverage/` に出力されます。

## ライセンス

MIT License. 詳細は [LICENSE.txt](LICENSE.txt) を参照してください。
