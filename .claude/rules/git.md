# Git

- Conventional Commits形式、本文は日本語（例: feat: ユーザー認証にOAuth2を追加）
- コミット・push・mergeは実行しない。これらはユーザーが判断して実行する
- 依頼された場合もコミットメッセージ案の提示までにとどめ、実行はユーザーに委ねる
- 作業ツリーへのファイル編集（Edit/Writeツールによる書き換え）は行ってよい。テスト・Lintの実行結果とあわせて報告する
- git add・stash・checkout・rebase・merge等、インデックスやHEADを変更するgitコマンドの実行は行わない。ステージングはユーザーが行う

## コマンドの実行

- `status` / `diff` / `log` 等の読み取り系コマンドは `--no-optional-locks` を付けて実行する
  - 例: `git --no-optional-locks status`、`git --no-optional-locks diff`
  - これらのコマンドはインデックスを更新するため `.git/index.lock` を作成する。
    削除に失敗する環境（リモートセッションのマウント配下など）や実行中断時にlockが残り、
    以後のgit操作がすべて失敗するようになる
  - `--no-optional-locks` を付けるとlockを取らなくなる。書き込み系コマンドのlockには影響しない
