#include "actbl_define.asm"

org $0000

.reset
    di                              ; 割り込みは一切使わない
    ld sp, $0000                    ; スタックは 0xFFFF から使う
    call vdp_init                   ; 映像初期化
    call map_generate               ; テスト用のマップ生成
    call player_init                ; プレイヤの座標初期化
    call map_render_init            ; 初期マップを描画
    call status_init                ; ステータスウィンドウの描画初期化

main_loop:
    call vdp_vsync_wait             ; 垂直同期待ち
    call joypad_update              ; ジョイパッド入力を更新（現フレーム: joypad, 前フレーム: joypad_prev）
    call player_move                ; 自機の移動
    call player_map_limit_check     ; 自機のマップ移動境界チェック
    call map_adjust                 ; マップ位置の調整
    call player_calc_map_position   ; マップ上のプレイヤ座標を算出
    call player_hitchk_map          ; マップとプレイヤの当たり判定
    call player_attack              ; 自機の攻撃（アイテム使用）
    call status_update              ; ステータスウィンドウの表示更新
    call status_toggle              ; ステータスウィンドウの表示・非表示を切り替え
    jr main_loop

.end:
    halt                            ; Steam 版はアプリ終了（RaspberryPi ではハングアップ）

#include "vars.asm"
#include "vdp.asm"
#include "joypad.asm"
#include "player.asm"
#include "map.asm"
#include "status.asm"
