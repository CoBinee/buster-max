; EnemyOne.s : 種類別のエネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Math.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Maze.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "EnemyOne.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 何もしない
;
_EnemyNull::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; リーパーが行動する
;
_EnemyReaper::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 90$

    ; 左右移動の更新
    xor     a
    bit     #0x00, ENEMY_ANIMATION(ix)
    jr      z, 100$
    ld      a, #ENEMY_REAPER_SPEED_X_MAXIMUM
100$:
    call    _EnemyGetApproachX
    ld      ENEMY_SPEED_X(ix), a

    ; 上下移動の更新
    call    _EnemyIsLand
    jr      nc, 110$
    ld      ENEMY_SPEED_Y(ix), #0x00
110$:
    ld      e, #ENEMY_REAPER_SPEED_Y_GRAVITY
    ld      d, #ENEMY_REAPER_SPEED_Y_MAXIMUM
    call    _EnemyAccelY

    ; 移動
    call    _EnemyMove
    call    _EnemyFallDown

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_REAPER_RECT_TOP << 8) | ENEMY_REAPER_RECT_LEFT)
    ld      de, #((ENEMY_REAPER_RECT_BOTTOM << 8) | ENEMY_REAPER_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyReaperSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; グレムリンが行動する
;
_EnemyGremlin::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; ジャンプの設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_0(ix), a

    ; 方向転換の設定
    ld      ENEMY_PARAM_1(ix), #0x01
    ld      ENEMY_PARAM_2(ix), #0x00

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 90$

    ; ジャンプ
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 109$
    dec     ENEMY_PARAM_0(ix)
    jr      z, 100$
    ld      ENEMY_SPEED_Y(ix), #0x00
    jr      109$
100$:
    ld      ENEMY_SPEED_Y(ix), #ENEMY_GREMLIN_SPEED_Y_JUMP
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_0(ix), a
;   jr      109$
109$:

    ; 方向転換
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      z, 110$
    ld      a, ENEMY_PARAM_2(ix)
    neg
    ld      ENEMY_PARAM_2(ix), a
    jr      119$
110$:
    dec     ENEMY_PARAM_1(ix)
    jr      nz, 119$
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_1(ix), a
    and     #0x08
    ld      a, #ENEMY_GREMLIN_SPEED_X_MAXIMUM
    jr      z, 111$
    neg
111$:
    ld      ENEMY_PARAM_2(ix), a
;   jr      119$
119$:

    ; 左右移動の更新
    ld      a, ENEMY_PARAM_2(ix)
    ld      ENEMY_SPEED_X(ix), a

    ; 上下移動の更新
    ld      e, #ENEMY_GREMLIN_SPEED_Y_GRAVITY
    ld      d, #ENEMY_GREMLIN_SPEED_Y_MAXIMUM
    call    _EnemyAccelY

    ; 移動
    call    _EnemyMove
    call    _EnemyFallDown

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_GREMLIN_RECT_TOP << 8) | ENEMY_GREMLIN_RECT_LEFT)
    ld      de, #((ENEMY_GREMLIN_RECT_BOTTOM << 8) | ENEMY_GREMLIN_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyGremlinSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; ゲイザーが行動する
;
_EnemyGazer::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 左右移動の設定
    call    _SystemGetRandom
    and     #0x20
    ld      a, #ENEMY_GAZER_SPEED_X_MAXIMUM
    jr      z, 00$
    neg
00$:
    ld      ENEMY_PARAM_0(ix), a

    ; 上下移動の設定
    call    _SystemGetRandom
    and     #0x04
    ld      a, #ENEMY_GAZER_SPEED_Y_MAXIMUM
    jr      z, 01$
    neg
01$:
    ld      ENEMY_PARAM_1(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 90$

    ; 左右移動の更新
    ld      a, ENEMY_PARAM_0(ix)
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      z, 100$
    neg
    ld      ENEMY_PARAM_0(ix), a
100$:
    ld      ENEMY_SPEED_X(ix), a

    ; 上下移動の更新
    ld      a, ENEMY_PARAM_1(ix)
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 110$
    neg
    ld      ENEMY_PARAM_1(ix), a
110$:
    ld      ENEMY_SPEED_Y(ix), a

    ; 移動
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_GAZER_RECT_TOP << 8) | ENEMY_GAZER_RECT_LEFT)
    ld      de, #((ENEMY_GAZER_RECT_BOTTOM << 8) | ENEMY_GAZER_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyGazerSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; バットが行動する
;
_EnemyBat::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 左右移動の設定
    call    _SystemGetRandom
    and     #0x20
    ld      a, #ENEMY_BAT_SPEED_X_MAXIMUM
    jr      z, 00$
    neg
00$:
    ld      ENEMY_PARAM_0(ix), a

    ; Y 位置の設定
    call    _SystemGetRandom
    and     #0x0f
    sub     #0x08
    add     a, #ENEMY_BAT_POSITION_Y
    ld      ENEMY_POSITION_Y(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 上下移動の設定
    ld      ENEMY_PARAM_2(ix), #ENEMY_BAT_SPEED_Y_CURVE_MAXIMUM
    ld      ENEMY_PARAM_3(ix), #-ENEMY_BAT_SPEED_Y_CURVE_ACCEL

    ; 降下の設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x40
    ld      ENEMY_PARAM_4(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 方向転換
    ld      a, ENEMY_PARAM_0(ix)
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      z, 100$
    neg
    ld      ENEMY_PARAM_0(ix), a
100$:
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 101$
    ld      a, ENEMY_PARAM_2(ix)
    neg
    ld      ENEMY_PARAM_2(ix), a
    ld      a, ENEMY_PARAM_3(ix)
    neg
    ld      ENEMY_PARAM_3(ix), a
101$:

    ; 振幅移動
    ld      a, ENEMY_PARAM_4(ix)
    or      a
    jr      z, 120$
    ld      a, ENEMY_PARAM_2(ix)
    add     a, ENEMY_PARAM_3(ix)
    ld      ENEMY_PARAM_2(ix), a
    cp      #ENEMY_BAT_SPEED_Y_CURVE_MAXIMUM
    jr      c, 110$
    jr      z, 110$
    cp      #-ENEMY_BAT_SPEED_Y_CURVE_MAXIMUM
    jr      nc, 110$
    ld      a, ENEMY_PARAM_3(ix)
    neg
    ld      ENEMY_PARAM_3(ix), a
110$:
    dec     ENEMY_PARAM_4(ix)
    jr      nz, 190$
    ld      ENEMY_PARAM_2(ix), #ENEMY_BAT_SPEED_Y_DROP_MAXIMUM

    ; 降下
120$:
    ld      a, ENEMY_PARAM_2(ix)
    sub     #ENEMY_BAT_SPEED_Y_DROP_BRAKE
    jp      p, 121$
    cp      #-ENEMY_BAT_SPEED_Y_DROP_MAXIMUM
    jr      nc, 121$
    ld      a, #-ENEMY_BAT_SPEED_Y_DROP_MAXIMUM
121$:
    ld      ENEMY_PARAM_2(ix), a
    or      a
    jp      p, 190$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      ENEMY_PARAM_1(ix)
    jr      nc, 190$
    ld      ENEMY_PARAM_2(ix), #-ENEMY_BAT_SPEED_Y_CURVE_MAXIMUM
    ld      ENEMY_PARAM_3(ix), #ENEMY_BAT_SPEED_Y_CURVE_ACCEL
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x40
    ld      ENEMY_PARAM_4(ix), a

    ; 移動
190$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_2(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_BAT_RECT_TOP << 8) | ENEMY_BAT_RECT_LEFT)
    ld      de, #((ENEMY_BAT_RECT_BOTTOM << 8) | ENEMY_BAT_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyBatSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; メイジが行動する
;
_EnemyMage::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    call    _EnemySetRoomPositionX
    ld      ENEMY_POSITION_Y(ix), #((MAZE_CELL_Y - 0x01) * MAZE_CELL_PIXEL - 0x01)

    ; 時間の設定
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x10
    ld      ENEMY_PARAM_0(ix), a

    ; 点滅の設定
    ld      ENEMY_DAMAGE_FRAME(ix), #ENEMY_MAGE_BLINK_FRAME

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_MAGE_ANIMATION_STAY

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
    ld      ENEMY_STATE(ix), #0x0f
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      nz, 90$

    ; 待機
20$:
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 30$
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 29$

    ; 発射の設定
    call    _SystemGetRandom
    and     #0x01
    add     a, #0x03
    add     a, a
    add     a, a
    add     a, a
    ld      ENEMY_PARAM_0(ix), a

    ; スプライトの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_MAGE_ANIMATION_FIRE

    ; 待機の完了
    inc     ENEMY_STATE(ix)
29$:
    jr      90$

    ; 発射
30$:
    dec     a
    jr      nz, 40$
    ld      a, ENEMY_PARAM_0(ix)
    and     #0x07
    jr      nz, 37$
    ld      hl, #enemyMageFireOffset
    ld      a, ENEMY_POSITION_X(ix)
    sub     (hl)
    jr      c, 38$
    ld      d, a
    inc     hl
    ld      a, ENEMY_POSITION_Y(ix)
    sub     (hl)
    jr      c, 38$
    ld      l, d
    ld      h, a
    call    _SystemGetRandom
    rlca
    and     #0x07
    cp      #0x05
    jr      c, 31$
    sub     #0x04
31$:
    add     a, #0x06
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      nc, 32$
    ld      a, d
    add     a, #(0x16 - 0x06)
    ld      d, a
32$:
    ld      e, #0x03
    call    _EnemyFireBallStraight
37$:
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 39$

    ; 点滅の設定
38$:
    ld      ENEMY_DAMAGE_FRAME(ix), #ENEMY_MAGE_BLINK_FRAME

    ; 発射の完了
    inc     ENEMY_STATE(ix)
39$:
    jr      90$

    ; 消える
40$:
    ld      ENEMY_STATE(ix), #0x00
;   jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_MAGE_RECT_TOP << 8) | ENEMY_MAGE_RECT_LEFT)
    ld      de, #((ENEMY_MAGE_RECT_BOTTOM << 8) | ENEMY_MAGE_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyMageSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; サイクロプスが行動する
