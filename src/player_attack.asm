; 攻撃処理
.player_attack
    ; キープモードチェック
    ld a, (player_wk)
    and a
    jz player_attack_check_flag

    ; ボタンが離された場合はキープ解除
    ld a, (joypad)
    and %00000011
    cp 3
    jnz player_attack_keep_do
    xor a
    ld (player_wk), a
    ld (WEAPON0_OAM + oam_attr), a
    ld (WEAPON1_OAM + oam_attr), a
    ret

player_attack_keep_do:
    ; vx/vyがゼロでないかチェック
    ld hl, (player_vx)
    ld a, h
    and a
    jnz player_attack_keep_do_inci
    ld a, l
    and a
    jnz player_attack_keep_do_inci
    ld hl, (player_vy)
    ld a, h
    and a
    jnz player_attack_keep_do_inci
    ld a, l
    and a
    jnz player_attack_keep_do_inci
    jr player_attack_keep_set_actbl

player_attack_keep_do_inci:
    ; カーソル入力があるのでインデクスを加算
    ld a, (player_wi)
    inc a
    ld (player_wi), a

    ; 対象アクションテーブルアドレスを設定して描画
player_attack_keep_set_actbl:
    and %00000100
    jz player_attack_keep_ptn0
    ld a, actbl_size
player_attack_keep_ptn0:
    ld hl, player_wa
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    call player_attack_render
    ret

player_attack_check_flag:
    ; フラグチェック
    ld a, (player_wf)
    and a
    jnz player_attack_do

    ; 右手入力チェック
    ld a, (joypad)
    and %00000001
    jnz player_attack_check_left
    ld a, 1
    ld (player_wf), a
    xor a
    ld (player_wi), a
    ld a, 2
    ld (player_ww), a
    jr player_attack_right

player_attack_check_left:
    ; 左手入力チェック
    ld a, (joypad)
    and %00000010
    ret nz
    ld a, 1
    ld (player_wf), a
    xor a
    ld (player_wi), a
    ld a, 2
    ld (player_ww), a
    jr player_attack_left

    ; 現在の向きによって使う攻撃パターンテーブルを決める（右手）
player_attack_right:
    ld a, (player_dir)
    cp $00
    jz player_attack_rd
    cp $20
    jz player_attack_ru
    cp $40
    jz player_attack_rl
    jp player_attack_rr
player_attack_rd:
    ld hl, player_sword_rd
    jp player_attack_set
player_attack_ru:
    ld hl, player_sword_ru
    jp player_attack_set
player_attack_rl:
    ld hl, player_sword_rl
    jp player_attack_set
player_attack_rr:
    ld hl, player_sword_rr
    jr player_attack_set

    ; 現在の向きによって使う攻撃パターンテーブルを決める（左手）
player_attack_left:
    ld a, (player_dir)
    cp $00
    jz player_attack_ld
    cp $20
    jz player_attack_lu
    cp $40
    jz player_attack_ll
    jp player_attack_lr
player_attack_ld:
    ld hl, player_sword_ld
    jp player_attack_set
player_attack_lu:
    ld hl, player_sword_lu
    jp player_attack_set
player_attack_ll:
    ld hl, player_sword_ll
    jp player_attack_set
player_attack_lr:
    ld hl, player_sword_lr

    ; 攻撃モーションセット
player_attack_set:
    ld (player_wp), hl

    ; 攻撃モーション開始
.player_attack_do
    ld hl, (player_wp)
    ld a, (player_wi)
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a

    call player_attack_render

    ; AB が話されていればウェイトをスキップ
    ld a, (joypad)
    and %00000011
    cp 3
    jz player_attack_do_skip_ww
    ; ウェイト減算
    ld a, (player_ww)
    dec a
    ld (player_ww), a
    ret nz
player_attack_do_skip_ww:

    ; 次のウェイトタイムを取得
    ld a, (hl)
    ld b, a
    inc hl

    ; 次のアクションテーブル先頭が ff なら攻撃終了
    ld a, (hl)
    inc a
    jnz player_attack_next
    ld (player_wf), a
    ld a, (joypad)
    and %00000011
    cp 3
    jnz player_attack_keep ; ボタンを押したままなのでキープモードにする
    xor a
    ld (WEAPON0_OAM + oam_attr), a
    ld (WEAPON1_OAM + oam_attr), a
    ret

    ; ボタンを押している状態なのでキープモード発動
player_attack_keep:
    ld bc, player_wa
    inc hl
    ld de, hl
    ld hl, actbl_size * 2
    out ($c3), a
    ld a, 1
    ld (player_wk), a
    xor a
    ld (player_wi), a
    ret

player_attack_next:
    ; インデックス加算
    ld a, (player_wi)
    add actbl_size
    ld (player_wi), a
    ld a, b
    ld (player_ww), a
    ret

; HLに設定されたアクションテーブルの内容にしたがってスプライトを描画
.player_attack_render
    ld a, (hl)
    and a
    jnz player_attack_do_w1
    ld de, WEAPON0_OAM
    jr player_attack_do_w_end
player_attack_do_w1:
    ld de, WEAPON1_OAM
player_attack_do_w_end:
    inc hl

    ; Y座標設定
    ld a, (player_y + 1)
    add (hl)
    inc hl
    ld (de), a
    inc de

    ; X座標設定    
    ld a, (player_x + 1)
    add (hl)
    inc hl
    ld (de), a
    inc de

    ; パターン設定
    ld a, (hl)
    inc hl
    ld (de), a
    inc de

    ; アトリビュート設定
    ld a, (hl)
    inc hl
    ld (de), a
    inc de

    ; heightMinus1設定
    ld a, (hl)
    inc hl
    ld (de), a
    inc de

    ; widthMinus1設定
    ld a, (hl)
    inc hl
    ld (de), a
    inc de

    ; bank設定
    ld a, (hl)
    inc hl
    ld (de), a

    ; プレイヤーパターン番号を設定
    ld a, (hl)
    ld (PLAYER_OAM + oam_ptn), a
    inc hl
    ret
