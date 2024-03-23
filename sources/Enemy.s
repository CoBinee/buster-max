; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include	"Maze.inc"
    .include    "Room.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "EnemyOne.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; エネミーのクリア
    call    EnemyClear

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$

    ; エネミー別の処理
    ld      hl, #19$
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (enemySprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 12$
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    and     #0x01
    jr      nz, 12$
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    ld      a, h
    or      l
    jr      z, 12$
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 11$
    call    20$
    jr      12$
11$:
    call    20$
    call    20$
    call    20$
    call    20$
;   jr      12$
12$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      90$

    ; ひとつのスプライトの描画
20$:
    push    de
    push    hl
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    pop     de
    ex      de, hl
    ld      a, ENEMY_POSITION_X(ix)
    ld      bc, #0x0000
    cp      #0x80
    jr      nc, 21$
    ld      bc, #0x2080
21$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X(ix)
    add     a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      c
    ld      (de), a
    inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    ld      e, a
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 29$
    ld      e, #0x00
29$:
    ret

    ; スプライトの更新
90$:
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーをクリアする
;
EnemyClear:

    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを配置する
;
_EnemyEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy

    ; エネミーのクリア
    call    EnemyClear
    ld      ix, #(_enemy + (ENEMY_ENTRY - 0x01) * ENEMY_LENGTH)

    ; エリアフラグの取得
    ld      a, (_game + GAME_AREA)
    call    _MazeGetAreaFlag

    ; 通路の配置
100$:
    bit     #MAZE_FLAG_ROOM_BIT, a
    jr      nz, 110$
    ld      hl, #enemyEntryPathLeft
    bit     #MAZE_FLAG_WALL_LEFT_BIT, a
    call    z, 180$
    ld      hl, #enemyEntryPathRight
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, a
    call    z, 180$
    bit     #MAZE_FLAG_WALL_DOWN_BIT, a
    jr      nz, 101$
    ld      hl, #enemyEntryPathUp
    bit     #MAZE_FLAG_WALL_UP_BIT, a
    call    z, 180$
    jr      102$
101$:
    ld      hl, #enemyEntryPathDown
    call    180$
;   jr      102$
102$:
    jp      190$

    ; 部屋の配置
110$:
;   ld      a, #ENEMY_TYPE_DAEMON
;   call    170$
    ld      hl, (_game + GAME_ROOM_L)
    ld      a, h
    or      l
    jr      z, 112$
    ld      a, (_game + GAME_AREA)
    call    _MazeGetAreaFlag
    ld      c, a
    ld      b, #ROOM_ENEMY_ENTRY
111$:
    ld      a, (hl)
    or      a
    call    nz, 170$
    inc     hl
    djnz    111$
112$:
    jp      190$

    ; 指定されたエネミーを配置
170$:
    push    af
    push    hl
    push    de
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    push    ix
    pop     hl
    ex      de, hl
    push    bc
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     bc
    bit     #ENEMY_FLAG_BOSS_BIT, ENEMY_FLAG(ix)
    jr      z, 171$
    bit     #MAZE_FLAG_BOSS_BIT, c
    jr      z, 173$
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL
    jr      174$
171$:
    call    _SystemGetRandom
    rrca
    and     #0x7f
    add     a, #0x40
    ld      ENEMY_POSITION_X(ix), a
    ld      a, #((MAZE_CELL_Y - 0x01) * MAZE_CELL_PIXEL - 0x01)
    bit     #ENEMY_FLAG_FLYER_BIT, ENEMY_FLAG(ix)
    jr      z, 172$
    call    _SystemGetRandom
    rlca
    and     #0x1f
    add     a, #0x40
172$:
    ld      ENEMY_POSITION_Y(ix), a
173$:
    ld      de, #-ENEMY_LENGTH
    add     ix, de
174$:
    pop     de
    pop     hl
    pop     af
    ret

    ; ランダムにエネミーを配置
180$:
    push    af
    push    hl
    push    bc
    push    de
    call    _SystemGetRandom
    and     #0x48
    jr      z, 189$
    call    _SystemGetRandom
    rrca
    rrca
    and     #0x03
    ld      e, a
    ld      d, #0x00
    push    hl
    add     hl, de
    ld      a, (hl)
    pop     hl
    ld      e, #0x04
;   ld      d, #0x00
    add     hl, de
    or      a
    jr      z, 189$
    push    hl
    add     a, a
    ld      e, a
;   ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    push    ix
    pop     hl
    ex      de, hl
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     hl
    call    _SystemGetRandom
    rrca
    and     (hl)
    inc     hl
    add     a, (hl)
    inc     hl
    ld      ENEMY_POSITION_X(ix), a
    ld      a, #((MAZE_CELL_Y - 0x01) * MAZE_CELL_PIXEL - 0x01)
    bit     #ENEMY_FLAG_FLYER_BIT, ENEMY_FLAG(ix)
    jr      z, 181$
    call    _SystemGetRandom
    rlca
    and     (hl)
    inc     hl
    add     a, (hl)
    inc     hl
181$:
    ld      ENEMY_POSITION_Y(ix), a
    call    _SystemGetRandom
    ld      ENEMY_ANIMATION(ix), a
    ld      de, #-ENEMY_LENGTH
    add     ix, de
189$:
    pop     de
    pop     bc
    pop     hl
    pop     af
    ret

    ; 配置の完了
190$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーを一体配置する
;
_EnemyEntryOne::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    iy

    ; a < エネミー

    ; エネミーの配置
    ld      iy, #(_enemy + (ENEMY_ENTRY - 0x01) * ENEMY_LENGTH)
    ld      de, #-ENEMY_LENGTH
    ld      c, a
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(iy)
    or      a
    jr      z, 11$
    add     iy, de
    djnz    10$
    jr      19$
11$:
    ld      a, c
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    push    iy
    pop     hl
    ex      de, hl
    ld      bc, #ENEMY_LENGTH
    ldir
;   jr      19$
19$:

    ; レジスタの復帰
    pop     iy
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーを検索する
;
_EnemyFind::

    ; レジスタの保存
    push    bc
    push    de
    push    iy

    ; a  < エネミーの種類
    ; hl > エネミーのエントリ

    ; 検索
    ld      iy, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    cp      ENEMY_TYPE(iy)
    jr      z, 11$
    add     iy, de
    djnz    10$
    ld      hl, #0x0000
    jr      19$
11$:
    push    iy
    pop     hl
;   jr      19$
19$:

    ; レジスタの復帰
    pop     iy
    pop     de
    pop     bc

    ; 終了
    ret

; ボスがいるかを検索する
;
_EnemyFindBoss::

    ; レジスタの保存
    push    bc
    push    de
    push    iy

    ; hl > エネミーのエントリ

    ; 検索
    ld      iy, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(iy)
    or      a
    jr      z, 11$
    bit     #ENEMY_FLAG_BOSS_BIT, ENEMY_FLAG(iy)
    jr      z, 11$
    cp      #ENEMY_TYPE_BOX
    jr      z, 11$
    cp      #ENEMY_TYPE_CRYSTAL
    jr      nz, 12$
    call    _PlayerIsItemRequire
    jr      c, 12$
11$:
    add     iy, de
    djnz    10$
    ld      hl, #0x0000
    jr      19$
12$:
    push    iy
    pop     hl
;   jr      19$
19$:

    ; レジスタの復帰
    pop     iy
    pop     de
    pop     bc

    ; 終了
    ret

; エネミーを横方向に加速する
;
_EnemyAccelX::

    ; レジスタの保存
    push    de

    ; e < 加速度
    ; d < 最大速度

    ; 加速
    ld      a, ENEMY_SPEED_X(ix)
    add     a, e
    jp      p, 10$
    ld      e, a
    ld      a, d
    neg
    ld      d, a
    ld      a, e
    cp      d
    jr      nc, 19$
    ld      a, d
    jr      19$
10$:
    cp      d
    jr      c, 19$
    jr      z, 19$
    ld      a, d
19$:
    ld      ENEMY_SPEED_X(ix), a

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; エネミーを縦方向に加速する
;
_EnemyAccelY::

    ; レジスタの保存
    push    de

    ; e < 加速度
    ; d < 最大速度

    ; 加速
    ld      a, ENEMY_SPEED_Y(ix)
    add     a, e
    jp      p, 10$
    ld      e, a
    ld      a, d
    neg
    ld      d, a
    ld      a, e
    cp      d
    jr      nc, 19$
    ld      a, d
    jr      19$
10$:
    cp      d
    jr      c, 19$
    jr      z, 19$
    ld      a, d
19$:
    ld      ENEMY_SPEED_Y(ix), a

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; エネミーを移動させる
;
_EnemyMove::

    ; レジスタの保存

    ; フラグのクリア
    res     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    res     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)

    ; 左右の移動
    ld      a, ENEMY_SPEED_X(ix)
    or      a
    jp      p, 11$
    add     a, #0x0f
    sra     a
    sra     a
    sra     a
    sra     a
    jr      z, 19$
    add     a, ENEMY_POSITION_X(ix)
    cp      ENEMY_POSITION_X(ix)
    jr      c, 10$
    jr      z, 10$
    xor     a
    set     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
