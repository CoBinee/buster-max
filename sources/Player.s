; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include	"Maze.inc"
    .include    "Player.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの設定
    ld      a, (_player + PLAYER_ATTACK_TYPE)
    or      a
    jr      z, 20$
    dec     a
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_DIRECTION)
    and     #0x01
    add     a, e
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_ATTACK_FRAME)
    rrca
    rrca
    and     #0x01
    add     a, e
    ld      hl, #playerSpriteAttack
    jr      22$
20$:
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_LAND_BIT, a
    jr      nz, 21$
    bit     #PLAYER_FLAG_HOLD_BIT, a
    jr      nz, 21$
    ld      a, (_player + PLAYER_DIRECTION)
    and     #0x01
    ld      hl, #playerSpriteJump
    jr      22$
21$:
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_ANIMATION)
    rrca
    rrca
    rrca
    and     #0x01
    add     a, e
    ld      hl, #playerSpriteWalk
    jr      22$
22$:
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      (_player + PLAYER_SPRITE_PERSON_L), hl
    ld      a, (_player + PLAYER_ITEM_SWORD)
    and     #0xfc
    ld      e, a
;   ld      d, #0x00
    add     hl, de
    ld      (_player + PLAYER_SPRITE_SWORD_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; ECC の取得
    ld      a, (_player + PLAYER_POSITION_X)
    ld      bc, #0x0000
    cp      #0x80
    jr      nc, 00$
    ld      bc, #0x2080
00$:

    ; スプライトの描画
    ld      a, (_player + PLAYER_DAMAGE_FRAME)
    and     #0x01
    jr      nz, 19$
    ld      hl, (_player + PLAYER_SPRITE_PERSON_L)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_PERSON)
    call    18$
    ld      hl, (_player + PLAYER_SPRITE_SWORD_L)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_SWORD_0)
    ld      a, (_game + GAME_FRAME)
    and     #0x01
    jr      z, 10$
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_SWORD_1)
10$:
    call    18$
    jr      19$
18$:
    ld      a, h
    or      l
    ret     z
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_X)
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
;   inc     hl
    inc     de
    ret
19$:

    ; レジスタの復帰

    ; 終了
    ret
    
; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; ダメージの設定
    ld      a, (_player + PLAYER_DAMAGE_POINT)
    or      a
    jr      z, 109$
    ld      e, a
    ld      hl, #(_player + PLAYER_LIFE)
    ld      a, (hl)
    sub     e
    jr      nc, 100$
    xor     a
100$:
    ld      (hl), a
    or      a
    jr      nz, 101$
    ld      a, #PLAYER_DAMAGE_FRAME_DEAD
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      a, #PLAYER_STATE_DEAD
    ld      (_player + PLAYER_STATE), a
    jp      90$
101$:
    ld      a, (_player + PLAYER_DAMAGE_SPEED)
    ld      (_player + PLAYER_SPEED_X), a
    xor     a
    ld      (_player + PLAYER_SPEED_Y), a
    ld      (_player + PLAYER_ATTACK_TYPE), a
    ld      (_player + PLAYER_ATTACK_FRAME), a
    ld      (_player + PLAYER_DAMAGE_POINT), a
    ld      (_player + PLAYER_SHIELD_POINT), a
    ld      (_player + PLAYER_SHIELD_FRAME), a
    ld      a, #PLAYER_DAMAGE_FRAME_BLINK
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      a, #SOUND_SE_DAMAGE
    call    _SoundPlaySe
109$:

    ; 薬の使用
    ld      hl, #(_player + PLAYER_ITEM_POTION)
    ld      a, (hl)
    or      a
    jr      z, 119$
    ld      de, #(_player + PLAYER_LIFE)
    ld      a, (de)
    inc     a
    cp      #PLAYER_LIFE_MAXIMUM
    jr      c, 110$
    xor     a
    ld      (hl), a
    ld      a, #PLAYER_LIFE_MAXIMUM
110$:
    ld      (de), a
