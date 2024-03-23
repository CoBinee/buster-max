; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_ENTER                =   0x20
GAME_STATE_PLAY                 =   0x30
GAME_STATE_MAP                  =   0x40
GAME_STATE_OVER                 =   0x50
GAME_STATE_CLEAR                =   0x60

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER_PERSON       =   0x00
GAME_SPRITE_PLAYER_SWORD_0      =   0x04
GAME_SPRITE_ENEMY               =   0x08
GAME_SPRITE_PLAYER_SWORD_1      =   0x48
GAME_SPRITE_ITEM                =   0x4c
GAME_SPRITE_MAP                 =   0x00

; ゲーム
GAME_REQUEST                    =   0x00
GAME_AREA                       =   0x01
GAME_ROOM_L                     =   0x02
GAME_ROOM_H                     =   0x03
GAME_TIMER                      =   0x04
GAME_FRAME                      =   0x05
GAME_SIZE                       =   0x06

; リクエスト
GAME_REQUEST_NULL               =   0x00
GAME_REQUEST_AREA_UP_BIT        =   0x00
GAME_REQUEST_AREA_UP            =   (1 << GAME_REQUEST_AREA_UP_BIT)
GAME_REQUEST_AREA_DOWN_BIT      =   0x01
GAME_REQUEST_AREA_DOWN          =   (1 << GAME_REQUEST_AREA_DOWN_BIT)
GAME_REQUEST_AREA_LEFT_BIT      =   0x02
GAME_REQUEST_AREA_LEFT          =   (1 << GAME_REQUEST_AREA_LEFT_BIT)
GAME_REQUEST_AREA_RIGHT_BIT     =   0x03
GAME_REQUEST_AREA_RIGHT         =   (1 << GAME_REQUEST_AREA_RIGHT_BIT)
GAME_REQUEST_BGM_PATH_BIT       =   0x04
GAME_REQUEST_BGM_PATH           =   (1 << GAME_REQUEST_BGM_PATH_BIT)
GAME_REQUEST_GAME_OVER_BIT      =   0x06
GAME_REQUEST_GAME_OVER          =   (1 << GAME_REQUEST_GAME_OVER_BIT)
GAME_REQUEST_GAME_CLEAR_BIT     =   0x07
GAME_REQUEST_GAME_CLEAR         =   (1 << GAME_REQUEST_GAME_CLEAR_BIT)

; エリア
GAME_AREA_NULL                  =   0x00

; タイマ
GAME_TIMER_NULL                 =   0x00

; フレーム
GAME_FRAME_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _game
