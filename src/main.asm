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
    call print_debug                ; デバッグ情報を表示
    jr main_loop

.end:
    halt

.print_debug
    ; ヘッダテキスト表示
    ld hl, $0202
    ld de, hello
    call vdp_print_fg_with_DEHL

    ; 現在のVXを表示
    ld hl, $0302
    ld de, str_vx
    call vdp_print_fg_with_DEHL
    ld a, (map_top)
    ld hl, $030B
    call vdp_print_u8_with_AHL
    add hl, $0400
    xor a
    ld (hl), a
    inc hl
    ld (hl), a

    ; 現在のVYを表示
    ld hl, $0402
    ld de, str_vy
    call vdp_print_fg_with_DEHL
    ld a, (map_left)
    ld hl, $040B
    call vdp_print_u8_with_AHL
    add hl, $0400
    xor a
    ld (hl), a
    inc hl
    ld (hl), a
    ret

hello: db "ROGUE LIKE A.RPG PROTOTYPE", 0
str_vx: db "MAP  TOP:",0
str_vy: db "MAP LEFT:",0

#include "vars.asm"
#include "vdp.asm"
#include "joypad.asm"
#include "player.asm"
#include "map.asm"
