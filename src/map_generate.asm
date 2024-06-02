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
map_generate_next:
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
    call map_generate_digL
    jr map_generate_digend
map_generate_R:
    call map_generate_digR
    jr map_generate_digend
map_generate_U:
    call map_generate_digU
    jr map_generate_digend
map_generate_D:
    call map_generate_digD
map_generate_digend:

    call mangen_shadow
    ld a, (mapgen_np)
    and a
    jz map_generate_end ; 次エリアを掘れなかったのでここまで

    out ($B4), a
    call mapgen_fill_wall
    ld bc, (mapgen_ns)
    ld de, $0202
    ld a, (mapchip_ground)
    push bc
    call mapgen_fill
    pop bc
    ld de, bc
    call mapgen1_2nd
    jp map_generate_next

map_generate_end:
    xor a
    out ($B4), a
    ret

.map_generate_digL
    ld hl, $FF00
    call man_generate_check_next_area
    ret z
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
    ld a, (maplast_y)
    ld l, a
    ld h, 62
    ld (mapgen_ns), hl
    ret

.map_generate_digR
    ld hl, $0100
    call man_generate_check_next_area
    ret z
    ld a, (maplast_x)
    ld b, a
    ld a, (maplast_y)
    ld c, a
    ld de, $4002
    ld a, (mapchip_ground)
    call mapgen_fill
    ld a, (maplast_y)
    ld l, a
    ld h, 0
    ld (mapgen_ns), hl
    ret

.map_generate_digU
    ld hl, $00FF
    call man_generate_check_next_area
    ret z
    ld a, (maplast_x)
    ld b, a
    ld c, 0
    ld d, 2
    ld a, (maplast_y)
    ld e, a
    ld a, (mapchip_ground)
    call mapgen_fill
    ld a, (maplast_x)
    ld h, a
    ld l, 62
    ld (mapgen_ns), hl
    ret

.map_generate_digD
    ld hl, $0001
    call man_generate_check_next_area
    ret z
    ld a, (maplast_x)
    ld b, a
    ld a, (maplast_y)
    ld c, a
    ld de, $0240
    ld a, (mapchip_ground)
    call mapgen_fill
    ld a, (maplast_x)
    ld h, a
    ld l, 0
    ld (mapgen_ns), hl
    ret

.man_generate_check_next_area
    in a, ($B4)
    ld (mapgen_cp), a
    ld b, a
    srl a
    srl a
    srl a
    srl a
    add l
    and $0F
    rlca
    rlca
    rlca
    rlca
    ld l, a
    ld a, b
    add h
    and $0F
    or l

    ld (mapgen_np), a
    out ($B4), a
    ld a, ($A000)
    and a
    jz man_generate_check_next_area_end
man_generate_check_next_area_failed:    
    xor a
    ld (mapgen_np), a
man_generate_check_next_area_end:
    ld a, (mapgen_cp)
    out ($B4), a
    ld a, (mapgen_np)
    and a
    ret