119$:

    ; シールドの設定
    ld      a, (_player + PLAYER_SHIELD_POINT)
    or      a
    jr      z, 129$
    ld      a, (_player + PLAYER_DIRECTION)
    bit     #PLAYER_DIRECTION_LR_BIT, a
    ld      a, #PLAYER_SPEED_X_SHIELD
    jr      z, 120$
    neg
120$:
    ld      (_player + PLAYER_SPEED_X), a
    xor     a
    ld      (_player + PLAYER_SPEED_Y), a
    ld      (_player + PLAYER_ATTACK_TYPE), a
    ld      (_player + PLAYER_ATTACK_FRAME), a
    ld      (_player + PLAYER_DAMAGE_POINT), a
    ld      (_player + PLAYER_DAMAGE_FRAME), a
    ld      (_player + PLAYER_SHIELD_POINT), a
    ld      a, #PLAYER_SHIELD_FRAME_BLINK
    ld      (_player + PLAYER_SHIELD_FRAME), a
    ld      a, #SOUND_SE_DEFENSE
    call    _SoundPlaySe
129$:

    ; 攻撃の操作
    ld      hl, #(_player + PLAYER_FLAG)
    ld      a, (_player + PLAYER_ATTACK_TYPE)
    or      a
    jr      nz, 209$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 209$
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 201$
    bit     #PLAYER_FLAG_LAND_BIT, (hl)
    jr      nz, 200$
    bit     #PLAYER_FLAG_JUMP_BIT, (hl)
    jr      nz, 201$
    set     #PLAYER_FLAG_JUMP_BIT, (hl)
200$:
    ld      a, #PLAYER_SPEED_Y_ATTACK_UP
    ld      (_player + PLAYER_SPEED_Y), a
    ld      a, #PLAYER_ATTACK_TYPE_UP
    ld      c, #SOUND_SE_ATTACK_1
    jr      208$
201$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 203$
    bit     #PLAYER_FLAG_LAND_BIT, (hl)
    jr      nz, 203$
    bit     #PLAYER_FLAG_JUMP_BIT, (hl)
    jr      nz, 202$
    ld      a, #PLAYER_ATTACK_TYPE_DOWN_LOW
    ld      c, #SOUND_SE_ATTACK_2
    jr      208$
202$:
    xor     a
    ld      (_player + PLAYER_SPEED_X), a
    ld      a, #PLAYER_SPEED_Y_ATTACK_DOWN
    ld      (_player + PLAYER_SPEED_Y), a
    ld      a, #PLAYER_ATTACK_TYPE_DOWN_HIGH
    ld      c, #SOUND_SE_ATTACK_2
    jr      208$
203$:
    ld      a, #PLAYER_ATTACK_TYPE_FRONT
    ld      c, #SOUND_SE_ATTACK_1
;   jr      208$
208$:
    ld      (_player + PLAYER_ATTACK_TYPE), a
    ld      a, #PLAYER_ATTACK_FRAME_SWING
    ld      (_player + PLAYER_ATTACK_FRAME), a
    res     #PLAYER_FLAG_HOLD_BIT, (hl)
    ld      a, c
    call    _SoundPlaySe
;   jr      209$
209$:

    ; 横移動の操作
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, #(_player + PLAYER_SPEED_X)
    ld      bc, #(_player + PLAYER_DIRECTION)
    ld      a, (_player + PLAYER_ATTACK_TYPE)
    cp      #PLAYER_ATTACK_TYPE_DOWN_LOW
    jr      z, 239$
    or      a
    jr      nz, 229$

    ; 左の操作
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 219$
    ld      a, (bc)
    res     #PLAYER_DIRECTION_LR_BIT, a
    ld      (bc), a
    bit     #PLAYER_FLAG_HOLD_BIT, (hl)
    jr      z, 210$
    ld      a, #-PLAYER_SPEED_X_HOLD
    jr      212$
210$:
    ld      a, (de)
    or      a
    jr      nz, 211$
    ld      a, #-PLAYER_SPEED_X_START
    jr      212$
211$:
    sub     #PLAYER_SPEED_X_ACCEL
    jp      p, 212$
    cp      #-PLAYER_SPEED_X_MAXIMUM
    jr      nc, 212$
    ld      a, #-PLAYER_SPEED_X_MAXIMUM
