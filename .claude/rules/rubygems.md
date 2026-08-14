# gemの配布（RubyGems）

## バージョン制約

- `required_ruby_version` は `>= 4.0.0`、`activesupport` は `~> 8.1` を維持する
  - 利用想定がこのバージョン以降のため。旧バージョンのRuby / Railsへの対応は行わない
  - 「利用可能な範囲が狭い」という理由で緩めない

## gemに同梱するファイル

- `spec.files` はホワイトリスト方式で指定する。除外方式（`reject`）に戻さない
  - 除外方式は開発用ファイルが増えたときに指定漏れが起き、そのまま配布されてしまう
  - ホワイトリストなら追加漏れは「配布されない」側に倒れる
- 配布対象は以下のみ
  - ディレクトリ: `lib/` `sig/` `exe/`
  - ファイル: `README.md` `CHANGELOG.md` `LICENSE`
- 開発用ファイルは配布しない
  - `.claude/` `.rubocop.yml` `.ruby-version` `.rspec` `.gitignore`
  - `Steepfile` `rbs_collection.yaml` `rbs_collection.lock.yaml`
  - `Gemfile` `Gemfile.lock` `Rakefile` `CODE_OF_CONDUCT.md` `bin/` `spec/` gemspec自身
- `sig/` は配布対象。RBS型定義の同梱は本gemの提供価値のひとつ
- `lib/generators/**/templates/*.tt` は配布対象。ジェネレータの実行に必要

## 作者・ライセンス

- `authors` は `decentworks`、`email` は `yutaka.mizomoto@sr-decentworks.com`
- ライセンスファイルは `LICENSE` の1ファイルのみ。`LICENSE.txt` を再作成しない
- `LICENSE` の著作者表記は `decentworks`（`authors` と一致させる）

## メタデータ

- `rubygems_mfa_required` は `"true"` を維持する
  - rubygems.org 側でMFAが有効でないと `gem push` が拒否される点に注意
- `homepage_uri` / `source_code_uri` / `changelog_uri` を維持する

## リリース前の確認

- `bundle exec rake`（rspec / rubocop / steep）が通ること
- `CHANGELOG.md` の `[Unreleased]` をバージョン見出しに変更し、`lib/decentworks/date_support/version.rb` と一致させること
- 公開APIの変更・削除がある場合は、CHANGELOGに **破壊的変更** として移行方法まで書くこと
- `gem build` で同梱ファイル一覧を確認し、開発用ファイルが含まれていないこと
- `gem push` / `rake release` は実行しない。ユーザーが判断して実行する
