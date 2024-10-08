.mapgen_init_chip_dungeon
    ld a, $02
    ld (mapchip_ground), a
    ld a, $01
    ld (mapchip_shadow), a
    ld a, $80
    ld (mapchip_wall), a
    ret

.mapgen_init_chip_rogue
    ld a, $10
    ld (mapchip_ground), a
    ld a, $00
    ld (mapchip_shadow), a
    ld a, $81
    ld (mapchip_wall), a
    ret

; 全てのマップバンクをゼロクリア
.mapgen_init_banks
    ld b, 0
    ld a, 0
    ld hl, $2000
mapgen_init_banks_loop:
    push bc
    ld bc, $A000
    out ($C2), a
    pop bc
    djnz mapgen_init_banks_loop
    ret

; HL に指定されたマップ座標系をアドレス形式に変換（HL以外のレジスタは変えない）
.mangen_xy_to_addr_with_HL
    push af

    ; 範囲外を指定できないようにしておく
    ld a, h
    and $3F
    ld h, a
    ld a, l
    and $3F
    ld l, a

    ; X,Y を マップアドレスに変換
    push bc
    ld b, h
    ld h, 64
    xor a
    out ($C5), a ; HL = L * 64
    ld a, b
    pop bc
    add l
    ld l, a
    ld a, 0
    adc h
    or $A0
    ld h, a

    pop af
    ret


; BC から描画基点アドレスを HL に求める
; B = 埋める基点X座標（0〜63）
; C = 埋める基点Y座標（0〜63）
.mangen_calc_addr
    ; A をスタックに保持しておく
    push af

    ; 念の為X,Yをmod64しておく
    ld a, b
    and $3F
    ld b, a
    ld a, c
    and $3F
    ld c, a

    ; 幅がオーバーする場合は補正
    ld a, b
    add d
    cp 65
    jc mangen_calc_addr_width_checked ; x + width < 65 なら補正不要
    ld a, 64
    sub b
    ld d, a
mangen_calc_addr_width_checked:

    ; 高さがオーバーする場合は補正
    ld a, c
    add e
    cp 65
    jc mangen_calc_addr_height_checked ; y + height < 65 なら補正不要
    ld a, 64
    sub c
    ld e, a
mangen_calc_addr_height_checked:

    ; HL を基点アドレスにする
    ld l, c
    ld h, 64
    xor a
    out ($C5), a ; HL = C * 64
    ld a, b
    add l
    ld l, a
    ld a, 0
    adc h
    or $A0
    ld h, a

    ; A をスタックから復帰
    pop af
    ret

; マップを壁で埋める
.mapgen_fill_wall
    ; マップを壁 ($80) で埋める
    ld a, (mapchip_wall)
    ld bc, $0000 ; X=0, Y=0
    ld de, $4040 ; W=64, H=64
    call mapgen_fill
    ret

; 指定された範囲のマップを指定されたパターンで埋める
; BC/DE は呼び出し時点の値を保持
; A = パターン番号
; B = 埋める基点X座標（0〜63）
; C = 埋める基点Y座標（0〜63）
; D = 埋める幅（1〜64）
; E = 埋める高さ（1〜64）
.mapgen_fill
    push bc
    push de
    call mangen_calc_addr
mapgen_fill_loopY:
    ld b, d
mapgen_fill_loopX:
    ld (hl), a
    inc hl
    djnz mapgen_fill_loopX

    ; HL を次の行にポイント
    push af
    ld a, 64
    sub d
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    pop af

    ; 次の行がまだあれば描画
    dec e
    jnz mapgen_fill_loopY
    pop de
    pop bc
    ret

; 指定された範囲のマップを指定されたパターンで囲う
; A = パターン番号
; B = 埋める基点X座標（0〜63）
; C = 埋める基点Y座標（0〜63）
; D = 埋める幅（1〜64）
; E = 埋める高さ（1〜64）
.mapgen_rect
    call mangen_calc_addr

    ; 1 行描画
mapgen_rect_line:
    ld b, d
mapgen_rect_line_loop:
    ld (hl), a
    inc hl
    djnz mapgen_rect_line_loop

mapgen_rect_next:
    dec e
    ret z

    ; HL を次の行にポイント
    push af
    ld a, 64
    sub d
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    pop af

    ; 次の行が最終行かチェック
    ld c, a
    ld a, e
    cp 1
    ld a, c
    jz mapgen_rect_line

    ; 左端と右端だけ描画
    ld (hl), a
    ld a, d
    dec a
    add l
    ld l, a
    ld a, 0
    adc h
    ld h, a
    ld a, c    
    ld (hl), a
    inc hl
    jr mapgen_rect_next