;
_EnemyCyclops::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    call    _EnemySetRoomPositionX
    ld      ENEMY_POSITION_Y(ix), #((MAZE_CELL_Y - 0x01) * MAZE_CELL_PIXEL - 0x01)
    
    ; ジャンプの設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_0(ix), a

    ; 方向転換の設定
    ld      ENEMY_PARAM_1(ix), #0x01
    ld      a, #ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    call    _EnemyGetApproachX
    ld      ENEMY_PARAM_2(ix), a

    ; 発射の設定
    ld      ENEMY_PARAM_3(ix), #0x00
    ld      ENEMY_PARAM_4(ix), #0x01

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
    ld      a, ENEMY_PARAM_3(ix)
    cp      #0x04
    jr      c, 10$
    ld      ENEMY_PARAM_3(ix), #0x04
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; ジャンプ
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 209$
    dec     ENEMY_PARAM_0(ix)
    jr      z, 200$
    ld      ENEMY_SPEED_Y(ix), #0x00
    jr      209$
200$:
    ld      ENEMY_SPEED_Y(ix), #ENEMY_CYCLOPS_SPEED_Y_JUMP
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_0(ix), a
;   jr      209$
209$:

    ; 方向転換
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      z, 210$
    ld      a, ENEMY_PARAM_2(ix)
    neg
    ld      ENEMY_PARAM_2(ix), a
    jr      219$
210$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #(0x01 * MAZE_CELL_PIXEL)
    jr      nc, 211$
    ld      ENEMY_PARAM_2(ix), #ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    jr      219$
211$:
    cp      #((MAZE_CELL_X - 0x01) * MAZE_CELL_PIXEL)
    jr      c, 212$
    ld      ENEMY_PARAM_2(ix), #-ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    jr      219$
212$:
    dec     ENEMY_PARAM_1(ix)
    jr      nz, 219$
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x20
    ld      ENEMY_PARAM_1(ix), a
    call    _SystemGetRandom
    and     #0x18
    jr      z, 219$
    and     #0x10
    jr      z, 213$
    ld      a, #ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    call    _EnemyGetApproachX
    jr      214$
213$:
    ld      a, ENEMY_PARAM_2(ix)
    neg
214$:
    ld      ENEMY_PARAM_2(ix), a
;   jr      219$
219$:

    ; 左右移動の更新
    ld      a, ENEMY_PARAM_2(ix)
    bit     #0x00, ENEMY_ANIMATION(ix)
    jr      z, 220$
    xor     a
220$:
    ld      ENEMY_SPEED_X(ix), a

    ; 上下移動の更新
    ld      e, #ENEMY_CYCLOPS_SPEED_Y_GRAVITY
    ld      d, #ENEMY_CYCLOPS_SPEED_Y_MAXIMUM
    call    _EnemyAccelY

    ; 移動
    call    _EnemyMove

    ; 発射の待機
    ld      a, ENEMY_PARAM_3(ix)
    or      a
    jr      z, 310$
    dec     ENEMY_PARAM_3(ix)
    jr      nz, 390$
    call    _SystemGetRandom
    and     #0x01
    add     a, #0x03
    add     a, a
    add     a, a
    add     a, a
    ld      ENEMY_PARAM_4(ix), a
    jr      390$

    ; 発射
310$:
    ld      a, ENEMY_PARAM_4(ix)
    and     #0x07
    jr      nz, 319$
    call    _SystemGetRandom
    and     #0x10
    add     a, #ENEMY_CYCLOPS_FIRE_SPEED_X
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      nc, 311$
    ld      hl, #(enemyCyclopsFireOffset + 0x0000)
    ld      a, ENEMY_POSITION_X(ix)
    sub     (hl)
    jr      c, 319$
    ld      d, a
    ld      a, e
    neg
    ld      e, a
    jr      312$
311$:
    ld      hl, #(enemyCyclopsFireOffset + 0x0002)
    ld      a, ENEMY_POSITION_X(ix)
    add     a, (hl)
    jr      c, 319$
    ld      d, a
;   jr      312$
312$:
    inc     hl
    ld      a, ENEMY_POSITION_Y(ix)
    sub     (hl)
    jr      c, 319$
    ld      l, d
    ld      h, a
    call    _SystemGetRandom
    and     #0x1f
    add     a, #ENEMY_CYCLOPS_FIRE_SPEED_Y
    neg
    ld      d, a
    ld      bc, #((ENEMY_CYCLOPS_FIRE_MAXIMUM << 8) | ENEMY_CYCLOPS_FIRE_GRAVITY)
    call    _EnemyFireBallParabola
;   jr      319$
319$:
    dec     ENEMY_PARAM_4(ix)
    jr      nz, 390$
    call    _SystemGetRandom
    rrca
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_3(ix), a
;   jr      390$

    ; 発射の完了
390$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_CYCLOPS_RECT_TOP << 8) | ENEMY_CYCLOPS_RECT_LEFT)
    ld      de, #((ENEMY_CYCLOPS_RECT_BOTTOM << 8) | ENEMY_CYCLOPS_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyCyclopsSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; ヒドラが行動する
;
_EnemyHydra::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    call    _EnemySetRoomPositionX
    ld      ENEMY_POSITION_Y(ix), #((MAZE_CELL_Y - 0x01) * MAZE_CELL_PIXEL - 0x01)
    
    ; 移動の設定
    ld      ENEMY_PARAM_0(ix), #0x00
    ld      a, #ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    call    _EnemyGetApproachX
    ld      ENEMY_PARAM_1(ix), a

    ; 発射の設定
    ld      ENEMY_PARAM_2(ix), #0x01

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
;
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 移動
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jr      z, 29$
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      z, 20$
    ld      a, ENEMY_PARAM_1(ix)
    neg
    ld      ENEMY_PARAM_1(ix), a
    jr      29$
20$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #(0x01 * MAZE_CELL_PIXEL)
    jr      nc, 21$
    ld      ENEMY_PARAM_1(ix), #ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    jr      29$
21$:
    cp      #((MAZE_CELL_X - 0x01) * MAZE_CELL_PIXEL)
    jr      c, 22$
    ld      ENEMY_PARAM_1(ix), #-ENEMY_CYCLOPS_SPEED_X_MAXIMUM
    jr      29$
22$:
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 29$
    ld      ENEMY_PARAM_1(ix), #0x00
    call    _SystemGetRandom
    and     #0x01
    add     a, #0x03
    add     a, a
    add     a, a
    add     a, a
    ld      ENEMY_PARAM_2(ix), a