10$:
    ld      ENEMY_POSITION_X(ix), a
    ld      e, a
    ld      d, ENEMY_POSITION_Y(ix)
    call    _MazeIsCellWall
    jr      nc, 19$
    ld      a, e
    and     #0xf0
    add     a, #MAZE_CELL_PIXEL
    ld      ENEMY_POSITION_X(ix), a
    set     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
    jr      19$
11$:
    sra     a
    sra     a
    sra     a
    sra     a
    jr      z, 19$
    add     a, ENEMY_POSITION_X(ix)
    jr      nc, 12$
    ld      a, #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
    set     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
12$:
    ld      ENEMY_POSITION_X(ix), a
    ld      e, a
    ld      d, ENEMY_POSITION_Y(ix)
    call    _MazeIsCellWall
    jr      nc, 19$
    ld      a, e
    and     #0xf0
    dec     a
    ld      ENEMY_POSITION_X(ix), a
    set     #ENEMY_FLAG_COLLISION_X_BIT, ENEMY_FLAG(ix)
;   jr      19$
19$:

    ; 上下の移動
    ld      a, ENEMY_SPEED_Y(ix)
    or      a
    jp      p, 21$
    add     a, #0x0f
    sra     a
    sra     a
    sra     a
    sra     a
    jr      z, 29$
    add     a, ENEMY_POSITION_Y(ix)
    cp      ENEMY_POSITION_Y(ix)
    jr      c, 20$
    jr      z, 20$
    xor     a
    set     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
