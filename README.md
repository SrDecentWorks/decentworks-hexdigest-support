# Decentworks::HexdigestSupport

> [!IMPORTANT]
> 本ライブラリは個人によって開発・保守されています。予告なく仕様変更または提供を終了する場合があります。ご利用にあたってはバージョンを固定のうえ、更新時は変更内容をご確認ください。

任意のRubyオブジェクトから、決定的なハッシュ値（16進ダイジェスト）を求めるための拡張ライブラリです。

`Object` にダイジェスト生成用のメソッドを追加し、`Array` / `Hash` / `Range` / `Struct` / `Data` / `Set` には構造を考慮した入力生成を、`Integer` / `Float` / `Rational` / `BigDecimal` / `Time` / `Date` / `DateTime` / `ActiveSupport::TimeWithZone` には正規化した入力生成を実装しています。

- **型を保持する** — `:a` と `"a"`、`1` と `"1"` は異なるダイジェストになります
- **順序に依存しない** — 配列・ハッシュは要素をソートしてから連結するため、並び順が違っても同じダイジェストになります
- **実行環境に依存しない** — `Hash#inspect` や `String#inspect` などネイティブの文字列表現には依存せず、自前で入力を組み立てます（Rubyのバージョンやロケールが変わってもダイジェストは変わりません）
- **ソルトに対応** — 設定したソルトをダイジェストの入力へ前置します
- **Railsの日時に対応** — `ActiveSupport::TimeWithZone` も `Time` と同じダイジェストになります
- **Railsの数値に対応** — `decimal` カラムの `BigDecimal` も `Integer` / `Float` と同じダイジェストになります

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

必要なRubyのバージョンは `>= 4.0.0` です。`activesupport` （`>= 8.0`）と `bigdecimal` （`>= 3.1`）に依存します。

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
1.to_hexdigest_input   # => "Numeric:\"1\""
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
Point.new(1, 2).to_hexdigest_source # => '{Symbol:"x"=>Numeric:"1",Symbol:"y"=>Numeric:"2"}'

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

### 数値

`Integer` / `Float` / `Rational` / `BigDecimal` は有理数として正規化され、**同じ型として扱われます**。同じ数であればクラスが違ってもダイジェストは一致します。

```ruby
1.to_hexdigest_type                 # => "Numeric"
BigDecimal("1.0").to_hexdigest_type # => "Numeric"

1.to_hexdigest == 1.0.to_hexdigest                # => true
1.to_hexdigest == BigDecimal("1.00").to_hexdigest # => true
1.to_hexdigest == Rational(2, 2).to_hexdigest     # => true
```

Railsでは同じ数が経路によって別のクラスで現れます（`decimal` カラムは `BigDecimal`、`integer` カラムやJSONの整数は `Integer`、JSONの小数は `Float`）。型をクラス名のままにすると入力経路の違いだけでダイジェストが割れてしまうため、時刻と同じく型を `"Numeric"` へ正規化しています。

値は、有限小数で表せる場合は十進表記に、表せない場合は既約分数の表記になります。

```ruby
1.0.to_hexdigest_source                # => "1"
1.5.to_hexdigest_source                # => "1.5"
BigDecimal("1.50").to_hexdigest_source # => "1.5"
1e20.to_hexdigest_source               # => "100000000000000000000"
(-0.0).to_hexdigest_source             # => "0"

Rational(1, 3).to_hexdigest_source     # => "1/3"
```

`Float` は2進の厳密値ではなく、`#to_s` が返す十進表記として解釈されます。`0.1` の厳密値は `1/10` ではありませんが、見た目どおりの十進として読むため `BigDecimal("0.1")` と同じダイジェストになります。

```ruby
0.1.to_hexdigest == BigDecimal("0.1").to_hexdigest # => true
0.1.to_hexdigest == Rational(1, 10).to_hexdigest   # => true

# 計算誤差は丸められず、そのまま保たれる
(0.1 + 0.2).to_hexdigest == 0.3.to_hexdigest # => false
```

