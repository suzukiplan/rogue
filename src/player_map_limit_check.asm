.player_map_limit_check
    call player_map_limit_check_UD
    call player_map_limit_check_LR
    ret

player_map_limit_check_UD:
    ld a, (player_ly + 1)
    and $80
    jnz player_map_limit_check_up
    ld hl, (player_ly)
    ld a, l
    or h
    jnz player_map_limit_check_down
    ret

player_map_limit_check_LR:
    ld a, (player_lx + 1)
    and $80
    jnz player_map_limit_check_left
    ld hl, (player_lx)
    ld a, l
    or h
    jnz player_map_limit_check_right
    ret

player_map_limit_check_up:
    ld a, (player_y + 1)
    and a
    ret nz
    call map_scroll_top
    ret

player_map_limit_check_down:
    ld a, (player_y + 1)
    cp 184
    ret c
    call map_scroll_bottom
    ret

player_map_limit_check_left:
    ld a, (player_x + 1)
    cp 9
    ret nc
    call map_scroll_left
    ret

player_map_limit_check_right:
    ld a, (player_x + 1)
    cp 232
    ret c
    call map_scroll_right
    ret