20$:
    ld      ENEMY_POSITION_Y(ix), a
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, a
    call    _MazeIsCellWall
    jr      nc, 29$
    ld      a, d
    and     #0xf0
    add     a, #MAZE_CELL_PIXEL
    ld      ENEMY_POSITION_Y(ix), a
    set     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      29$
21$:
    sra     a
    sra     a
    sra     a
    sra     a
    jr      z, 29$
    add     a, ENEMY_POSITION_Y(ix)
    cp      #(MAZE_CELL_Y * MAZE_CELL_PIXEL)
    jr      c, 22$
    ld      a, #(MAZE_CELL_Y * MAZE_CELL_PIXEL - 0x01)
    set     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
22$:
    ld      ENEMY_POSITION_Y(ix), a
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, a
    call    _MazeIsCellWall
    jr      nc, 29$
    ld      a, d
    and     #0xf0
    dec     a
    ld      ENEMY_POSITION_Y(ix), a
    set     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのいる方向を取得する
;
_EnemyGetApproachDirection::

    ; レジスタの保存

    ; a > 向き

    ; 向きの取得
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      a, #ENEMY_DIRECTION_L
    jr      c, 10$
    ld      a, #ENEMY_DIRECTION_R
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 横方向にプレイヤへ近づく移動量を取得する
;
_EnemyGetApproachX::

    ; レジスタの保存
    push    de

    ; a < 移動量（+）
    ; a > 移動量

    ; 移動量の取得
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      a, e
    jr      nc, 10$
    neg
