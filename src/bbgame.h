// SPDX-License-Identifier: GPL-2.0-or-later
// Yharnam-Hunters: interface between the loader and a game library (BB_GAME_LIB).
// The loader maps and relocates the image, applies patches, then loads the library and calls
// its bbgame_init before any game code runs. The library replaces game functions by asking
// the loader to install a jump at their entry. Offsets are guest offsets (ELF p_vaddr).
#pragma once

#include <stdint.h>

#define BBGAME_API_VERSION 1u

typedef struct BbGameHost {
    uint32_t version;          /* BBGAME_API_VERSION */
    unsigned char *image;      /* host address of guest offset 0 */
    uint64_t image_size;
    /* Replace the function at `offset`, `size` bytes long, by a jump to `target`. Returns 0, or
       -1 if the function is shorter than the 14-byte jump or not inside an executable segment. */
    int (*install_hook)(uint64_t offset, uint64_t size, const void *target);
} BbGameHost;

/* Exported by the game library. Returns 0, or nonzero to stop the loader. */
typedef int (*BbGameInit)(const BbGameHost *host);
#define BBGAME_INIT_SYMBOL "bbgame_init"
