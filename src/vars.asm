; バンク定義
defvars $0000
{
    bank_prg ds.b 4
    bank_palette ds.b 1
    bank_font ds.b 1
    bank_player ds.b 1
}

; スプライトインデクス定義
defvars $0000
{
    si_player ds.b 1
}

; OAM レコード定義
defvars $0000
{
    oam_y       ds.b 1
    oam_x       ds.b 1
    oam_ptn     ds.b 1
    oam_attr    ds.b 1
    oam_height  ds.b 1
    oam_width   ds.b 1
    oam_bank    ds.b 1
    oam_rsv     ds.b 1
    oam_size    ds.b 1
}

; グローバル変数
defvars $c000
{
    joypad ds.b 1                   ; 最新のジョイパッド
    joypad_prev ds.b 1              ; 直前フレームのジョイパッド
    player_an ds.b 1                ; プレイヤのアニメーションカウンタ
    player_dir ds.b 1               ; プレイヤの向き
    player_x ds.w 1                 ; プレイヤX座標（実数）
    player_y ds.w 1                 ; プレイヤY座標（実数）
    player_vx ds.w 1                ; プレイヤX移動量（実数）
    player_vy ds.w 1                ; プレイヤX移動量（実数）
}