;   jr      29$
29$:

    ; 左右移動の更新
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_X(ix), a

    ; 上下移動の更新
    ld      e, #ENEMY_HYDRA_SPEED_Y_GRAVITY
    ld      d, #ENEMY_HYDRA_SPEED_Y_MAXIMUM
    call    _EnemyAccelY

    ; 移動
    call    _EnemyMove

    ; 発射
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 39$
    and     #0x07
    jr      nz, 32$
    call    _SystemGetRandom
    and     #0x10
    add     a, #ENEMY_HYDRA_FIRE_SPEED_X
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      nc, 30$
    ld      hl, #(enemyHydraFireOffset + 0x0000)
    ld      a, ENEMY_POSITION_X(ix)
    sub     (hl)
    jr      c, 32$
    ld      d, a
    ld      a, e
    neg
    ld      e, a
    jr      31$
30$:
    ld      hl, #(enemyHydraFireOffset + 0x0002)
    ld      a, ENEMY_POSITION_X(ix)
    add     a, (hl)
    jr      c, 32$
    ld      d, a
;   jr      31$
31$:
    inc     hl
    ld      a, ENEMY_POSITION_Y(ix)
    sub     (hl)
    jr      c, 32$
    ld      l, d
    ld      h, a
    call    _SystemGetRandom
    and     #0x1f
    add     a, #ENEMY_HYDRA_FIRE_SPEED_Y
    neg
    ld      d, a
    ld      bc, #((ENEMY_HYDRA_FIRE_SPEED_Y_MAXIMUM << 8) | ENEMY_HYDRA_FIRE_SPEED_Y_GRAVITY)
    call    _EnemyFireBallBound
;   jr      32$
32$:
    dec     ENEMY_PARAM_2(ix)
    jr      nz, 39$
    call    _SystemGetRandom
    rrca
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_0(ix), a
    ld      a, #ENEMY_HYDRA_SPEED_X_MAXIMUM
    call    _EnemyGetApproachX
    ld      ENEMY_PARAM_1(ix), a
;   jr      39$
39$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_HYDRA_RECT_TOP << 8) | ENEMY_HYDRA_RECT_LEFT)
    ld      de, #((ENEMY_HYDRA_RECT_BOTTOM << 8) | ENEMY_HYDRA_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyHydraSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; デーモンが行動する
;
_EnemyDaemon::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; X 位置の設定
    call    _EnemySetRoomPositionX
    
    ; 左右移動の設定
    ld      a, #ENEMY_DAEMON_SPEED_X_CURVE_MAXIMUM
    call    _EnemyGetApproachX
    ld      ENEMY_PARAM_0(ix), a

    ; Y 位置の設定
    call    _SystemGetRandom
    and     #0x0f
    sub     #0x08
    add     a, #ENEMY_DAEMON_POSITION_Y
    ld      ENEMY_POSITION_Y(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 上下移動の設定
    ld      ENEMY_PARAM_2(ix), #ENEMY_DAEMON_SPEED_Y_CURVE_MAXIMUM
    ld      ENEMY_PARAM_3(ix), #-ENEMY_DAEMON_SPEED_Y_CURVE_ACCEL

    ; 降下の設定
    call    _SystemGetRandom
    and     #0x7f
    add     a, #0x60
    ld      ENEMY_PARAM_4(ix), a

    ; 発射の設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x30
    ld      ENEMY_PARAM_5(ix), a
    ld      ENEMY_PARAM_6(ix), #0x00

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 方向転換
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      z, 100$
    ld      a, ENEMY_PARAM_0(ix)
    neg
    ld      ENEMY_PARAM_0(ix), a
100$:
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 101$
    ld      a, ENEMY_PARAM_2(ix)
    neg
    ld      ENEMY_PARAM_2(ix), a
    ld      a, ENEMY_PARAM_3(ix)
    neg
    ld      ENEMY_PARAM_3(ix), a
101$:

    ; 降下
    ld      a, ENEMY_PARAM_4(ix)
    or      a
    jr      nz, 120$
    ld      a, ENEMY_PARAM_2(ix)
    sub     #ENEMY_DAEMON_SPEED_Y_DROP_BRAKE
    jp      p, 110$
    cp      #-ENEMY_DAEMON_SPEED_Y_DROP_MAXIMUM
    jr      nc, 110$
    ld      a, #-ENEMY_DAEMON_SPEED_Y_DROP_MAXIMUM
110$:
    ld      ENEMY_PARAM_2(ix), a
    or      a
    jp      p, 190$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      ENEMY_PARAM_1(ix)
    jr      nc, 190$
    ld      ENEMY_PARAM_2(ix), #-ENEMY_DAEMON_SPEED_Y_CURVE_MAXIMUM
    ld      ENEMY_PARAM_3(ix), #ENEMY_DAEMON_SPEED_Y_CURVE_ACCEL
    call    _SystemGetRandom
    and     #0x7f
    add     a, #0x60
    ld      ENEMY_PARAM_4(ix), a
    jr      190$

    ; 発射
120$:
    ld      a, ENEMY_PARAM_5(ix)
    or      a
    jr      z, 121$
    dec     ENEMY_PARAM_5(ix)
    jr      nz, 130$
    ld      hl, #enemyDaemonFireOffset
    ld      b, #0x04
    call    _EnemyFireBallStraights
    ld      ENEMY_PARAM_6(ix), #ENEMY_DAEMON_FIRE_FRAME
121$:
    dec     ENEMY_PARAM_6(ix)
    jr      nz, 90$
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x30
    ld      ENEMY_PARAM_5(ix), a
    jr      90$

    ; 振幅移動
130$:
    ld      a, ENEMY_PARAM_2(ix)
    add     a, ENEMY_PARAM_3(ix)
    ld      ENEMY_PARAM_2(ix), a
    cp      #ENEMY_DAEMON_SPEED_Y_CURVE_MAXIMUM
    jr      c, 131$
    jr      z, 131$
    cp      #-ENEMY_DAEMON_SPEED_Y_CURVE_MAXIMUM
    jr      nc, 131$
    ld      a, ENEMY_PARAM_3(ix)
    neg
    ld      ENEMY_PARAM_3(ix), a
131$:
    dec     ENEMY_PARAM_4(ix)
    jr      nz, 190$
    ld      ENEMY_PARAM_2(ix), #ENEMY_DAEMON_SPEED_Y_DROP_MAXIMUM
;   jr      190$

    ; 移動
190$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_2(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_DAEMON_RECT_TOP << 8) | ENEMY_DAEMON_RECT_LEFT)
    ld      de, #((ENEMY_DAEMON_RECT_BOTTOM << 8) | ENEMY_DAEMON_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyDaemonSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; グリーンドラゴンが行動する
;
_EnemyDragonGreen::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; X 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x80
    sub     #0x40
    ld      ENEMY_POSITION_X(ix), a
    
    ; Y 位置の設定
    ld      ENEMY_POSITION_Y(ix), #0x40

    ; 向きの設定
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 速度の設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 発射の設定
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
    ld      ENEMY_PARAM_3(ix), #0x00

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
    ld      ENEMY_PARAM_2(ix), #0x01
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 移動の更新
200$:
    ld      a, ENEMY_PARAM_1(ix)
    or      a
    jr      z, 210$
    jp      p, 201$
    add     a, #ENEMY_DRAGON_SPEED_Y_BRAKE
    jr      c, 202$
    jr      209$
201$:
    sub     #ENEMY_DRAGON_SPEED_Y_BRAKE
    jr      c, 202$
    jr      209$
202$:
    xor     a
;   jr      209$
209$:
    ld      ENEMY_PARAM_1(ix), a
    jr      230$

    ; 向きの設定
210$:
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 発射の更新
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 310$
    dec     ENEMY_PARAM_2(ix)
    jr      z, 300$

    ; 移動の開始
220$:
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ENEMY_DRAGON_POSITION_TOP
    jr      c, 223$
    cp      #ENEMY_DRAGON_POSITION_BOTTOM
    jr      nc, 222$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 221$
    neg
221$:
    cp      #ENEMY_DRAGON_RANGE_X
    jr      c, 223$
    call    _SystemGetRandom
    and     #0x04
    jr      nz, 223$
222$:
    ld      a, #-ENEMY_DRAGON_SPEED_Y_FLAP
    jr      229$
223$:
    ld      a, #ENEMY_DRAGON_SPEED_Y_FLAP
;   jr      229$
229$:
    ld      ENEMY_PARAM_1(ix), a
;   jr      230$

    ; 移動
230$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    jr      90$

    ; 発射の開始
300$:
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDragonGreenFireOffset
    add     hl, de
    ld      b, #0x03
    call    _EnemyFireBallStraights
    ld      ENEMY_PARAM_3(ix), #ENEMY_DRAGON_FIRE_FRAME
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE
    jr      90$

    ; 発射
