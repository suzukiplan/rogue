.map_adjust
    call map_adjust_top
    call map_adjust_bottom
    call map_adjust_left
    call map_adjust_right
    ret

.map_adjust_top
    ld a, (map_top)
    cp $3F
    ret z ; スクロール上限なのでスクロールしない

    ld a, (player_y + 1)
    sub 32
    ret nc

    ; プレイヤ座標補正
    push af
    ld a, 32
    ld (player_y + 1), a
    pop af

    ; sy を更新
    ld hl, map_sy
    add (hl)
    ld (hl), a
    ld (vdp_scroll_bg_y), a

    ; sy が -8 以下かチェック
    and $FF
    ret p ; 正数なのでそのままで OK
    cp $F9
    ret nc ; -7 以上なのでそのままで OK

    ; スクロール補正 +8
    add 8
    ld (map_sy), a
    ld (vdp_scroll_bg_y), a

    ; マップ描画基点をデクリメント
    ld hl, map_top
    ld a, (map_top)
    dec a
    and $3F
    ld (map_top), a

    ; リミットに到達した場合は再補正をする
    cp $3F
    jnz map_adjust_top_render
    xor a
    ld (map_sy), a
    ld (vdp_scroll_bg_y), a
map_adjust_top_render:
    call map_render
    ret

.map_adjust_bottom
    ld a, (map_top)
    cp 39
    ret z ; スクロール上限なのでスクロールしない

    ld a, (player_y + 1)
    sub 159
    ret c

    ; プレイヤ座標補正
    push af
    ld a, 159
    ld (player_y + 1), a
    pop af

    ; sy を更新
    ld hl, map_sy
    add (hl)
    ld (hl), a
    ld (vdp_scroll_bg_y), a

    ; sy が 8 以上かチェック
    and $FF
    ret m ; 負数なのでそのままで OK
    cp $08
    ret c ; 7 以下なのでそのままで OK

    ; スクロール補正 -8
    sub 8
    ld (map_sy), a
    ld (vdp_scroll_bg_y), a

    ; マップ描画基点をインクリメント
    ld a, (map_top)
    inc a
    and $3F
    ld (map_top), a

    ; リミットに到達した場合は再補正をする
    cp 39
    jnz map_adjust_bottom_render
    xor a
    ld (map_sy), a
    ld (vdp_scroll_bg_y), a
map_adjust_bottom_render:
    call map_render
    ret

.map_adjust_left
    ld a, (map_left)
    cp $3F
    ret z ; スクロール上限なのでスクロールしない

    ld a, (player_x + 1)
    sub 32
    ret nc

    ; プレイヤ座標補正
    push af
    ld a, 32
    ld (player_x + 1), a
    pop af

    ; sx を更新
    ld hl, map_sx
    add (hl)
    ld (hl), a
    ld (vdp_scroll_bg_x), a

    ; sx が -8 以下かチェック
    and $FF
    ret p ; 正数なのでそのままで OK
    cp $F9
    ret nc ; -7 以上なのでそのままで OK

    ; スクロール補正 +8
    add 8
    ld (map_sx), a
    ld (vdp_scroll_bg_x), a

    ; マップ描画基点をデクリメント
    ld a, (map_left)
    dec a
    and $3F
    ld (map_left), a

    ; リミットに到達した場合は再補正をする
    cp $3F
    jnz map_adjust_left_render
    xor a
    ld (map_sx), a
    ld (vdp_scroll_bg_x), a
map_adjust_left_render:
    call map_render
    ret

.map_adjust_right
    ld a, (map_left)
    cp 33
    ret z ; スクロール上限なのでスクロールしない

    ld a, (player_x + 1)
    sub 208
    ret c

    ; プレイヤ座標補正
    push af
    ld a, 208
    ld (player_x + 1), a
    pop af

    ; sx を更新
    ld hl, map_sx
    add (hl)
    ld (hl), a
    ld (vdp_scroll_bg_x), a

    ; sx が 8 以上かチェック
    and $FF
    ret m ; 負数なのでそのままで OK
    cp $08
    ret c ; 7 以下なのでそのままで OK

    ; スクロール補正 -8
    sub 8
    ld (map_sx), a
    ld (vdp_scroll_bg_x), a

    ; マップ描画基点をインクリメント
    ld a, (map_left)
    inc a
    and $3F
    ld (map_left), a

    ; リミットに到達した場合は再補正をする
    cp 33
    jnz map_adjust_right_render
    xor a
    ld (map_sx), a
    ld (vdp_scroll_bg_x), a
map_adjust_right_render:
    call map_render
    ret

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
    call map_render

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

    ; 壁 ($80) で左右を囲む
    ld hl, $A000 + 64
    ld b, 62
map_generate_64x64_wall_lr:
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