10$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 縦方向にプレイヤへ近づく移動量を取得する
;
_EnemyGetApproachY::

    ; レジスタの保存
    push    de

    ; a < 移動量（+）
    ; a > 移動量

    ; 移動量の取得
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      a, e
    jr      nc, 10$
    neg
10$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; エネミーがダメージを受けた
;
_EnemyDamage::

    ; レジスタの保存

    ; ポイントの更新
    ld      a, ENEMY_DAMAGE_POINT(ix)
    or      a
    jr      z, 19$
    ld      a, ENEMY_LIFE(ix)
    sub     ENEMY_DAMAGE_POINT(ix)
    jr      nc, 10$
    xor     a
10$:
    ld      ENEMY_LIFE(ix), a
    or      a
    jr      z, 12$
    ld      a, ENEMY_FLAG(ix)
    and     #ENEMY_FLAG_DAMAGE_BACK
    jr      z, 11$
    ld      a, #ENEMY_SPEED_X_DAMAGE
    call    _EnemyGetApproachX
    neg
11$:
    ld      ENEMY_SPEED_X(ix), a
    xor     a
    ld      ENEMY_SPEED_Y(ix), a
    ld      ENEMY_DAMAGE_POINT(ix), a
    ld      ENEMY_DAMAGE_FRAME(ix), #ENEMY_DAMAGE_FRAME_BLINK
    jr      19$
12$:
;   xor     a
    ld      ENEMY_SPEED_X(ix), a
    ld      ENEMY_SPEED_Y(ix), a
    ld      ENEMY_DAMAGE_POINT(ix), a
    ld      ENEMY_DAMAGE_FRAME(ix), #ENEMY_DAMAGE_FRAME_DEAD
;   jr      19$
19$:

    ; フレームの更新
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jr      z, 29$
    dec     ENEMY_DAMAGE_FRAME(ix)
    jr      nz, 20$
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 24$
20$:
    ld      a, ENEMY_SPEED_X(ix)
    or      a
    jp      p, 21$
    add     a, #(ENEMY_SPEED_X_DAMAGE / ENEMY_DAMAGE_FRAME_BLINK)
    jr      nc, 23$
    jr      22$
21$:
    sub     #(ENEMY_SPEED_X_DAMAGE / ENEMY_DAMAGE_FRAME_BLINK)
    jr      nc, 23$
;   jr      22$
22$:
    xor     a
;   jr      23$
23$:
    ld      ENEMY_SPEED_X(ix), a
    call    _EnemyMove
    jr      29$
24$:
    bit     #ENEMY_FLAG_BOSS_BIT, ENEMY_FLAG(ix)
    jr      z, 25$
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_CRYSTAL
    jr      z, 25$
    cp      #ENEMY_TYPE_BOX
    jr      z, 25$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_BGM_PATH_BIT, (hl)
25$:
    xor     a
    ld      ENEMY_TYPE(ix), a
    bit     #ENEMY_FLAG_BOSS_BIT, ENEMY_FLAG(ix)
    jr      z, 29$
    ld      a, (_game + GAME_AREA)
    ld      c, #MAZE_FLAG_BOSS
    call    _MazeSetAreaFlag
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 画面外に落下した　
;
_EnemyFallDown::

    ; レジスタの保存

    ; 落下の判定
    bit     #ENEMY_FLAG_COLLISION_Y_BIT, ENEMY_FLAG(ix)
    jr      z, 10$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #(MAZE_CELL_Y * MAZE_CELL_PIXEL - 0x01)
    jr      c, 10$
    xor     a
    ld      ENEMY_TYPE(ix), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 接地している
