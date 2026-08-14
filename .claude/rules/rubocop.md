---
paths: .rubocop.yml
---

# RuboCop 設定

## 前提(omakase ベース)

- `rubocop-rails-omakase` を `inherit_gem` している。omakase 側で `Style` / `Layout` / `Lint` / `Metrics` / `Naming` の各部門は丸ごと `Enabled: false` にされている
- omakase が個別に再有効化済みの cop 以外は、`Enabled: true` を明記しない限りその cop の設定(`EnforcedStyle` / `Max` 等)を書いても無視される
- 逆に omakase が既に有効化・設定済みの cop には `Enabled: true` を重ねて書かない(例: `Layout/LeadingCommentSpace` は追加オプションのみ書く)
- cop を追加・変更する前に、`bundle show rubocop-rails-omakase` のパスから実際の `rubocop.yml` を確認し、既に有効化されているか・既定値は何かを確認する

## 冗長な記述を避ける

- 追加・変更する値が RuboCop 本体または omakase の既定値と同じ場合は書かない(書いても no-op)
- コメントで既定値からの変更理由を書く場合、「何の既定値か」(RuboCop 本体 / omakase / standardrb)を混同しない
- 定期的に `.rubocop.yml` 全体を棚卸しし、既定値と同じになっている記述・意味を持たなくなった記述がないか確認する

## Exclude / Include

- `inherit_mode: merge` を指定しない限り、`Exclude` / `Include` は配列ごと上書きされ継承元とマージされない
- `AllCops.Exclude` を変更する場合、既存の除外対象(`bin/` `tmp/` `vendor/` `coverage/`)を漏らさないこと。RuboCop 本体既定の `.git/` `node_modules/` 除外も上書きで消える点に注意する
- 特定 cop に `Include` を追加したいだけの場合は `Style/StringLiterals` の例に倣い、`inherit_mode: merge: [Include]` で継承元の指定を壊さずに追加する

## バージョン整合

- `AllCops.TargetRubyVersion` は `.ruby-version` および gemspec の `required_ruby_version` と必ず一致させる

## 変更方針

- 既存の `Enabled: true` / `Max` / `Exclude` を理由なく緩めない
- 変更後は `bundle exec rubocop` を実行し、意図通りに検出・非検出になることを確認してから反映する
