#define vdp_nametbl_bg  $8000
#define vdp_attr_bg     $8400
#define vdp_nametbl_fg  $8800
#define vdp_attr_fg     $8C00
#define vdp_oam_addr    $9000
#define vdp_palette     $9800
#define vdp_status      $9F07
#define vdp_dpm_bg      $9F08
#define vdp_dpm_fg      $9F09
#define vdp_dpm_sprite  $9F0A
#define vdp_pattern     $A000
#define vdp_scroll_bg_x $9F02
#define vdp_scroll_bg_y $9F03
#define vdp_scroll_fg_x $9F04
#define vdp_scroll_fg_y $9F05

.vdp_init
    call vdp_vsync_wait
    call vdp_palette_init
    call vdp_cls
    call vdp_dpm_init
    ret

.vdp_vsync_wait
    push af
vdp_vsync_wait_loop:
    ld a, (vdp_status)
    and $80
    jz vdp_vsync_wait_loop
    pop af
    ret

; パレットを初期化
.vdp_palette_init
    push af
    push bc
    push de
    push hl
    ld a, bank_palette
    out ($c0), a
    ld hl, vdp_pattern
    ld de, vdp_palette
    ld bc, $200
    ldir
    pop hl
    pop de
    pop bc
    pop af
    ret

; 初期状態を font.chr にする
.vdp_dpm_init
    push af
    ld a, bank_map01
    ld (vdp_dpm_bg), a
    ld a, bank_font
    ld (vdp_dpm_fg), a
    ld (vdp_dpm_sprite), a
    pop af
    ret

; BG の nametable と attribute を 0 クリア
.vdp_cls_bg
    push af
    push bc
    push hl
    ld hl, vdp_nametbl_bg
    ld bc, $800
    xor a
vdp_cls_bg_loop:
    ld (hl), a
    inc hl
    dec bc
    jnz vdp_cls_bg_loop
    pop hl
    pop bc
    pop af
    ret

; FG の nametable と attribute を 0 クリア
.vdp_cls_fg
    push af
    push bc
    push hl
    ld hl, vdp_nametbl_fg
    ld bc, $800
    xor a
vdp_cls_fg_loop:
    ld (hl), a
    inc hl
    dec bc
    jnz vdp_cls_fg_loop
    pop hl
    pop bc
    pop af
    ret

; OAM を 0 クリア
.vdp_cls_oam
    push af
    push bc
    push hl
    ld hl, vdp_oam_addr
    ld bc, $800
    xor a
vdp_cls_oam_loop:
    ld (hl), a
    inc hl
    dec bc
    jnz vdp_cls_oam_loop
    pop hl
    pop bc
    pop af
    ret

.vdp_cls
    call vdp_cls_bg
    call vdp_cls_fg
    call vdp_cls_oam
    ret


; HLに指定された座標X,Y座標をBGのBGのネームテーブルアドレスへ変換
.vdp_xy_to_bg_HL
    push af
    push bc
    ld b, h
    xor a
    ld h, a
vdp_xy_to_bg_HL_loop:
    add hl, 32
    djnz vdp_xy_to_bg_HL_loop
    add hl, vdp_nametbl_bg
    pop bc
    pop af
    ret

; HLに指定された座標X,Y座標をFGのFGのネームテーブルアドレスへ変換
.vdp_xy_to_fg_HL
    push af
    push bc
    ld b, h
    xor a
    ld h, a
vdp_xy_to_fg_HL_loop:
    add hl, 32
    djnz vdp_xy_to_fg_HL_loop
    add hl, vdp_nametbl_fg
    pop bc
    pop af
    ret

; FG へ $00 終端の文字列を表示
; h = X座標
; l = Y座標
; de = 文字列ポインタ
.vdp_print_fg_with_DEHL
    push af
    push bc
    push de
    push hl

    ; 座標をアドレスオフセットへ変換
    call vdp_xy_to_fg_HL

vdp_print_fg_with_DEHL_loopW:
    ; 文字コード取得
    ld a, (de)
    and a
    jz vdp_print_fg_with_DEHL_end

    ; 文字コード書き込み
    ld (hl), a

    ; 属性更新
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

    inc de
    jmp vdp_print_fg_with_DEHL_loopW