212$:
    ld      (de), a
    jr      239$
219$:

    ; 右の操作
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 229$
    ld      a, (bc)
    set     #PLAYER_DIRECTION_LR_BIT, a
    ld      (bc), a
    bit     #PLAYER_FLAG_HOLD_BIT, (hl)
    jr      z, 220$
    ld      a, #PLAYER_SPEED_X_HOLD
    jr      222$
220$:
    ld      a, (de)
    or      a
    jr      nz, 221$
    ld      a, #PLAYER_SPEED_X_START
    jr      222$
221$:
    add     a, #PLAYER_SPEED_X_ACCEL
    jp      m, 222$
    cp      #PLAYER_SPEED_X_MAXIMUM
    jr      c, 222$
    ld      a, #PLAYER_SPEED_X_MAXIMUM
222$:
    ld      (de), a
    jr      239$
229$:

    ; 左右の停止
    ld      a, (de)
    or      a
    jp      p, 230$
    add     a, #PLAYER_SPEED_X_BRAKE
    jp      m, 231$
    xor     a
    jr      231$
230$:
    sub     #PLAYER_SPEED_X_BRAKE
    jp      p, 231$
    xor     a
231$:
    ld      (de), a
;   jr      239$
239$:

    ; 縦移動の操作
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, #(_player + PLAYER_SPEED_Y)
    ld      a, (_player + PLAYER_ATTACK_TYPE)
    cp      #PLAYER_ATTACK_TYPE_DOWN_HIGH
    jr      z, 269$
    or      a
    jr      nz, 259$

    ; ジャンプの操作
    ld      a, (_input + INPUT_KEY_UP)
    dec     a
    jr      nz, 249$
    bit     #PLAYER_FLAG_LAND_BIT, (hl)
    jr      nz, 240$
    bit     #PLAYER_FLAG_JUMP_BIT, (hl)
    jr      nz, 249$
    set     #PLAYER_FLAG_JUMP_BIT, (hl)
240$:
    ld      a, #PLAYER_SPEED_Y_JUMP
    ld      (de), a
    res     #PLAYER_FLAG_HOLD_BIT, (hl)
    ld      a, #SOUND_SE_JUMP
    call    _SoundPlaySe
    jr      269$
249$:

    ; 昇降の操作
    bit     #PLAYER_FLAG_HOLD_BIT, (hl)
    jr      z, 259$
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 250$
    ld      a, #-PLAYER_SPEED_Y_HOLD
    ld      (de), a
    jr      251$
250$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 251$
    ld      a, #PLAYER_SPEED_Y_HOLD
    ld      (de), a
    jr      251$
251$:
    ld      (de), a
    jr      269$
259$:

    ; 重力の影響
    ld      a, (de)
    add     a, #PLAYER_SPEED_Y_GRAVITY
    jp      m, 260$
    cp      #PLAYER_SPEED_Y_MAXIMUM
    jr      c, 260$
    ld      a, #PLAYER_SPEED_Y_MAXIMUM
260$:
    ld      (de), a
;   jr      269$
269$:

    ; 操作の完了
290$:

    ; 移動の開始

    ; 左右の移動
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (_player + PLAYER_SPEED_X)
    or      a
    jp      p, 302$
    add     a, #0x0f
    sra     a
    sra     a
    sra     a
    sra     a
    jr      z, 309$
    add     a, (hl)
    cp      (hl)
    jr      c, 300$
    jr      z, 300$
    ld      (hl), #0x00
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_LEFT_BIT, (hl)
    jr      309$
300$:
    ld      (hl), a
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    call    _MazeIsCellWall
    jr      c, 301$
    ld      a, d
    sub     #(PLAYER_SIZE_PERSON_Y - 0x01)
    ld      d, a
    call    _MazeIsCellWall
    jr      nc, 309$
301$:
    ld      a, e
    and     #0xf0
    add     a, #MAZE_CELL_PIXEL
    ld      (hl), a
    jr      309$
