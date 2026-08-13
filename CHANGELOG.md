## [Unreleased]

### 追加

- `Struct` / `Data` に `#to_hexdigest_source` を実装（メンバー名と値の組で決まる）
- `Set` に `#to_hexdigest_source` を実装（`Array` へ委譲し、挿入順に依存しない）
- `Time` / `DateTime` / `ActiveSupport::TimeWithZone` に `#to_hexdigest_source` を実装（UTCへ変換し、ナノ秒精度で正規化）
- `Date` に `#to_hexdigest_source` を実装（ISO 8601の日付）
- 時刻を表す型に共通の実装を持つ `::Decentworks::HexdigestSupport::TimeLike` を追加

### 変更

- **破壊的**: `nil` の `#to_hexdigest_source` を空文字から `"nil"` へ変更。`nil` を含む値のダイジェストが変わります
- `Time` / `DateTime` / `ActiveSupport::TimeWithZone` の `#to_hexdigest_type` を `"Time"` へ正規化。Railsでは同じ瞬間が経路によって別のクラスで現れるため、クラス名を型にするとダイジェストが割れてしまいます
- `activesupport`（`>= 8.0`）を依存に追加

## [0.1.0] - 2026-08-07

- Initial release
