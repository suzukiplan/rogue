.map_scroll_sub
    ld a, (hl)
    sub 8
    ld (hl), a
    ret

.map_scroll_add
    ld a, (hl)
    add 8
    ld (hl), a
    ret

.map_scroll_left
    in a, ($B4)
    ld b, a
    and $F0
    ld c, a
    ld a, b
    dec a
    and $0F
    or c
    out ($B4), a

    ld b, 28
    ld hl, vdp_scroll_bg_x
map_scroll_left_loop:
    call map_scroll_sub
    call map_scroll_left_sp
    call vdp_vsync_wait
    djnz map_scroll_left_loop

    ld b, 3
map_scroll_left_loop2:
    call map_scroll_sub
    call vdp_vsync_wait
    djnz map_scroll_left_loop2

    ld a, 33
    ld (map_left), a
    xor a
    ld (vdp_scroll_bg_x), a
    call map_render
    ret

.map_scroll_left_sp
    ld a, (vdp_oam_addr + oam_size * si_player + oam_x)
    add 8
    ld (vdp_oam_addr + oam_size * si_player + oam_x), a
    ld a, (player_x + 1)
    add 8
    ld (player_x + 1), a
    ld a, (vdp_oam_addr + oam_size * si_weapon0 + oam_x)
    add 8
    ld (vdp_oam_addr + oam_size * si_weapon0 + oam_x), a
    ld a, (vdp_oam_addr + oam_size * si_weapon1 + oam_x)
    add 8
    ld (vdp_oam_addr + oam_size * si_weapon1 + oam_x), a
    ret

.map_scroll_right
    in a, ($B4)
    ld b, a
    and $F0
    ld c, a
    ld a, b
    inc a
    and $0F
    or c
    out ($B4), a

    ld b, 28
    ld hl, vdp_scroll_bg_x
map_scroll_right_loop:
    call map_scroll_add
    call map_scroll_right_sp
    call vdp_vsync_wait
    djnz map_scroll_right_loop

    ld b, 3
map_scroll_right_loop2:
    call map_scroll_add
    call vdp_vsync_wait
    djnz map_scroll_right_loop2

    ld a, 63
    ld (map_left), a
    xor a
    ld (vdp_scroll_bg_x), a
    call map_render
    ret

.map_scroll_right_sp
    ld a, (vdp_oam_addr + oam_size * si_player + oam_x)
    sub 8
    ld (vdp_oam_addr + oam_size * si_player + oam_x), a
    ld a, (player_x + 1)
    sub 8
    ld (player_x + 1), a
    ld a, (vdp_oam_addr + oam_size * si_weapon0 + oam_x)
    sub 8
    ld (vdp_oam_addr + oam_size * si_weapon0 + oam_x), a
    ld a, (vdp_oam_addr + oam_size * si_weapon1 + oam_x)
    sub 8
    ld (vdp_oam_addr + oam_size * si_weapon1 + oam_x), a
    ret

