; EnemyOne.inc : 種類別のエネミー
;


; マクロの定義
;

; なし

; リーパー
ENEMY_REAPER_SPEED_X_MAXIMUM        =   0x10
ENEMY_REAPER_SPEED_X_ACCEL          =   0x00
ENEMY_REAPER_SPEED_Y_MAXIMUM        =   0x58
ENEMY_REAPER_SPEED_Y_GRAVITY        =   0x08
ENEMY_REAPER_RECT_LEFT              =   0x09
ENEMY_REAPER_RECT_TOP               =   0x15
ENEMY_REAPER_RECT_RIGHT             =   0x08
ENEMY_REAPER_RECT_BOTTOM            =   0x00

; グレムリン
ENEMY_GREMLIN_SPEED_X_MAXIMUM       =   0x10
ENEMY_GREMLIN_SPEED_X_ACCEL         =   0x00
ENEMY_GREMLIN_SPEED_Y_MAXIMUM       =   0x58
ENEMY_GREMLIN_SPEED_Y_GRAVITY       =   0x08
ENEMY_GREMLIN_SPEED_Y_JUMP          =   -0x50
ENEMY_GREMLIN_RECT_LEFT             =   0x08
ENEMY_GREMLIN_RECT_TOP              =   0x17
ENEMY_GREMLIN_RECT_RIGHT            =   0x07
ENEMY_GREMLIN_RECT_BOTTOM           =   0x00

; ゲイザー
ENEMY_GAZER_SPEED_X_MAXIMUM         =   0x10
ENEMY_GAZER_SPEED_X_ACCEL           =   0x00
ENEMY_GAZER_SPEED_Y_MAXIMUM         =   0x10
ENEMY_GAZER_SPEED_Y_GRAVITY         =   0x00
ENEMY_GAZER_RECT_LEFT               =   0x08
ENEMY_GAZER_RECT_TOP                =   0x06
ENEMY_GAZER_RECT_RIGHT              =   0x07
ENEMY_GAZER_RECT_BOTTOM             =   0x05

; バット
ENEMY_BAT_POSITION_Y                =   0x40
ENEMY_BAT_SPEED_X_MAXIMUM           =   0x10
ENEMY_BAT_SPEED_X_ACCEL             =   0x00
ENEMY_BAT_SPEED_Y_MAXIMUM           =   0x58
ENEMY_BAT_SPEED_Y_GRAVITY           =   0x00
ENEMY_BAT_SPEED_Y_CURVE_MAXIMUM     =   0x20
ENEMY_BAT_SPEED_Y_CURVE_ACCEL       =   0x04
ENEMY_BAT_SPEED_Y_DROP_MAXIMUM      =   0x58
ENEMY_BAT_SPEED_Y_DROP_BRAKE        =   0x03
ENEMY_BAT_RECT_LEFT                 =   0x08
ENEMY_BAT_RECT_TOP                  =   0x06
ENEMY_BAT_RECT_RIGHT                =   0x07
ENEMY_BAT_RECT_BOTTOM               =   0x05

; メイジ
ENEMY_MAGE_SPEED_X_MAXIMUM          =   0x00
ENEMY_MAGE_SPEED_X_ACCEL            =   0x00
ENEMY_MAGE_SPEED_Y_MAXIMUM          =   0x00
ENEMY_MAGE_SPEED_Y_GRAVITY          =   0x00
ENEMY_MAGE_RECT_LEFT                =   0x07
ENEMY_MAGE_RECT_TOP                 =   0x17
ENEMY_MAGE_RECT_RIGHT               =   0x06
ENEMY_MAGE_RECT_BOTTOM              =   0x00
ENEMY_MAGE_BLINK_FRAME              =   0x10
ENEMY_MAGE_ANIMATION_STAY           =   0x00
ENEMY_MAGE_ANIMATION_FIRE           =   0x08

; サイクロプス
ENEMY_CYCLOPS_SPEED_X_MAXIMUM       =   0x10
ENEMY_CYCLOPS_SPEED_X_ACCEL         =   0x00
ENEMY_CYCLOPS_SPEED_Y_MAXIMUM       =   0x58
ENEMY_CYCLOPS_SPEED_Y_GRAVITY       =   0x04
ENEMY_CYCLOPS_SPEED_Y_JUMP          =   -0x30
ENEMY_CYCLOPS_RECT_LEFT             =   0x09
ENEMY_CYCLOPS_RECT_TOP              =   0x1d
ENEMY_CYCLOPS_RECT_RIGHT            =   0x08
ENEMY_CYCLOPS_RECT_BOTTOM           =   0x00
ENEMY_CYCLOPS_FIRE_SPEED_X          =   0x10
ENEMY_CYCLOPS_FIRE_SPEED_Y          =   0x30
ENEMY_CYCLOPS_FIRE_GRAVITY          =   0x04
ENEMY_CYCLOPS_FIRE_MAXIMUM          =   0x58

