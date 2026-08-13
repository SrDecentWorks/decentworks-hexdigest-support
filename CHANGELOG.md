## [Unreleased]

### 追加

- `Struct` / `Data` に `#to_hexdigest_source` を実装（メンバー名と値の組で決まる）
- `Set` に `#to_hexdigest_source` を実装（`Array` へ委譲し、挿入順に依存しない）
- `Time` / `DateTime` / `ActiveSupport::TimeWithZone` に `#to_hexdigest_source` を実装（UTCへ変換し、ナノ秒精度で正規化）
- `Date` に `#to_hexdigest_source` を実装（ISO 8601の日付）
- 時刻を表す型に共通の実装を持つ `::Decentworks::HexdigestSupport::TimeLike` を追加
- オブジェクトIDを含む値を検出した場合の例外 `::Decentworks::HexdigestSupport::NonDeterministicSourceError` を追加。`#to_s` も `#to_hexdigest_source` も実装していないオブジェクト、および `Proc` や無名クラスのように独自の `#to_s` がオブジェクトIDを含む型が対象で、配列・ハッシュ・構造体の中に含まれている場合も検出します

### 変更

- **破壊的**: `nil` の `#to_hexdigest_source` を空文字から `"nil"` へ変更。`nil` を含む値のダイジェストが変わります
- **破壊的**: 値の引用・エスケープを `#inspect` から自前実装へ変更。`#inspect` は非ASCII文字を `Encoding.default_external` 次第でエスケープするため、同じ値でもロケールによってダイジェストが変わっていました。エスケープ対象を `"` と `\` のみに限ったため、**制御文字（改行・タブなど）を含む値のダイジェストが変わります**（ASCIIのみで制御文字を含まない値、およびUTF-8環境で求めた非ASCIIの値は変わりません）
- `Time` / `DateTime` / `ActiveSupport::TimeWithZone` の `#to_hexdigest_type` を `"Time"` へ正規化。Railsでは同じ瞬間が経路によって別のクラスで現れるため、クラス名を型にするとダイジェストが割れてしまいます
- `activesupport`（`>= 8.0`）を依存に追加

## [0.1.0] - 2026-08-07

- Initial release
