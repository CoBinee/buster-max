; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_X                =   0x03
ENEMY_POSITION_Y                =   0x04
ENEMY_DIRECTION                 =   0x05
ENEMY_SPEED_X                   =   0x06
ENEMY_SPEED_Y                   =   0x07
ENEMY_ANIMATION                 =   0x08
ENEMY_LIFE                      =   0x09
ENEMY_ATTACK_POINT              =   0x0a
ENEMY_ATTACK_FRAME              =   0x0b
ENEMY_DAMAGE_POINT              =   0x0c
ENEMY_DAMAGE_FRAME              =   0x0d
ENEMY_RECT_LEFT                 =   0x0e
ENEMY_RECT_TOP                  =   0x0f
ENEMY_RECT_RIGHT                =   0x10
ENEMY_RECT_BOTTOM               =   0x11
ENEMY_SPRITE_L                  =   0x12
ENEMY_SPRITE_H                  =   0x13
ENEMY_PARAM_0                   =   0x14
ENEMY_PARAM_1                   =   0x15
ENEMY_PARAM_2                   =   0x16
ENEMY_PARAM_3                   =   0x17
ENEMY_PARAM_4                   =   0x18
ENEMY_PARAM_5                   =   0x19
ENEMY_PARAM_6                   =   0x1a
ENEMY_PARAM_7                   =   0x1b
ENEMY_LENGTH                    =   0x1c
ENEMY_ENTRY                     =   0x0c

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_REAPER               =   0x01
ENEMY_TYPE_GREMLIN              =   0x02
ENEMY_TYPE_GAZER                =   0x03
ENEMY_TYPE_BAT                  =   0x04
ENEMY_TYPE_MAGE                 =   0x05
ENEMY_TYPE_CYCLOPS              =   0x06
ENEMY_TYPE_HYDRA                =   0x07
ENEMY_TYPE_DAEMON               =   0x08
ENEMY_TYPE_DRAGON_GREEN         =   0x09
ENEMY_TYPE_DRAGON_BLUE          =   0x0a
ENEMY_TYPE_DRAGON_RED           =   0x0b
ENEMY_TYPE_DRAGON_YELLOW        =   0x0c
ENEMY_TYPE_BOX                  =   0x0d
ENEMY_TYPE_CRYSTAL              =   0x0e
ENEMY_TYPE_IDOL                 =   0x0f
ENEMY_TYPE_GATE                 =   0x10
ENEMY_TYPE_BALL_STRAIGHT        =   0x11
ENEMY_TYPE_BALL_PARABOLA        =   0x12
ENEMY_TYPE_BALL_BOUND           =   0x13

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_COLLISION_X_BIT      =   0x00
ENEMY_FLAG_COLLISION_X          =   (1 << ENEMY_FLAG_COLLISION_X_BIT)
ENEMY_FLAG_COLLISION_Y_BIT      =   0x01
ENEMY_FLAG_COLLISION_Y          =   (1 << ENEMY_FLAG_COLLISION_Y_BIT)
ENEMY_FLAG_RECT_BIT             =   0x02
ENEMY_FLAG_RECT                 =   (1 << ENEMY_FLAG_RECT_BIT)
ENEMY_FLAG_DAMAGE_BACK_BIT      =   0x03
ENEMY_FLAG_DAMAGE_BACK          =   (1 << ENEMY_FLAG_DAMAGE_BACK_BIT)
ENEMY_FLAG_FLYER_BIT            =   0x04
ENEMY_FLAG_FLYER                =   (1 << ENEMY_FLAG_FLYER_BIT)
ENEMY_FLAG_BOSS_BIT             =   0x05
ENEMY_FLAG_BOSS                 =   (1 << ENEMY_FLAG_BOSS_BIT)
ENEMY_FLAG_ARM_BIT              =   0x06
ENEMY_FLAG_ARM                  =   (1 << ENEMY_FLAG_ARM_BIT)
ENEMY_FLAG_2x2_BIT              =   0x07
ENEMY_FLAG_2x2                  =   (1 << ENEMY_FLAG_2x2_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 向き
ENEMY_DIRECTION_L               =   0x00
ENEMY_DIRECTION_R               =   0x01

; 速度
ENEMY_SPEED_NULL                =   0x00
ENEMY_SPEED_X_DAMAGE            =   0x40

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; ライフ
ENEMY_LIFE_NULL                 =   0x00

; 攻撃
ENEMY_ATTACK_POINT_NULL         =   0x00
ENEMY_ATTACK_FRAME_NULL         =   0x00

; ダメージ
ENEMY_DAMAGE_POINT_NULL         =   0x00
ENEMY_DAMAGE_FRAME_NULL         =   0x00
ENEMY_DAMAGE_FRAME_BLINK        =   0x10
ENEMY_DAMAGE_FRAME_DEAD         =   0x20

; 矩形
ENEMY_RECT_NULL                 =   0x00

; スプライト
ENEMY_SPRITE_NULL               =   0x00
ENEMY_SPRITE_LENGTH             =   (0x10 * 0x04)

; パラメータ
ENEMY_PARAM_NULL                =   0x00

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyEntry
    .globl  _EnemyEntryOne
    .globl  _EnemyFind
    .globl  _EnemyFindBoss
    .globl  _EnemyAccelX
    .globl  _EnemyAccelY
    .globl  _EnemyMove
    .globl  _EnemyGetApproachX
    .globl  _EnemyGetApproachY
    .globl  _EnemyGetApproachDirection
    .globl  _EnemyDamage
    .globl  _EnemyFallDown
    .globl  _EnemyIsLand
    .globl  _EnemySetRoomPositionX
    .globl  _EnemySetRect
    .globl  _EnemySetSpriteSimple
    .globl  _EnemySetSpriteDirection2x2
    .globl  _EnemyFireBallStraight
    .globl  _EnemyFireBallStraights
    .globl  _EnemyFireBallParabola
    .globl  _EnemyFireBallBound

; 外部変数宣言
;

    .globl  _enemy