302$:
    sra     a
    sra     a
    sra     a
    sra     a
    jr      z, 309$
    add     a, (hl)
    jr      nc, 303$
    ld      (hl), #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_RIGHT_BIT, (hl)
    jr      309$
303$:
    ld      (hl), a
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    call    _MazeIsCellWall
    jr      c, 304$
    ld      a, d
    sub     #(PLAYER_SIZE_PERSON_Y - 0x01)
    ld      d, a
    call    _MazeIsCellWall
    jr      nc, 309$
304$:
    ld      a, e
    and     #0xf0
    dec     a
    ld      (hl), a
;   jr      309$
309$:

    ; 接地フラグのクリア
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_LAND_BIT, (hl)

    ; 上下の移動
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jp      p, 311$
    inc     a
    sra     a
;   sra     a
;   sra     a
;   sra     a
    jr      z, 319$
    add     a, (hl)
    cp      (hl)
    jr      c, 310$
    jr      z, 310$
    ld      (hl), #0x00
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_UP_BIT, (hl)
    jr      319$
310$:
    ld      (hl), a
    sub     #(PLAYER_SIZE_PERSON_Y - 0x01)
    jr      c, 319$
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    ld      e, a
    call    _MazeIsCellWall
    jr      nc, 319$
    ld      a, d
    and     #0xf0
    add     a, #(MAZE_CELL_PIXEL + PLAYER_SIZE_PERSON_Y - 0x01)
    ld      (hl), a
    jr      319$
311$:
    sra     a
;   sra     a
;   sra     a
;   sra     a
    jr      z, 319$
    add     a, (hl)
    cp      #(MAZE_CELL_Y * MAZE_CELL_PIXEL)
    jr      c, 312$
    ld      (hl), #(MAZE_CELL_Y * MAZE_CELL_PIXEL)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_DOWN_BIT, (hl)
    jr      319$
312$:
    ld      (hl), a
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X)
    ld      e, a
    call    _MazeIsCellWall
    jr      nc, 313$
    ld      a, d
    and     #0xf0
    dec     a
    ld      (hl), a
    jr      314$
313$:
    inc     d
    call    _MazeIsCellWall
    jr      nc, 319$
314$:
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_LAND_BIT, (hl)
    res     #PLAYER_FLAG_JUMP_BIT, (hl)
;   jr      319$
319$:

    ; 蔦に掴まる
    ld      a, (_player + PLAYER_ATTACK_TYPE)
    or      a
    jr      nz, 329$
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, (_player + PLAYER_POSITION_X)
    call    _MazeIsCellIvy
    jr      c, 320$
    ld      a, d
    sub     #(PLAYER_SIZE_PERSON_Y - 0x01)
    ld      d, a
    call    _MazeIsCellIvy
    jr      nc, 321$
320$:
    bit     #PLAYER_FLAG_HOLD_BIT, (hl)
    jr      nz, 329$
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 321$
    set     #PLAYER_FLAG_HOLD_BIT, (hl)
    res     #PLAYER_FLAG_JUMP_BIT, (hl)
    ld      hl, #(_player + PLAYER_DIRECTION)
    set     #PLAYER_DIRECTION_UP_BIT, (hl)
    jr      329$
321$:
    res     #PLAYER_FLAG_HOLD_BIT, (hl)
    ld      hl, #(_player + PLAYER_DIRECTION)
    res     #PLAYER_DIRECTION_UP_BIT, (hl)
;   jr      329$
329$:

    ; 移動の完了
390$:

    ; 攻撃の更新
    ld      hl, #(_player + PLAYER_ATTACK_FRAME)
    ld      de, #(_player + PLAYER_ATTACK_TYPE)
    ld      a, (de)
    cp      #PLAYER_ATTACK_TYPE_FRONT
    jr      nz, 400$
    dec     (hl)
    jr      nz, 409$
    xor     a
    jr      402$
400$:
    cp      #PLAYER_ATTACK_TYPE_UP
    jr      nz, 401$
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jp      m, 409$
    ld      (hl), #PLAYER_ATTACK_FRAME_CLOSE
    ld      a, #PLAYER_ATTACK_TYPE_FRONT
    jr      402$
