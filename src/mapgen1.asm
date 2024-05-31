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
    ld b, 8
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

    ; 影を描画
    ld l, $01
mangen1_shadow_loopY:
    ld h, $01
mangen1_shadow_loopX:
    ; HL が地面かチェック
    push hl
    call mapgen_get_chip
    pop hl
    cp $02
    jnz mangen1_shadow_next ; 地面ではないのでスキップ

    ; 上のチップが壁かチェック
    push hl
    dec l
    call mapgen_get_chip
    pop hl
    cp $80
    jz mangen1_shadow_draw ; 上が壁なので影を描画

    ; 左のチップが壁かチェック
    push hl
    dec h
    call mapgen_get_chip
    pop hl
    cp $80
    jz mangen1_shadow_draw ; 上が壁なので影を描画

    ; 左上が壁かチェック
    push hl
    dec l
    dec h
    call mapgen_get_chip
    pop hl
    cp $80
    jnz mangen1_shadow_next ; 左が壁ではないのでスキップ

mangen1_shadow_draw:
    ; 影を描画
    ld a, $01
    push hl
    call mapgen_set_chip
    pop hl

mangen1_shadow_next:
    ld a, h
    inc a
    and $3F
    ld h, a
    jnz mangen1_shadow_loopX

    ld a, l
    inc a
    and $3F
    ld l, a
    jnz mangen1_shadow_loopY
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
