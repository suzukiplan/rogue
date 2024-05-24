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

#include "player_move.asm"
#include "player_attack.asm"

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
                 ; keep mode pattern
                 db 0,  13,  -3, $84, $80, 1,1, bank_player, $08, 1
                 db 0,  12,  -4, $84, $80, 1,1, bank_player, $0A, 1

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
                 db 0,  13,   3, $84, $C0, 1,1, bank_player, $0C, 1
                 db $FF ; end of action (-1)
                 db 0,  13,   3, $84, $C0, 1,1, bank_player, $0C, 1
                 db 0,  12,   4, $84, $C0, 1,1, bank_player, $0E, 1

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
                 db 1, -11,   3, $A4, $80, 1,1, bank_player, $28, 1
                 db $FF ; end of action (-1)
                 db 1, -11,   3, $A4, $80, 1,1, bank_player, $28, 1
                 db 1, -10,   4, $A4, $80, 1,1, bank_player, $2A, 1

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
                 db 1, -11,  -3, $A4, $C0, 1,1, bank_player, $2C, 1
                 db $FF ; end of action (-1)
                 db 1, -11,  -3, $A4, $C0, 1,1, bank_player, $2C, 1
                 db 1, -10,  -2, $A4, $C0, 1,1, bank_player, $2E, 1

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
                 db 1,   4, -14, $C4, $80, 1,1, bank_player, $48, 1
                 db 1,   3, -15, $C4, $80, 1,1, bank_player, $4A, 1


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
                 db 0,   4, -15, $E4, $C0, 1,1, bank_player, $4C, 1
                 db $FF ; end of action (-1)
                 db 0,   4, -15, $E4, $C0, 1,1, bank_player, $4C, 1
                 db 0,   3, -16, $E4, $C0, 1,1, bank_player, $4E, 1

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
                 db 0,   4,  15, $E4, $80, 1,1, bank_player, $68, 1
                 db 0,   3,  16, $E4, $80, 1,1, bank_player, $6A, 1

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
                 db 1,   4,  14, $C4, $C0, 1,1, bank_player, $6C, 1
                 db $FF ; end of action (-1)
                 db 1,   4,  14, $C4, $C0, 1,1, bank_player, $6C, 1
                 db 1,   3,  15, $C4, $C0, 1,1, bank_player, $6E, 1