401$:
    or      a
    jr      z, 409$
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_LAND_BIT, a
    jr      z, 409$
    ld      a, #PLAYER_ATTACK_TYPE_FRONT
;   jr      402$
402$:
    ld      (de), a
409$:

    ; 攻撃の位置の取得
    ld      a, (_player + PLAYER_ATTACK_TYPE)
    or      a
    jr      z, 419$
    dec     a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      a, (_player + PLAYER_DIRECTION)
    bit     #PLAYER_DIRECTION_LR_BIT, a
    jr      nz, 413$
    ld      hl, #playerAttackPositionLeft
    add     hl, de
    ld      de, #(_player + PLAYER_ATTACK_POSITION_1_X)
    ld      bc, #((PLAYER_ATTACK_POSITION_SIZE << 8) | 0x00)
410$:
    ld      a, (_player + PLAYER_POSITION_X)
    sub     (hl)
    jr      nc, 411$
    ld      a, c
411$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     (hl)
    jr      nc, 412$
    ld      a, c
412$:
    ld      (de), a
    inc     hl
    inc     de
    djnz    410$
    jr      419$
413$:
    ld      hl, #playerAttackPositionRight
    add     hl, de
    ld      de, #(_player + PLAYER_ATTACK_POSITION_1_X)
    ld      bc, #((PLAYER_ATTACK_POSITION_SIZE << 8) | (MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01))
414$:
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, (hl)
    jr      nc, 415$
    ld      a, c
415$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     (hl)
    jr      nc, 416$
    ld      a, c
416$:
    ld      (de), a
    inc     hl
    inc     de
    djnz    414$
;   jr      419$
419$:

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 500$
    dec     (hl)
500$:

    ; ダメージの矩形の取得
    ld      hl, #(_player + PLAYER_DAMAGE_RECT_LEFT)
    ld      bc, (_player + PLAYER_POSITION_X)
    ld      a, c
    sub     #(PLAYER_SIZE_PERSON_X / 2)
    jr      nc, 510$
    xor     a
510$:
    ld      (hl), a
    inc     hl
    ld      a, b
    sub     #(PLAYER_SIZE_PERSON_Y - 0x01)
    jr      nc, 511$
    xor     a
511$:
    ld      (hl), a
    inc     hl
    ld      a, c
    add     a, #(PLAYER_SIZE_PERSON_X / 2 - 0x01)
    jr      nc, 512$
    ld      a, #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
512$:
    ld      (hl), a
    inc     hl
    ld      (hl), b
;   inc     hl

    ; シールドの更新
    ld      hl, #(_player + PLAYER_SHIELD_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 600$
    dec     (hl)
600$:

    ; シールドの矩形の取得
    ld      de, #(_player + PLAYER_SHIELD_RECT_LEFT)
    ld      bc, (_player + PLAYER_POSITION_X)
    ld      a, (_player + PLAYER_DIRECTION)
    bit     #PLAYER_DIRECTION_LR_BIT, a
    jr      nz, 614$
    ld      hl, #playerShieldRectLeft
    ld      a, c
    sub     (hl)
    jr      nc, 610$
    xor     a
610$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    sub     (hl)
    jr      nc, 611$
    xor     a
611$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    sub     (hl)
    jr      nc, 612$
    xor     a
612$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    sub     (hl)
    jr      nc, 613$
    xor     a
613$:
    ld      (de), a
;   inc     hl
;   inc     de
    jr      619$
614$:
    ld      hl, #playerShieldRectRight
    ld      a, c
    add     a, (hl)
    jr      nc, 615$
    ld      a, #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
615$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    sub     (hl)
    jr      nc, 616$
    xor     a
616$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    jr      nc, 617$
    ld      a, #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
617$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    sub     (hl)
    jr      nc, 618$
    xor     a
618$:
    ld      (de), a
;   inc     hl
;   inc     de
;   jr      619$
619$:

    ; 中心の取得
    ld      a, (_player + PLAYER_POSITION_X)
    ld      (_player + PLAYER_CENTER_X), a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #(PLAYER_SIZE_PERSON_Y / 0x02)
    ld      (_player + PLAYER_CENTER_Y), a

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_LAND_BIT, a
    jr      z, 80$
    ld      a, (_player + PLAYER_SPEED_X)
    or      a
    jr      nz, 88$
    ld      (hl), #PLAYER_ANIMATION_STAY
    jr      89$