310$:
    dec     ENEMY_PARAM_3(ix)
    jr      nz, 319$
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
319$:
    jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_DRAGON_RECT_TOP << 8) | ENEMY_DRAGON_RECT_LEFT)
    ld      de, #((ENEMY_DRAGON_RECT_BOTTOM << 8) | ENEMY_DRAGON_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyDragonGreenSprite
    call    _EnemySetSpriteDirection2x2

    ; レジスタの復帰

    ; 終了
    ret

; ブルードラゴンが行動する
;
_EnemyDragonBlue::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; X 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x80
    sub     #0x40
    ld      ENEMY_POSITION_X(ix), a
    
    ; Y 位置の設定
    ld      ENEMY_POSITION_Y(ix), #0x40

    ; 向きの設定
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 速度の設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 発射の設定
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
    ld      ENEMY_PARAM_3(ix), #0x00

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
    ld      ENEMY_PARAM_2(ix), #0x01
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 移動の更新
200$:
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jr      z, 210$
    jp      p, 201$
    add     a, #ENEMY_DRAGON_SPEED_X_BRAKE
    jr      c, 202$
    jr      209$
201$:
    sub     #ENEMY_DRAGON_SPEED_X_BRAKE
    jr      c, 202$
    jr      209$
202$:
    xor     a
;   jr      209$
209$:
    ld      ENEMY_PARAM_0(ix), a
    jr      230$

    ; 向きの設定
210$:
;   call    _EnemyGetApproachDirection
;   ld      ENEMY_DIRECTION(ix), a

    ; 発射の更新
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 310$
    dec     ENEMY_PARAM_2(ix)
    jr      z, 300$

    ; 移動の開始
220$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #ENEMY_DRAGON_POSITION_LEFT
    jr      c, 223$
    cp      #ENEMY_DRAGON_POSITION_RIGHT
    jr      nc, 222$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    cp      #ENEMY_DRAGON_RANGE_X
    jr      c, 222$
    cp      #-ENEMY_DRAGON_RANGE_X
    jr      nc, 223$
    call    _SystemGetRandom
    bit     #0x04, a
    jr      nz, 221$
    bit     #0x03, a
    jr      nz, 222$
    jr      223$
221$:
    call    _EnemyGetApproachDirection
    or      a
    jr      nz, 223$
;   jr      222$
222$:
    ld      ENEMY_DIRECTION(ix), #ENEMY_DIRECTION_L
    ld      ENEMY_PARAM_0(ix), #-ENEMY_DRAGON_SPEED_X_FLAP
    jr      229$
223$:
    ld      ENEMY_DIRECTION(ix), #ENEMY_DIRECTION_R
    ld      ENEMY_PARAM_0(ix), #ENEMY_DRAGON_SPEED_X_FLAP
;   jr      229$
229$:
;   jr      230$

    ; 移動
230$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    inc     ENEMY_ANIMATION(ix)
    jr      90$

    ; 発射の開始
300$:
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a
    add     a, a
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDragonBlueFireOffset
    add     hl, de
    ld      b, #0x03
    call    _EnemyFireBallStraights
    ld      ENEMY_PARAM_3(ix), #ENEMY_DRAGON_FIRE_FRAME
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE
    jr      90$

    ; 発射
310$:
    dec     ENEMY_PARAM_3(ix)
    jr      nz, 319$
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
319$:
    jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_DRAGON_RECT_TOP << 8) | ENEMY_DRAGON_RECT_LEFT)
    ld      de, #((ENEMY_DRAGON_RECT_BOTTOM << 8) | ENEMY_DRAGON_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyDragonBlueSprite
    call    _EnemySetSpriteDirection2x2

    ; レジスタの復帰

    ; 終了
    ret

; レッドドラゴンが行動する
;
_EnemyDragonRed::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; X 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x80
    sub     #0x40
    ld      ENEMY_POSITION_X(ix), a
    
    ; Y 位置の設定
    ld      ENEMY_POSITION_Y(ix), #0x40

    ; 向きの設定
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 速度の設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 発射の設定
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
    ld      ENEMY_PARAM_3(ix), #0x00

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
    ld      ENEMY_PARAM_2(ix), #0x01
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 移動の更新
200$:
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jr      z, 202$
    ld      a, ENEMY_POSITION_X(ix)
    cp      #ENEMY_DRAGON_POSITION_LEFT
    jr      c, 201$
    jr      z, 201$
    cp      #ENEMY_DRAGON_POSITION_RIGHT
    jr      c, 202$
201$:
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    jr      209$
202$:
    ld      a, ENEMY_PARAM_1(ix)
    or      a
    jr      z, 210$
    jp      p, 203$
    add     a, #ENEMY_DRAGON_SPEED_Y_BRAKE
    jr      c, 204$
    jr      209$
203$:
    sub     #ENEMY_DRAGON_SPEED_Y_BRAKE
    jr      c, 204$
    jr      209$
204$:
    xor     a
;   jr      209$
209$:
    ld      ENEMY_PARAM_1(ix), a
    jr      230$

    ; 向きの設定
210$:
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 発射の更新
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 310$
    dec     ENEMY_PARAM_2(ix)
    jr      z, 300$

    ; 移動の開始
220$:
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ENEMY_DRAGON_POSITION_TOP
    jr      c, 223$
    cp      #ENEMY_DRAGON_POSITION_BOTTOM
    jr      nc, 221$
    call    _SystemGetRandom
    and     #0x45
    jr      z, 222$
221$:
    ld      de, #((-ENEMY_DRAGON_SPEED_Y_FLAP << 8) | 0x00)
    jr      229$
222$:
    ld      de, #((ENEMY_DRAGON_SPEED_Y_FLAP << 8) | 0x00)
    jr      229$
223$:
    ld      a, (_player + PLAYER_POSITION_X)
    bit     #0x07, a
    jr      nz, 224$
    bit     #0x07, ENEMY_POSITION_X(ix)
    jr      z, 225$
    jr      227$
224$:
    bit     #0x07, ENEMY_POSITION_X(ix)
    jr      nz, 225$
    jr      226$
225$:
    ld      de, #((ENEMY_DRAGON_SPEED_Y_DROP << 8) | 0x00)
    jr      229$
226$:
    ld      de, #((ENEMY_DRAGON_SPEED_Y_DROP << 8) | ENEMY_DRAGON_SPEED_X_DROP)
    jr      229$
227$:
    ld      de, #((ENEMY_DRAGON_SPEED_Y_DROP << 8) | (-ENEMY_DRAGON_SPEED_X_DROP & 0xff))
;   jr      229$
229$:
    ld      ENEMY_PARAM_0(ix), e
    ld      ENEMY_PARAM_1(ix), d
;   jr      230$

    ; 移動
230$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    jr      90$

    ; 発射の開始
300$:
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDragonRedFireOffset
    add     hl, de
    ld      b, #0x03
    call    _EnemyFireBallStraights
    ld      ENEMY_PARAM_3(ix), #ENEMY_DRAGON_FIRE_FRAME
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE
    jr      90$

    ; 発射
310$:
    dec     ENEMY_PARAM_3(ix)
    jr      nz, 319$
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
319$:
    jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_DRAGON_RECT_TOP << 8) | ENEMY_DRAGON_RECT_LEFT)
    ld      de, #((ENEMY_DRAGON_RECT_BOTTOM << 8) | ENEMY_DRAGON_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyDragonRedSprite
    call    _EnemySetSpriteDirection2x2

    ; レジスタの復帰

    ; 終了
    ret

; イエロードラゴンが行動する
;
_EnemyDragonYellow::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; X 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x80
    sub     #0x40
    ld      ENEMY_POSITION_X(ix), a
    
    ; Y 位置の設定
    ld      ENEMY_POSITION_Y(ix), #0x40

    ; 向きの設定
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 速度の設定
    xor     a
    ld      ENEMY_PARAM_0(ix), a
    ld      ENEMY_PARAM_1(ix), a

    ; 発射の設定
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
    ld      ENEMY_PARAM_3(ix), #0x00

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 10$
    ld      ENEMY_PARAM_2(ix), #0x01
10$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 移動の更新
200$:
    ld      a, ENEMY_PARAM_0(ix)
    or      ENEMY_PARAM_1(ix)
    jr      z, 210$
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jp      p, 201$
    add     a, #ENEMY_DRAGON_SPEED_X_BRAKE
    jr      c, 202$
    jr      203$
201$:
    sub     #ENEMY_DRAGON_SPEED_X_BRAKE
    jr      c, 202$
    jr      203$