`NaN` と `±Infinity` は有理数にできないため、`#to_s` の結果がそのまま値になります。

```ruby
Float::NAN.to_hexdigest_source      # => "NaN"
Float::INFINITY.to_hexdigest_source # => "Infinity"

# NaN同士は#==がfalseになるが、ダイジェストは一致する
Float::NAN.to_hexdigest == BigDecimal("NaN").to_hexdigest # => true
```

> [!NOTE]
> `Complex` は正規化の対象外で、型は `"Complex"` のままです。`Complex(1, 0) == 1` は真ですが、ダイジェストは一致しません。

### 日時

`Time` / `DateTime` / `ActiveSupport::TimeWithZone` はUTCへ変換し、ナノ秒までの精度で正規化されます。タイムゾーンの違いはダイジェストに影響しません。

```ruby
Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest_source
# => "2026-08-13T04:05:06.000000000Z"

# 同じ瞬間を指す時刻は同じダイジェストになる
Time.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest == Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest # => true
```

さらに、この3つは**同じ型として扱われます**。同じ瞬間を指していればクラスが違ってもダイジェストは一致します。

```ruby
Time.zone = "Asia/Tokyo"

Time.zone.local(2026, 8, 13, 13, 5, 6).to_hexdigest_type # => "Time"
DateTime.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest_type # => "Time"

Time.zone.local(2026, 8, 13, 13, 5, 6).to_hexdigest == Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest # => true
```

Railsでは同じ瞬間が経路によって別のクラスで現れます（`Time.zone.now` とActiveRecordの `datetime` カラムは `ActiveSupport::TimeWithZone`、`Time.now` や `File.mtime` は `Time`）。型をクラス名のままにすると、入力経路の違いだけでダイジェストが割れてしまうため、時刻に限っては型を `"Time"` へ正規化しています。

`Date` は「ある一瞬」ではなく1日を指すため、この正規化の対象外です。

```ruby
Date.new(2026, 8, 13).to_hexdigest_source # => "2026-08-13"
Date.new(2026, 8, 13).to_hexdigest_type   # => "Date"

# 同じ日付のDateTimeとは異なるダイジェストになる
Date.new(2026, 8, 13).to_hexdigest == DateTime.new(2026, 8, 13).to_hexdigest # => false
```

> [!NOTE]
> ナノ秒より細かい精度は切り捨てられます。DBの `timestamp`（多くはマイクロ秒）と往復させても値が変わらない粒度に揃えるためです。

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

`#to_s` も `#to_hexdigest_source` も実装していないオブジェクトは、既定の `Object#to_s` が返すオブジェクトIDが値になってしまいます。この場合は例外になります。

```ruby
Object.new.to_hexdigest
# => Decentworks::HexdigestSupport::NonDeterministicSourceError

# Procや無名クラスのように、独自の#to_sがオブジェクトIDを含む型も同様
proc {}.to_hexdigest
# => Decentworks::HexdigestSupport::NonDeterministicSourceError
```

配列やハッシュの中に含まれている場合も検出されます。

```ruby
{ user: Object.new }.to_hexdigest
# => Decentworks::HexdigestSupport::NonDeterministicSourceError
```

`String` と `Symbol` は検査の対象外です。値そのものが文字列であり、オブジェクトIDが混入する経路がないためです。オブジェクトIDの表記で始まる文字列（`#inspect` の結果や、それを含むログの1行など）もそのまま扱えます。

```ruby
"#<User:0x00007f9e0c0d1234>".to_hexdigest # => 例外にならない
```

> [!NOTE]
> 裏を返すと、利用側が自分でオブジェクトを文字列化して渡した場合（`"#{object}"` など）は検出できません。gemから見ればただの文字列であり、他の文字列と区別する手段がないためです。

### 循環参照

自身を含む値も例外になります。そのまま辿ると再帰が終わらず、`StandardError` を継承しない `SystemStackError` になってしまうためです。`SystemStackError` は呼び出し側の `rescue` をすり抜けます。

