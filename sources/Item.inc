; Item.inc : アイテム
;


; マクロの定義
;

; アイテム
ITEM_TYPE                       =   0x00
ITEM_POSITION_X                 =   0x01
ITEM_POSITION_Y                 =   0x02
ITEM_ANIMATION                  =   0x03
ITEM_RECT_LEFT                  =   0x04
ITEM_RECT_TOP                   =   0x05
ITEM_RECT_RIGHT                 =   0x06
ITEM_RECT_BOTTOM                =   0x07
ITEM_LENGTH                     =   0x08

; 種類
ITEM_TYPE_NULL                  =   0x00
ITEM_TYPE_POTION                =   0x01
ITEM_TYPE_SWORD                 =   0x02
ITEM_TYPE_KEY                   =   0x03
ITEM_TYPE_ROD                   =   0x04
ITEM_TYPE_CROWN                 =   0x05
ITEM_TYPE_RING                  =   0x06
ITEM_TYPE_NECKLACE              =   0x07

; 位置
ITEM_POSITION_NULL              =   0x00

; アニメーション
ITEM_ANIMATION_NULL             =   0x00
ITEM_ANIMATION_MOVE             =   0x10

; 矩形
ITEM_RECT_NULL                  =   0x00

; 大きさ
ITEM_SIZE_X                     =   0x10
ITEM_SIZE_Y                     =   0x10

; 外部関数宣言
;

    .globl  _ItemInitialize
    .globl  _ItemUpdate
    .globl  _ItemRender
    .globl  _ItemEntry

; 外部変数宣言
;

    .globl  _item
