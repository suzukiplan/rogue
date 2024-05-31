.mapgen1
    ; マップを壁 ($80) で埋める
    ld a, $80
    ld bc, $0000 ; X=0, Y=0
    ld de, $4040 ; W=64, H=64
    call mapgen_fill

    ; 最初の部屋を作成
    call mapgen_make_room ; 部屋をランダム位置に作成して中央座標が BC に返る
    ld de, bc             ; 中央座標を DE へ保持

    ; 2つ目以降の部屋を作成
    ld b, 5
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

    ; エリア境界を壁 ($80) で囲う
    ld a, $80
    ld bc, $0000 ; X=0, Y=0
    ld de, $4040 ; W=64, H=64
    call mapgen_rect
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
    ld a, $02
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
    ld a, $02
    call mapgen_fill
    pop de
    jr mapgen1_dig_vertical
    ret
