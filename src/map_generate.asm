.map_generate
    xor a
    out ($B4), a
    call mapgen1

    ; 最初の部屋の中央座標にプレイヤ初期座標 (X) を設定
    ld a, (map1st_x)
    cp 16
    jc map_generate_set_left_zero
    cp 32
    jnc map_generate_set_left_limit
    sub 16
    jr map_generate_set_left
map_generate_set_left_limit:
    ld a, 31
    jr map_generate_set_left
map_generate_set_left_zero:
    xor a
map_generate_set_left:
    ld (map_left), a
    ld a, (map1st_x)
    ld hl, map_left
    sub (hl)
    rlca ; x2
    rlca ; x4
    rlca ; x8
    ld h, a
    ld l, 0
    ld (player_x), hl

    ; 最初の部屋の中央座標にプレイヤ初期座標 (Y) を設定
    ld a, (map1st_y)
    cp 12
    jc map_generate_set_top_zero
    cp 40
    jnc map_generate_set_top_limit
    sub 12
    jr map_generate_set_top
map_generate_set_top_limit:
    ld a, 39
    jr map_generate_set_top
map_generate_set_top_zero:
    xor a
map_generate_set_top:
    ld (map_top), a
    ld a, (map1st_y)
    ld hl, map_top
    sub (hl)
    rlca ; x2
    rlca ; x4
    rlca ; x8
    ld h, a
    ld l, 0
    ld (player_y), hl

    ret
