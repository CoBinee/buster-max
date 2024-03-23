; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_DIRECTION                =   0x04
PLAYER_SPEED_X                  =   0x05
PLAYER_SPEED_Y                  =   0x06
PLAYER_ANIMATION                =   0x07
PLAYER_LIFE                     =   0x08
PLAYER_ATTACK_TYPE              =   0x09
PLAYER_ATTACK_FRAME             =   0x0a
PLAYER_ATTACK_POSITION_1_X      =   0x0b
PLAYER_ATTACK_POSITION_1_Y      =   0x0c
PLAYER_ATTACK_POSITION_2_X      =   0x0d
PLAYER_ATTACK_POSITION_2_Y      =   0x0e
PLAYER_ATTACK_POSITION_3_X      =   0x0f
PLAYER_ATTACK_POSITION_3_Y      =   0x10
PLAYER_DAMAGE_POINT             =   0x11
PLAYER_DAMAGE_FRAME             =   0x12
PLAYER_DAMAGE_SPEED             =   0x13
PLAYER_DAMAGE_RECT_LEFT         =   0x14
PLAYER_DAMAGE_RECT_TOP          =   0x15
PLAYER_DAMAGE_RECT_RIGHT        =   0x16
PLAYER_DAMAGE_RECT_BOTTOM       =   0x17
PLAYER_SHIELD_POINT             =   0x18
PLAYER_SHIELD_FRAME             =   0x19
PLAYER_SHIELD_RECT_LEFT         =   0x1a
PLAYER_SHIELD_RECT_TOP          =   0x1b
PLAYER_SHIELD_RECT_RIGHT        =   0x1c
PLAYER_SHIELD_RECT_BOTTOM       =   0x1d
PLAYER_CENTER_X                 =   0x1e
PLAYER_CENTER_Y                 =   0x1f
PLAYER_ITEM                     =   0x20
PLAYER_ITEM_NULL                =   0x20
PLAYER_ITEM_POTION              =   0x21
PLAYER_ITEM_SWORD               =   0x22
PLAYER_ITEM_KEY                 =   0x23
PLAYER_ITEM_ROD                 =   0x24
PLAYER_ITEM_CROWN               =   0x25
PLAYER_ITEM_RING                =   0x26
PLAYER_ITEM_NECKLACE            =   0x27
PLAYER_SPRITE_PERSON_L          =   0x28
PLAYER_SPRITE_PERSON_H          =   0x29
PLAYER_SPRITE_SWORD_L           =   0x2a
PLAYER_SPRITE_SWORD_H           =   0x2b
PLAYER_LENGTH                   =   0x30

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10
PLAYER_STATE_DEAD               =   0x20
PLAYER_STATE_CLEAR              =   0x30

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_LAND_BIT            =   0x00
PLAYER_FLAG_LAND                =   (1 << PLAYER_FLAG_LAND_BIT)
PLAYER_FLAG_HOLD_BIT            =   0x01
PLAYER_FLAG_HOLD                =   (1 << PLAYER_FLAG_HOLD_BIT)
PLAYER_FLAG_JUMP_BIT            =   0x02
PLAYER_FLAG_JUMP                =   (1 << PLAYER_FLAG_JUMP_BIT)

; 向き
PLAYER_DIRECTION_LR_BIT         =   0x00
PLAYER_DIRECTION_LR_LEFT        =   0x00
PLAYER_DIRECTION_LR_RIGHT       =   0x01
PLAYER_DIRECTION_UP_BIT         =   0x01
PLAYER_DIRECTION_UP             =   (1 << PLAYER_DIRECTION_UP_BIT)

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_X_MAXIMUM          =   0x30
PLAYER_SPEED_X_START            =   0x10
PLAYER_SPEED_X_ACCEL            =   0x04
PLAYER_SPEED_X_BRAKE            =   0x04
PLAYER_SPEED_X_HOLD             =   0x20
PLAYER_SPEED_X_DAMAGE           =   0x40
PLAYER_SPEED_X_SHIELD           =   0x30
PLAYER_SPEED_Y_MAXIMUM          =   ( 0x58 >> 3)
PLAYER_SPEED_Y_JUMP             =   (-0x60 >> 3)
PLAYER_SPEED_Y_GRAVITY          =   ( 0x08 >> 3)
PLAYER_SPEED_Y_HOLD             =   ( 0x20 >> 3)
PLAYER_SPEED_Y_ATTACK_UP        =   (PLAYER_SPEED_Y_JUMP - PLAYER_SPEED_Y_GRAVITY)
PLAYER_SPEED_Y_ATTACK_DOWN      =   ( 0x80 >> 3)

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00
PLAYER_ANIMATION_STAY           =   (0x00 + 0x07)
PLAYER_ANIMATION_ACTION         =   (0x08 + 0x07)

; ライフ
PLAYER_LIFE_NULL                =   0x00
PLAYER_LIFE_MAXIMUM             =   0x30

; 攻撃
PLAYER_ATTACK_TYPE_NULL         =   0x00
PLAYER_ATTACK_TYPE_FRONT        =   0x01
PLAYER_ATTACK_TYPE_UP           =   0x02
PLAYER_ATTACK_TYPE_DOWN_LOW     =   0x03
PLAYER_ATTACK_TYPE_DOWN_HIGH    =   0x04
PLAYER_ATTACK_FRAME_NULL        =   0x00
PLAYER_ATTACK_FRAME_SWING       =   0x07
PLAYER_ATTACK_FRAME_CLOSE       =   0x03
PLAYER_ATTACK_POSITION_NULL     =   0x00
PLAYER_ATTACK_POSITION_SIZE     =   0x03

; ダメージ
PLAYER_DAMAGE_POINT_NULL        =   0x00
PLAYER_DAMAGE_FRAME_NULL        =   0x00
PLAYER_DAMAGE_FRAME_BLINK       =   (PLAYER_SPEED_X_DAMAGE / PLAYER_SPEED_X_BRAKE)
PLAYER_DAMAGE_FRAME_DEAD        =   0x60
PLAYER_DAMAGE_FRAME_CLEAR       =   0x60
PLAYER_DAMAGE_SPEED_NULL        =   0x00
PLAYER_DAMAGE_RECT_NULL         =   0x00

; シールド
PLAYER_SHIELD_POINT_NULL        =   0x00
PLAYER_SHIELD_FRAME_NULL        =   0x00
PLAYER_SHIELD_FRAME_BLINK       =   (PLAYER_SPEED_X_SHIELD / PLAYER_SPEED_X_BRAKE)
PLAYER_SHIELD_RECT_NULL         =   0x00

; 中心
PLAYER_CENTER_NULL              =   0x00

; アイテム
PLAYER_ITEM_NULL                =   0x00

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; 大きさ
PLAYER_SIZE_PERSON_X            =   0x0c
PLAYER_SIZE_PERSON_Y            =   0x18

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerMoveAreaUp
    .globl  _PlayerMoveAreaDown
    .globl  _PlayerMoveAreaLeft
    .globl  _PlayerMoveAreaRight
    .globl  _PlayerPickupItem
    .globl  _PlayerUseItem
    .globl  _PlayerIsItem
    .globl  _PlayerIsItemRequire

; 外部変数宣言
;

    .globl  _player

