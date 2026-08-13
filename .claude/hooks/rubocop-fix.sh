#!/bin/bash
# .claude/hooks/rubocop-fix.sh
# PostToolUse(Edit|Write) で発火。編集された .rb に rubocop -a をかけ、
# 残った違反を Claude にフィードバックする。
set -uo pipefail

input=$(cat)
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")

[[ -z "$file_path" ]] && exit 0
[[ "$file_path" != *.rb ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# --server で常駐プロセスを使い、毎回のRuby起動コスト（1〜2秒）を避ける
output=$(bundle exec rubocop --server --autocorrect --format simple "$file_path" 2>&1)
status=$?

if [[ $status -ne 0 ]]; then
  # exit 2 の stderr は Claude に渡り、自分で直させられる
  echo "RuboCop violations remain in ${file_path}:" >&2
  echo "$output" >&2
  exit 2
fi

exit 0
