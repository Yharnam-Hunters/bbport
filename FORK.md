# Yharnam-Hunters fork of bbport

Private fork of <https://github.com/deadinside28/bloodborne_pc> (GPL-2.0-or-later), used as the
runtime scaffold of bloodborne-port. Upstream is the `upstream` remote; this fork's `master` is
upstream plus the changes below, rebased when upstream moves.

## Local changes

- `src/bbgame.h`, `src/probe.c`: game library plug-in point. With `BB_GAME_LIB=/path/lib.so`,
  the loader loads the library after relocations and patches, before any game code runs, and
  calls its `bbgame_init(const BbGameHost *)`. The library can replace a game function by a
  14-byte absolute jump at its entry (`install_hook`). Refused when `BB_SKIP_GAME_CHECK=1`:
  addresses are only valid for the executable `scripts/game_check.py` pins.
