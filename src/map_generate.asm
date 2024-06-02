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
    call mangen_shadow
    ret
