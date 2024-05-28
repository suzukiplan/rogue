#include "actbl_define.asm"

org $0000

.reset
    di                              ; 割り込みは一切使わない
    ld sp, $0000                    ; スタックは 0xFFFF から使う
    call vdp_init                   ; 映像初期化
    call player_init                ; プレイヤの座標初期化
    call map_generate_64x64
    call map_render_init

main_loop:
    call vdp_vsync_wait             ; 垂直動機
    call joypad_update              ; ジョイパッド入力を更新（joypad, joypad_prev）
    call player_move                ; 自機の移動
    call player_attack              ; 自機の攻撃（アイテム使用）
    call map_adjust                 ; マップ位置の調整
    call player_calc_map_position   ; マップ上のプレイヤ座標を算出
    call player_hitchk_map          ; マップとプレイヤの当たり判定
    call print_debug                ; デバッグ情報を表示
    jr main_loop

.end:
    halt

.print_debug
    ; ヘッダテキスト表示
    ld hl, $0202
    ld de, hello
    call vdp_print_fg_with_DEHL

    ; 現在のXを表示
    ld hl, $0302
    ld de, str_vx
    call vdp_print_fg_with_DEHL
    ld a, (player_mx)
    ld hl, $0305
    call vdp_print_u8_with_AHL
    add hl, $0400
    xor a
    ld (hl), a
    inc hl
    ld (hl), a

    ; 現在のYを表示
    ld hl, $0402
    ld de, str_vy
    call vdp_print_fg_with_DEHL
    ld a, (player_my)
    ld hl, $0405
    call vdp_print_u8_with_AHL
    add hl, $0400
    xor a
    ld (hl), a
    inc hl
    ld (hl), a

    ; 当たり判定枠を表示
    ld a, (player_mx)
    ld hl, map_left
    sub (hl)
    ld h, 8
    ld l, a
    ld a, 0
    out ($C5), a
    ld a, l
    ld hl, map_sx
    sub (hl)
    ld ($9000 + si_debug * oam_size + oam_x), a
    ld a, (player_my)
    ld hl, map_top
    sub (hl)
    inc a
    ld h, 8
    ld l, a
    ld a, 0
    out ($C5), a
    ld a, l
    ld hl, map_sy
    sub (hl)
    ld ($9000 + si_debug * oam_size + oam_y), a
    ld a, $80
    ld ($9000 + si_debug * oam_size + oam_attr), a
    ld a, $DD
    ld ($9000 + si_debug * oam_size + oam_ptn), a
    ld a, 2
    ld ($9000 + si_debug * oam_size + oam_width), a
    ld a, 1
    ld ($9000 + si_debug * oam_size + oam_height), a
    ld a, bank_player
    ld ($9000 + si_debug * oam_size + oam_bank), a

    ret

hello: db "ROGUE LIKE A.RPG PROTOTYPE", 0
str_vx: db "X:",0
str_vy: db "Y:",0
comma: db ",",0

#include "vars.asm"
#include "vdp.asm"
#include "joypad.asm"
#include "player.asm"
#include "map.asm"
