#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Everything that must pass before a push of this fork. The pre-push hook (tools/hooks/pre-push)
# runs it on every git push and refuses the push when it fails; it can also be run alone.
set -uo pipefail
# git exports GIT_DIR, GIT_INDEX_FILE and similar variables to hooks; the gate runs git in other
# repositories (its tests clone one and commit there), so none of them may leak in.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_COMMON_DIR GIT_OBJECT_DIRECTORY \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES
cd "$(git rev-parse --show-toplevel)"
ident="$(git config user.name) <$(git config user.email)>"
fail=0

upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo origin/master)
# the commits being pushed: from the hook (BB_PUSH_RANGE), else what the upstream does not have
if [ -n "${BB_PUSH_RANGE:-}" ]; then read -ra range <<<"$BB_PUSH_RANGE"; else range=("$upstream..HEAD"); fi

others=$(git log "${range[@]}" --format='%an <%ae>%n%cn <%ce>' | sort -u | grep -vx "$ident" || true)
if [ -z "$others" ]; then echo "ok   authors and committers"; else echo "FAIL authors: $others"; fail=1; fi
refused=0
while IFS= read -r pattern; do
    [ -n "$pattern" ] || continue
    n=$(git log "${range[@]}" --format=%B | grep -ciE -- "$pattern" || true)
    refused=$((refused + n))
done < <(git config --get-all bb.refuseMessage || true)
if [ "$refused" = 0 ]; then echo "ok   commit messages (bb.refuseMessage)"; else echo "FAIL $refused line(s) in unpushed commit messages match bb.refuseMessage"; fail=1; fi
# changes inside a submodule's own checkout are its business; a moved submodule pointer is not
if [ -z "$(git status --porcelain --ignore-submodules=dirty)" ]; then echo "ok   clean working tree"; else echo "FAIL uncommitted changes"; fail=1; fi
if python3 tools/check_no_game_data.py --tracked >/dev/null 2>&1; then echo "ok   no game data"; else echo "FAIL tools/check_no_game_data.py --tracked"; fail=1; fi
if [ -x "$(git rev-parse --git-path hooks/pre-commit)" ]; then echo "ok   pre-commit hook installed"; else echo "FAIL run tools/install_hooks.sh"; fail=1; fi

if [ $fail = 0 ]; then echo "pre-push: all green"; else echo "pre-push: NOT ready to push"; fi
exit $fail
