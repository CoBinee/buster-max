; Maze.inc : 迷路
;


; マクロの定義
;

; 大きさ
MAZE_SIZE_X                     =   0x10
MAZE_SIZE_X_MASK                =   0x0f
MAZE_SIZE_X_SHIFT               =   0x00
MAZE_SIZE_Y                     =   0x08
MAZE_SIZE_Y_MASK                =   0x70
MAZE_SIZE_Y_SHIFT               =   0x04

; フラグ
MAZE_FLAG_NULL                  =   0x00
MAZE_FLAG_WALL_UP_BIT           =   0x00
MAZE_FLAG_WALL_UP               =   (1 << MAZE_FLAG_WALL_UP_BIT)
MAZE_FLAG_WALL_DOWN_BIT         =   0x01
MAZE_FLAG_WALL_DOWN             =   (1 << MAZE_FLAG_WALL_DOWN_BIT)
MAZE_FLAG_WALL_LEFT_BIT         =   0x02
MAZE_FLAG_WALL_LEFT             =   (1 << MAZE_FLAG_WALL_LEFT_BIT)
MAZE_FLAG_WALL_RIGHT_BIT        =   0x03
MAZE_FLAG_WALL_RIGHT            =   (1 << MAZE_FLAG_WALL_RIGHT_BIT)
MAZE_FLAG_ROOM_BIT              =   0x04
MAZE_FLAG_ROOM                  =   (1 << MAZE_FLAG_ROOM_BIT)
MAZE_FLAG_BOSS_BIT              =   0x05
MAZE_FLAG_BOSS                  =   (1 << MAZE_FLAG_BOSS_BIT)
MAZE_FLAG_ITEM_BIT              =   0x06
MAZE_FLAG_ITEM                  =   (1 << MAZE_FLAG_ITEM_BIT)

; クラスタ
MAZE_CLUSTER_X                  =   0x08
MAZE_CLUSTER_X_MASK             =   0x07
MAZE_CLUSTER_X_SHIFT            =   0x00
MAZE_CLUSTER_Y                  =   0x08
MAZE_CLUSTER_Y_MASK             =   0x38
MAZE_CLUSTER_Y_SHIFT            =   0x03

; 部屋
MAZE_ROOM_SIZE                  =   0x20

; エリア

; セル
MAZE_CELL_X                     =   0x10
MAZE_CELL_Y                     =   0x0a
MAZE_CELL_PIXEL                 =   0x10
MAZE_CELL_NULL                  =   0x00
MAZE_CELL_IVY                   =   0x08
MAZE_CELL_IVY_0                 =   0x08
MAZE_CELL_IVY_1                 =   0x09
MAZE_CELL_WALL_BIT              =   0x04
MAZE_CELL_WALL                  =   0x10
MAZE_CELL_WALL_UPPER_0          =   0x10
MAZE_CELL_WALL_UPPER_1          =   0x11
MAZE_CELL_WALL_UPPER_2          =   0x12
MAZE_CELL_WALL_UPPER_3          =   0x13
MAZE_CELL_WALL_LOWER_0          =   0x14
MAZE_CELL_WALL_LOWER_1          =   0x15
MAZE_CELL_WALL_SIDE_0           =   0x16
MAZE_CELL_WALL_SIDE_1           =   0x17

; パターンネーム
MAZE_PATTERN_NAME_X             =   0x20
MAZE_PATTERN_NAME_Y             =   0x14

; 位置
MAZE_POSITION_START_X           =   0x80
MAZE_POSITION_START_Y           =   0x8f


; 外部関数宣言
;

    .globl  _MazeInitialize
    .globl  _MazeGetAreaStart
    .globl  _MazeGetAreaUp
    .globl  _MazeGetAreaDown
    .globl  _MazeGetAreaLeft
    .globl  _MazeGetAreaRight
    .globl  _MazeGetAreaFlag
    .globl  _MazeSetAreaFlag
    .globl  _MazeResetAreaFlag
    .globl  _MazeGetAreaOrder
    .globl  _MazeGetAreaRoomOrder
    .globl  _MazeBuildArea
    .globl  _MazePrintArea
    .globl  _MazePrintFlag
    .globl  _MazeGetCell
    .globl  _MazeIsCellWall
    .globl  _MazeIsCellIvy


; 外部変数宣言
;