202$:
    xor     a
;   jr      203$
203$:
    ld      ENEMY_PARAM_0(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    or      a
    jp      p, 204$
    add     a, #ENEMY_DRAGON_SPEED_Y_BRAKE
    jr      c, 205$
    jr      206$
204$:
    sub     #ENEMY_DRAGON_SPEED_Y_BRAKE
    jr      c, 205$
    jr      206$
205$:
    xor     a
;   jr      206$
206$:
    ld      ENEMY_PARAM_1(ix), a
    jr      230$

    ; 向きの設定
210$:
    call    _EnemyGetApproachDirection
    ld      ENEMY_DIRECTION(ix), a

    ; 発射の更新
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 310$
    dec     ENEMY_PARAM_2(ix)
    jr      z, 300$

    ; 移動の開始
220$:
    ld      a, ENEMY_POSITION_X(ix)
    cp      #ENEMY_DRAGON_POSITION_LEFT
    jr      c, 222$
    cp      #ENEMY_DRAGON_POSITION_RIGHT
    jr      nc, 221$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    cp      #-ENEMY_DRAGON_RANGE_X
    jr      nc, 222$
    cp      #ENEMY_DRAGON_RANGE_X
    jr      c, 221$
    ld      a, ENEMY_DIRECTION(ix)
    or      a
    jr      nz, 222$
221$:
    ld      a, #-ENEMY_DRAGON_SPEED_X_FLAP
    jr      223$
222$:
    ld      a, #ENEMY_DRAGON_SPEED_X_FLAP
;   jr      223$
223$:
    ld      ENEMY_PARAM_0(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ENEMY_DRAGON_POSITION_TOP
    jr      c, 225$
    cp      #ENEMY_DRAGON_POSITION_BOTTOM
    jr      c, 225$
224$:
    ld      a, #-ENEMY_DRAGON_SPEED_Y_FLAP
    jr      226$
225$:
    ld      a, #ENEMY_DRAGON_SPEED_Y_FLAP
;   jr      226$
226$:
    ld      ENEMY_PARAM_1(ix), a
;   jr      230$

    ; 移動
230$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
    
    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    jr      90$

    ; 発射の開始
300$:
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDragonYellowFireOffset
    add     hl, de
    ld      b, #0x03
    call    _EnemyFireBallStraights
    ld      ENEMY_PARAM_3(ix), #ENEMY_DRAGON_FIRE_FRAME
    ld      ENEMY_ANIMATION(ix), #ENEMY_DRAGON_ANIMATION_FIRE
    jr      90$

    ; 発射
310$:
    dec     ENEMY_PARAM_3(ix)
    jr      nz, 319$
    call    _SystemGetRandom
    and     #0x03
    inc     a
    ld      ENEMY_PARAM_2(ix), a
319$:
    jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_DRAGON_RECT_TOP << 8) | ENEMY_DRAGON_RECT_LEFT)
    ld      de, #((ENEMY_DRAGON_RECT_BOTTOM << 8) | ENEMY_DRAGON_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyDragonYellowSprite
    call    _EnemySetSpriteDirection2x2

    ; レジスタの復帰

    ; 終了
    ret

; ボックスが行動する
;
_EnemyBox::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #ENEMY_BOX_POSITION_X
    ld      ENEMY_POSITION_Y(ix), #ENEMY_BOX_POSITION_Y

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_BOX_ANIMATION_CLOSE

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージ判定
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 19$
    ld      a, #ITEM_TYPE_KEY
    call    _PlayerIsItem
    jr      c, 10$
    xor     a
    ld      ENEMY_DAMAGE_POINT(ix), a
    ld      ENEMY_DAMAGE_FRAME(ix), a
    jr      19$
10$:
    ld      a, #ITEM_TYPE_KEY
    call    _PlayerUseItem
    ld      ENEMY_ANIMATION(ix), #ENEMY_BOX_ANIMATION_OPEN
;   jr      19$
19$:
    call    _EnemyDamage

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_BOX_RECT_TOP << 8) | ENEMY_BOX_RECT_LEFT)
    ld      de, #((ENEMY_BOX_RECT_BOTTOM << 8) | ENEMY_BOX_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyBoxSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; クリスタルが行動する
;
_EnemyCrystal::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #ENEMY_CRYSTAL_POSITION_X
    ld      ENEMY_POSITION_Y(ix), #ENEMY_CRYSTAL_POSITION_Y

    ; 上下移動の設定
    ld      ENEMY_PARAM_0(ix), #0x00
    ld      ENEMY_PARAM_1(ix), #ENEMY_CRYSTAL_SPEED_Y_CURVE_MAXIMUM

    ; 発射の設定
    ld      ENEMY_PARAM_2(ix), #0x00
    ld      ENEMY_PARAM_3(ix), #0x01

    ; スプライトの設定
    ld      hl, #enemyCrystalSprite
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; アイテムの監視
    call    _PlayerIsItemRequire
    jp      nc, 20$

    ; ダメージの処理
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 100$
    ld      a, ENEMY_PARAM_2(ix)
    cp      #0x04
    jr      c, 100$
    ld      ENEMY_PARAM_2(ix), #0x04
100$:
    call    _EnemyDamage
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 90$

    ; 上下移動
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 130$
    inc     ENEMY_PARAM_0(ix)
    ld      a, ENEMY_PARAM_0(ix)
    and     #0x01
    jr      nz, 119$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ENEMY_CRYSTAL_POSITION_TOP
    jr      nc, 110$
    ld      ENEMY_PARAM_1(ix), #ENEMY_CRYSTAL_SPEED_Y_CURVE_MAXIMUM
    jr      111$
110$:
    cp      #ENEMY_CRYSTAL_POSITION_BOTTOM
    jr      c, 111$
    ld      ENEMY_PARAM_1(ix), #-ENEMY_CRYSTAL_SPEED_Y_CURVE_MAXIMUM
;   jr      111$
111$:
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
    call    _EnemyMove
;   jr      119$
119$:

    ; 発射の待機
    dec     ENEMY_PARAM_2(ix)
    jr      nz, 139$
    call    _SystemGetRandom
    and     #0x03
    jr      nz, 120$
    ld      a, #0x02
120$:
    add     a, #0x02
    add     a, a
    add     a, a
    add     a, a
    ld      ENEMY_PARAM_3(ix), a
;   jr      120$

    ; 発射
130$:
    ld      a, ENEMY_PARAM_3(ix)
    and     #0x07
    jr      nz, 138$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    ld      l, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    neg
    ld      h, a
    call    _MathGetAtan2
    add     a, #0x03
    and     #0xf8
    rrca
    ld      e, a
    call    _SystemGetRandom
    and     #0x0c
    jr      z, 131$
    sub     #0x08
    add     a, e
    and     #0x7c
    ld      e, a
131$:
    ld      d, #0x00
    ld      hl, #enemyCrystalFireOffset
    add     hl, de
    ld      b, #0x01
    call    _EnemyFireBallStraights
;   jr      138$
138$:
    dec     ENEMY_PARAM_3(ix)
    jr      nz, 139$
    call    _SystemGetRandom
    rrca
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_2(ix), a
;   jr      139$
139$:
    jr      90$

    ; 何もしない
20$:

    ; ダメージの無効化
    xor     a
    ld      ENEMY_DAMAGE_POINT(ix), a
    ld      ENEMY_DAMAGE_FRAME(ix), a
;   jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_CRYSTAL_RECT_TOP << 8) | ENEMY_CRYSTAL_RECT_LEFT)
    ld      de, #((ENEMY_CRYSTAL_RECT_BOTTOM << 8) | ENEMY_CRYSTAL_RECT_RIGHT)
    call    _EnemySetRect

    ; アイドルの監視
    ld      a, #ENEMY_TYPE_IDOL
    call    _EnemyFind
    ld      a, h
    or      l
    jr      z, 91$
    push    hl
    pop     iy
    ld      a, ENEMY_POSITION_X(ix)
    ld      ENEMY_POSITION_X(iy), a
    ld      a, ENEMY_POSITION_Y(ix)
    ld      ENEMY_POSITION_Y(iy), a
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_PARAM_0(iy), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_PARAM_1(iy), a
91$:

    ; レジスタの復帰

    ; 終了
    ret

