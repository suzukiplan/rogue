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
    ld a, h
    cp 8
    jnc player_move_update_vars_x_check_right
    ld hl, $0800
    jr player_move_update_vars_x_set
player_move_update_vars_x_check_right:
    cp $E8
    jc player_move_update_vars_x_set
    ld hl, $E800
player_move_update_vars_x_set:
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
    ld a, h
    cp 8
    jnc player_move_update_vars_y_check_bottom
    ld hl, $0800
    jr player_move_update_vars_y_set
player_move_update_vars_y_check_bottom:
    cp $B8
    jc player_move_update_vars_y_set
    ld hl, $B800
player_move_update_vars_y_set:
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
    ld a, (player_wk)
    and a
    jnz player_move_up_skip_setdir
    ld a, (player_wf)
    and a
    jnz player_move_up_skip_setdir
    ld a, $20
    ld (player_dir), a
player_move_up_skip_setdir:
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
    ld a, (player_wk)
    and a
    jnz player_move_down_skip_setdir
    ld a, (player_wf)
    and a
    jnz player_move_down_skip_setdir
    ld a, $00
    ld (player_dir), a
player_move_down_skip_setdir:
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
    ld a, (player_wk)
    and a
    jnz player_move_left_skip_setdir
    ld a, (player_wf)
    and a
    jnz player_move_left_skip_setdir
    ld a, $40
    ld (player_dir), a
player_move_left_skip_setdir:
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
    ld a, (player_wk)
    and a
    jnz player_move_right_skip_setdir
    ld a, (player_wf)
    and a
    jnz player_move_right_skip_setdir
    ld a, $60
    ld (player_dir), a
player_move_right_skip_setdir:
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