; 4x4〜20x20 の部屋を作成して BC に部屋の中央座標を返す
.mapgen_make_room
mapgen_make_room_retry1:
    in a, ($CA)
    and $3F
    cp 2
    jc mapgen_make_room_retry1 ; 2 未満はリトライ
    cp 59
    jnc mapgen_make_room_retry1 ; 59 以上はリトライ
    ld b, a

mapgen_make_room_retry2:
    in a, ($CA)
    and $3F
    cp 2
    jc mapgen_make_room_retry2 ; 2 未満はリトライ
    cp 59
    jnc mapgen_make_room_retry2 ; 59 以上はリトライ
    ld c, a

mapgen_make_room_retry3:
    in a, ($CA)
    and $0F
    add 4
    ld d, a
    add b
    cp 64
    jnc mapgen_make_room_retry3 ; x+w >= 64 ならリトライ

mapgen_make_room_retry4:
    in a, ($CA)
    and $0F
    add 4
    ld e, a
    add c
    cp 64
    jnc mapgen_make_room_retry4 ; y+h >= 64 ならリトライ

    ld a, (mapchip_ground)
    call mapgen_fill
    ; 中央座標（穴掘り用）を返す
    srl d
    ld a, b
    add d
    ld b, a
    srl e
    ld a, c
    add e
    ld c, a
    ret

; 指定されたマップ座標のチップパターンを取得（Aに返す）
; H = 基点X座標（0〜63）
; L = 基点Y座標（0〜63）
.mapgen_get_chip
    call mangen_xy_to_addr_with_HL
    ld a, (hl)
    ret

; 指定されたマップ座標にチップパターンを書き込む
; A = 書き込むチップパターン
; H = 基点X座標（0〜63）
; L = 基点Y座標（0〜63）
.mapgen_set_chip
    call mangen_xy_to_addr_with_HL
    ld (hl), a
    ret

; 現在のマップに影を描画
.mangen_shadow
    ; 影を描画
    ld hl, $0101
    call mangen_xy_to_addr_with_HL
mangen_shadow_loop:
    push hl

    ; HL が地面かチェック
    ld a, (hl)
    ld ix, mapchip_ground
    cp (ix+0)
    jnz mangen_shadow_next ; 地面ではないのでスキップ

    ; 上のチップが壁かチェック
    add hl, -64
    ld a, (hl)
    ld ix, mapchip_wall
    cp (ix+0)
    jz mangen_shadow_draw ; 上が壁なので影を描画

    ; 左上が壁かチェック
    add hl, -1
    ld a, (hl)
    cp (ix+0)
    jz mangen_shadow_draw ; 左上が壁なので影を描画

    ; 左のチップが壁かチェック
    add hl, 64
    ld a, (hl)
    cp (ix+0)
    jnz mangen_shadow_next ; 左が壁ではないのでスキップ

mangen_shadow_draw:
    ; 影を描画
    pop hl
    push hl
    ld a, (mapchip_shadow)
    ld (hl), a

mangen_shadow_next:
    ; $A000 + 4096 - 64 まで繰り返す
    pop hl
    inc hl
    ld a, l
    cp $C0
    jnz mangen_shadow_loop
    ld a, h
    cp $AF
    jnz mangen_shadow_loop
    ret

; プレイヤポジションを map1st_x, map1st_y に初期化
.mangen_player_position_init
    ; 最初の部屋の中央座標にプレイヤ初期座標 (X) を設定
    ld a, (map1st_x)
    cp 16
    jc map_generate_set_left_zero
    cp 32
    jnc map_generate_set_left_limit
    sub 16
    jr map_generate_set_left
map_generate_set_left_limit:
    ld a, 31
    jr map_generate_set_left
map_generate_set_left_zero:
    xor a
map_generate_set_left:
    ld (map_left), a
    ld a, (map1st_x)
    ld hl, map_left
    sub (hl)
    rlca ; x2
    rlca ; x4
    rlca ; x8
    ld h, a
    ld l, 0
    ld (player_x), hl

    ; 最初の部屋の中央座標にプレイヤ初期座標 (Y) を設定
    ld a, (map1st_y)
    cp 12
    jc map_generate_set_top_zero
    cp 40
    jnc map_generate_set_top_limit
    sub 12
    jr map_generate_set_top
map_generate_set_top_limit:
    ld a, 39
    jr map_generate_set_top
map_generate_set_top_zero:
    xor a
map_generate_set_top:
    ld (map_top), a
    ld a, (map1st_y)
    ld hl, map_top
    sub (hl)
    rlca ; x2
    rlca ; x4
    rlca ; x8
    ld h, a
    ld l, 0
    ld (player_y), hl
    ret