80$:
    bit     #PLAYER_FLAG_HOLD_BIT, a
    jr      z, 81$
    ld      a, (_player + PLAYER_SPEED_X)
    or      a
    jr      nz, 88$
    ld      a, (_player + PLAYER_SPEED_Y)
    or      a
    jr      nz, 88$
    jr      89$
81$:
    ld      (hl), #0x00
    jr      89$
88$:
    inc     (hl)
;   jr      89$
89$:

    ; プレイの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが死亡した
;
PlayerDead:

    ; レジスタの保存

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      nz, 10$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_GAME_OVER_BIT, (hl)
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがクリアした
;
PlayerClear:

    ; レジスタの保存

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      nz, 10$
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_GAME_CLEAR_BIT, (hl)
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを上のエリアに移動させる
;
_PlayerMoveAreaUp::

    ; レジスタの保存

    ; 位置の設定
    ld      a, #(MAZE_CELL_Y * MAZE_CELL_PIXEL - 0x01)
    ld      (_player + PLAYER_POSITION_Y), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを下のエリアに移動させる
;
_PlayerMoveAreaDown::

    ; レジスタの保存

    ; 位置の設定
    xor     a
    ld      (_player + PLAYER_POSITION_Y), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを左のエリアに移動させる
;
_PlayerMoveAreaLeft::

    ; レジスタの保存

    ; 位置の設定
    ld      a, #(MAZE_CELL_X * MAZE_CELL_PIXEL - 0x01)
    ld      (_player + PLAYER_POSITION_X), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを右のエリアに移動させる
;
_PlayerMoveAreaRight::

    ; レジスタの保存

    ; 位置の設定
    xor     a
    ld      (_player + PLAYER_POSITION_X), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがアイテムを拾う
;
_PlayerPickupItem::

    ; レジスタの保存
    push    hl
    push    de

    ; a < アイテム

    ; アイテムの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_player + PLAYER_ITEM)
    add     hl, de
    inc     (hl)

    ; SE の再生
    ld      a, #SOUND_SE_ITEM
    call    _SoundPlaySe

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤがアイテムを使う
;
_PlayerUseItem::

    ; レジスタの保存
    push    hl
    push    de

    ; a < アイテム

    ; アイテムの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_player + PLAYER_ITEM)
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
10$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

;  プレイヤがアイテムを持っているかを判定する
;
_PlayerIsItem::

    ; レジスタの保存
    push    hl
    push    de

    ; a  < アイテム
    ; cf > 0/1 = 持っていない/いる

    ; アイテムの判定
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_player + PLAYER_ITEM)
    add     hl, de
    ld      a, (hl)
    cp      #0x01
    ccf

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

;  プレイヤがクリアに必要なアイテムをすべて持っているかを判定する
;
_PlayerIsItemRequire::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 持っていない/いる

    ; アイテムの判定
    ld      hl, #(_player + PLAYER_ITEM_ROD)
    xor     a
    cp      (hl)
    jr      nc, 10$
    inc     hl
    cp      (hl)
    jr      nc, 10$
    inc     hl
    cp      (hl)
    jr      nc, 10$
    inc     hl
    cp      (hl)
