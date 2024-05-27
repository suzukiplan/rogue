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

.player_calc_map_position
    ; プレイヤのマップ上のX座標を求める
    ld a, (map_left)
    push af
    ld a, (player_x + 1)
    ld h, a
    ld l, 8
    ld a, $01
    out ($C5), a
    pop af
    add l
    and $3F
    ld b, a
    ld a, (map_sx)
    and $FF
    jp m, player_calc_map_position_x_minus1
    and $0F
    jp nz, player_calc_map_position_x_plus1
    ld a, b
    jr player_calc_map_position_x_set
player_calc_map_position_x_minus1:
    ld a, b
    dec a
    and $3F
    jr player_calc_map_position_x_set
player_calc_map_position_x_plus1:
    ld a, b
    inc a
    and $3F
player_calc_map_position_x_set:
    ld (player_mx), a

    ; プレイヤのマップ上のY座標を求める
    ld a, (map_top)
    push af
    ld a, (player_y + 1)
    ld h, a
    ld l, 8
    ld a, $01
    out ($C5), a
    pop af
    add l
    and $3F
    ld b, a
    ld a, (map_sy)
    and $FF
    jp m, player_calc_map_position_y_minus1
    and $0F
    jp nz, player_calc_map_position_y_plus1
    ld a, b
    jr player_calc_map_position_y_set
player_calc_map_position_y_minus1:
    ld a, b
    dec a
    and $3F
    jr player_calc_map_position_y_set
player_calc_map_position_y_plus1:
    ld a, b
    inc a
    and $3F
player_calc_map_position_y_set:
    ld (player_my), a
    ret

#include "player_move.asm"
#include "player_attack.asm"
