; Item.s : アイテム
;


; モジュール宣言
;
    .module Item

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Maze.inc"
    .include    "Room.inc"
    .include	"Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; アイテムを初期化する
;
_ItemInitialize::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; アイテムを更新する
;
_ItemUpdate::

    ; レジスタの保存

    ; アイテムの存在
    ld      a, (_item + ITEM_TYPE)
    or      a
    jr      z, 90$
    ld      a, (_game + GAME_AREA)
    call    _MazeGetAreaFlag
    bit     #MAZE_FLAG_BOSS_BIT, a
    jr      z, 90$

    ; 移動
    ld      hl, #(_item + ITEM_ANIMATION)
    ld      de, #(_item + ITEM_POSITION_Y)
    bit     #MAZE_FLAG_ITEM_BIT, a
    jr      nz, 10$
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
    ex      de, hl
    dec     (hl)
    jr      19$
10$:
    cp      #ITEM_ANIMATION_MOVE
    jr      nc, 11$
    inc     (hl)
    ex      de, hl
    dec     (hl)
    jr      19$
11$:
    xor     a
    ld      (_item + ITEM_TYPE), a
;   jr      19$
19$:

    ; 矩形の設定
    ld      a, (_item + ITEM_POSITION_X)
    sub     #(ITEM_SIZE_X / 0x02)
    ld      (_item + ITEM_RECT_LEFT), a
    add     #(ITEM_SIZE_X - 0x01)
    ld      (_item + ITEM_RECT_RIGHT), a
    ld      a, (_item + ITEM_POSITION_Y)
    sub     #(ITEM_SIZE_Y / 0x02)
    ld      (_item + ITEM_RECT_TOP), a
    add     #(ITEM_SIZE_Y - 0x01)
    ld      (_item + ITEM_RECT_BOTTOM), a

    ; 更新の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; アイテムを描画する
;
_ItemRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_item + ITEM_TYPE)
    or      a
    jr      z, 10$
    ld      e, a
    ld      a, (_game + GAME_AREA)
    call    _MazeGetAreaFlag
    bit     #MAZE_FLAG_BOSS_BIT, a
    jr      z, 10$
    ld      a, (_item + ITEM_ANIMATION)
    and     #0x01
    jr      nz, 10$
    ld      a, e
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #itemSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_ITEM)
    ld      a, (_item + ITEM_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_item + ITEM_POSITION_X)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
10$:

    ; レジスタの復帰

    ; 終了
    ret

; アイテムを配置する
;
_ItemEntry::

    ; レジスタの保存

    ; アイテムの初期化
    ld      hl, #itemDefault
    ld      de, #_item
    ld      bc, #ITEM_LENGTH
    ldir

    ; アイテムの取得
    ld      a, (_game + GAME_AREA)
    call    _MazeGetAreaFlag
    bit     #MAZE_FLAG_ITEM_BIT, a
    jr      nz, 10$
    ld      hl, (_game + GAME_ROOM_L)
    ld      de, #ROOM_ITEM
    add     hl, de
    ld      a, (hl)
    ld      (_item + ITEM_TYPE), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; アイテムの初期値
;
itemDefault:

    .db     ITEM_TYPE_NULL
    .db     0x80 ; ITEM_POSITION_NULL
    .db     0x60 ; ITEM_POSITION_NULL
    .db     ITEM_ANIMATION_MOVE
    .db     ITEM_RECT_NULL
    .db     ITEM_RECT_NULL
    .db     ITEM_RECT_NULL
    .db     ITEM_RECT_NULL

; スプライト
;
itemSprite:

    .db     -0x10, -0x10, 0x00, VDP_COLOR_TRANSPARENT
    .db     -0x10, -0x10, 0x50, VDP_COLOR_CYAN
    .db     -0x10, -0x10, 0x54, VDP_COLOR_CYAN
    .db     -0x10, -0x10, 0x58, VDP_COLOR_LIGHT_YELLOW
    .db     -0x10, -0x10, 0x5c, VDP_COLOR_LIGHT_RED
    .db     -0x10, -0x10, 0x60, VDP_COLOR_LIGHT_YELLOW
    .db     -0x10, -0x10, 0x64, VDP_COLOR_LIGHT_GREEN
    .db     -0x10, -0x10, 0x68, VDP_COLOR_LIGHT_BLUE


; DATA 領域
;
    .area   _DATA

; アイテム
;
_item::

    .ds     ITEM_LENGTH