10$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay
    .dw     PlayerDead
    .dw     PlayerClear

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_PLAY
    .db     PLAYER_FLAG_NULL
    .db     MAZE_POSITION_START_X
    .db     MAZE_POSITION_START_Y
    .db     PLAYER_DIRECTION_LR_RIGHT
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_ANIMATION_NULL
    .db     PLAYER_LIFE_MAXIMUM
    .db     PLAYER_ATTACK_TYPE_NULL
    .db     PLAYER_ATTACK_FRAME_NULL
    .db     PLAYER_ATTACK_POSITION_NULL
    .db     PLAYER_ATTACK_POSITION_NULL
    .db     PLAYER_ATTACK_POSITION_NULL
    .db     PLAYER_ATTACK_POSITION_NULL
    .db     PLAYER_ATTACK_POSITION_NULL
    .db     PLAYER_ATTACK_POSITION_NULL
    .db     PLAYER_DAMAGE_POINT_NULL
    .db     PLAYER_DAMAGE_FRAME_NULL
    .db     PLAYER_DAMAGE_SPEED_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_SHIELD_POINT_NULL
    .db     PLAYER_SHIELD_FRAME_NULL
    .db     PLAYER_SHIELD_RECT_NULL
    .db     PLAYER_SHIELD_RECT_NULL
    .db     PLAYER_SHIELD_RECT_NULL
    .db     PLAYER_SHIELD_RECT_NULL
    .db     PLAYER_CENTER_NULL
    .db     PLAYER_CENTER_NULL
    .db     PLAYER_ITEM_NULL
    .db     PLAYER_ITEM_NULL
    .db     0x04 ; PLAYER_ITEM_NULL
    .db     PLAYER_ITEM_NULL
    .db     PLAYER_ITEM_NULL
    .db     PLAYER_ITEM_NULL
    .db     PLAYER_ITEM_NULL
    .db     PLAYER_ITEM_NULL
    .db     PLAYER_SPRITE_NULL
    .db     PLAYER_SPRITE_NULL
    .db     PLAYER_SPRITE_NULL
    .db     PLAYER_SPRITE_NULL
    .db     0x00, 0x00, 0x00, 0x00

; 攻撃
;
playerAttackPositionLeft:

    .db     -(-0x21 + 0x0e), -(-0x1f + 0x12)    ; PLAYER_ATTACK_TYPE_FRONT + PLAYER_DIRECTION_LEFT
    .db     -(-0x21 + 0x0a), -(-0x1f + 0x12)
    .db     -(-0x21 + 0x06), -(-0x1f + 0x12)
    .db     0x00, 0x00
    .db     -(-0x1b + 0x10), -(-0x1f + 0x08)    ; PLAYER_ATTACK_TYPE_UP + PLAYER_DIRECTION_LEFT
    .db     -(-0x1b + 0x10), -(-0x1f + 0x04)
    .db     -(-0x1b + 0x10), -(-0x1f + 0x00)
    .db     0x00, 0x00
    .db     -(-0x21 + 0x0e), -(-0x1f + 0x12)    ; PLAYER_ATTACK_TYPE_DOWN_LOW + PLAYER_DIRECTION_LEFT
    .db     -(-0x21 + 0x0a), -(-0x1f + 0x12)
    .db     -(-0x21 + 0x06), -(-0x1f + 0x12)
    .db     0x00, 0x00
    .db     -(-0x21 + 0x0e), -(-0x1f + 0x12)    ; PLAYER_ATTACK_TYPE_DOWN_HIGH + PLAYER_DIRECTION_LEFT
    .db     -(-0x21 + 0x0a), -(-0x1f + 0x12)
    .db     -(-0x21 + 0x06), -(-0x1f + 0x12)
    .db     0x00, 0x00

playerAttackPositionRight:

    .db     -0x01 + 0x13, -(-0x1f + 0x12)   ; PLAYER_ATTACK_TYPE_FRONT + PLAYER_DIRECTION_RIGHT
    .db     -0x01 + 0x17, -(-0x1f + 0x12)
    .db     -0x01 + 0x1b, -(-0x1f + 0x12)
    .db     0x00, 0x00
    .db     -0x07 + 0x11, -(-0x1f + 0x08)   ; PLAYER_ATTACK_TYPE_UP + PLAYER_DIRECTION_RIGHT
    .db     -0x07 + 0x11, -(-0x1f + 0x04)
    .db     -0x07 + 0x11, -(-0x1f + 0x00)
    .db     0x00, 0x00
    .db     -0x01 + 0x13, -(-0x1f + 0x12)   ; PLAYER_ATTACK_TYPE_DOWN_LOW + PLAYER_DIRECTION_RIGHT
    .db     -0x01 + 0x17, -(-0x1f + 0x12)
    .db     -0x01 + 0x1b, -(-0x1f + 0x12)
    .db     0x00, 0x00
    .db     -0x01 + 0x13, -(-0x1f + 0x12)   ; PLAYER_ATTACK_TYPE_DOWN_HIGH + PLAYER_DIRECTION_RIGHT
    .db     -0x01 + 0x17, -(-0x1f + 0x12)
    .db     -0x01 + 0x1b, -(-0x1f + 0x12)
    .db     0x00, 0x00

