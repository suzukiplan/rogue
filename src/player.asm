#define PLAYER_OAM vdp_oam_addr + oam_size * si_player
#define WEAPON0_OAM vdp_oam_addr + oam_size * si_weapon0
#define WEAPON1_OAM vdp_oam_addr + oam_size * si_weapon1
#define PLAYER_MOVE_POW 77
#define PLAYER_MOVE_DEC 44

.player_init
    xor a
    ld (player_an), a
    ld (player_dir), a
    ld h, 100
    ld l, 0
    ld (player_x), hl
    ld (player_y), hl
    ld h, 0
    ld (player_vx), hl
    ld (player_vy), hl
    call player_render_refresh
    ret

player_render_refresh:
    ld hl, PLAYER_OAM
    ld a, (player_y + 1)
    ld (hl), a
    inc hl

    ld a, (player_x + 1)
    ld (hl), a
    inc hl

    ld a, $00
    ld (hl), a
    inc hl

    ld a, $80
    ld (hl), a
    inc hl

    ld a, 1
    ld (hl), a
    inc hl

    ld a, 1
    ld (hl), a
    inc hl

    ld a, bank_player
    ld (hl), a
    ret

.player_move
    ld a, (joypad)
    ld b, a
    and %10000000
    call z, player_move_up
    jz player_move_check_LR
    ld a, b
    and %01000000
    call z, player_move_down

player_move_check_LR:
    ld a, b
    and %00100000
    call z, player_move_left
    jz player_move_check_var_x
    ld a, b
    and %00010000
    call z, player_move_right

player_move_check_var_x:
    ; vx が 0 で無ければ x 方向の移動処理を実行
    ld hl, (player_vx)
    ld a, h
    and a
    jz player_move_update_vars_check_xl
    call player_move_update_vars_x
    jp player_move_check_var_y
player_move_update_vars_check_xl:
    ld a, l
    and a
    call nz, player_move_update_vars_x

player_move_check_var_y:
    ; vy が 0 で無ければ y 方向の移動処理を実行
    ld hl, (player_vy)
    ld a, h
    and a
    jz player_move_update_vars_check_yl
    call player_move_update_vars_y
    jp player_move_check_var_end
player_move_update_vars_check_yl:
    ld a, l
    and a
    call nz, player_move_update_vars_y
player_move_check_var_end:

    ; vx/vy が非ゼロならアニメーション
    ld bc, (player_vx)
    ld de, (player_vy)
    ld a, b
    and a
    jnz player_move_animate
    ld a, c
    and a
    jnz player_move_animate
    ld a, d
    and a
    jnz player_move_animate
    ld a, e
    and a
    jnz player_move_animate
    jp player_move_animate_end
player_move_animate:
    ld a, (player_an)
    inc a
    ld (player_an), a
    and %00001100
    rrca
    ld b, a
    ld a, (player_dir)
    add b
    ld (PLAYER_OAM + oam_ptn), a
    
player_move_animate_end:
    ret

player_move_update_vars_x:
    ld hl, (player_x)
    ld de, (player_vx)
    add hl, de
    ld (player_x), hl
    ld a, h
    ld (PLAYER_OAM + oam_x), a

    ld a, d
    and $80
    jnz player_move_update_vars_vx_add

player_move_update_vars_vx_sub:
    ld hl, de
    add hl, -PLAYER_MOVE_DEC
    ld a, h
    and $80
    jz player_move_update_vars_vx_add_end
    ld hl, $0000
    jp player_move_update_vars_vx_add_end

player_move_update_vars_vx_add:
    ld hl, de
    add hl, PLAYER_MOVE_DEC
    ld a, h
    and $80
    jnz player_move_update_vars_vx_add_end
    ld hl, $0000
player_move_update_vars_vx_add_end:
    ld (player_vx), hl
    ret

player_move_update_vars_y:
    ld hl, (player_y)
    ld de, (player_vy)
    add hl, de
    ld (player_y), hl
    ld a, h
    ld (PLAYER_OAM + oam_y), a

    ld a, d
    and $80
    jnz player_move_update_vars_vy_add

player_move_update_vars_vy_sub:
    ld hl, de
    add hl, -PLAYER_MOVE_DEC
    ld a, h
    and $80
    jz player_move_update_vars_vy_add_end
    ld hl, $0000
    jp player_move_update_vars_vy_add_end

player_move_update_vars_vy_add:
    ld hl, de
    add hl, PLAYER_MOVE_DEC
    ld a, h
    and $80
    jnz player_move_update_vars_vy_add_end
    ld hl, $0000
player_move_update_vars_vy_add_end:
    ld (player_vy), hl
    ret

player_move_up:
    push af
    ld a, $20
    ld (player_dir), a
    ld hl, (player_vy)
    add hl, -PLAYER_MOVE_POW
    ld a, h
    cmp -4
    jnz player_move_up_do
    ld hl, $fd00
