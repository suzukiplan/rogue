.map_adjust
    xor a
    ld (map_refresh), a
    call map_adjust_top
    call map_adjust_bottom
    call map_adjust_left
    call map_adjust_right
    ld a, (map_refresh)
    and a
    call nz, map_render
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
    ld hl, map_refresh
    inc (hl)
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
    ld hl, map_refresh
    inc (hl)
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
    ld hl, map_refresh
    inc (hl)
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
    ld hl, map_refresh
    inc (hl)
    ret