; シールド
;
playerShieldRectLeft:

    .db     -(-0x0b), -(-0x11), -(-0x09), -(-0x06)

playerShieldRectRight:

    .db     0x05, -(-0x11), 0x08, -(-0x06)

; スプライト
;
playerSpriteWalk:

    .db     -0x1f - 0x01, -0x11, 0x04, VDP_COLOR_WHITE  ; PLAYER_DIRECTION_LEFT
    .db     -0x1d - 0x01, -0x09, 0x3c, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x09, 0x40, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x09, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x08, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x09, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x40, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x10, VDP_COLOR_WHITE  ; PLAYER_DIRECTION_RIGHT
    .db     -0x1d - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x19, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x14, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x1c, VDP_COLOR_WHITE  ; PLAYER_DIRECTION_UP (+ PLAYER_DIRECTION_LEFT)
    .db     -0x1d - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x19, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x20, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x1c, VDP_COLOR_WHITE  ; PLAYER_DIRECTION_UP (+ PLAYER_DIRECTION_RIGHT)
    .db     -0x1d - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1d - 0x01, -0x19, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x20, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x44, VDP_COLOR_CYAN

playerSpriteJump:

    .db     -0x1f - 0x01, -0x11, 0x08, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x09, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x40, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x14, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x19, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x40, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x44, VDP_COLOR_CYAN

playerSpriteAttack:

    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_FRONT + PLAYER_DIRECTION_LEFT
    .db     -0x1f - 0x01, -0x19, 0x24, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x28, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x2c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x21, 0x24, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x21, 0x28, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x21, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_FRONT + PLAYER_DIRECTION_RIGHT
    .db     -0x1f - 0x01, -0x09, 0x30, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x34, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x38, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x01, 0x30, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x01, 0x34, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x01, 0x38, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_UP + PLAYER_DIRECTION_LEFT
    .db     -0x23 - 0x01, -0x1b, 0x3c, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x1b, 0x40, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x1b, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE
    .db     -0x23 - 0x01, -0x1b, 0x3c, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x1b, 0x40, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x1b, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_UP + PLAYER_DIRECTION_RIGHT
    .db     -0x23 - 0x01, -0x07, 0x3c, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x07, 0x40, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x07, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE
    .db     -0x23 - 0x01, -0x07, 0x3c, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x07, 0x40, VDP_COLOR_CYAN
    .db     -0x23 - 0x01, -0x07, 0x44, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_DOWN_LOW + PLAYER_DIRECTION_LEFT
    .db     -0x1f - 0x01, -0x19, 0x24, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x28, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x2c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x21, 0x24, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x21, 0x28, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x21, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_DOWN_LOW + PLAYER_DIRECTION_RIGHT
    .db     -0x1f - 0x01, -0x09, 0x30, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x34, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x38, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x01, 0x30, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x01, 0x34, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x01, 0x38, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_DOWN_HIGH + PLAYER_DIRECTION_LEFT
    .db     -0x1f - 0x01, -0x19, 0x24, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x28, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x19, 0x2c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x0c, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x21, 0x24, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x21, 0x28, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x21, 0x3c, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE  ; PLAYER_ATTACK_TYPE_DOWN_HIGH + PLAYER_DIRECTION_RIGHT
    .db     -0x1f - 0x01, -0x09, 0x30, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x34, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x09, 0x38, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x11, 0x18, VDP_COLOR_WHITE
    .db     -0x1f - 0x01, -0x01, 0x30, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x01, 0x34, VDP_COLOR_CYAN
    .db     -0x1f - 0x01, -0x01, 0x38, VDP_COLOR_CYAN


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH
