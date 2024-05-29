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
    xor a
    ld (map_left), a
map_scroll_left_loop:
    call map_scroll_left_bg
    call map_scroll_left_sp
    call vdp_vsync_wait
    djnz map_scroll_left_loop

    ld b, 3
map_scroll_left_loop2:
    call map_scroll_left_bg
    call vdp_vsync_wait
    djnz map_scroll_left_loop2
    xor a
    ld (vdp_scroll_bg_x), a
    call map_render
    ret

.map_scroll_left_bg
    push bc
    push hl
    ld a, (hl)
    sub 8
    ld (hl), a
    ld a, (map_top)
    ld l, a
    ld h, 64
    ld a, $00
    out ($C5), a
    ld a, h
    or $A0
    ld h, a
    ld a, (map_left)
    dec a
    and $3F
    ld (map_left), a
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    ld a, (map_left)
    inc a
    and $1F
    ld de, vdp_nametbl_bg
    add e
    ld e, a
    ld a, 0
    adc d
    ld d, a
    ld b, 32
map_scroll_left_bg_loop:
    ld a, (hl)
    ld (de), a
    add hl, 64
    add de, 32
    djnz map_scroll_left_bg_loop
    pop hl
    pop bc
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

    ld a, 32
    ld (map_left), a
    ld b, 28
    ld hl, vdp_scroll_bg_x
map_scroll_right_loop:
    call map_scroll_right_bg
    call map_scroll_right_sp
    call vdp_vsync_wait
    djnz map_scroll_right_loop

    ld b, 3
map_scroll_right_loop2:
    call map_scroll_right_bg
    call vdp_vsync_wait
    djnz map_scroll_right_loop2

    xor a
    ld (vdp_scroll_bg_x), a
    call map_render
    ret

.map_scroll_right_bg
    push bc
    push hl
    ld a, (hl)
    add 8
    ld (hl), a
    ld a, (map_top)
    ld l, a
    ld h, 64
    ld a, $00
    out ($C5), a
    ld a, h
    or $A0
    ld h, a
    ld a, (map_left)
    sub 32
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    ld a, (map_left)
    dec a
    and $1F
    ld de, vdp_nametbl_bg
    add e
    ld e, a
    ld a, 0
    adc d
    ld d, a
    ld b, 32
map_scroll_right_bg_loop:
    ld a, (hl)
    ld (de), a
    add hl, 64
    add de, 32
    djnz map_scroll_right_bg_loop
    ld hl, map_left
    inc (hl)
    pop hl
    pop bc
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

.map_scroll_top
    in a, ($B4)
    ld b, a
    and $0F
    ld c, a
    ld a, b
    sub $10
    and $F0
    or c
    out ($B4), a

    ld b, 23
    ld hl, vdp_scroll_bg_y
    xor a
    ld (map_top), a
map_scroll_top_loop:
    call map_scroll_top_bg
    call map_scroll_top_sp
    call vdp_vsync_wait
    djnz map_scroll_top_loop

    call map_scroll_top_bg
    call vdp_vsync_wait
    call map_scroll_top_bg
    call vdp_vsync_wait

    xor a
    ld (vdp_scroll_bg_y), a
    call map_render
    ld a, 39
    ld (map_top), a
    ret

.map_scroll_top_bg
    push bc
    push hl
    ld a, (hl)
    sub 8
    ld (hl), a
    ld a, (map_top)
    dec a
    and $3F
    ld (map_top), a
    ld l, a
    ld h, 64
    ld a, $00
    out ($C5), a
    ld a, h
    or $A0
    ld h, a
    ld a, (map_left)
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a

    push hl
    ld a, (map_top)
    inc a
    and $1F
    ld l, a
    ld h, 32
    xor a
    out ($C5), a
    ld de, vdp_nametbl_bg
    add hl, de
    ld de, hl
    pop hl

    ld b, 32
map_scroll_top_bg_loop:
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    djnz map_scroll_top_bg_loop
    pop hl
    pop bc
    ret

.map_scroll_top_sp
    ld a, (vdp_oam_addr + oam_size * si_player + oam_y)
    add 8
    ld (vdp_oam_addr + oam_size * si_player + oam_y), a
    ld a, (player_y + 1)
    add 8
    ld (player_y + 1), a
    ld a, (vdp_oam_addr + oam_size * si_weapon0 + oam_y)
    add 8
    ld (vdp_oam_addr + oam_size * si_weapon0 + oam_y), a
    ld a, (vdp_oam_addr + oam_size * si_weapon1 + oam_y)
    add 8
    ld (vdp_oam_addr + oam_size * si_weapon1 + oam_y), a
    ret

.map_scroll_bottom
    in a, ($B4)
    ld b, a
    and $0F
    ld c, a
    ld a, b
    add $10
    and $F0
    or c
    out ($B4), a

    ld b, 23
    ld hl, vdp_scroll_bg_y
    xor a
    ld (map_top), a
map_scroll_bottom_loop:
    call map_scroll_bottom_bg
    call map_scroll_bottom_sp
    call vdp_vsync_wait
    djnz map_scroll_bottom_loop
    call map_scroll_bottom_bg
    call vdp_vsync_wait
    xor a
    ld (vdp_scroll_bg_y), a
    ld a, 63
    ld (map_top), a
    call map_render
    ret

.map_scroll_bottom_bg
    push bc
    push hl
    ld a, (hl)
    add 8
    ld (hl), a
    ld a, (map_top)
    ld l, a
    ld h, 64
    ld a, $00
    out ($C5), a
    ld a, h
    or $A0
    ld h, a
    ld a, (map_left)
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a

    push hl
    ld a, (map_top)
    inc a
    and $3F
    ld (map_top), a
    add 24
    and $1F
    ld l, a
    ld h, 32
    xor a
    out ($C5), a
    ld de, vdp_nametbl_bg
    add hl, de
    ld de, hl
    pop hl

    ld b, 32
map_scroll_bottom_bg_loop:
    ld a, (hl)
    ld (de), a
    inc hl
    inc de
    djnz map_scroll_bottom_bg_loop
    pop hl
    pop bc
    ret

.map_scroll_bottom_sp
    ld a, (vdp_oam_addr + oam_size * si_player + oam_y)
    sub 8
    ld (vdp_oam_addr + oam_size * si_player + oam_y), a
    ld a, (player_y + 1)
    sub 8
    ld (player_y + 1), a
    ld a, (vdp_oam_addr + oam_size * si_weapon0 + oam_y)
    sub 8
    ld (vdp_oam_addr + oam_size * si_weapon0 + oam_y), a
    ld a, (vdp_oam_addr + oam_size * si_weapon1 + oam_y)
    sub 8
    ld (vdp_oam_addr + oam_size * si_weapon1 + oam_y), a
    ret
