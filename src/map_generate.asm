.map_generate
    xor a
    out ($B4), a
    call map_generate_64x64
    ld a, $01
map_generate_loop:
    out ($B5), a
    inc a
    jnz map_generate_loop

    ld a, 15
    out ($B4), a
    call map_generate_64x64d
    xor a
    out ($B4), a
    ret

.map_generate_64x64
    ; ゼロクリア
    ld hl, $A000
    ld bc, $2000
map_generate_64x64_clear:
    ld a, $02
    ld (hl), a
    inc hl
    dec bc
    ld a, b
    and a
    jnz map_generate_64x64_clear
    ld a, c
    and a
    jnz map_generate_64x64_clear

    ; 8x8 毎に 2x2 の壁を描画
    ld hl, $A000

    ld c, 8
map_generate_64x64_2x2_y:
    ld b, 8
map_generate_64x64_2x2_x:
    push hl
        add hl, 3 * 64 + 3
        ld a, $80
        ld (hl), a
        inc hl
        ld (hl), a
        inc hl
        ld a, $01
        ld (hl), a
        add hl, 62
        ld a, $80
        ld (hl), a
        inc hl
        ld (hl), a
        inc hl
        ld a, $01
        ld (hl), a
        add hl, 62
        ld (hl), a
        inc hl
        ld (hl), a
        inc hl
        ld (hl), a
    pop hl
    add hl, 8
    djnz map_generate_64x64_2x2_x
    dec c
    add hl, 7 * 64
    jnz map_generate_64x64_2x2_y

    ; 壁 ($80) で上下を囲む
    ld hl, $A000
    ld b, 64
map_generate_64x64_wall_ud:
    ld a, b
    cp 30
    jz map_generate_64x64_wall_ud_skip
    cp 31
    jz map_generate_64x64_wall_ud_skip
    cp 32
    jz map_generate_64x64_wall_ud_skip
    cp 33
    jz map_generate_64x64_wall_ud_skip
    ld a, $80
    ld (hl), a
    add hl, 64
    ld a, $01
    ld (hl), a
    add hl, 64 * 62
    ld a, $80
    ld (hl), a
    add hl, -(64 * 63)
    inc hl
    djnz map_generate_64x64_wall_ud
    jr map_generate_64x64_wall_ud_end
map_generate_64x64_wall_ud_skip:
    ld a, $02
    ld (hl), a
    add hl, 64
    ld a, $02
    ld (hl), a
    add hl, 64 * 62
    ld a, $02
    ld (hl), a
    add hl, -(64 * 63)
    inc hl
    djnz map_generate_64x64_wall_ud
map_generate_64x64_wall_ud_end:

    ; 壁 ($80) で左右を囲む
    ld hl, $A000 + 64
    ld b, 62
map_generate_64x64_wall_lr:
    ld a, b
    cp 29
    jz map_generate_64x64_wall_lr_skip02
    cp 30
    jz map_generate_64x64_wall_lr_skip02
    cp 31
    jz map_generate_64x64_wall_lr_skip02
    cp 32
    jz map_generate_64x64_wall_lr_skip01
    ld a, $80
    ld (hl), a
    inc hl
    ld a, $01
    ld (hl), a
    add hl, 62
    ld a, $80
    ld (hl), a
    inc hl
    djnz map_generate_64x64_wall_lr
    ret
map_generate_64x64_wall_lr_skip01:
    ld a, $01
    ld (hl), a
    inc hl
    ld a, $01
    ld (hl), a
    add hl, 62
    ld a, $01
    ld (hl), a
    inc hl
    djnz map_generate_64x64_wall_lr
    ret
map_generate_64x64_wall_lr_skip02:
    ld a, $02
    ld (hl), a
    inc hl
    ld a, $02
    ld (hl), a
    add hl, 62
    ld a, $02
    ld (hl), a
    inc hl
    djnz map_generate_64x64_wall_lr
    ret

.map_generate_64x64d
    ; ゼロクリア
    ld hl, $A000
    ld bc, $2000
map_generate_64x64d_clear:
    ld a, $01
    ld (hl), a
    inc hl
    dec bc
    ld a, b
    and a
    jnz map_generate_64x64d_clear
    ld a, c
    and a
    jnz map_generate_64x64d_clear

    ; 8x8 毎に 2x2 の壁を描画
    ld hl, $A000

    ld c, 8
map_generate_64x64d_2x2_y:
    ld b, 8
map_generate_64x64d_2x2_x:
    push hl
        add hl, 3 * 64 + 3
        ld a, $80
        ld (hl), a
        inc hl
        ld (hl), a
        inc hl
        ld a, $01
        ld (hl), a
        add hl, 62
        ld a, $80
        ld (hl), a
        inc hl
        ld (hl), a
        inc hl
        ld a, $01
        ld (hl), a
        add hl, 62
        ld (hl), a
        inc hl
        ld (hl), a
        inc hl
        ld (hl), a
    pop hl
    add hl, 8
    djnz map_generate_64x64d_2x2_x
    dec c
    add hl, 7 * 64
    jnz map_generate_64x64d_2x2_y

    ; 壁 ($80) で上下を囲む
    ld hl, $A000
    ld b, 64
map_generate_64x64d_wall_ud:
    ld a, b
    cp 30
    jz map_generate_64x64d_wall_ud_skip
    cp 31
    jz map_generate_64x64d_wall_ud_skip
    cp 32
    jz map_generate_64x64d_wall_ud_skip
    cp 33
    jz map_generate_64x64d_wall_ud_skip
    ld a, $80
    ld (hl), a
    add hl, 64
    ld a, $01
    ld (hl), a
    add hl, 64 * 62
    ld a, $80
    ld (hl), a
    add hl, -(64 * 63)
    inc hl
    djnz map_generate_64x64d_wall_ud
    jr map_generate_64x64d_wall_ud_end
map_generate_64x64d_wall_ud_skip:
    ld a, $01
    ld (hl), a
    add hl, 64
    ld a, $01
    ld (hl), a
    add hl, 64 * 62
    ld a, $01
    ld (hl), a
    add hl, -(64 * 63)
    inc hl
    djnz map_generate_64x64d_wall_ud
map_generate_64x64d_wall_ud_end:

    ; 壁 ($80) で左右を囲む
    ld hl, $A000 + 64
    ld b, 62
map_generate_64x64d_wall_lr:
    ld a, b
    cp 29
    jz map_generate_64x64d_wall_lr_skip02
    cp 30
    jz map_generate_64x64d_wall_lr_skip02
    cp 31
    jz map_generate_64x64d_wall_lr_skip02
    cp 32
    jz map_generate_64x64d_wall_lr_skip01
    ld a, $80
    ld (hl), a
    inc hl
    ld a, $01
    ld (hl), a
    add hl, 62
    ld a, $80
    ld (hl), a
    inc hl
    djnz map_generate_64x64d_wall_lr
    ret
map_generate_64x64d_wall_lr_skip01:
    ld a, $01
    ld (hl), a
    inc hl
    ld a, $01
    ld (hl), a
    add hl, 62
    ld a, $01
    ld (hl), a
    inc hl
    djnz map_generate_64x64d_wall_lr
    ret
map_generate_64x64d_wall_lr_skip02:
    ld a, $01
    ld (hl), a
    inc hl
    ld a, $01
    ld (hl), a
    add hl, 62
    ld a, $01
    ld (hl), a
    inc hl
    djnz map_generate_64x64d_wall_lr
    ret