; アイドルが行動する
;
_EnemyIdol::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #ENEMY_IDOL_POSITION_X
    ld      ENEMY_POSITION_Y(ix), #ENEMY_IDOL_POSITION_Y

    ; 上下移動の設定
    ld      ENEMY_PARAM_0(ix), #0x00
    ld      ENEMY_PARAM_1(ix), #ENEMY_IDOL_SPEED_Y_CURVE_MAXIMUM

    ; 待機の設定
    ld      ENEMY_PARAM_2(ix), #0x10

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #ENEMY_IDOL_ANIMATION_STAY

    ; 降下フラグの設定
    ld      ENEMY_PARAM_7(ix), #0x00

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの処理
    xor     a
    ld      ENEMY_DAMAGE_POINT(ix), a

    ; クリスタルの監視
    ld      a, #ENEMY_TYPE_CRYSTAL
    call    _EnemyFind
    ld      a, h
    or      l
    jr      nz, 90$

    ; 降下の開始
    ld      a, ENEMY_PARAM_7(ix)
    or      a
    jr      nz, 10$
    inc     ENEMY_PARAM_7(ix)
    ld      a, #SOUND_BGM_IDOL
    call    _SoundPlayBgm

    ; 降下
10$:
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ENEMY_IDOL_POSITION_BOTTOM
    jr      nc, 20$
    inc     ENEMY_PARAM_0(ix)
    ld      a, ENEMY_PARAM_0(ix)
    and     #0x01
    jr      nz, 11$
    ld      ENEMY_SPEED_Y(ix), #ENEMY_IDOL_SPEED_Y_CURVE_MAXIMUM
    call    _EnemyMove
11$:
    ld      a, ENEMY_PARAM_0(ix)
    rrca
    ld      ENEMY_DAMAGE_FRAME(ix), a
    jr      90$

    ; 待機
20$:
    ld      a, ENEMY_PARAM_2(ix)
    or      a
    jr      z, 21$
    dec     ENEMY_PARAM_2(ix)
    jr      nz, 21$
    ld      ENEMY_ANIMATION(ix), #ENEMY_IDOL_ANIMATION_OPEN
    ld      a, #ENEMY_TYPE_GATE
    call    _EnemyEntryOne
21$:
    ld      ENEMY_DAMAGE_FRAME(ix), #0x00
;   jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_IDOL_RECT_TOP << 8) | ENEMY_IDOL_RECT_LEFT)
    ld      de, #((ENEMY_IDOL_RECT_BOTTOM << 8) | ENEMY_IDOL_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      hl, #enemyIdolSprite
    call    _EnemySetSpriteSimple

    ; レジスタの復帰

    ; 終了
    ret

; ゲートが行動する
;
_EnemyGate::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #ENEMY_GATE_POSITION_X
    ld      ENEMY_POSITION_Y(ix), #ENEMY_GATE_POSITION_Y

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージの処理
    xor     a
    ld      ENEMY_DAMAGE_POINT(ix), a

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_GATE_RECT_TOP << 8) | ENEMY_GATE_RECT_LEFT)
    ld      de, #((ENEMY_GATE_RECT_BOTTOM << 8) | ENEMY_GATE_RECT_RIGHT)
    call    _EnemySetRect

    ; パターンネームの設定
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x1c
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyGatePatternName
    add     hl, de
    ld      de, #(_patternName + (ENEMY_GATE_POSITION_Y / 0x08 - 0x02) * 0x0020 + (ENEMY_GATE_POSITION_X / 0x08 - 0x02))
    ex      de, hl
    ld      b, #0x04
91$:
    push    bc
    ld      b, #0x04
92$:
    ld      a, (de)
    ld      (hl), a
    inc     hl
    inc     de
    djnz    92$
    ld      bc, #(0x0020 - 0x0004)
    add     hl, bc
    pop     bc
    djnz    91$

    ; レジスタの復帰

    ; 終了
    ret

; ボールが行動する
;
_EnemyBall::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 待機の設定
    ld      ENEMY_PARAM_7(ix), #ENEMY_BALL_STAY_FRAME

    ; 種類別の設定
    ld      a, ENEMY_TYPE(ix)

    ; 直線ボールの設定
    cp      #ENEMY_TYPE_BALL_STRAIGHT
    jr      nz, 01$
    xor     a
    ld      ENEMY_PARAM_1(ix), a
    ld      ENEMY_PARAM_2(ix), a
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBallDirectionSpeed
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_PARAM_3(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_PARAM_4(ix), a
;   inc     hl
    ld      de, #0x0000
    ld      b, ENEMY_PARAM_0(ix)
00$:
    ld      a, e
    add     a, ENEMY_PARAM_3(ix)
    ld      e, a
    ld      a, d
    add     a, ENEMY_PARAM_4(ix)
    ld      d, a
    djnz    00$
    ld      ENEMY_PARAM_3(ix), e
    ld      ENEMY_PARAM_4(ix), d
    jr      08$

    ; 放物線ボールの設定
01$:
    cp      #ENEMY_TYPE_BALL_PARABOLA
    jr      nz, 02$
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
    jr      08$

    ; バウンドボールの設定  
02$:
    ld      a, ENEMY_PARAM_0(ix)
    ld      ENEMY_SPEED_X(ix), a
    ld      a, ENEMY_PARAM_1(ix)
    ld      ENEMY_SPEED_Y(ix), a
;   jr      08$

    ; 初期化の完了
08$:
    inc     ENEMY_STATE(ix)
09$:

    ; ダメージ判定
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jp      nz, 80$

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)

    ; 待機
    ld      a, ENEMY_PARAM_7(ix)
    or      a
    jr      z, 19$
    dec     ENEMY_PARAM_7(ix)
    jp      90$
19$:

    ; 種類別の処理
    ld      a, ENEMY_TYPE(ix)

    ; 直線ボールの更新
200$:
    cp      #ENEMY_TYPE_BALL_STRAIGHT
    jr      nz, 210$
    ld      a, ENEMY_FLAG(ix)
    and     #(ENEMY_FLAG_COLLISION_X | ENEMY_FLAG_COLLISION_Y)
    jr      nz, 80$
    ld      a, ENEMY_PARAM_1(ix)
    add     a, ENEMY_PARAM_3(ix)
    ld      c, a
    and     #0xf0
    ld      b, a
    ld      a, ENEMY_DIRECTION(ix)
    cp      #0x10
    jr      c, 201$
    ld      a, b
    neg
    ld      b, a
201$:
    ld      ENEMY_SPEED_X(ix), b
    ld      a, c
    and     #0x0f
    ld      ENEMY_PARAM_1(ix), a
    ld      a, ENEMY_PARAM_2(ix)
    add     a, ENEMY_PARAM_4(ix)
    ld      c, a
    and     #0xf0
    ld      b, a
    ld      a, ENEMY_DIRECTION(ix)
    cp      #0x08
    jr      c, 202$
    cp      #0x18
    jr      c, 203$
202$:
    ld      a, b
    neg
    ld      b, a
203$:
    ld      ENEMY_SPEED_Y(ix), b
    ld      a, c
    and     #0x0f
    ld      ENEMY_PARAM_2(ix), a
    jr      290$

    ; 放物線ボールの更新
210$:
    cp      #ENEMY_TYPE_BALL_PARABOLA
    jr      nz, 220$
    ld      a, ENEMY_FLAG(ix)
    and     #(ENEMY_FLAG_COLLISION_X | ENEMY_FLAG_COLLISION_Y)
    jr      nz, 80$
    ld      e, ENEMY_PARAM_2(ix)
    ld      d, ENEMY_PARAM_3(ix)
    call    _EnemyAccelY
    jr      290$

    ; バウンドボールの更新
220$:
    bit     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      nz, 80$
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 221$
    ld      a, ENEMY_SPEED_Y(ix)
    neg
    ld      ENEMY_SPEED_Y(ix), a
221$:
    ld      e, ENEMY_PARAM_2(ix)
    ld      d, ENEMY_PARAM_3(ix)
    call    _EnemyAccelY
;   jr      290$    

    ; 移動
290$:
    call    _EnemyMove
    jr      90$

    ; ボールの削除
80$:
    xor     a
    ld      ENEMY_TYPE(ix), a
;   jr      90$

    ; 行動の完了
90$:

    ; 矩形の設定
    ld      hl, #((ENEMY_BALL_RECT_TOP << 8) | ENEMY_BALL_RECT_LEFT)
    ld      de, #((ENEMY_BALL_RECT_BOTTOM << 8) | ENEMY_BALL_RECT_RIGHT)
    call    _EnemySetRect

    ; スプライトの設定
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x07
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBallSprite
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; なし
_enemyNullDefault:

    .db     ENEMY_TYPE_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_LIFE_NULL
    .db     ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