; ヒドラ
ENEMY_HYDRA_SPEED_X_MAXIMUM         =   0x10
ENEMY_HYDRA_SPEED_X_ACCEL           =   0x00
ENEMY_HYDRA_SPEED_Y_MAXIMUM         =   0x58
ENEMY_HYDRA_SPEED_Y_GRAVITY         =   0x08
ENEMY_HYDRA_RECT_LEFT               =   0x0e
ENEMY_HYDRA_RECT_TOP                =   0x1f
ENEMY_HYDRA_RECT_RIGHT              =   0x0d
ENEMY_HYDRA_RECT_BOTTOM             =   0x00
ENEMY_HYDRA_FIRE_SPEED_X            =   0x20
ENEMY_HYDRA_FIRE_SPEED_Y            =   0x00
ENEMY_HYDRA_FIRE_SPEED_Y_GRAVITY    =   0x04
ENEMY_HYDRA_FIRE_SPEED_Y_MAXIMUM    =   0x58

; デーモン
ENEMY_DAEMON_POSITION_Y             =   0x40
ENEMY_DAEMON_SPEED_X_MAXIMUM        =   0x10
ENEMY_DAEMON_SPEED_X_ACCEL          =   0x00
ENEMY_DAEMON_SPEED_X_CURVE_MAXIMUM  =   0x10
ENEMY_DAEMON_SPEED_X_DROP_MAXIMUM   =   0x30
ENEMY_DAEMON_SPEED_Y_MAXIMUM        =   0x58
ENEMY_DAEMON_SPEED_Y_GRAVITY        =   0x00
ENEMY_DAEMON_SPEED_Y_CURVE_MAXIMUM  =   0x20
ENEMY_DAEMON_SPEED_Y_CURVE_ACCEL    =   0x04
ENEMY_DAEMON_SPEED_Y_DROP_MAXIMUM   =   0x58
ENEMY_DAEMON_SPEED_Y_DROP_BRAKE     =   0x03
ENEMY_DAEMON_RECT_LEFT              =   0x10
ENEMY_DAEMON_RECT_TOP               =   0x10
ENEMY_DAEMON_RECT_RIGHT             =   0x0f
ENEMY_DAEMON_RECT_BOTTOM            =   0x0f
ENEMY_DAEMON_FIRE_FRAME             =   0x18
ENEMY_DAEMON_FIRE_SPEED             =   0x02
ENEMY_DAEMON_ANIMATION_FIRE         =   0x08

; ドラゴン
ENEMY_DRAGON_POSITION_LEFT          =   0x40
ENEMY_DRAGON_POSITION_RIGHT         =   0xc0
ENEMY_DRAGON_POSITION_TOP           =   0x30
ENEMY_DRAGON_POSITION_BOTTOM        =   0x70
ENEMY_DRAGON_SPEED_X_MAXIMUM        =   0x10
ENEMY_DRAGON_SPEED_X_ACCEL          =   0x00
ENEMY_DRAGON_SPEED_X_FLAP           =   0x20
ENEMY_DRAGON_SPEED_X_DROP           =   0x30
ENEMY_DRAGON_SPEED_X_BRAKE          =   0x01
ENEMY_DRAGON_SPEED_Y_MAXIMUM        =   0x58
ENEMY_DRAGON_SPEED_Y_GRAVITY        =   0x00
ENEMY_DRAGON_SPEED_Y_FLAP           =   0x20
ENEMY_DRAGON_SPEED_Y_DROP           =   0x38
ENEMY_DRAGON_SPEED_Y_BRAKE          =   0x01
ENEMY_DRAGON_RECT_LEFT              =   0x14
ENEMY_DRAGON_RECT_TOP               =   0x14
ENEMY_DRAGON_RECT_RIGHT             =   0x13
ENEMY_DRAGON_RECT_BOTTOM            =   0x0f
ENEMY_DRAGON_RANGE_X                =   0x38
ENEMY_DRAGON_RANGE_Y                =   0x38
ENEMY_DRAGON_FIRE_FRAME             =   0x10
ENEMY_DRAGON_FIRE_SPEED             =   0x02
ENEMY_DRAGON_ANIMATION_FIRE         =   0x10

; ボックス
ENEMY_BOX_POSITION_X                =   0x80
ENEMY_BOX_POSITION_Y                =   0x8f
ENEMY_BOX_SPEED_X_MAXIMUM           =   0x00
ENEMY_BOX_SPEED_X_ACCEL             =   0x00
ENEMY_BOX_SPEED_Y_MAXIMUM           =   0x00
ENEMY_BOX_SPEED_Y_GRAVITY           =   0x00
ENEMY_BOX_RECT_LEFT                 =   0x0c
ENEMY_BOX_RECT_TOP                  =   0x13
ENEMY_BOX_RECT_RIGHT                =   0x0b
ENEMY_BOX_RECT_BOTTOM               =   0x00
ENEMY_BOX_ANIMATION_CLOSE           =   0x00
ENEMY_BOX_ANIMATION_OPEN            =   0x08

