.map_generate
    ; マップチップの種別を初期化
    call mapgen_init_chip_dungeon

    ; 全マップの左上を 0x00 にする
    call mapgen_init_banks

    ; 最初の区画を生成
    xor a
    out ($B4), a
    call mapgen_fill_wall
    call mapgen1
    call mangen_player_position_init

    ; 最後の部屋の座標（maplast_x, maplast_y）のどちらに彫り進めれば隣区画に最短の経路になるかを求める
    ld hl, maplast_x
    ld a, (hl)
    ld b, a
    ld a, 63
    sub (hl)
    ld c, a
    ld hl, maplast_y
    ld a, (hl)
    ld d, a
    ld a, 63
    sub (hl)
    ld e, a
    ld a, b
    cp c
    jc map_generate_LZ ; 左(B) < 右(C) なので左に掘り進めるべき（暫定）
map_generate_RZ:
    ld a, d
    cp e
    jc map_generate_RUZ ; 上(D) < 下(E) なので上に掘り進めるべき（暫定）
map_generate_RDZ:
    ld a, c
    cp e
    jc map_generate_R ; 右(C) < 下(E) なので右に掘り進める
    jr map_generate_D ; 右(C) >= 下(E) なので右に掘り進める
map_generate_RUZ:
    ld a, c
    cp d
    jc map_generate_R ; 右(C) < 上(D) なので右に掘り進める
    jr map_generate_U ; 右(C) >= 上(D) なので上に掘り進める
map_generate_LZ:
    ld a, b
    ld a, d
    cp e
    jc map_generate_LUZ ; 上(D) < 下(E) なので上に掘り進めるべき（暫定）
map_generate_LDZ:
    ld a, b
    cp e
    jc map_generate_L ; 左(C) < 下(E) なので左に掘り進める
    jr map_generate_D ; 左(C) >= 下(E) なので下に掘り進める
map_generate_LUZ:
    ld a, b
    cp d
    jc map_generate_L ; 左(B) < 上(D) なので左に掘り進める
    jr map_generate_U ; 左(B) >= 上(D) なので上に掘り進める
map_generate_L:
    ld b, 0
    ld a, (maplast_y)
    ld c, a
    ld a, (maplast_x)
    inc a
    ld d, a
    ld e, 2
    ld a, (mapchip_ground)
    ld a, (mapchip_wall)
    call mapgen_fill
    xor a
    jr map_generate_digend
map_generate_R:
    ld a, (maplast_x)
    ld b, a
    ld a, (maplast_y)
    ld c, a
    ld de, $4002
    ld a, (mapchip_ground)
    call mapgen_fill
    xor a
    jr map_generate_digend
map_generate_U:
    ld a, (maplast_x)
    ld b, a
    ld c, 0
    ld d, 2
    ld a, (maplast_y)
    ld e, a
    ld a, (mapchip_ground)
    call mapgen_fill
    xor a
    jr map_generate_digend
map_generate_D:
    ld a, (maplast_x)
    ld b, a
    ld a, (maplast_y)
    ld c, a
    ld de, $0240
    ld a, (mapchip_ground)
    call mapgen_fill
    xor a
map_generate_digend:
    call mangen_shadow
    ret
