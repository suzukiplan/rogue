.map_render_init
    xor a
    ld (map_top), a
    ld (map_left), a
    ld (map_sx), a
    ld (map_sy), a
    ; Attribute を $84 で更新
    ld hl, vdp_attr_bg
    ld bc, $0400
map_render_init_attr:
    ld a, $04
    ld (hl), a
    inc hl
    dec bc
    ld a, b
    and a
    jnz map_render_init_attr
    ld a, c
    and a
    jnz map_render_init_attr

.map_render
    ld a, (map_top)
    ld l, a
    ld h, 64
    ld a, $00
    out ($C5), a
    ld de, hl
    ld hl, vdp_nametbl_bg

    ld c, 32
map_render_loopY:
    ld b, 32
map_render_loopX:
    push de
    ld a, (map_left)
    add 32
    sub b
    and $3F
    add e
    ld e, a
    ld a, $A0
    adc d
    ld d, a
    ld a, (de)
    ld (hl), a
    pop de
    inc hl
    djnz map_render_loopX

    add de, 64
    ld a, d
    and $0F
    ld d, a

    dec c
    jnz map_render_loopY
    ret