_enemyNullSprite:

    .db     0xcc, 0xcc, 0x00, 0x00

; リーパー
_enemyReaperDefault::

    .db     ENEMY_TYPE_REAPER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x03 ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyReaperSprite:

    .db     -0x1f - 0x01, -0x11, 0x80, VDP_COLOR_LIGHT_YELLOW 
    .db     -0x1f - 0x01, -0x11, 0x84, VDP_COLOR_LIGHT_YELLOW 

; グレムリン
_enemyGremlinDefault::

    .db     ENEMY_TYPE_GREMLIN
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x02 ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyGremlinSprite:

    .db     -0x1f - 0x01, -0x10, 0x88, VDP_COLOR_LIGHT_GREEN
    .db     -0x1f - 0x01, -0x10, 0x8c, VDP_COLOR_LIGHT_GREEN

; ゲイザー
_enemyGazerDefault::

    .db     ENEMY_TYPE_GAZER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_FLYER | ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x02 ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyGazerSprite:

    .db     -0x10 - 0x01, -0x10, 0x90, VDP_COLOR_MAGENTA
    .db     -0x10 - 0x01, -0x10, 0x94, VDP_COLOR_MAGENTA

; バット
_enemyBatDefault::

    .db     ENEMY_TYPE_BAT
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_FLYER | ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x02 ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyBatSprite:

    .db     -0x10 - 0x01, -0x10, 0x98, VDP_COLOR_LIGHT_BLUE
    .db     -0x10 - 0x01, -0x10, 0x9c, VDP_COLOR_LIGHT_BLUE

; メイジ
_enemyMageDefault::

    .db     ENEMY_TYPE_MAGE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS | ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x05 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyMageSprite:

    .db     -0x1f - 0x01, -0x11, 0xa0, VDP_COLOR_MAGENTA
    .db     -0x1f - 0x01, -0x11, 0xa4, VDP_COLOR_MAGENTA

enemyMageFireOffset:

    .db     -(-0x0c), -(-0x1c)

; サイクロプス
_enemyCyclopsDefault::

    .db     ENEMY_TYPE_CYCLOPS
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS | ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x05 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyCyclopsSprite:

    .db     -0x1f - 0x01, -0x11, 0xa8, VDP_COLOR_DARK_YELLOW
    .db     -0x1f - 0x01, -0x11, 0xac, VDP_COLOR_DARK_YELLOW

enemyCyclopsFireOffset:

    .db     -(-0x0c), -(-0x18)
    .db     0x0b,     -(-0x18)

; ヒドラ
_enemyHydraDefault::

    .db     ENEMY_TYPE_HYDRA
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS | ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x05 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyHydraSprite:

    .db     -0x1f - 0x01, -0x10, 0xb0, VDP_COLOR_MEDIUM_GREEN
    .db     -0x1f - 0x01, -0x10, 0xb4, VDP_COLOR_MEDIUM_GREEN

enemyHydraFireOffset:

    .db     -(-0x0a), -(-0x1a)
    .db     0x09,     -(-0x1a)

; デーモン
_enemyDaemonDefault::

    .db     ENEMY_TYPE_DAEMON
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS | ENEMY_FLAG_FLYER | ENEMY_FLAG_DAMAGE_BACK
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x05 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyDaemonSprite:

    .db     -0x10 - 0x01, -0x10, 0xb8, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01, -0x10, 0xbc, VDP_COLOR_LIGHT_RED

enemyDaemonFireOffset:

    .db     -0x03, 0x0f, 0x11, ENEMY_DAEMON_FIRE_SPEED
    .db      0x03, 0x0f, 0x0f, ENEMY_DAEMON_FIRE_SPEED
    .db     -0x09, 0x0d, 0x13, ENEMY_DAEMON_FIRE_SPEED
    .db      0x09, 0x0d, 0x0d, ENEMY_DAEMON_FIRE_SPEED

; グリーンドラゴン
_enemyDragonGreenDefault::

    .db     ENEMY_TYPE_DRAGON_GREEN
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x08 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyDragonGreenSprite:

    .db     -0x20 - 0x01, -0x20, 0xc0, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01,  0x00, 0xc4, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01, -0x20, 0xe0, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01,  0x00, 0xe4, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01, -0x20, 0xc8, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01,  0x00, 0xcc, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01, -0x20, 0xe8, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01,  0x00, 0xec, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01, -0x20, 0xd0, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01,  0x00, 0xd4, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01, -0x20, 0xf0, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01,  0x00, 0xf4, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01, -0x20, 0xd8, VDP_COLOR_DARK_GREEN
    .db     -0x20 - 0x01,  0x00, 0xdc, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01, -0x20, 0xf8, VDP_COLOR_DARK_GREEN
    .db      0x00 - 0x01,  0x00, 0xfc, VDP_COLOR_DARK_GREEN

enemyDragonGreenFireOffset:

    .db     -0x10 - 0x0f, -0x08 - 0x03, 0x19, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x0e, -0x08 + 0x06, 0x16, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x09, -0x08 + 0x0d, 0x13, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0f, -0x08 - 0x03, 0x07, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0e, -0x08 + 0x06, 0x0a, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x09, -0x08 + 0x0d, 0x0d, ENEMY_DRAGON_FIRE_SPEED

; ブルードラゴン
_enemyDragonBlueDefault::

    .db     ENEMY_TYPE_DRAGON_BLUE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x08 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyDragonBlueSprite:

    .db     -0x20 - 0x01, -0x20, 0xc0, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01,  0x00, 0xc4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x20, 0xe0, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xe4, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01, -0x20, 0xc8, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01,  0x00, 0xcc, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x20, 0xe8, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xec, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01, -0x20, 0xd0, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01,  0x00, 0xd4, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x20, 0xf0, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xf4, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01, -0x20, 0xd8, VDP_COLOR_DARK_BLUE
    .db     -0x20 - 0x01,  0x00, 0xdc, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x20, 0xf8, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0xfc, VDP_COLOR_DARK_BLUE

enemyDragonBlueFireOffset:

    .db     -0x10 - 0x0f, -0x08 + 0x03, 0x17, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x0b, -0x08 + 0x0b, 0x14, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x03, -0x08 + 0x0f, 0x11, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0f, -0x08 + 0x03, 0x09, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0b, -0x08 + 0x0b, 0x0c, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x03, -0x08 + 0x0f, 0x0e, ENEMY_DRAGON_FIRE_SPEED


; レッドドラゴン
_enemyDragonRedDefault::

    .db     ENEMY_TYPE_DRAGON_RED
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x08 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyDragonRedSprite:

    .db     -0x20 - 0x01, -0x20, 0xc0, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01,  0x00, 0xc4, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x20, 0xe0, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0xe4, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01, -0x20, 0xc8, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01,  0x00, 0xcc, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x20, 0xe8, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0xec, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01, -0x20, 0xd0, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01,  0x00, 0xd4, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x20, 0xf0, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0xf4, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01, -0x20, 0xd8, VDP_COLOR_DARK_RED
    .db     -0x20 - 0x01,  0x00, 0xdc, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x20, 0xf8, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0xfc, VDP_COLOR_DARK_RED

enemyDragonRedFireOffset:

    .db     -0x10 - 0x0f, -0x08 - 0x03, 0x19, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x0e, -0x08 + 0x06, 0x16, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x09, -0x08 + 0x0d, 0x13, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0f, -0x08 - 0x03, 0x07, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0e, -0x08 + 0x06, 0x0a, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x09, -0x08 + 0x0d, 0x0d, ENEMY_DRAGON_FIRE_SPEED

; イエロードラゴン
_enemyDragonYellowDefault::

    .db     ENEMY_TYPE_DRAGON_YELLOW
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x08 ; ENEMY_LIFE_NULL
    .db     0x02 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyDragonYellowSprite:

    .db     -0x20 - 0x01, -0x20, 0xc0, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01,  0x00, 0xc4, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01, -0x20, 0xe0, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01,  0x00, 0xe4, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01, -0x20, 0xc8, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01,  0x00, 0xcc, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01, -0x20, 0xe8, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01,  0x00, 0xec, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01, -0x20, 0xd0, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01,  0x00, 0xd4, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01, -0x20, 0xf0, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01,  0x00, 0xf4, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01, -0x20, 0xd8, VDP_COLOR_DARK_YELLOW
    .db     -0x20 - 0x01,  0x00, 0xdc, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01, -0x20, 0xf8, VDP_COLOR_DARK_YELLOW
    .db      0x00 - 0x01,  0x00, 0xfc, VDP_COLOR_DARK_YELLOW

