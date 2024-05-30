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