```ruby
values = [1]
values << values

values.to_hexdigest
# => Decentworks::HexdigestSupport::CircularReferenceError
```

配列・ハッシュ・`Struct` / `Data` / `Set` に加えて、独自クラス同士が参照しあう場合も検出されます。Railsで `belongs_to :parent` と `has_many :children` の両方をダイジェストへ含めた場合などが該当します。

```ruby
class Node
  attr_accessor :parent

  def to_hexdigest_source = { parent: }.to_hexdigest_source
end

node = Node.new
node.parent = node

node.to_hexdigest
# => Decentworks::HexdigestSupport::CircularReferenceError
```

同じオブジェクトが兄弟として複数回現れるのは循環ではないため、例外にはなりません。判定に使うのは、その時点で辿っている経路だけです。

```ruby
tags = %w[a b]

[tags, tags].to_hexdigest # => 例外にならない
```

> [!NOTE]
> 自身を含まない深いネスト（1万段など）は `SystemStackError` のままです。循環と違って有限であり、深さの上限を決め打ちすると正当な構造まで弾いてしまうためです。

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

### 値の引用とエスケープ

値は引用符で囲まれ、引用符（`"`）とバックスラッシュ（`\`）だけがエスケープされます。`#inspect` は使いません。`#inspect` は非ASCII文字を `Encoding.default_external` が印字可能かどうかでエスケープするか決めるため、同じ値でもロケール次第でダイジェストが変わってしまうためです。

```ruby
# UTF-8環境の#inspectと同じ出力になる
"あ".to_hexdigest_input # => "String:\"あ\""

# 制御文字はエスケープせず、そのまま入力に含まれる
"a\nb".to_hexdigest_input # => "String:\"a\nb\"" （#inspectなら "String:\"a\\nb\""）
```

> [!CAUTION]
> 改行やタブなどの制御文字を含む値は、`#inspect` を使っていた頃とダイジェストが変わります。ASCIIのみで制御文字を含まない値、およびUTF-8環境で求めた非ASCIIの値のダイジェストは変わりません。

### コアクラスの拡張

本gemは `Object` / `NilClass` / `Array` / `Hash` / `Range` / `Struct` / `Data` / `Set` / `Integer` / `Float` / `Rational` / `BigDecimal` / `Time` / `Date` / `DateTime` / `ActiveSupport::TimeWithZone` にメソッドを追加するモンキーパッチです。`#to_hexdigest_source` などのメソッド名が他のライブラリと衝突しないか確認してください。

### ActiveSupportのコア拡張の読み込み

`ActiveSupport::TimeWithZone` は ActiveSupport の autoload 経由でしか解決できないため、本gemは `require "active_support/time"` を無条件に実行します。これに伴い、`Time` / `Date` / `DateTime` / `Integer` / `Numeric` / `String` へのActiveSupportのコア拡張（`3.days` や `String#to_time` など）も読み込まれます。

Railsであればいずれも読み込まれているものなので影響はありませんが、Rails以外で使う場合はこの副作用を考慮してください。

なお、gem本体が依存するのは `activesupport` のみで、`railties` には依存しません（ジェネレータは `lib/generators` 配下に置かれ、Railsのジェネレータ探索から呼ばれた時にだけ読み込まれます）。

### 数値の型の正規化

`Integer` / `Float` / `Rational` / `BigDecimal` の `#to_hexdigest_type` は `"Numeric"` を返します。「型で区別する」という本gemの原則に対する意図的な例外です。

同じ数が経路によって別のクラスで現れるRailsでは、型を実装クラス名のままにするとダイジェストが割れます。詳細は[数値](#数値)を参照してください。

### 時刻の型の正規化

`Time` / `DateTime` / `ActiveSupport::TimeWithZone` の `#to_hexdigest_type` は `"Time"` を返します。「型で区別する」という本gemの原則に対する意図的な例外です。

同じ瞬間が経路によって別のクラスで現れるRailsでは、型を実装クラス名のままにするとダイジェストが割れます。詳細は[日時](#日時)を参照してください。

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
