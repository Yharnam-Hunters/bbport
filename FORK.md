# Yharnam-Hunters fork of bbport

Public fork of <https://github.com/deadinside28/bloodborne_pc> (GPL-2.0-or-later), used as the
runtime scaffold of [Paleblood](https://github.com/Yharnam-Hunters/Paleblood). Upstream is the `upstream` remote; this fork's `master` is
upstream plus the changes below, rebased when upstream moves.

## Local changes

- `src/bbgame.h`, `src/probe.c`: game library plug-in point. With `BB_GAME_LIB=/path/lib.so`,
  the loader loads the library after relocations and patches, before any game code runs, and
  calls its `bbgame_init(const BbGameHost *)`. The library can replace a game function by a
  14-byte absolute jump at its entry (`install_hook`). Refused when `BB_SKIP_GAME_CHECK=1`:
  addresses are only valid for the executable `scripts/game_check.py` pins.

## Rules

The same rules as Paleblood's [CONTRIBUTING.md](https://github.com/Yharnam-Hunters/Paleblood/blob/main/CONTRIBUTING.md):

- **Your own copy.** Everything starts from your own console and your own copy of the game,
  dumped from your own PS4. This repository does not provide or point to game files, pkgs,
  firmware, keys or decryption tools. Requests for or links to game files, in issues, pull
  requests or anywhere else, are removed and may lead to a ban.
- **No game files, ever**: no binaries, assets, extracted data or decompiler output.
- **No screenshots, clips or images of the game**, anywhere in this repository: not in commits,
  issues or pull requests. The only images allowed are recordings of tool output under
  `docs/assets/`, listed in `docs/assets/ALLOWLIST` with the command that produced them.
- `tools/check_no_game_data.py` enforces the file rules in the pre-commit hook
  (`tools/install_hooks.sh`) and in CI.
