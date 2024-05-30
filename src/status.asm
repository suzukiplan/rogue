.status_init
    ld a, bank_status
    ld (vdp_dpm_fg), a

    ; ウィンドウ背景とアトリビュートを描画
    ld hl, vdp_nametbl_fg
    inc hl
    add hl, 32
    ld b, 24
status_init_attr_y:
    push bc
    ld b, 8
status_init_attr_x:
    xor a
    ld (hl), a
    add hl, $400
    ld a, $85
    ld (hl), a
    add hl, -$400
    inc hl
    djnz status_init_attr_x
    add hl, 32 - 8
    pop bc
    djnz status_init_attr_y

    ; 四隅の角を描画
    ld hl, vdp_nametbl_fg
    inc hl
    add hl, 32
    ld a, $05
    ld (hl), a
    add hl, 7
    ld a, $06
    ld (hl), a
    add hl, 32 * 23
    ld a, $08
    ld (hl), a
    add hl, -7
    ld a, $07
    ld (hl), a

    ; 上下枠を描画
    ld hl, vdp_nametbl_fg
    inc hl
    add hl, 33
    ld b, 6
status_init_ud:
    ld a, $03
    ld (hl), a
    add hl, 32 * 23
    ld a, $04
    ld (hl), a
    add hl, -(32 * 23) + 1
    djnz status_init_ud

    ; 左右枠を描画
    ld hl, vdp_nametbl_fg
    add hl, 65
    ld b, 22
status_init_lr:
    ld a, $01
    ld (hl), a
    add hl, 7
    ld a, $02
    ld (hl), a
    add hl, 32 - 7
    djnz status_init_lr

    xor a
    ld (status_pos), a
    ld (status_tag), a
    ld (status_dir), a
    ld (status_vdir), a
    ld (status_hidden), a

    ld hl, $0202
    ld de, status_str0
    call vdp_print_fg_with_DEHL
    ld hl, $0302
    ld de, status_str1
    call vdp_print_fg_with_DEHL
    ld hl, $0502
    ld de, status_str2
    call vdp_print_fg_with_DEHL
    ret

status_str0: db "ROGUE",0
status_str1: db "LIKE",0
status_str2: db "A.RPG",0

.status_update_safe
    push af
    push bc
    push de
    push hl
    call status_update
    pop hl
    pop de
    pop bc
    pop af
    ret

.status_update
    ld a, (status_vdir)
    and a
    ret nz

    ld a, (status_dir)
    and a
    jnz status_update_move

    ld a, (status_pos)
    and a
    jnz status_update_check_right

status_update_check_left:
    ld a, (vdp_oam_addr + si_player * oam_size + oam_x)
    cp 100
    ret nc
    ld a, -1
    ld (status_dir), a
    ld a, 22
    ld (status_tag), a
    ret
status_update_check_right:
    ld a, (vdp_oam_addr + si_player * oam_size + oam_x)
    cp 140
    ret c
    ld a, 1
    ld (status_dir), a
    ld a, 0
    ld (status_tag), a
    ret

status_update_move:
    ld a, (status_pos)
    ld hl, status_dir
    add (hl)
    and $1F
    ld (status_pos), a

    ld h, a
    ld l, 8
    xor a
    out ($C5), a
    ld a, l
    neg
    ld (vdp_scroll_fg_x), a

    ld a, (status_pos)
    ld hl, status_tag
    cp (hl)
    ret nz

    xor a
    ld (status_dir), a
    ret

.status_toggle
    ; 移動中の場合はキャンセル
    ld a, (status_dir)
    and a
    ret nz

    ; 切り替え中かチェック
    ld a, (status_vdir)
    and a
    jz status_toggle_check
    jp status_toggle_move

status_toggle_check:
    ; 現在フレームで SELECT が押されているかチェック
    ld a, (joypad)
    and %00000100
    ret nz

    ; 直前フレームで SELECT が離されていたかチェック
    ld a, (joypad_prev)
    and %00000100
    ret z

    ld a, (status_hidden)
    and a
    jz status_toggle_hide

status_toggle_show:
    xor a
    ld (status_hidden), a
    ld a, (vdp_oam_addr + si_player * oam_size + oam_x)
    cp 120
    jc status_toggle_show_to_left
status_toggle_show_to_right:
    ld a, 22
    ld (status_pos), a
    xor a
    ld (status_tag), a
    ld a, $01
    ld (status_vdir), a
    ld a, 8
    ld (status_ax), a
    ret
status_toggle_show_to_left:
    xor a
    ld (status_pos), a
    ld a, 22
    ld (status_tag), a
    ld a, $FF
    ld (status_vdir), a
    ld a, 1
    ld (status_ax), a
    ret

status_toggle_hide:
    inc a
    ld (status_hidden), a
    ld a, (status_pos)
    and a
    jz status_toggle_hide_to_left
status_toggle_hide_to_right:
    xor a
    ld (status_tag), a
    ld a, $01
    ld (status_vdir), a
    ld a, 8
    ld (status_ax), a
    ret
status_toggle_hide_to_left:
    ld a, 22
    ld (status_tag), a
    ld a, $FF
    ld (status_vdir), a
    ld a, 1
    ld (status_ax), a
    ret

status_toggle_move:
    ld a, (status_ax)
    cp 1
    jc status_toggle_move_do
    cp 9
    jnc status_toggle_move_do
    ld hl, vdp_attr_fg
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a

    ld b, 32
status_toggle_move_attr_loop:
    ld a, (hl)
    xor %10000000
    ld (hl), a
    add hl, 32
    djnz status_toggle_move_attr_loop

    ld a, (status_ax)
    ld hl, status_vdir
    sub (hl)
    and $1F
    ld (status_ax), a

status_toggle_move_do:
    ld a, (status_pos)
    ld hl, status_vdir
    add (hl)
    and $1F
    ld (status_pos), a

    ld h, a
    ld l, 8
    xor a
    out ($C5), a
    ld a, l
    neg
    ld (vdp_scroll_fg_x), a

    ld a, (status_pos)
    ld hl, status_tag
    cp (hl)
    ret nz

    xor a
    ld (status_vdir), a

    ret
