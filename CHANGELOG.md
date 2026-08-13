## [Unreleased]

### 追加

- `Struct` / `Data` に `#to_hexdigest_source` を実装（メンバー名と値の組で決まる）
- `Set` に `#to_hexdigest_source` を実装（`Array` へ委譲し、挿入順に依存しない）
- `Time` / `DateTime` に `#to_hexdigest_source` を実装（UTCへ変換し、ナノ秒精度で正規化）
- `Date` に `#to_hexdigest_source` を実装（ISO 8601の日付）
- `::Decentworks::HexdigestSupport::OptionalExtensions.apply!` を追加。本gemより後に `require "set"` / `require "date"` した場合に拡張を適用する

### 変更

- **破壊的**: `nil` の `#to_hexdigest_source` を空文字から `"nil"` へ変更。`nil` を含む値のダイジェストが変わります

## [0.1.0] - 2026-08-07

- Initial release
