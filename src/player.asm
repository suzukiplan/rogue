#define PLAYER_OAM vdp_oam_addr + oam_size * si_player
#define WEAPON0_OAM vdp_oam_addr + oam_size * si_weapon0
#define WEAPON1_OAM vdp_oam_addr + oam_size * si_weapon1
#define PLAYER_MOVE_POW 77
#define PLAYER_MOVE_DEC 44

.player_init
    xor a
    ld (player_an), a
    ld (player_dir), a
    ld h, 100
    ld l, 0
    ld (player_x), hl
    ld (player_y), hl
    ld h, 0
    ld (player_vx), hl
    ld (player_vy), hl
    call player_render_refresh
    ret

player_render_refresh:
    ld hl, PLAYER_OAM
    ld a, (player_y + 1)
    ld (hl), a
    inc hl

    ld a, (player_x + 1)
    ld (hl), a
    inc hl

    ld a, $00
    ld (hl), a
    inc hl

    ld a, $80
    ld (hl), a
    inc hl

    ld a, 1
    ld (hl), a
    inc hl

    ld a, 1
    ld (hl), a
    inc hl

    ld a, bank_player
    ld (hl), a
    ret

#include "player_move.asm"
#include "player_attack.asm"
