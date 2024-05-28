.player_hitchk_map
    ; 衝突判定ワークエリアにプレイヤの衝突判定範囲をセット
    ld a, (player_x + 1)
    ld (hitchk_work + rect_size + rect_x), a
    ld a, (player_y + 1)
    add 8 ; 下半身のみチェック
    ld (hitchk_work + rect_size + rect_y), a
    ld a, 16
    ld (hitchk_work + rect_size + rect_width), a
    ld a, 8
    ld (hitchk_work + rect_size + rect_height), a
    ; マップチップは幅と高さが固定なのでここでセットしておく
    ld (hitchk_work + rect_width), a
    ld (hitchk_work + rect_height), a

    ; 左上との衝突判定
    ld a, (player_mx)
    ld d, a
    ld a, (player_my)
    inc a
    ld e, a
    call player_hitchk_map_execute
    push de
    ld d, 0
    ld e, 1
    call player_hitchk_map_debug
    pop de

    ; 中央上との衝突判定
    inc d
    call player_hitchk_map_execute
    push de
    ld d, 1
    ld e, 1
    call player_hitchk_map_debug
    pop de

    ; 右上との衝突判定
    inc d
    call player_hitchk_map_execute
    push de
    ld d, 2
    ld e, 1
    call player_hitchk_map_debug
    pop de

    ; 右下との衝突判定
    inc e
    call player_hitchk_map_execute
    push de
    ld d, 2
    ld e, 2
    call player_hitchk_map_debug
    pop de

    ; 下中央との衝突判定
    dec d
    call player_hitchk_map_execute
    push de
    ld d, 1
    ld e, 2
    call player_hitchk_map_debug
    pop de

    ; 左下との衝突判定
    dec d
    call player_hitchk_map_execute
    push de
    ld d, 0
    ld e, 2
    call player_hitchk_map_debug
    pop de
    ret

player_hitchk_map_execute:
    ; キャラクタパターンを求める
    ld l, e
    ld h, 64
    xor a
    out ($c5), a
    ld a, d
    add l
    ld l, a
    ld a, 0
    adc h
    or $A0
    ld h, a
    ld a, (hl)

    ; 7-bit目が立っていなければチェック不要
    and $80
    ret z

    ; マップ座標系Xをスプライト座標系に変換して当たり判定ワークエリアにセット
    ld hl, map_left
    ld a, d
    sub (hl)
    ld l, a
    ld h, 8
    xor a
    out ($c5), a
    ld a, l
    ld hl, map_sx
    sub (hl)
    ld (hitchk_work + rect_x), a

    ; マップ座標系Yをスプライト座標系に変換して当たり判定ワークエリアにセット
    ld hl, map_top
    ld a, e
    sub (hl)
    ld l, a
    ld h, 8
    xor a
    out ($c5), a
    ld a, l
    ld hl, map_sy
    sub (hl)
    ld (hitchk_work + rect_y), a

    ; 当たり判定を実行
    ld hl, hitchk_work
    in a, ($C4)
    ret

.player_hitchk_map_debug
    add '0'
    push af
    ld hl, vdp_nametbl_fg + 6 * 32 + 3
    ld a, d
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    ld b, e
player_hitchk_map_debug_loop:
    add hl, 32
    djnz player_hitchk_map_debug_loop
    pop af
    ld (hl), a
    add hl, $400
    ld a, $80
    ld (hl), a
    ret