;
_EnemyIsLand::

    ; レジスタの保存
    push    de

    ; cf > 1 = 接地

    ; 接地の判定
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    inc     d
    call    _MazeIsCellWall

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 部屋での X 位置を設定する
;
_EnemySetRoomPositionX::

    ; レジスタの保存
    push    de

    ; 位置の設定
    ld      a, (_player + PLAYER_POSITION_X)
    cpl
    and     #0x80
    add     a, #0x20
    ld      e, a
    call    _SystemGetRandom
    and     #0x3f
    add     a, e
    ld      ENEMY_POSITION_X(ix), a

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 矩形を設定する
;
_EnemySetRect::

    ; レジスタの保存

    ; hl < 左上
    ; de < 右下

    ; 矩形の取得
    ld      a, ENEMY_POSITION_X(ix)
    sub     l
    jr      nc, 10$
    xor     a
10$:
    ld      ENEMY_RECT_LEFT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     h
    jr      nc, 11$
    xor     a
11$:
    ld      ENEMY_RECT_TOP(ix), a
    ld      a, ENEMY_POSITION_X(ix)
    add     a, e
    jr      nc, 12$
    ld      a, #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
12$:
    ld      ENEMY_RECT_RIGHT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, d
    jr      nc, 13$
    ld      a, #(MAZE_CELL_Y * MAZE_CELL_PIXEL - 0x01)
13$:
    ld      ENEMY_RECT_BOTTOM(ix), a
    set     #ENEMY_FLAG_RECT_BIT, ENEMY_FLAG(ix)

    ; レジスタの復帰

    ; 終了
    ret

; 向きに関係ないスプライトを設定する
;
_EnemySetSpriteSimple::

    ; レジスタの保存
    push    hl
    push    de

    ; hl < スプライト

    ; スプライトの設定
    ld      a, ENEMY_ANIMATION(ix)
    rrca
    and     #0x04
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 向きを考慮した 2x2 サイズのスプライトを設定する
;
_EnemySetSpriteDirection2x2::

    ; レジスタの保存
    push    hl
    push    de

    ; hl < スプライト

    ; スプライトの設定
    ld      a, ENEMY_DIRECTION(ix)
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x10
    add     a, e
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 直線ボールを発射する
;
_EnemyFireBallStraight::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; hl < 位置
    ; d  < 向き
    ; e  < 速度

    ; ボールの登録
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      19$
11$:
    push    hl
    push    de
    ld      hl, #_enemyBallStraightDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     hl
    ld      ENEMY_POSITION_X(ix), l
    ld      ENEMY_POSITION_Y(ix), h
    ld      ENEMY_DIRECTION(ix), d
    ld      ENEMY_PARAM_0(ix), e
    call    _SystemGetRandom
    ld      ENEMY_ANIMATION(ix), a
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

_EnemyFireBallStraights::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < 発射位置 X/Y, 向き, 速度
    ; b  < 発射数

    ; 発射
