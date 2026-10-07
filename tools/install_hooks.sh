#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Maintainer-only: install the automatic backup hook (tools/hooks/post-commit-backup.sh).
#   BB_BACKUP_DIR=<dir outside every repository> [BB_ARCHIVE_URL=<archive repo>] \
#   [BB_BACKUP_BRANCH=master] tools/install_hooks.sh --maintainer
# Without --maintainer it does nothing: contributors need no hooks in this repository.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
if [ "${1:-}" != "--maintainer" ]; then
    echo "nothing to install (the backup hook is maintainer-only: --maintainer)"
    exit 0
fi
[ -n "${BB_BACKUP_DIR:-}" ] && git -C "$root" config bb.backupDir "$BB_BACKUP_DIR"
[ -n "${BB_ARCHIVE_URL:-}" ] && git -C "$root" config bb.archiveRemote "$BB_ARCHIVE_URL"
git -C "$root" config bb.backupBranch "${BB_BACKUP_BRANCH:-master}"
if [ -z "$(git -C "$root" config --get bb.backupDir || true)" ]; then
    echo "backups off (set BB_BACKUP_DIR to enable)"
    exit 0
fi
chmod +x "$root/tools/hooks/post-commit-backup.sh"
ln -sf ../../tools/hooks/post-commit-backup.sh "$root/.git/hooks/post-commit"
git -C "$root" config bb.backup true
echo "backups on: every 10 commits on $(git -C "$root" config --get bb.backupBranch) to $(git -C "$root" config --get bb.backupDir)"
"$root/tools/hooks/post-commit-backup.sh" --now
