org $0000

.init
    di
    im 1
    ld sp, $0000
    call vdp_init

    ld hl, $0202
    ld de, hello
    call vdp_print_bg_with_DEHL
    call player_init

    ld hl, $0302
    ld de, str_vx
    call vdp_print_bg_with_DEHL

    ld hl, $0402
    ld de, str_vy
    call vdp_print_bg_with_DEHL

main_loop:
    call vdp_vsync_wait
    call joypad_update
    call player_move
    call player_attack

    ld de, (player_vx)
    ld hl, $0305
    call vdp_print_s16_with_DEHL
    ld a, ' '
    ld (hl), a
    inc hl
    ld (hl), a

    ld de, (player_vy)
    ld hl, $0405
    call vdp_print_s16_with_DEHL
    ld a, ' '
    ld (hl), a
    inc hl
    ld (hl), a

ld hl, $0502
ld a, (joypad)
and %00000010
jz md_on
ld de, str_md_off
call vdp_print_bg_with_DEHL
jp main_loop
md_on:
ld de, str_md_on
call vdp_print_bg_with_DEHL

    jmp main_loop

.end:
    jp end

hello: db "ROGUE LIKE A.RPG PROTOTYPE", 0
str_vx: db "VX:",0
str_vy: db "VY:",0
str_md_off: db "MT:OFF", 0
str_md_on:  db "MT:ON ", 0

#include "vars.asm"
#include "vdp.asm"
#include "joypad.asm"
#include "player.asm"