player_move_up_do:
    ld (player_vy), hl
    pop af
    ret

player_move_down:
    push af
    ld a, $00
    ld (player_dir), a
    ld hl, (player_vy)
    add hl, PLAYER_MOVE_POW
    ld a, h
    cmp 3
    jnz player_move_down_do
    ld hl, $02ff
player_move_down_do:
    ld (player_vy), hl
    pop af
    ret

player_move_left:
    push af
    ld a, $40
    ld (player_dir), a
    ld hl, (player_vx)
    add hl, -PLAYER_MOVE_POW
    ld a, h
    cmp -4
    jnz player_move_left_do
    ld hl, $fd00
player_move_left_do:
    ld (player_vx), hl
    pop af
    ret

player_move_right:
    push af
    ld a, $60
    ld (player_dir), a
    ld hl, (player_vx)
    add hl, PLAYER_MOVE_POW
    ld a, h
    cmp 3
    jnz player_move_right_do
    ld hl, $02ff
player_move_right_do:
    ld (player_vx), hl
    pop af
    ret

; 攻撃処理
.player_attack
    ld a, (player_wf)
    and a
    jnz player_attack_do
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

    ; ウェイト減算
    ld a, (player_ww)
    dec a
    ld (player_ww), a
    ret nz

    ; 次のウェイトタイムを取得
    ld a, (hl)
    ld b, a
    inc hl

    ; 次のアクションテーブル先頭が ff なら攻撃終了
    ld a, (hl)
    inc a
    jnz player_attack_next
    ld (player_wf), a
    ld (WEAPON0_OAM + oam_attr), a
    ld (WEAPON1_OAM + oam_attr), a
    ret

player_attack_next:
    ; インデックス加算
    ld a, (player_wi)
    add 10
    ld (player_wi), a
    ld a, b
    ld (player_ww), a
    ret

; 下方向への剣攻撃アクションテーブル（右手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_rd: db 0,   0, -14, $80, $80, 1,1, bank_player, $00, 4
                 db 0,   0, -14, $80, $80, 1,1, bank_player, $00, 3
                 db 0,   1, -13, $80, $80, 1,1, bank_player, $00, 2
                 db 0,   5, -12, $82, $80, 1,1, bank_player, $02, 1
                 db 0,   8, -12, $82, $80, 1,1, bank_player, $02, 1
                 db 0,   9, -11, $82, $80, 1,1, bank_player, $02, 1
                 db 0,  12,  -4, $84, $80, 1,1, bank_player, $04, 4
                 db 0,  12,  -4, $84, $80, 1,1, bank_player, $04, 7
                 db 0,  12,  -4, $84, $80, 1,1, bank_player, $04, 12
                 db 0,  13,  -3, $84, $80, 1,1, bank_player, $08, 1
                 db $FF ; end of action (-1)

; 下方向への剣攻撃アクションテーブル（左手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_ld: db 0,   0,  14, $80, $C0, 1,1, bank_player, $04, 4
                 db 0,   0,  14, $80, $C0, 1,1, bank_player, $04, 3
                 db 0,   1,  13, $80, $C0, 1,1, bank_player, $04, 2
                 db 0,   5,  12, $82, $C0, 1,1, bank_player, $02, 1
                 db 0,   8,  12, $82, $C0, 1,1, bank_player, $02, 1
                 db 0,   9,  11, $82, $C0, 1,1, bank_player, $02, 1
                 db 0,  12,   4, $84, $C0, 1,1, bank_player, $00, 4
                 db 0,  12,   4, $84, $C0, 1,1, bank_player, $00, 7
                 db 0,  12,   4, $84, $C0, 1,1, bank_player, $00, 12
                 db 0,  13,   3, $84, $C0, 1,1, bank_player, $0A, 1
                 db $FF ; end of action (-1)

; 上方向への剣攻撃アクションテーブル（右手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_ru: db 1,   0,  14, $A0, $80, 1,1, bank_player, $20, 4
                 db 1,   0,  14, $A0, $80, 1,1, bank_player, $20, 3
                 db 1,  -4,  12, $A0, $80, 1,1, bank_player, $20, 2
                 db 1,  -8,  10, $A2, $80, 1,1, bank_player, $22, 2
                 db 1,  -9,   8, $A2, $80, 1,1, bank_player, $22, 1
                 db 1, -12,   4, $A4, $80, 1,1, bank_player, $24, 4
                 db 1, -12,   4, $A4, $80, 1,1, bank_player, $24, 7
                 db 1, -12,   4, $A4, $80, 1,1, bank_player, $24, 12
                 db 1, -13,   3, $A4, $80, 1,1, bank_player, $28, 1
                 db $FF ; end of action (-1)

