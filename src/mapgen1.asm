.mapgen1
    ; 最初の部屋を作成
    call mapgen_make_room ; 部屋をランダム位置に作成して中央座標が BC に返る
    ld de, bc             ; 中央座標を DE へ保持
    ld a, b
    ld (map1st_x), a
    ld a, c
    ld (map1st_y), a

    ; 2つ目以降の部屋を作成
    in a, ($CA)
    and $07
    add 2
    ld b, a
mapgen1_loop:
    push bc
    push de
    call mapgen_make_room ; 部屋をランダム位置に作成して中央座標が BC に返る
    pop de
    push bc
    call mapgen1_dig ; 直前の部屋の中央座標（DE）と現在の部屋の中央座標（BC）を掘って繋げる
    pop bc
    ld de, bc
    pop bc
    djnz mapgen1_loop

    ret

; BC → DE に向かって 2x2 の穴を掘る
.mapgen1_dig
    ; 横方向に掘る
mapgen1_dig_horizontal:
    ld a, b
    cmp d
    jz mapgen1_dig_vertical ; もう掘れない
    jc mapgen1_dig_h_plus
    dec b
    ld a, b
    cp 2
    jc mapgen1_dig_vertical ; もう掘れない
    jr mapgen1_dig_horizontal_do
mapgen1_dig_h_plus:
    inc b
    ld a, b
    cp 62
    jnc mapgen1_dig_vertical ; もう掘れない
mapgen1_dig_horizontal_do:
    push de
    ld de, $0202
    ld a, (mapchip_ground)
    call mapgen_fill
    pop de
    jr mapgen1_dig_horizontal

    ; 縦方向に掘る
mapgen1_dig_vertical:
    ld a, c
    cmp e
    ret z ; もう掘れない
    jc mapgen1_dig_v_plus
    dec c
    jr mapgen1_dig_vertical_do
mapgen1_dig_v_plus:
    inc c
mapgen1_dig_vertical_do:
    push de
    ld de, $0202
    ld a, (mapchip_ground)
    call mapgen_fill
    pop de
    jr mapgen1_dig_vertical
    ret
