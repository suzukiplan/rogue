; バンク定義
defvars $0000
{
    bank_prg ds.b 4                 ; プログラム
    bank_palette ds.b 1             ; パレット
    bank_font ds.b 1                ; フォント画像
    bank_player ds.b 1              ; プレイヤ画像
}

; スプライトインデクス定義
defvars $0000
{
    si_weapon0 ds.b 1               ; プレイヤより描画優先度が高い武器
    si_player ds.b 1                ; プレイヤ
    si_weapon1 ds.b 1               ; プレイヤより描画優先度が低い武器
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
    player_wf ds.b 1                ; プレイヤ攻撃アクションフラグ
    player_wp ds.w 1                ; プレイヤ攻撃アクションテーブルのポインタ
    player_wi ds.b 1                ; プレイヤ攻撃アクションテーブルのインデクス
    player_ww ds.b 1                ; プレイヤ攻撃アクションテーブルのインデクス加算待ちフレーム
}
