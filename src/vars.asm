; バンク定義
defvars $0000
{
    bank_prg ds.b 4                 ; プログラム
    bank_actbl ds.b 1               ; アクションテーブル
    bank_palette ds.b 1             ; パレット
    bank_font ds.b 1                ; フォント画像
    bank_player ds.b 1              ; プレイヤ画像
    bank_map01 ds.b 1               ; マップ画像(01)
}

; アクションテーブル
defvars $0000
{
    actbl_oi ds.b 1                 ; oam index (0: weapon0, 1: weapon1)
    actbl_yof ds.b 1                ; y offset (-128 ~ 127)
    actbl_xof ds.b 1                ; x offset (-128 ~ 127)
    actbl_ptn ds.b 1                ; weapon sprite pattern number
    actbl_attr ds.b 1               ; weapon sprite attribute
    actbl_height ds.b 1             ; weapon sprite height (minus 1)
    actbl_width ds.b 1              ; weapon sprite width (minus 1)
    actbl_bank ds.b 1               ; weapon sprite bank
    actbl_player ds.b 1             ; player sprite pattern number
    actbl_wtime ds.b 1              ; wait time (frames)
    actbl_size ds.b 1
}

; スプライトインデクス定義
defvars $0000
{
    si_weapon0 ds.b 1               ; プレイヤより描画優先度が高い武器
    si_player ds.b 1                ; プレイヤ
    si_weapon1 ds.b 1               ; プレイヤより描画優先度が低い武器
    si_debug ds.b 1                 ; 当たり判定目安ガイド
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

; 矩形データ定義
defvars $0000
{
    rect_x ds.b 1
    rect_y ds.b 1
    rect_width ds.b 1
    rect_height ds.b 1
    rect_size ds.b 1
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
    player_mx ds.b 1                ; プレイヤマップ座標系X
    player_my ds.b 1                ; プレイヤマップ座標系Y
    player_wf ds.b 1                ; プレイヤ攻撃アクションフラグ
    player_wp ds.w 1                ; プレイヤ攻撃アクションテーブルのポインタ
    player_wi ds.b 1                ; プレイヤ攻撃アクションテーブルのインデクス
    player_ww ds.b 1                ; プレイヤ攻撃アクションテーブルのインデクス加算待ちフレーム
    player_wk ds.b 1                ; 攻撃モーションキープモード・フラグ
    player_wa ds.b actbl_size * 2   ; 攻撃モーションキープ対象のアクションテーブル・レコード

    map_top ds.b 1                  ; マップ描画基点（上）
    map_left ds.b 1                 ; マップ描画基点（左）
    map_sx ds.b 1                   ; マップスクロールX（-7〜7）
    map_sy ds.b 1                   ; マップスクロールY（-7〜7）

    hitchk_work ds.b rect_size * 2  ; 当たり判定用ワークエリア
    actbl_work ds.b 512             ; アクションテーブルの読み込み領域
}
