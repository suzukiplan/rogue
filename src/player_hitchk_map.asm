.player_hitchk_map
    ; 衝突判定ワークエリアにプレイヤの衝突判定範囲をセット
    ld a, 16
    ld (hitchk_work + rect_size + rect_width), a
    ld a, 8
    ld (hitchk_work + rect_size + rect_height), a
    ; マップチップは幅と高さが固定なのでここでセットしておく
    ld (hitchk_work + rect_width), a
    ld (hitchk_work + rect_height), a

    ; lx が 0 かチェック
    ld d, 1
    ld hl, (player_lx)
    ld a, h
    or l
    and a
    jnz player_hitchk_map_lx_not_zero
    ld d, 0
player_hitchk_map_lx_not_zero:

    ; ly が 0 かチェック
    ld e, 1
    ld hl, (player_ly)
    ld a, h
    or l
    and a
    jnz player_hitchk_map_ly_not_zero
    ld e, 0
player_hitchk_map_ly_not_zero:

    ; lx/ly の 0 or not 0 の組み合わせによる判定分岐
    ld a, d
    add e
    and a
    ret z ; 両方 0 なので判定省略
    cp 2
    jz player_hitchk_map_check_both ; 両方 not 0 のチェック
    ld a, d
    and a
    jnz player_hitchk_map_check_x_only ; lx だけ not 0
    jr player_hitchk_map_check_y_only ; ly だけ not 0

; lx だけ非ゼロ → 1回だけチェック & 上下移動補正あり
player_hitchk_map_check_x_only:
    ; 判定ビットが 1 つも立ってなければそのままリターン
    call player_hitchk_map_all
    and $FF
    ret z
    ; X座標の補正
    ld hl, (player_x)
    ld de, (player_lx)
    sub hl, de
    ld (player_x), hl
    ld a, h
    ld (vdp_oam_addr + si_player * oam_size + oam_x), a
    call player_hitchk_map_hoseiY
    ret

; ly だけ非ゼロ → 1回だけチェック & 左右移動補正あり
player_hitchk_map_check_y_only:
    ; 判定ビットが 1 つも立ってなければそのままリターン
    call player_hitchk_map_all
    and $FF
    ret z
    ; Y座標の補正
    ld hl, (player_y)
    ld de, (player_ly)
    sub hl, de
    ld (player_y), hl
    ld a, h
    ld (vdp_oam_addr + si_player * oam_size + oam_y), a
    call player_hitchk_map_hoseiX
    ret

player_hitchk_map_check_both:
    ; 判定ビットが 1 つも立ってなければそのままリターン
    call player_hitchk_map_all
    and $FF
    ret z

    ; X座標の補正
    ld hl, (player_x)
    ld de, (player_lx)
    sub hl, de
    ld (player_x), hl
    ld a, h
    ld (vdp_oam_addr + si_player * oam_size + oam_x), a

    ; 判定ビットが 1 つも立ってなければそのままリターン
    call player_hitchk_map_all
    and $FF
    ret z

    ; X座標の補正を一度解除
    ld hl, (player_x)
    ld de, (player_lx)
    add hl, de
    ld (player_x), hl
    ld a, h
    ld (vdp_oam_addr + si_player * oam_size + oam_x), a

    ; Y座標の補正
    ld hl, (player_y)
    ld de, (player_ly)
    sub hl, de
    ld (player_y), hl
    ld a, h
    ld (vdp_oam_addr + si_player * oam_size + oam_y), a

    ; 判定ビットが 1 つも立ってなければそのままリターン
    call player_hitchk_map_all
    and $FF
    ret z

    ; X座標を再補正
    ld hl, (player_x)
    ld de, (player_lx)
    sub hl, de
    ld (player_x), hl
    ld a, h
    ld (vdp_oam_addr + si_player * oam_size + oam_x), a
    ret