enemyDragonYellowFireOffset:

    .db     -0x10 - 0x0f, -0x08 - 0x03, 0x19, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x0e, -0x08 + 0x06, 0x16, ENEMY_DRAGON_FIRE_SPEED
    .db     -0x10 - 0x09, -0x08 + 0x0d, 0x13, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0f, -0x08 - 0x03, 0x07, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x0e, -0x08 + 0x06, 0x0a, ENEMY_DRAGON_FIRE_SPEED
    .db      0x10 + 0x09, -0x08 + 0x0d, 0x0d, ENEMY_DRAGON_FIRE_SPEED

; ボックス
_enemyBoxDefault::

    .db     ENEMY_TYPE_BOX
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x01 ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyBoxSprite:

    .db     -0x1f - 0x01, -0x10, 0x6c, VDP_COLOR_DARK_RED
    .db     -0x1f - 0x01, -0x10, 0x70, VDP_COLOR_DARK_RED

; クリスタル
_enemyCrystalDefault::

    .db     ENEMY_TYPE_CRYSTAL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_BOSS | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0x10 ; ENEMY_LIFE_NULL
    .db     0x03 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyCrystalSprite:

    .db     -0x10 - 0x01, -0x11, 0x74, VDP_COLOR_DARK_YELLOW

enemyCrystalFireOffset:

    .db      0x00, -0x16, 0x00, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x04, -0x15, 0x01, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x08, -0x14, 0x02, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x0c, -0x12, 0x03, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x0f, -0x0f, 0x04, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x12, -0x0c, 0x05, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x14, -0x08, 0x06, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x15, -0x04, 0x07, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x16,  0x00, 0x08, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x15,  0x04, 0x09, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x14,  0x08, 0x0a, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x12,  0x0c, 0x0b, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x0f,  0x0f, 0x0c, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x0c,  0x12, 0x0d, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x08,  0x14, 0x0e, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x04,  0x15, 0x0f, ENEMY_CRYSTAL_FIRE_SPEED
    .db      0x00,  0x16, 0x10, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x04,  0x15, 0x11, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x08,  0x14, 0x12, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x0c,  0x12, 0x13, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x0f,  0x0f, 0x14, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x12,  0x0c, 0x15, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x14,  0x08, 0x16, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x15,  0x04, 0x17, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x16,  0x00, 0x18, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x15, -0x04, 0x19, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x14, -0x08, 0x1a, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x12, -0x0c, 0x1b, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x0f, -0x0f, 0x1c, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x0c, -0x12, 0x1d, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x08, -0x14, 0x1e, ENEMY_CRYSTAL_FIRE_SPEED
    .db     -0x04, -0x15, 0x1f, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x00, -0x10, 0x00, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x03, -0x0f, 0x01, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x06, -0x0e, 0x02, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x09, -0x0d, 0x03, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0b, -0x0b, 0x04, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0d, -0x09, 0x05, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0e, -0x06, 0x06, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0f, -0x03, 0x07, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x10,  0x00, 0x08, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0f,  0x03, 0x09, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0e,  0x06, 0x0a, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0d,  0x09, 0x0b, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x0b,  0x0b, 0x0c, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x09,  0x0d, 0x0d, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x06,  0x0e, 0x0e, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x03,  0x0f, 0x0f, ENEMY_CRYSTAL_FIRE_SPEED
;   .db      0x00,  0x10, 0x10, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x03,  0x0f, 0x11, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x06,  0x0e, 0x12, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x09,  0x0d, 0x13, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0b,  0x0b, 0x14, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0d,  0x09, 0x15, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0e,  0x06, 0x16, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0f,  0x03, 0x17, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x10,  0x00, 0x18, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0f, -0x03, 0x19, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0e, -0x06, 0x1a, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0d, -0x09, 0x1b, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x0b, -0x0b, 0x1c, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x09, -0x0d, 0x1d, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x06, -0x0e, 0x1e, ENEMY_CRYSTAL_FIRE_SPEED
;   .db     -0x03, -0x0f, 0x1f, ENEMY_CRYSTAL_FIRE_SPEED

; アイドル
_enemyIdolDefault::

    .db     ENEMY_TYPE_IDOL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0xff ; ENEMY_LIFE_NULL
    .db     0x04 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyIdolSprite:

    .db     -0x10 - 0x01, -0x11, 0x78, VDP_COLOR_CYAN
    .db     -0x10 - 0x01, -0x11, 0x7c, VDP_COLOR_CYAN

; ゲート
_enemyGateDefault::

    .db     ENEMY_TYPE_GATE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0xff ; ENEMY_LIFE_NULL
    .db     0x00 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyGatePatternName:

    .db     0x60, 0x61, 0x61, 0x62, 0x63, 0x00, 0x00, 0x64, 0x63, 0x00, 0x00, 0x64, 0x65, 0x66, 0x66, 0x67
    .db     0x68, 0x69, 0x69, 0x6a, 0x6b, 0x00, 0x00, 0x6c, 0x6b, 0x00, 0x00, 0x6c, 0x6d, 0x6e, 0x6e, 0x6f
    .db     0x70, 0x71, 0x71, 0x72, 0x73, 0x00, 0x00, 0x74, 0x73, 0x00, 0x00, 0x74, 0x75, 0x76, 0x76, 0x77
    .db     0x78, 0x79, 0x79, 0x7a, 0x7b, 0x00, 0x00, 0x7c, 0x7b, 0x00, 0x00, 0x7c, 0x7d, 0x7e, 0x7e, 0x7f
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x62, 0x00, 0x00, 0x65, 0x67, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x68, 0x6a, 0x00, 0x00, 0x6d, 0x6f, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x72, 0x00, 0x00, 0x75, 0x77, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; ボール
_enemyBallStraightDefault::

    .db     ENEMY_TYPE_BALL_STRAIGHT
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_ARM | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0xff ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

_enemyBallParabolaDefault::

    .db     ENEMY_TYPE_BALL_PARABOLA
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_ARM | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0xff ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

_enemyBallBoundDefault::

    .db     ENEMY_TYPE_BALL_BOUND
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_ARM | ENEMY_FLAG_FLYER
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_L
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_SPEED_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     0xff ; ENEMY_LIFE_NULL
    .db     0x01 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_FRAME_NULL
    .db     ENEMY_DAMAGE_POINT_NULL
    .db     ENEMY_DAMAGE_FRAME_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_RECT_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_SPRITE_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

enemyBallSprite:

    .db     -0x11 - 0x01, -0x11, 0x48, VDP_COLOR_LIGHT_RED
    .db     -0x11 - 0x01, -0x11, 0x48, VDP_COLOR_DARK_GREEN
    .db     -0x11 - 0x01, -0x11, 0x4c, VDP_COLOR_LIGHT_BLUE
    .db     -0x11 - 0x01, -0x11, 0x4c, VDP_COLOR_DARK_YELLOW
    .db     -0x11 - 0x01, -0x11, 0x48, VDP_COLOR_DARK_RED
    .db     -0x11 - 0x01, -0x11, 0x48, VDP_COLOR_LIGHT_GREEN
    .db     -0x11 - 0x01, -0x11, 0x4c, VDP_COLOR_DARK_BLUE
    .db     -0x11 - 0x01, -0x11, 0x4c, VDP_COLOR_LIGHT_YELLOW

enemyBallDirectionSpeed:

    .db     0x00, 0x10
    .db     0x03, 0x0f
    .db     0x06, 0x0e
    .db     0x09, 0x0d
    .db     0x0b, 0x0b
    .db     0x0d, 0x09
    .db     0x0e, 0x06
    .db     0x0f, 0x03
    .db     0x10, 0x00
    .db     0x0f, 0x03
    .db     0x0e, 0x06
    .db     0x0d, 0x09
    .db     0x0b, 0x0b
    .db     0x09, 0x0d
    .db     0x06, 0x0e
    .db     0x03, 0x0f
    .db     0x00, 0x10
    .db     0x03, 0x0f
    .db     0x06, 0x0e
    .db     0x09, 0x0d
    .db     0x0b, 0x0b
    .db     0x0d, 0x09
    .db     0x0e, 0x06
    .db     0x0f, 0x03
    .db     0x10, 0x00
    .db     0x0f, 0x03
    .db     0x0e, 0x06
    .db     0x0d, 0x09
    .db     0x0b, 0x0b
    .db     0x09, 0x0d
    .db     0x06, 0x0e
    .db     0x03, 0x0f


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

