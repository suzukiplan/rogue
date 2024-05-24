#include "actbl_define.asm"

org $0000

.reset
    di                              ; 割り込みは一切使わない
    ld sp, $0000                    ; スタックは 0xFFFF から使う
    call vdp_init                   ; 映像初期化

main_loop:
    call vdp_vsync_wait             ; 垂直動機
    call joypad_update              ; ジョイパッド入力を更新（joypad, joypad_prev）
    call player_move                ; 自機の移動
    call player_attack              ; 自機の攻撃（アイテム使用）
    call print_debug                ; デバッグ情報を表示
    jr main_loop

.end:
    halt

.print_debug
    ; ヘッダテキスト表示
    ld hl, $0202
    ld de, hello
    call vdp_print_fg_with_DEHL
    call player_init

    ; 現在のVXを表示
    ld hl, $0302
    ld de, str_vx
    call vdp_print_fg_with_DEHL
    ld de, (player_vx)
    ld hl, $0305
    call vdp_print_s16_with_DEHL
    add hl, $0400
    xor a
    ld (hl), a
    inc hl
    ld (hl), a

    ; 現在のVYを表示
    ld hl, $0402
    ld de, str_vy
    call vdp_print_fg_with_DEHL
    ld de, (player_vy)
    ld hl, $0405
    call vdp_print_s16_with_DEHL
    add hl, $0400
    xor a
    ld (hl), a
    inc hl
    ld (hl), a
    ret

hello: db "ROGUE LIKE A.RPG PROTOTYPE", 0
str_vx: db "VX:",0
str_vy: db "VY:",0

#include "vars.asm"
#include "vdp.asm"
#include "joypad.asm"
#include "player.asm"