.player_hitchk_map_all
    ; プレイヤ座標をセット
    ld a, (player_x + 1)
    ld (hitchk_work + rect_size + rect_x), a
    ld a, (player_y + 1)
    add 8 ; 下半身のみチェック
    ld (hitchk_work + rect_size + rect_y), a

    ; 当たり判定ビットクリア
    xor a
    ld (player_hit), a

    ; 左上との衝突判定
    ld a, (player_mx)
    ld d, a
    ld a, (player_my)
    inc a
    and $3F
    ld e, a
    call player_hitchk_map_execute
    and $01
    ld hl, player_hit
    or (hl)
    ld (hl), a

    ; 中央上との衝突判定
    inc d
    ld a, d
    and $3F
    ld d, a
    call player_hitchk_map_execute
    and $01
    rlca
    ld hl, player_hit
    or (hl)
    ld (hl), a

    ; 右上との衝突判定
    inc d
    ld a, d
    and $3F
    ld d, a
    call player_hitchk_map_execute
    and $01
    rlca
    rlca
    ld hl, player_hit
    or (hl)
    ld (hl), a

    ; 右下との衝突判定
    inc e
    ld a, e
    and $3F
    ld e, a
    call player_hitchk_map_execute
    and $01
    rlca
    rlca
    rlca
    ld hl, player_hit
    or (hl)
    ld (hl), a

    ; 下中央との衝突判定
    dec d
    ld a, d
    and $3F
    ld d, a
    call player_hitchk_map_execute
    and $01
    rlca
    rlca
    rlca
    rlca
    ld hl, player_hit
    or (hl)
    ld (hl), a

    ; 左下との衝突判定
    dec d
    ld a, d
    and $3F
    ld d, a
    call player_hitchk_map_execute
    and $01
    rlca
    rlca
    rlca
    rlca
    rlca
    ld hl, player_hit
    or (hl)
    ld (hl), a
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

.player_hitchk_map_hoseiY
    ld a, (hitchk_work + rect_y)
    and $07
    ld b, a
    ld a, (hitchk_work + rect_size + rect_y)
    and $07
    sub b
    ret z ; 左下チップのY座標 mod 8 と プレイヤY座標 mod 8 が同値なので補正なし

    ; 進行方向をチェック
    ld a, d
    and $80
    jz player_hitchk_map_hoseiY_right

player_hitchk_map_hoseiY_left:
    ld a, (player_hit)
    cp %00100000
    jz player_hitchk_map_hoseiY_up
    cp %00000001
    jz player_hitchk_map_hoseiY_down
    ret

player_hitchk_map_hoseiY_right:
    ld a, (player_hit)
    cp %00001000
    jz player_hitchk_map_hoseiY_up
    cp %00000100
    jz player_hitchk_map_hoseiY_down
    ret

player_hitchk_map_hoseiY_down:
    ld a, (player_y + 1)
    inc a
    ld (player_y + 1), a
    ld (vdp_oam_addr + si_player * oam_size + oam_y), a
    ret
player_hitchk_map_hoseiY_up:
    ld a, (player_y + 1)
    dec a
    ld (player_y + 1), a
    ld (vdp_oam_addr + si_player * oam_size + oam_y), a
    ret

.player_hitchk_map_hoseiX
    ; 進行方向をチェック
    ld a, d
    and $80
    jz player_hitchk_map_hoseiX_down

player_hitchk_map_hoseiX_up:
    ld a, (player_hit)
    cp %00000001
    jz player_hitchk_map_hoseiX_right
    cp %00000100
    jz player_hitchk_map_hoseiX_left
    cp %00000010
    jz player_hitchk_map_hoseiX_left
    ret

player_hitchk_map_hoseiX_down:
    ld a, (player_hit)
    cp %00001000
    jz player_hitchk_map_hoseiX_left
    cp %00010000
    jz player_hitchk_map_hoseiX_left
    cp %00100000
    jz player_hitchk_map_hoseiX_right
    ret

player_hitchk_map_hoseiX_right:
    ld a, (player_x + 1)
    inc a
    ld (player_x + 1), a
    ld (vdp_oam_addr + si_player * oam_size + oam_x), a
    ret
player_hitchk_map_hoseiX_left:
    ld a, (player_x + 1)
    dec a
    ld (player_x + 1), a
    ld (vdp_oam_addr + si_player * oam_size + oam_x), a
    ret
