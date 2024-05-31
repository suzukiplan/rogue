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
    ld hl, $0101
    call mangen_xy_to_addr_with_HL
mangen1_shadow_loop:
    push hl

    ; HL が地面かチェック
    ld a, (hl)
    cp $02
    jnz mangen1_shadow_next ; 地面ではないのでスキップ

    ; 上のチップが壁かチェック
    add hl, -64
    ld a, (hl)
    cp $80
    jz mangen1_shadow_draw ; 上が壁なので影を描画

    ; 左上が壁かチェック
    add hl, -1
    ld a, (hl)
    cp $80
    jz mangen1_shadow_draw ; 左上が壁なので影を描画

    ; 左のチップが壁かチェック
    add hl, 64
    ld a, (hl)
    cp $80
    jnz mangen1_shadow_next ; 左が壁ではないのでスキップ

mangen1_shadow_draw:
    ; 影を描画
    pop hl
    push hl
    ld a, $01
    ld (hl), a

mangen1_shadow_next:
    ; $A000 + 4096 - 64 まで繰り返す
    pop hl
    inc hl
    ld a, l
    cp $C0
    jnz mangen1_shadow_loop
    ld a, h
    cp $AF
    jnz mangen1_shadow_loop
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