10$:
    push    bc
    ld      a, ENEMY_POSITION_X(ix)
    add     a, (hl)
    ld      c, a
    inc     hl
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, (hl)
    ld      b, a
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      e, (hl)
    inc     hl
    push    hl
    ld      l, c
    ld      h, b
    call    _EnemyFireBallStraight
    pop     hl
    pop     bc
    djnz    10$

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 放物線ボールを発射する
;
_EnemyFireBallParabola::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; hl < 位置
    ; de < Y/X 速度
    ; c  < 重力
    ; b  < Y の最大速度

    ; ボールの登録
    ld      ix, #_enemy
    push    bc
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
11$:
    pop     bc
    or      a
    jr      nz, 19$
    push    hl
    push    bc
    push    de
    ld      hl, #_enemyBallParabolaDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc
    pop     hl
    ld      ENEMY_POSITION_X(ix), l
    ld      ENEMY_POSITION_Y(ix), h
    ld      ENEMY_PARAM_0(ix), e
    ld      ENEMY_PARAM_1(ix), d
    ld      ENEMY_PARAM_2(ix), c
    ld      ENEMY_PARAM_3(ix), b
    call    _SystemGetRandom
    ld      ENEMY_ANIMATION(ix), a
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; バウンドボールを発射する
;
_EnemyFireBallBound::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; hl < 位置
    ; de < Y/X 速度
    ; c  < 重力
    ; b  < Y の最大速度

    ; ボールの登録
    ld      ix, #_enemy
    push    bc
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
11$:
    pop     bc
    or      a
    jr      nz, 19$
    push    hl
    push    bc
    push    de
    ld      hl, #_enemyBallBoundDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc
    pop     hl
    ld      ENEMY_POSITION_X(ix), l
    ld      ENEMY_POSITION_Y(ix), h
    ld      ENEMY_PARAM_0(ix), e
    ld      ENEMY_PARAM_1(ix), d
    ld      ENEMY_PARAM_2(ix), c
    ld      ENEMY_PARAM_3(ix), b
    call    _SystemGetRandom
    ld      ENEMY_ANIMATION(ix), a
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
enemyProc:
    
    .dw     _EnemyNull
    .dw     _EnemyReaper
    .dw     _EnemyGremlin
    .dw     _EnemyGazer
    .dw     _EnemyBat
    .dw     _EnemyMage
    .dw     _EnemyCyclops
    .dw     _EnemyHydra
    .dw     _EnemyDaemon
    .dw     _EnemyDragonGreen
    .dw     _EnemyDragonBlue
    .dw     _EnemyDragonRed
    .dw     _EnemyDragonYellow
    .dw     _EnemyBox
    .dw     _EnemyCrystal
    .dw     _EnemyIdol
    .dw     _EnemyGate
    .dw     _EnemyBall
    .dw     _EnemyBall
    .dw     _EnemyBall

; エネミーの初期値
;
enemyDefault:

    .dw     _enemyNullDefault
    .dw     _enemyReaperDefault
    .dw     _enemyGremlinDefault
    .dw     _enemyGazerDefault
    .dw     _enemyBatDefault
    .dw     _enemyMageDefault
    .dw     _enemyCyclopsDefault
    .dw     _enemyHydraDefault
    .dw     _enemyDaemonDefault
    .dw     _enemyDragonGreenDefault
    .dw     _enemyDragonBlueDefault
    .dw     _enemyDragonRedDefault
    .dw     _enemyDragonYellowDefault
    .dw     _enemyBoxDefault
    .dw     _enemyCrystalDefault
    .dw     _enemyIdolDefault
    .dw     _enemyGateDefault
    .dw     _enemyBallStraightDefault
    .dw     _enemyBallParabolaDefault
    .dw     _enemyBallBoundDefault

; 配置
;
enemyEntryPathLeft:

    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_REAPER, ENEMY_TYPE_GREMLIN, ENEMY_TYPE_GAZER
    .db     0x1f, 0x40, 0x1f, 0x70

enemyEntryPathRight:

    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_REAPER, ENEMY_TYPE_GREMLIN, ENEMY_TYPE_GAZER
    .db     0x1f, 0xa0, 0x1f, 0x70

enemyEntryPathUp:

    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_GAZER, ENEMY_TYPE_GAZER, ENEMY_TYPE_GAZER
    .db     0x3f, 0x60, 0x1f, 0x40

enemyEntryPathDown:

    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_GREMLIN, ENEMY_TYPE_GAZER, ENEMY_TYPE_GAZER
    .db     0x3f, 0x60, 0x1f, 0x70


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySprite:

    .ds     0x01