vdp_print_fg_with_DEHL_end:
    pop hl
    pop de
    pop bc
    pop af
    ret

; FG へ unsigned 8bit (0 ~ 255) の数字列を表示
; h = X座標
; l = Y座標
; a = 表示する数字列
; hl に最後に書いた文字のアドレス+1 を返す
.vdp_print_u8_with_AHL
    push af
    push bc
    push de
    call vdp_xy_to_fg_HL
    ld b, 0
    ld d, 0
    ld e, a
    jp vdp_print_s16_with_DEHL_put100

; FG へ signed 16bit (-32768 ~ 32767) の数字列を表示
; h = X座標
; l = Y座標
; de = 表示する数字列
; hl に最後に書いた文字のアドレス+1 を返す
.vdp_print_s16_with_DEHL
    push af
    push bc
    push de

    call vdp_xy_to_fg_HL

    ld a, d
    and $80
    jz vdp_print_s16_with_DEHL_put10k

    ; マイナスを描画
    ld (hl), '-'

    ; 属性更新
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

    ; 負数を正数にする
    push hl
    ld hl, 0
    sbc hl, de
    ld de, hl
    pop hl

vdp_print_s16_with_DEHL_put10k:
    ; 1万の位が (ゼロでなければ) 表示
    ld b, 0 ; 描画フラグ
    push hl
    ld hl, de
    ld c, 100
    ld a, $81
    out ($c5), a ; HL = HL / 100
    out ($c5), a ; HL = HL / 100
    ld c, l
    pop hl
    ld a, c
    and a
    jz vdp_print_s16_with_DEHL_put1k
    ld b, 1 ; 以降は 0 でも描画
    add '0'
    ld (hl), a
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

vdp_print_s16_with_DEHL_put1k:
    push hl
    ld hl, de
    ld c, 100
    ld a, $81
    out ($c5), a ; HL = HL / 100
    ld c, 10
    out ($c5), a ; HL = HL / 10
    ld a, $82
    out ($c5), a ; HL = HL mod 10
    ld c, l
    pop hl
    ; 既に1万の位が描画済みなら0でも描画
    ld a, b
    and a
    jnz vdp_print_s16_with_DEHL_put1k_do
    ; 0でなければ描画
    ld a, c
    and a
    jz vdp_print_s16_with_DEHL_put100
vdp_print_s16_with_DEHL_put1k_do:
    ld b, 1 ; 以降は 0 でも描画
    ld a, c
    add '0'
    ld (hl), a
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

vdp_print_s16_with_DEHL_put100:
    push hl
    ld hl, de
    ld c, 100
    ld a, $81
    out ($c5), a ; HL = HL / 100
    ld c, 10
    ld a, $82
    out ($c5), a ; HL = HL mod 10
    ld c, l
    pop hl
    ; 既に1000以上の位が描画済みなら0でも描画
    ld a, b
    and a
    jnz vdp_print_s16_with_DEHL_put100_do
    ; 0でなければ描画
    ld a, c
    and a
    jz vdp_print_s16_with_DEHL_put10
vdp_print_s16_with_DEHL_put100_do:
    ld b, 1 ; 以降は 0 でも描画
    ld a, c
    add '0'
    ld (hl), a
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

vdp_print_s16_with_DEHL_put10:
    push hl
    ld hl, de
    ld c, 10
    ld a, $81
    out ($c5), a ; HL = HL / 10
    ld a, $82
    out ($c5), a ; HL = HL mod 10
    ld c, l
    pop hl
    ; 既に100以上の位が描画済みなら0でも描画
    ld a, b
    and a
    jnz vdp_print_s16_with_DEHL_put10_do
    ; 0でなければ描画
    ld a, c
    and a
    jz vdp_print_s16_with_DEHL_put1
vdp_print_s16_with_DEHL_put10_do:
    ld a, c
    add '0'
    ld (hl), a
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

vdp_print_s16_with_DEHL_put1:
    push hl
    ld hl, de
    ld c, 10
    ld a, $82
    out ($c5), a ; HL = HL mod 10
    ld c, l
    pop hl
    ld a, c
    add '0'
    ld (hl), a
    add hl, $0400
    ld a, $85
    ld (hl), a
    add hl, -$03FF

vdp_print_s16_with_DEHL_end:
    pop de
    pop bc
    pop af
    ret
