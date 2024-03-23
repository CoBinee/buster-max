; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Maze.inc"
    .include    "Room.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 迷路の初期化
    call    _MazeInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; アイテムの初期化
    call    _ItemInitialize

    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_SIZE
    ldir

    ; 最初のエリアの取得
    call    _MazeGetAreaStart
    ld      (_game + GAME_AREA), a
    
    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE_GAME_NORMAL) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンネームのクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0x00
    ldir

90$:
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; サウンドの停止
    call    _SystemStopSound
    
    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (gameState), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (gameState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; リクエストの処理
    ld      hl, #(_game + GAME_REQUEST)

    ; エリアの変更
    ld      de, #(_game + GAME_AREA)
200$:
    bit     #GAME_REQUEST_AREA_UP_BIT, (hl)
    jr      z, 201$
    call    _PlayerMoveAreaUp
    ld      a, (de)
    call    _MazeGetAreaUp
    jr      204$
201$:
    bit     #GAME_REQUEST_AREA_DOWN_BIT, (hl)
    jr      z, 202$
    call    _PlayerMoveAreaDown
    ld      a, (de)
    call    _MazeGetAreaDown
    jr      204$
202$:
    bit     #GAME_REQUEST_AREA_LEFT_BIT, (hl)
    jr      z, 203$
    call    _PlayerMoveAreaLeft
    ld      a, (de)
    call    _MazeGetAreaLeft
    jr      204$
203$:
    bit     #GAME_REQUEST_AREA_RIGHT_BIT, (hl)
    jr      z, 209$
    call    _PlayerMoveAreaRight
    ld      a, (de)
    call    _MazeGetAreaRight
;   jr      204$
204$:
    ld      (de), a
    ld      a, (hl)
    and     #~(GAME_REQUEST_AREA_UP | GAME_REQUEST_AREA_DOWN | GAME_REQUEST_AREA_LEFT | GAME_REQUEST_AREA_RIGHT)
    ld      (hl), a
    ld      a, #GAME_STATE_ENTER
    ld      (gameState), a
;   jr      209$
209$:

    ; BGM の再生
    bit     #GAME_REQUEST_BGM_PATH_BIT, (hl)
    jr      z, 219$
    ld      a, #SOUND_BGM_PATH
    call    _SoundPlayBgm
    ld      a, (hl)
    and     #~(GAME_REQUEST_BGM_PATH)
    ld      (hl), a
219$:

    ; ゲームの監視
    bit     #GAME_REQUEST_GAME_CLEAR_BIT, (hl)
    jr      z, 220$
    ld      a, #GAME_STATE_CLEAR
    jr      221$
220$:
    bit     #GAME_REQUEST_GAME_OVER_BIT, (hl)
    jr      z, 229$
    ld      a, #GAME_STATE_OVER
;   jr      221$
221$:
    ld      (gameState), a
    ld      a, (hl)
    and     #~(GAME_REQUEST_GAME_CLEAR | GAME_REQUEST_GAME_OVER)
    ld      (hl), a
229$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; タイマの設定
    ld      a, #0x60
    ld      (_game + GAME_TIMER), a

    ; 開始の描画
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x0280 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #gameStartPatternName
    ld      de, #(_patternName + 0x0148)
    ld      bc, #0x0010
    ldir

    ; ステータスの描画
    call    GamePrintStatus

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; タイマの更新
    ld      hl, #(_game + GAME_TIMER)
    dec     (hl)
    jr      nz, 10$
    ld      a, #GAME_STATE_ENTER
    ld      (gameState), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; エリアに入る
;
GameEnter:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; 部屋の取得
    ld      a, (_game + GAME_AREA)
    call    _RoomGet
    ld      (_game + GAME_ROOM_L), hl

    ; カラーテーブルの設定
    ld      a, h
    or      l
    ld      a, #(APP_COLOR_TABLE_GAME_NORMAL >> 6)
    jr      z, 00$
    ld      de, #ROOM_COLOR_TABLE
    add     hl, de
    ld      a, (hl)
00$:
    ld      (_videoRegister + VDP_R3), a

    ; エリアの作成
    call    _MazeBuildArea

    ; エリアの描画
    ; call    _MazePrintArea

    ; エネミーの配置
    call    _EnemyEntry

    ; アイテムの配置
    call    _ItemEntry

    ; BGM の再生
    call    _EnemyFindBoss
    ld      a, h
    or      l
    ld      a, #SOUND_BGM_PATH
    jr      z, 01$
    ld      a, #SOUND_BGM_BOSS
01$:
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; エリアの描画
    call    _MazePrintArea

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; アイテムの更新
    call    _ItemUpdate

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; アイテムの描画
    call    _ItemRender

    ; ステータスの描画
    call    GamePrintStatus

    ; マップへの切り替え
120$:
    ld      a, (_input + INPUT_BUTTON_ESC)
    dec     a
    jr      nz, 129$
    ld      a, #GAME_STATE_MAP
    ld      (gameState), a
129$:

    ; デバッグ
;   ld      a, (_game + GAME_AREA)
;   call    _MazeGetAreaOrder
;   ld      (_appDebug + 0x0000), a
;   ld      a, (_game + GAME_AREA)
;   call    _MazeGetAreaRoomOrder
;   ld      (_appDebug + 0x0001), a
;   ld      a, (_game + GAME_AREA)
;   call    _MazeGetAreaFlag
;   ld      (_appDebug + 0x0002), a

    ; レジスタの復帰

    ; 終了
    ret

; マップを表示する
;
GameMap:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; マップの描画
    call    GamePrintMap

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; プレイ再開
    ld      a, (_input + INPUT_BUTTON_ESC)
    dec     a
    jr      nz, 10$
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe
    ld      a, #GAME_STATE_PLAY
    ld      (gameState), a
10$:

    ; スプライトの描画
    ld      a, (_game + GAME_FRAME)
    and     #0x08
    jr      z, 20$
    ld      hl, #(_sprite + GAME_SPRITE_MAP)
    ld      a, (_game + GAME_AREA)
    ld      c, a
    and     #MAZE_SIZE_Y_MASK
    rrca
    add     a, #0x33
    ld      (hl), a
    inc     hl
    ld      a, c
    and     #MAZE_SIZE_X_MASK
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x43
    ld      (hl), a
    inc     hl
    ld      (hl), #0x00
    inc     hl
    ld      (hl), #VDP_COLOR_MEDIUM_RED
;   inc     hl
20$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ゲームオーバーの描画
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x0280 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #gameOverPatternName
    ld      de, #(_patternName + 0x014b)
    ld      bc, #0x000a
    ldir

    ; BGM の再生
    ld      a, #SOUND_BGM_OVER
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$
;   ld      a, #SOUND_SE_CLICK
;   call    _SoundPlaySe
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (gameState)
    and     #0x0f
    jr      nz, 09$

    ; ゲームクリアの描画
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x0280 - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #gameClearPatternName0
    ld      de, #(_patternName + 0x00e8)
    ld      bc, #0x0010
    ldir
    ld      hl, #gameClearPatternName1
    ld      de, #(_patternName + 0x0146)
    ld      bc, #0x0014
    ldir
    ld      hl, #gameClearPatternName2
    ld      de, #(_patternName + 0x018e)
    ld      bc, #0x0004
    ldir

    ; BGM の再生
    ld      a, #SOUND_BGM_CLEAR
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #gameState
    inc     (hl)
09$:

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$
;   ld      a, #SOUND_SE_CLICK
;   call    _SoundPlaySe
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; ヒットを判定する
;
GameHit:

    ; レジスタの保存

    ; プレイヤが死んでいる
    ld      a, (_player + PLAYER_LIFE)
    or      a
    jp      z, 90$

    ; プレイヤがダメージを受けている
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jp      nz, 90$

    ; エネミーとの判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jp      z, 190$
    ld      a, ENEMY_LIFE(ix)
    or      a
    jp      z, 190$
    ld      a, ENEMY_DAMAGE_FRAME(ix)
    or      a
    jp      nz, 190$
    bit     #ENEMY_FLAG_ARM_BIT, ENEMY_FLAG(ix)
    jr      nz, 120$

    ; プレイヤからエネミーへの攻撃判定
110$:
    ld      a, (_player + PLAYER_ATTACK_FRAME)
    cp      #(PLAYER_ATTACK_FRAME_CLOSE + 0x01)
    jr      c, 119$
    ld      a, (_player + PLAYER_ITEM_SWORD)
    sra     a
    sra     a
    ld      c, a
    ld      hl, #(_player + PLAYER_ATTACK_POSITION_1_X)
111$:
    ld      a, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    cp      ENEMY_RECT_LEFT(ix)
    jr      c, 114$
    cp      ENEMY_RECT_RIGHT(ix)
    jr      z, 112$
    jr      nc, 114$
112$:
    ld      a, d
    cp      ENEMY_RECT_TOP(ix)
    jr      c, 114$
    cp      ENEMY_RECT_BOTTOM(ix)
    jr      z, 113$
    jr      nc, 114$
113$:
    inc     ENEMY_DAMAGE_POINT(ix)
114$:
    dec     c
    jr      nz, 111$
119$:
    jr      130$

    ; プレイヤーのシールド判定
120$:
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jr      nz, 129$
    ld      a, (_player + PLAYER_ATTACK_FRAME)
    or      a
    jr      nz, 129$
    bit     #ENEMY_FLAG_RECT_BIT, ENEMY_FLAG(ix)
    jr      z, 129$
    ld      a, (_player + PLAYER_SHIELD_RECT_LEFT)
    cp      ENEMY_RECT_RIGHT(ix)
    jr      z, 121$
    jr      nc, 129$
121$:
    ld      a, (_player + PLAYER_SHIELD_RECT_RIGHT)
    cp      ENEMY_RECT_LEFT(ix)
    jr      c, 129$
    ld      a, (_player + PLAYER_SHIELD_RECT_TOP)
    cp      ENEMY_RECT_BOTTOM(ix)
    jr      z, 122$
    jr      nc, 129$
122$:
    ld      a, (_player + PLAYER_SHIELD_RECT_BOTTOM)
    cp      ENEMY_RECT_TOP(ix)
    jr      c, 129$
    ld      hl, #(_player + PLAYER_SHIELD_POINT)
    inc     (hl)
    inc     ENEMY_DAMAGE_POINT(ix)
129$:
;   jr      130$

    ; プレイヤとエネミーの接触判定
130$:
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    or      a
    jr      nz, 139$
    bit     #ENEMY_FLAG_RECT_BIT, ENEMY_FLAG(ix)
    jr      z, 139$
    ld      a, (_player + PLAYER_DAMAGE_RECT_LEFT)
    cp      ENEMY_RECT_RIGHT(ix)
    jr      z, 131$
    jr      nc, 139$
131$:
    ld      a, (_player + PLAYER_DAMAGE_RECT_RIGHT)
    cp      ENEMY_RECT_LEFT(ix)
    jr      c, 139$
    ld      a, (_player + PLAYER_DAMAGE_RECT_TOP)
    cp      ENEMY_RECT_BOTTOM(ix)
    jr      z, 132$
    jr      nc, 139$
132$:
    ld      a, (_player + PLAYER_DAMAGE_RECT_BOTTOM)
    cp      ENEMY_RECT_TOP(ix)
    jr      c, 139$
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_GATE
    jr      z, 134$
    ld      hl, #(_player + PLAYER_DAMAGE_POINT)
    ld      a, ENEMY_ATTACK_POINT(ix)
    add     a, (hl)
    ld      (hl), a
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    ld      a, #PLAYER_SPEED_X_DAMAGE
    jr      nc, 133$
    neg
133$:
    ld      (_player + PLAYER_DAMAGE_SPEED), a
    bit     #ENEMY_FLAG_ARM_BIT, ENEMY_FLAG(ix)
    jr      z, 139$
    inc     ENEMY_DAMAGE_POINT(ix)
    jr      139$
134$:
    ld      a, #PLAYER_DAMAGE_FRAME_CLEAR
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      a, #PLAYER_STATE_CLEAR
    ld      (_player + PLAYER_STATE), a
;   jr      139$
139$:
;   jr      190$

190$:
    ld      de, #ENEMY_LENGTH
    add     ix, de
    dec     b
    jp      nz, 100$

    ; アイテムとの判定
    ld      a, (_item + ITEM_TYPE)
    or      a
    jr      z, 29$
    ld      a, (_game + GAME_AREA)
    call    _MazeGetAreaFlag
    bit     #MAZE_FLAG_BOSS_BIT, a
    jr      z, 29$
    bit     #MAZE_FLAG_ITEM_BIT, a
    jr      nz, 29$
    ld      de, (_player + PLAYER_CENTER_X)
    ld      a, (_item + ITEM_RECT_LEFT)
    cp      e
    jr      z, 20$
    jr      nc, 29$
20$:
    ld      a, (_item + ITEM_RECT_RIGHT)
    cp      e
    jr      c, 29$
    ld      a, (_item + ITEM_RECT_TOP)
    cp      d
    jr      z, 21$
    jr      nc, 29$
21$:
    ld      a, (_item + ITEM_RECT_BOTTOM)
    cp      d
    jr      c, 29$
    ld      a, (_item + ITEM_TYPE)
    call    _PlayerPickupItem
    ld      a, (_game + GAME_AREA)
    ld      c, #MAZE_FLAG_ITEM
    call    _MazeSetAreaFlag
;   jr      29$
29$:

    ; 判定の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存

    ; ライフの描画
    ld      hl, #gameStatusVitality
    ld      de, #(_patternName + 0x02a1)
    ld      bc, #0x0008
    ldir
    ld      hl, #(_patternName + 0x02c1)
    ld      de, #(_player + PLAYER_LIFE)
    ld      c, #0x00
    ld      a, (de)
    sra     a
    sra     a
    jr      z, 11$
    ld      b, a
    ld      a, #0xd4
10$:
    ld      (hl), a
    inc     hl
    inc     c
    djnz    10$
11$:
    ld      a, (de)
    and     #0x03
    jr      z, 12$
    add     a, #0xd0
    ld      (hl), a
    inc     hl
    inc     c
12$:
    ld      a, #(PLAYER_LIFE_MAXIMUM / 0x04)
    sub     c
    jr      z, 14$
    ld      b, a
    ld      a, #0xd0
13$:
    ld      (hl), a
    inc     hl
    djnz    13$
14$:

    ; アイテムの描画
    ld      hl, #(_patternName + 0x02b0)
    ld      de, #(_player + PLAYER_ITEM_SWORD)

    ; 剣の描画
    ld      a, (de)
    and     #0xfc
    add     a, #(0x80 - 0x04)
    call    27$
    ld      a, (de)
    and     #0x03
    call    28$
    inc     de

    ; 鍵の描画
    ld      a, #0x90
    call    27$
    ld      a, (de)
    call    28$
    inc     hl
    inc     de

    ; 杖の描画
    ld      a, (de)
    or      a
    ld      a, #0x98
    call    nz, 27$
    inc     de

    ; 王冠の描画
    ld      a, (de)
    or      a
    ld      a, #0x94
    call    nz, 27$
    inc     de

    ; 指輪の描画
    ld      a, (de)
    or      a
    ld      a, #0xa0
    call    nz, 27$
    inc     de

    ; 首飾りの描画
    ld      a, (de)
    or      a
    ld      a, #0xa8
    call    nz, 27$
;   inc     de
    jr      29$

    ; アイコンの描画
27$:
    push    de
    ld      de, #0x001f
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    add     hl, de
    inc     a
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
    or      a
    sbc     hl, de
    pop     de
    ret

    ; 数字の描画
28$:
    push    hl
    push    de
    ld      de, #0x0020
    add     hl, de
    add     a, #0x10
    ld      (hl), a
    pop     de
    pop     hl
    inc     hl
    ret

    ; アイテム描画の完了
29$:

    ; レジスタの復帰

    ; 終了
    ret

; マップを描画する
;
GamePrintMap:

    ; レジスタの保存
    
    ; クリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #0x0280
    ld      (hl), #0x00
    ldir

    ; 下地の描画
    ld      hl, #(gameMapPatternName + 0x0000)
    ld      de, #(_patternName + 0x00a7)
    ld      bc, #0x0012
    ldir
    ld      de, #(_patternName + 0x00c7)
    ld      a, #MAZE_SIZE_Y
10$:
    ld      hl, #(gameMapPatternName + 0x0012)
    ld      bc, #0x0012
    ldir
    ex      de, hl
    ld      bc, #0x000e
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$
    ld      hl, #(gameMapPatternName + 0x0024)
    ld      bc, #0x0012
    ldir

    ; フラグの描画
    ld      hl, #(_patternName + 0x00c8)
    ld      de, #(0x0020 - MAZE_SIZE_X)
    xor     a
    ld      c, #MAZE_SIZE_Y
20$:
    ld      b, #MAZE_SIZE_X
21$:
    push    af
    call    _MazeGetAreaFlag
    and     #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_LEFT | MAZE_FLAG_WALL_RIGHT | MAZE_FLAG_ROOM)
    add     a, #0xe0
    ld      (hl), a
    pop     af
    inc     hl
    inc     a
    djnz    21$
    add     hl, de
    dec     c
    jr      nz, 20$

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GameEnter
    .dw     GamePlay
    .dw     GameMap
    .dw     GameOver
    .dw     GameClear

; ゲームの初期値
;
gameDefault:

    .db     GAME_REQUEST_NULL
    .db     GAME_AREA_NULL
    .db     0x00, 0x00
    .db     GAME_TIMER_NULL
    .db     GAME_FRAME_NULL

; ステータス
;
gameStatusVitality:

    .db     0x36, 0x29, 0x34, 0x21, 0x2c, 0x29, 0x34, 0x39

; マップ
;
gameMapPatternName:

    .db     0xd8, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xd9, 0xda
    .db     0xdb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xdc
    .db     0xdd, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xdf

; スタート
;
gameStartPatternName:

    ; RETURN FROM mayQ
    .db     0x32, 0x25, 0x34, 0x35, 0x32, 0x2e, 0x00, 0x26, 0x32, 0x2f, 0x2d, 0x00, 0x9c, 0x9d, 0x9e, 0x9f

; ゲームオーバー
;
gameOverPatternName:

    ; GAME  OVER
    .db     0x27, 0x21, 0x2d, 0x25, 0x00, 0x00, 0x2f, 0x36, 0x25, 0x32

; クリア
;
gameClearPatternName0:

    ; CONGRATULATIONS!
    .db     0x23, 0x2f, 0x2e, 0x27, 0x32, 0x21, 0x34, 0x35, 0x2c, 0x21, 0x34, 0x29, 0x2f, 0x2e, 0x33, 0x01

gameClearPatternName1:

    ; YOU'VE RETURNED FROM
    .db     0x39, 0x2f, 0x35, 0x07, 0x36, 0x25, 0x00, 0x32, 0x25, 0x34, 0x35, 0x32, 0x2e, 0x25, 0x24, 0x00, 0x26, 0x32, 0x2f, 0x2d

gameClearPatternName2:

    ; mayQ
    .db     0x9c, 0x9d, 0x9e, 0x9f


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
gameState:
    
    .ds     1

; ゲーム
;
_game:

    .ds     GAME_SIZE
