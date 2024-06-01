#define PLAYER_OAM vdp_oam_addr + oam_size * si_player
#define WEAPON0_OAM vdp_oam_addr + oam_size * si_weapon0
#define WEAPON1_OAM vdp_oam_addr + oam_size * si_weapon1
#define PLAYER_MOVE_POW 77
#define PLAYER_MOVE_DEC 44

.player_init
    xor a
    ld (player_an), a
    ld (player_dir), a
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

.player_calc_map_position
    ; プレイヤのマップ上のX座標を求める
    ld a, (player_x + 1)
    ld hl, map_sx
    add (hl)
    ld h, a
    ld l, 8
    ld a, $01
    out ($C5), a
    ld a, l
    ld hl, map_left
    add (hl)
    and $3F
    ld (player_mx), a

    ; プレイヤのマップ上のY座標を求める
    ld a, (player_y + 1)
    ld hl, map_sy
    add (hl)
    ld h, a
    ld l, 8
    ld a, $01
    out ($C5), a
    ld a, l
    ld hl, map_top
    add (hl)
    and $3F
    ld (player_my), a
    ret

#include "player_map_limit_check.asm"
#include "player_move.asm"
#include "player_attack.asm"
#include "player_hitchk_map.asm"