; 上方向への剣攻撃アクションテーブル（左手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_lu: db 1,   0, -14, $A0, $C0, 1,1, bank_player, $24, 4
                 db 1,   0, -14, $A0, $C0, 1,1, bank_player, $24, 3
                 db 1,  -4, -12, $A0, $C0, 1,1, bank_player, $24, 2
                 db 1,  -8, -10, $A2, $C0, 1,1, bank_player, $22, 2
                 db 1,  -9,  -8, $A2, $C0, 1,1, bank_player, $22, 1
                 db 1, -12,  -4, $A4, $C0, 1,1, bank_player, $20, 4
                 db 1, -12,  -4, $A4, $C0, 1,1, bank_player, $20, 7
                 db 1, -12,  -4, $A4, $C0, 1,1, bank_player, $20, 12
                 db 1, -13,  -3, $A4, $C0, 1,1, bank_player, $2A, 1
                 db $FF ; end of action (-1)

; 左方向への剣攻撃アクションテーブル（右手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_rl: db 1, -10,   0, $C0, $80, 1,1, bank_player, $40, 4
                 db 1, -10,   0, $C0, $80, 1,1, bank_player, $40, 3
                 db 1,  -8,  -4, $C0, $80, 1,1, bank_player, $40, 2
                 db 1,  -6,  -8, $C2, $80, 1,1, bank_player, $42, 2
                 db 1,  -2,  -9, $C2, $80, 1,1, bank_player, $42, 1
                 db 1,   2, -12, $C4, $80, 1,1, bank_player, $44, 4
                 db 1,   3, -12, $C4, $80, 1,1, bank_player, $44, 7
                 db 1,   4, -12, $C4, $80, 1,1, bank_player, $44, 12
                 db 1,   4, -14, $C4, $80, 1,1, bank_player, $48, 1
                 db $FF ; end of action (-1)


; 左方向への剣攻撃アクションテーブル（左手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_ll: db 0,  11,   5, $E0, $C0, 1,1, bank_player, $44, 4
                 db 0,  11,   4, $E0, $C0, 1,1, bank_player, $44, 3
                 db 0,  11,   2, $E0, $C0, 1,1, bank_player, $44, 2
                 db 0,  12,  -5, $E2, $C0, 1,1, bank_player, $42, 1
                 db 0,  12,  -7, $E2, $C0, 1,1, bank_player, $42, 1
                 db 0,  10,  -8, $E2, $C0, 1,1, bank_player, $42, 1
                 db 0,   3, -13, $E4, $C0, 1,1, bank_player, $40, 4
                 db 0,   3, -14, $E4, $C0, 1,1, bank_player, $40, 7
                 db 0,   3, -14, $E4, $C0, 1,1, bank_player, $40, 12
                 db 0,   4, -15, $E4, $C0, 1,1, bank_player, $4A, 1
                 db $FF ; end of action (-1)

; 右方向への剣攻撃アクションテーブル（右手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_rr: db 0,  11,  -5, $E0, $80, 1,1, bank_player, $60, 4
                 db 0,  11,  -4, $E0, $80, 1,1, bank_player, $60, 3
                 db 0,  11,  -2, $E0, $80, 1,1, bank_player, $60, 2
                 db 0,  12,   5, $E2, $80, 1,1, bank_player, $62, 1
                 db 0,  12,   7, $E2, $80, 1,1, bank_player, $62, 1
                 db 0,  10,   8, $E2, $80, 1,1, bank_player, $62, 1
                 db 0,   3,  13, $E4, $80, 1,1, bank_player, $64, 4
                 db 0,   3,  14, $E4, $80, 1,1, bank_player, $64, 7
                 db 0,   3,  14, $E4, $80, 1,1, bank_player, $64, 12
                 db 0,   4,  15, $E4, $80, 1,1, bank_player, $68, 1
                 db $FF ; end of action (-1)

; 右方向への剣攻撃アクションテーブル（左手）
;                   o  yof  xof  ptn  atr  h,w  bank         ppt  wt
player_sword_lr: db 1, -10,   0, $C0, $C0, 1,1, bank_player, $64, 4
                 db 1, -10,   0, $C0, $C0, 1,1, bank_player, $64, 3
                 db 1,  -8,   4, $C0, $C0, 1,1, bank_player, $64, 2
                 db 1,  -6,   8, $C2, $C0, 1,1, bank_player, $62, 2
                 db 1,  -2,   9, $C2, $C0, 1,1, bank_player, $62, 1
                 db 1,   2,  12, $C4, $C0, 1,1, bank_player, $60, 4
                 db 1,   3,  12, $C4, $C0, 1,1, bank_player, $60, 7
                 db 1,   4,  12, $C4, $C0, 1,1, bank_player, $60, 12
                 db 1,   4,  14, $C4, $C0, 1,1, bank_player, $6A, 1
                 db $FF ; end of action (-1)