; クリスタル
ENEMY_CRYSTAL_POSITION_X            =   0x80
ENEMY_CRYSTAL_POSITION_Y            =   0x50
ENEMY_CRYSTAL_POSITION_TOP          =   0x48
ENEMY_CRYSTAL_POSITION_BOTTOM       =   0x58
ENEMY_CRYSTAL_SPEED_X_MAXIMUM       =   0x00
ENEMY_CRYSTAL_SPEED_X_ACCEL         =   0x00
ENEMY_CRYSTAL_SPEED_Y_MAXIMUM       =   0x00
ENEMY_CRYSTAL_SPEED_Y_GRAVITY       =   0x00
ENEMY_CRYSTAL_SPEED_Y_CURVE_MAXIMUM =   0x10
ENEMY_CRYSTAL_RECT_LEFT             =   0x0d
ENEMY_CRYSTAL_RECT_TOP              =   0x10
ENEMY_CRYSTAL_RECT_RIGHT            =   0x0c
ENEMY_CRYSTAL_RECT_BOTTOM           =   0x0f
ENEMY_CRYSTAL_FIRE_SPEED            =   0x02

; アイドル
ENEMY_IDOL_POSITION_X               =   0x80
ENEMY_IDOL_POSITION_Y               =   0x50
ENEMY_IDOL_POSITION_TOP             =   0x48
ENEMY_IDOL_POSITION_BOTTOM          =   0x84
ENEMY_IDOL_SPEED_X_MAXIMUM          =   0x00
ENEMY_IDOL_SPEED_X_ACCEL            =   0x00
ENEMY_IDOL_SPEED_Y_MAXIMUM          =   0x00
ENEMY_IDOL_SPEED_Y_GRAVITY          =   0x00
ENEMY_IDOL_SPEED_Y_CURVE_MAXIMUM    =   0x10
ENEMY_IDOL_RECT_LEFT                =   0x05
ENEMY_IDOL_RECT_TOP                 =   0x0e
ENEMY_IDOL_RECT_RIGHT               =   0x04
ENEMY_IDOL_RECT_BOTTOM              =   0x0b
ENEMY_IDOL_ANIMATION_STAY           =   0x00
ENEMY_IDOL_ANIMATION_OPEN           =   0x08

; ゲート
ENEMY_GATE_POSITION_X               =   0x80
ENEMY_GATE_POSITION_Y               =   0x50
ENEMY_GATE_SPEED_X_MAXIMUM          =   0x00
ENEMY_GATE_SPEED_X_ACCEL            =   0x00
ENEMY_GATE_SPEED_Y_MAXIMUM          =   0x00
ENEMY_GATE_SPEED_Y_GRAVITY          =   0x00
ENEMY_GATE_RECT_LEFT                =   0x08
ENEMY_GATE_RECT_TOP                 =   0x08
ENEMY_GATE_RECT_RIGHT               =   0x07
ENEMY_GATE_RECT_BOTTOM              =   0x07

; ボール
ENEMY_BALL_SPEED_X_MAXIMUM          =   0x00
ENEMY_BALL_SPEED_X_ACCEL            =   0x00
ENEMY_BALL_SPEED_Y_MAXIMUM          =   0x00
ENEMY_BALL_SPEED_Y_GRAVITY          =   0x00
ENEMY_BALL_RECT_LEFT                =   0x07
ENEMY_BALL_RECT_TOP                 =   0x07
ENEMY_BALL_RECT_RIGHT               =   0x06
ENEMY_BALL_RECT_BOTTOM              =   0x06
ENEMY_BALL_STAY_FRAME               =   0x08

; 外部関数宣言
;

    .globl  _EnemyNull
    .globl  _EnemyReaper
    .globl  _EnemyGremlin
    .globl  _EnemyGazer
    .globl  _EnemyBat
    .globl  _EnemyMage
    .globl  _EnemyCyclops
    .globl  _EnemyHydra
    .globl  _EnemyDaemon
    .globl  _EnemyDragonGreen
    .globl  _EnemyDragonBlue
    .globl  _EnemyDragonRed
    .globl  _EnemyDragonYellow
    .globl  _EnemyBox
    .globl  _EnemyCrystal
    .globl  _EnemyIdol
    .globl  _EnemyGate
    .globl  _EnemyBall

; 外部変数宣言
;

    .globl  _enemyNullDefault
    .globl  _enemyReaperDefault
    .globl  _enemyGremlinDefault
    .globl  _enemyGazerDefault
    .globl  _enemyBatDefault
    .globl  _enemyMageDefault
    .globl  _enemyCyclopsDefault
    .globl  _enemyHydraDefault
    .globl  _enemyDaemonDefault
    .globl  _enemyDragonGreenDefault
    .globl  _enemyDragonBlueDefault
    .globl  _enemyDragonRedDefault
    .globl  _enemyDragonYellowDefault
    .globl  _enemyBoxDefault
    .globl  _enemyCrystalDefault
    .globl  _enemyIdolDefault
    .globl  _enemyGateDefault
    .globl  _enemyBallStraightDefault
    .globl  _enemyBallParabolaDefault
    .globl  _enemyBallBoundDefault
