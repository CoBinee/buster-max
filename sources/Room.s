; Room.s : 部屋
;


; モジュール宣言
;
    .module Room

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Maze.inc"
    .include	"Room.inc"
    .include	"Enemy.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 部屋を取得する
;
_RoomGet::

    ; レジスタの保存
    push    de

    ; a  < area
    ; hl > room

    ; 部屋の取得
    call    _MazeGetAreaRoomOrder
    cp      #MAZE_ROOM_SIZE
    ld      hl, #0x0000
    jr      nc, 10$
    add     a, a
    add     a, a
    add     a, a
    ld      l, a
    ld      de, #room
    add     hl, de
10$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 定数の定義
;

; 部屋
room:

    ; No.00
    .db     ENEMY_TYPE_IDOL, ENEMY_TYPE_CRYSTAL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.01
    .db     ENEMY_TYPE_BOX, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_RING
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.02
    .db     ENEMY_TYPE_MAGE, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.03
    .db     ENEMY_TYPE_CYCLOPS, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.04
    .db     ENEMY_TYPE_HYDRA, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.05
    .db     ENEMY_TYPE_DAEMON, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.06
    .db     ENEMY_TYPE_DRAGON_GREEN, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_KEY
    .db     (APP_COLOR_TABLE_GAME_GREEN) >> 6
    .db     0x00, 0x00

    ; No.07
    .db     ENEMY_TYPE_BOX, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NECKLACE
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.08
    .db     ENEMY_TYPE_BAT, ENEMY_TYPE_CYCLOPS, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.09
    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_HYDRA, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.10
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_DRAGON_GREEN, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_GREEN) >> 6
    .db     0x00, 0x00

    ; No.11
    .db     ENEMY_TYPE_GREMLIN, ENEMY_TYPE_DAEMON, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.12
    .db     ENEMY_TYPE_BAT, ENEMY_TYPE_MAGE, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.13
    .db     ENEMY_TYPE_DRAGON_BLUE, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_KEY
    .db     (APP_COLOR_TABLE_GAME_BLUE) >> 6
    .db     0x00, 0x00

    ; No.14
    .db     ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.15
    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_BAT, ENEMY_TYPE_HYDRA, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.16
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_GREMLIN, ENEMY_TYPE_DAEMON, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.17
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_BAT, ENEMY_TYPE_DRAGON_GREEN, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_GREEN) >> 6
    .db     0x00, 0x00

    ; No.18
    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_BAT, ENEMY_TYPE_MAGE, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.19
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_DRAGON_BLUE, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_BLUE) >> 6
    .db     0x00, 0x00

    ; No.20
    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_BAT, ENEMY_TYPE_CYCLOPS, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.21
    .db     ENEMY_TYPE_DRAGON_RED, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_KEY
    .db     (APP_COLOR_TABLE_GAME_RED) >> 6
    .db     0x00, 0x00

    ; No.22
    .db     ENEMY_TYPE_BOX, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_ROD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.23
    .db     ENEMY_TYPE_GREMLIN, ENEMY_TYPE_GAZER, ENEMY_TYPE_DAEMON, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.24
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_GREMLIN, ENEMY_TYPE_DRAGON_BLUE, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_BLUE) >> 6
    .db     0x00, 0x00

    ; No.25
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_BAT, ENEMY_TYPE_MAGE, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.26
    .db     ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.27
    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_BAT, ENEMY_TYPE_CYCLOPS, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_SWORD
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.28
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_GREMLIN, ENEMY_TYPE_DRAGON_RED, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_NULL
    .db     (APP_COLOR_TABLE_GAME_RED) >> 6
    .db     0x00, 0x00

    ; No.29
    .db     ENEMY_TYPE_GAZER, ENEMY_TYPE_BAT, ENEMY_TYPE_HYDRA, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_POTION
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.30
    .db     ENEMY_TYPE_DRAGON_YELLOW, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_KEY
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00

    ; No.31
    .db     ENEMY_TYPE_BOX, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ITEM_TYPE_CROWN
    .db     (APP_COLOR_TABLE_GAME_NORMAL) >> 6
    .db     0x00, 0x00


; DATA 領域
;
    .area   _DATA

