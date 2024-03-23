; Maze.s : 迷路
;


; モジュール宣言
;
    .module Maze

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Maze.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 迷路を初期化する
;
_MazeInitialize::
    
    ; レジスタの保存

    ; フラグの初期化
100$:
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
    xor     a
    ld      (hl), a
    ldir

    ; 迷路の作成
    call    MazeBuild
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 迷路を作成する
;
MazeBuild:

    ; レジスタの保存

    ; クラスタの初期設定
    ld      hl, #(mazeCluster + 0x0000)
    ld      de, #(mazeCluster + 0x0001)
    ld      bc, #(MAZE_CLUSTER_X * MAZE_CLUSTER_Y - 0x0001)
    ld      (hl), #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_LEFT | MAZE_FLAG_WALL_RIGHT)
    ldir

    ; クラスタリングのためのワークの初期化
    ld      hl, #mazeWork
    ld      b, #(MAZE_CLUSTER_X * MAZE_CLUSTER_Y)
    xor     a
100$:
    ld      (hl), a
    inc     hl
    inc     a
    djnz    100$

    ; クラスタリングによる迷路の生成
110$:
    call    _SystemGetRandom
    and     #(MAZE_CLUSTER_X_MASK | MAZE_CLUSTER_Y_MASK)
    ld      e, a
    ld      d, #0x00
111$:
    call    30$
    jr      nz, 112$
    ld      a, e
    inc     a
    and     #(MAZE_CLUSTER_X_MASK | MAZE_CLUSTER_Y_MASK)
    ld      e, a
    jr      111$
112$:
    call    40$
    ld      hl, #mazeWork
    ld      a, (hl)
    inc     hl
    ld      b, #(MAZE_CLUSTER_X * MAZE_CLUSTER_Y - 0x0001)
113$:
    cp      (hl)
    jr      nz, 110$
    inc     hl
    djnz    113$

    ; クラスタの展開
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
    ld      (hl), #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_LEFT | MAZE_FLAG_WALL_RIGHT)
    ldir
    ld      hl, #(mazeCluster + MAZE_CLUSTER_X * MAZE_CLUSTER_Y - 0x0001)
    ld      de, #(mazeFlag + MAZE_SIZE_X * MAZE_SIZE_Y - 0x0002)
    ld      b, #(MAZE_CLUSTER_X * MAZE_CLUSTER_Y)
120$:
    ld      a, (hl)
    ld      (de), a
    dec     hl
    dec     de
    dec     de
    djnz    120$
    ld      hl, #mazeFlag
    ld      c, #MAZE_SIZE_Y
121$:
    ld      b, #(MAZE_CLUSTER_X - 0x01)
122$:
    ld      a, (hl)
    and     #MAZE_FLAG_WALL_RIGHT
    jr      nz, 123$
    inc     hl
    ld      (hl), #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN)
    inc     hl
    jr      125$
123$:
    call    _SystemGetRandom
    and     #0x10
    jr      nz, 124$
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    inc     hl
    ld      (hl), #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_RIGHT)
    inc     hl
    jr      125$
124$:
    inc     hl
    ld      (hl), #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_LEFT)
    inc     hl
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
;   jr      125$
125$:
    djnz    122$
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    inc     hl
    ld      (hl), #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_RIGHT)
    inc     hl
    dec     c
    jr      nz, 121$

    ; 部屋の作成
    ld      hl, #mazeWork
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x0000)
130$:
    ld      (hl), c
    inc     hl
    inc     c
    djnz    130$
    ld      de, #mazeWork
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
131$:
    push    bc
    call    _SystemGetRandom
    and     #(MAZE_SIZE_X_MASK | MAZE_SIZE_Y_MASK)
    ld      c, a
    ld      b, #0x00
    ld      hl, #mazeWork
    add     hl, bc
    ld      c, (hl)
    ld      a, (de)
    ld      (hl), a
    ld      a, c
    ld      (de), a
    inc     de
    pop     bc
    djnz    131$
    ld      de, #mazeWork
    ld      b, #MAZE_ROOM_SIZE
132$:
    push    bc
    ld      a, (de)
    ld      c, a
    ld      b, #0x00
    ld      hl, #mazeFlag
    add     hl, bc
    ld      a, (hl)
    pop     bc
    cpl
    and     #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN)
    jr      z, 133$
    inc     de
    jr      132$
133$:
    set     #MAZE_FLAG_ROOM_BIT, (hl)
    inc     de
    djnz    132$

    ; 距離取得のためのワークの初期化
    ld      hl, #(mazeWork + 0x0000)
    ld      de, #(mazeWork + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x0001)
    ld      a, #0xff
    ld      (hl), a
    ldir

    ; 迷路の距離の取得
    call    _SystemGetRandom
140$:
    and     #(MAZE_SIZE_X_MASK | MAZE_SIZE_Y_MASK)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_ROOM_BIT, (hl)
    jr      nz, 141$
    ld      a, e
    inc     a
    jr      140$
141$:
    xor     a
    ld      hl, #mazeWork
    add     hl, de
    ld      (hl), a
    call    50$

    ; 迷路の順番の取得
    xor     a
    ld      c, a
150$:
    ld      de, #0x0000
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
151$:
    ld      hl, #mazeWork
    add     hl, de
    cp      (hl)
    jr      nz, 152$
    ld      hl, #mazeOrder
    add     hl, de
    ld      (hl), c
    inc     c
152$:
    inc     e
    djnz    151$
    inc     a
    ld      d, a
    ld      a, c
    cp      #(MAZE_SIZE_X * MAZE_SIZE_Y)
    ld      a, d
    jr      c, 150$

    ; 部屋の順番の取得
    ld      hl, #(mazeRoomOrder + 0x0000)
    ld      de, #(mazeRoomOrder + 0x0001)
    ld      bc, #(MAZE_SIZE_X * MAZE_SIZE_Y)
    ld      (hl), #0xff
    ldir
    xor     a
    ld      c, a
160$:
    ld      de, #0x0000
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
161$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_ROOM_BIT, (hl)
    jr      z, 162$
    ld      hl, #mazeOrder
    add     hl, de
    cp      (hl)
    jr      nz, 162$
    ld      hl, #mazeRoomOrder
    add     hl, de
    ld      (hl), c
    inc     c
162$:
    inc     e
    djnz    161$
    inc     a
    cp      #(MAZE_SIZE_X * MAZE_SIZE_Y)
    jr      c, 160$

    ; 外周に穴をあける
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + MAZE_SIZE_X * (MAZE_SIZE_Y - 1))
    ld      b, #MAZE_SIZE_X
170$:
    ld      a, (de)
    or      (hl)
    bit     #MAZE_FLAG_ROOM_BIT, a
    jr      nz, 171$
    call    _SystemGetRandom
    rlca
    cp      #0x80
    jr      nc, 171$
    res     #MAZE_FLAG_WALL_UP_BIT, (hl)
    ex      de, hl
    res     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    ex      de, hl
171$:
    inc     hl
    inc     de
    djnz    170$
    ld      hl, #(mazeFlag + 0x0000)
    ld      de, #(mazeFlag + MAZE_SIZE_X - 1)
    ld      b, #MAZE_SIZE_X
172$:
    ld      a, (de)
    or      (hl)
    bit     #MAZE_FLAG_ROOM_BIT, a
    jr      nz, 173$
    call    _SystemGetRandom
    rlca
    cp      #0x40
    jr      nc, 173$
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    ex      de, hl
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    ex      de, hl
173$:
    push    bc
    ld      bc, #MAZE_SIZE_X
    add     hl, bc
    ex      de, hl
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    172$

    ; 迷路の作成の完了
    jp      90$

    ; 上のクラスタの取得 de > bc
20$:
    push    af
    ld      a, e
    and     #MAZE_CLUSTER_Y_MASK
    jr      z, 29$
    sub     #MAZE_CLUSTER_X
    ld      c, a
    ld      a, e
    and     #MAZE_CLUSTER_X_MASK
    add     a, c
    jr      28$

    ; 下のクラスタの取得 de > bc
21$:
    push    af
    ld      a, e
    add     a, #MAZE_CLUSTER_X
    and     #MAZE_CLUSTER_Y_MASK
    jr      z, 29$
    ld      c, a
    ld      a, e
    and     #MAZE_CLUSTER_X_MASK
    add     a, c
    jr      28$

    ; 左のクラスタの取得 de > bc
22$:
    push    af
    ld      a, e
    and     #MAZE_CLUSTER_X_MASK
    jr      z, 29$
    dec     a
    ld      c, a
    ld      a, e
    and     #MAZE_CLUSTER_Y_MASK
    add     a, c
    jr      28$

    ; 右のクラスタの取得 de > bc
23$:
    push    af
    ld      a, e
    inc     a
    and     #MAZE_CLUSTER_X_MASK
    jr      z, 29$
    ld      c, a
    ld      a, e
    and     #MAZE_CLUSTER_Y_MASK
    add     a, c
;   jr      28$

    ; 参照可
28$:
    ld      c, a
    ld      b, d
    pop     af
    or      a
    ret

    ; 参照不可
29$:
    pop     af
    scf
    ret

    ; 上下左右のクラスタの検査
30$:
    push    hl
    push    bc
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    20$
    jr      c, 31$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      nz, 39$
31$:
    call    21$
    jr      c, 32$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      nz, 39$
32$:
    call    22$
    jr      c, 33$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      nz, 39$
33$:
    call    23$
    jr      c, 34$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      39$
34$:
    sub     a
39$:
    pop     bc
    pop     hl
    ret

    ; クラスタの結合
40$:
    push    hl
    push    bc
    call    _SystemGetRandom
    rlca
    rlca
    and     #0x03
    jr      z, 41$
    dec     a
    jr      z, 44$
    dec     a
    jr      z, 43$
    jr      42$
41$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    20$
    jr      c, 42$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 42$
    ld      hl, #mazeCluster
    add     hl, de
    res     #MAZE_FLAG_WALL_UP_BIT, (hl)
    ld      hl, #mazeCluster
    add     hl, bc
    res     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    jr      45$
42$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    21$
    jr      c, 43$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 43$
    ld      hl, #mazeCluster
    add     hl, de
    res     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    ld      hl, #mazeCluster
    add     hl, bc
    res     #MAZE_FLAG_WALL_UP_BIT, (hl)
    jr      45$
43$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    22$
    jr      c, 44$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 44$
    ld      hl, #mazeCluster
    add     hl, de
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    ld      hl, #mazeCluster
    add     hl, bc
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    jr      45$
44$:
    ld      hl, #mazeWork
    add     hl, de
    ld      a, (hl)
    call    23$
    jr      c, 41$
    ld      hl, #mazeWork
    add     hl, bc
    cp      (hl)
    jr      z, 41$
    ld      hl, #mazeCluster
    add     hl, de
    res     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    ld      hl, #mazeCluster
    add     hl, bc
    res     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
;   jr      45$
45$:
    push    de
    ld      hl, #mazeWork
    add     hl, de
    ld      d, (hl)
    ld      hl, #mazeWork
    add     hl, bc
    ld      e, (hl)
    ld      a, e
    cp      d
    jr      c, 46$
    ld      e, d
    ld      d, a
46$:
    ld      hl, #mazeWork
    ld      a, e
    ld      b, #(MAZE_CLUSTER_X * MAZE_CLUSTER_Y)
47$:
    cp      (hl)
    jr      nz, 48$
    ld      (hl), d
48$:
    inc     hl
    djnz    47$
    pop     de
    pop     bc
    pop     hl
    ret

    ; 迷路の距離の取得
50$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_UP_BIT, (hl)
    jr      nz, 52$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    ld      a, e
    sub     #MAZE_SIZE_X
    ld      e, a
    ld      a, (hl)
    inc     a
    ld      hl, #mazeWork
    add     hl, de
    cp      (hl)
    jr      nc, 51$
    ld      (hl), a
    call    50$
51$:
    pop     de
52$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_DOWN_BIT, (hl)
    jr      nz, 54$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    ld      a, e
    add     a, #MAZE_SIZE_X
    ld      e, a
    ld      a, (hl)
    inc     a
    ld      hl, #mazeWork
    add     hl, de
    cp      (hl)
    jr      nc, 53$
    ld      (hl), a
    call    50$
53$:
    pop     de
54$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_LEFT_BIT, (hl)
    jr      nz, 56$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    dec     e
    ld      a, (hl)
    inc     a
    dec     hl
    cp      (hl)
    jr      nc, 55$
    ld      (hl), a
    call    50$
55$:
    pop     de
56$:
    ld      hl, #mazeFlag
    add     hl, de
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, (hl)
    jr      nz, 58$
    push    de
    ld      hl, #mazeWork
    add     hl, de
    inc     e
    ld      a, (hl)
    inc     a
    inc     hl
    cp      (hl)
    jr      nc, 57$
    ld      (hl), a
    call    50$
57$:
    pop     de
58$:
    ret

    ; 処理の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 迷路の開始エリアを取得する
;
_MazeGetAreaStart::

    ; レジスタの保存
    push    hl
    push    bc

    ; a > start area

    ; 順番の検索
    ld      hl, #mazeOrder
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x0000)
10$:
    ld      a, (hl)
    or      a
    jr      z, 11$
    inc     hl
    inc     c
    jr      10$
11$:
    ld      a, c

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 指定されたエリアの上のエリアを取得する
;
_MazeGetAreaUp::

    ; レジスタの保存
    push    bc

    ; a < base area
    ; a > up area

    ; エリアの取得
    ld      c, a
    sub     #(0x01 << MAZE_SIZE_Y_SHIFT)
    and     #MAZE_SIZE_Y_MASK
    ld      b, a
    ld      a, c
    and     #MAZE_SIZE_X_MASK
    or      b

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 指定されたエリアの下のエリアを取得する
;
_MazeGetAreaDown::

    ; レジスタの保存
    push    bc

    ; a < base area
    ; a > down area

    ; エリアの取得
    ld      c, a
    add     a, #(0x01 << MAZE_SIZE_Y_SHIFT)
    and     #MAZE_SIZE_Y_MASK
    ld      b, a
    ld      a, c
    and     #MAZE_SIZE_X_MASK
    or      b

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 指定されたエリアの左のエリアを取得する
;
_MazeGetAreaLeft::

    ; レジスタの保存
    push    bc

    ; a < base area
    ; a > left area

    ; エリアの取得
    ld      c, a
    dec     a
    and     #MAZE_SIZE_X_MASK
    ld      b, a
    ld      a, c
    and     #MAZE_SIZE_Y_MASK
    or      b

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 指定されたエリアの右のエリアを取得する
;
_MazeGetAreaRight::

    ; レジスタの保存
    push    bc

    ; a < base area
    ; a > right area

    ; エリアの取得
    ld      c, a
    inc     a
    and     #MAZE_SIZE_X_MASK
    ld      b, a
    ld      a, c
    and     #MAZE_SIZE_Y_MASK
    or      b

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; エリアのフラグを取得する
;
_MazeGetAreaFlag::

    ; レジスタの保存
    push    hl
    push    de

    ; a < area
    ; a > flag

    ; フラグの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エリアのフラグをセットする
;
_MazeSetAreaFlag::

    ; レジスタの保存
    push    hl
    push    de

    ; a < area
    ; c < flag

    ; フラグの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    ld      a, c
    or      (hl)
    ld      (hl), a

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エリアのフラグをリセットする
;
_MazeResetAreaFlag::

    ; レジスタの保存
    push    hl
    push    de

    ; a < area
    ; c < flag

    ; フラグの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    ld      a, c
    cpl
    and     (hl)
    ld      (hl), a

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エリアの順番を取得する
;
_MazeGetAreaOrder::

    ; レジスタの保存
    push    hl
    push    de

    ; a < area
    ; a > order

    ; 順番の取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeOrder
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エリアの部屋の順番を取得する
;
_MazeGetAreaRoomOrder::

    ; レジスタの保存
    push    hl
    push    de

    ; a < area
    ; a > order

    ; 順番の取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeRoomOrder
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 迷路のエリアを作成する
;
_MazeBuildArea::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; セルの作成
    ld      a, (_game + GAME_AREA)
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    ld      a, (hl)
    bit     #MAZE_FLAG_ROOM_BIT, a
    jr      nz, 10$
    call    200$
    jr      12$
10$:
    call    300$
    jr      12$
11$:
12$:
    call    50$
    jp      90$

    ; 通路の作成
200$:
    ld      hl, #(mazeCell + 0x0000)
    ld      de, #(mazeCell + 0x0001)
    ld      bc, #(MAZE_CELL_X * MAZE_CELL_Y - 0x0001)
    ld      (hl), #0x00
    ldir
210$:
    ld      hl, #mazeCellPathUpExit
    ld      de, #(mazeCell + (MAZE_CELL_X - 0x0006) / 2)
    bit     #MAZE_FLAG_WALL_UP_BIT, a
    jr      z, 211$
    ld      hl, #mazeCellPathUpWall
211$:
    ld      b, #0x05
    call    280$
    ld      hl, #mazeCellPathDownExit
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0002) * MAZE_CELL_X + (MAZE_CELL_X - 0x0006) / 2)
    bit     #MAZE_FLAG_WALL_DOWN_BIT, a
    jr      z, 212$
    ld      hl, #mazeCellPathDownWall
212$:
    ld      b, #0x02
    call    280$
    ld      hl, #mazeCellPathLeftExit
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0006) * MAZE_CELL_X)
    bit     #MAZE_FLAG_WALL_LEFT_BIT, a
    jr      z, 213$
    ld      hl, #mazeCellPathLeftWall
213$:
    ld      b, #0x06
    call    280$
    ld      hl, #mazeCellPathRightExit
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0006) * MAZE_CELL_X + (MAZE_CELL_X - 0x0006))
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, a
    jr      z, 214$
    ld      hl, #mazeCellPathRightWall
214$:
    ld      b, #0x06
    call    280$
220$:
    push    af
    and     #(MAZE_FLAG_WALL_UP | MAZE_FLAG_WALL_DOWN | MAZE_FLAG_WALL_LEFT | MAZE_FLAG_WALL_RIGHT)
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeCellPathCorner
    add     hl, de
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0006) * MAZE_CELL_X + 0x0005)
    ex      de, hl
    ld      a, (de)
    ld      (hl), a
    ld      bc, #0x0005
    add     hl, bc
    inc     de
    ld      a, (de)
    ld      (hl), a
    ld      bc, #(0x0005 * MAZE_CELL_X - 0x0005)
    add     hl, bc
    inc     de
    ld      a, (de)
    ld      (hl), a
    ld      bc, #0x0005
    add     hl, bc
    inc     de
    ld      a, (de)
    ld      (hl), a
    pop     af
230$:
    ld      de, #(mazeCell + (MAZE_CELL_X / 2 - 0x0001))
    ld      b, #0x07
    bit     #MAZE_FLAG_WALL_UP_BIT, a
    call    z, 290$
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0005) * MAZE_CELL_X + (MAZE_CELL_X / 2 - 0x0001))
    ld      b, #0x05
    bit     #MAZE_FLAG_WALL_DOWN_BIT, a
    call    z, 290$
    ret
280$:
    push    bc
    ld      bc, #0x0006
    ldir
    ex      de, hl
    ld      bc, #(MAZE_CELL_X - 0x0006)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    280$
    ret
290$:
    ld      hl, #mazeCellIvy
291$:
    push    bc
    ld      bc, #0x0002
    ldir
    ex      de, hl
    ld      bc, #(MAZE_CELL_X - 0x0002)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    291$
    ret

    ; 部屋の作成
300$:
    ld      hl, #mazeCellRoom
    ld      de, #mazeCell
    ld      bc, #(MAZE_CELL_X * MAZE_CELL_Y)
    ldir
    bit     #MAZE_FLAG_WALL_LEFT_BIT, a
    call    z, 310$
    bit     #MAZE_FLAG_WALL_RIGHT_BIT, a
    call    z, 311$
    ret
310$:
    ld      hl, #mazeCellRoomLeftExit
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0006) * MAZE_CELL_X)
    jr      312$
311$:
    ld      hl, #mazeCellRoomRightExit
    ld      de, #(mazeCell + (MAZE_CELL_Y - 0x0006) * MAZE_CELL_X + (MAZE_CELL_X - 0x0001))
;   jr      312$
312$:
    ld      b, #0x06
313$:
    push    bc
    ldi
    ex      de, hl
    ld      bc, #(MAZE_CELL_X - 0x0001)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    313$
    ret

    ; ボスの作成
400$:
    ret

    ; セルからパターンネームを作成
50$:
    ld      hl, #mazePatternName
    ld      de, #mazeCell
    ld      b, #MAZE_CELL_Y
51$:
    push    bc
    ld      b, #MAZE_CELL_X
52$:
    push    bc
    ld      a, (de)
    push    de
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ex      de, hl
    ld      hl, #mazeCellPatternName
    add     hl, bc
    ex      de, hl
    ld      bc, #(MAZE_PATTERN_NAME_X - 0x0001)
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    or      a
    sbc     hl, bc
    pop     de
    inc     de
    pop     bc
    djnz    52$
    ld      bc, #MAZE_PATTERN_NAME_X
    add     hl, bc
    pop     bc
    djnz    51$
    ret

    ; 作成の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 迷路のエリアを描画する
;
_MazePrintArea::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; パターンネームの転送
    ld      hl, #mazePatternName
    ld      de, #_patternName
    ld      bc, #(MAZE_PATTERN_NAME_X * MAZE_PATTERN_NAME_Y)
    ldir
    
    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 迷路のフラグを描画する
;
_MazePrintFlag::

    ; レジスタの保存

    ; フラグの描画
    ld      hl, #(_patternName + 0x0108)
    ld      de, #mazeFlag
    ld      c, #MAZE_SIZE_Y
10$:
    ld      b, #MAZE_SIZE_X
11$:
    ld      a, (de)
    and     #0x1f
    add     a, #0xe0
    ld      (hl), a
    inc     hl
    inc     de
    djnz    11$
    push    de
    ld      de, #(0x20 - MAZE_SIZE_X)
    add     hl, de
    pop     de
    dec     c
    jr      nz, 10$

    ; レジスタの復帰

    ; 終了
    ret

; セルを取得する
;
_MazeGetCell::

    ; レジスタの保存
    push    hl
    push    de

    ; de < Y/X 座標
    ; a  > セル

    ; セルの取得
    ld      a, d
    and     #0xf0
    ld      d, a
    ld      a, e
    rrca
    rrca
    rrca
    rrca
    and     #0x0f
    add     a, d
    ld      e, a
    ld      d, #0x00
    ld      hl, #mazeCell
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; セルが壁かどうかを判定する
;
_MazeIsCellWall::

    ; レジスタの保存

    ; de < Y/X 座標
    ; cf > 1 = 壁

    ; セルの取得
    call    _MazeGetCell
    and     #MAZE_CELL_WALL
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; セルが蔦かどうかを判定する
;
_MazeIsCellIvy::

    ; レジスタの保存

    ; de < Y/X 座標
    ; cf > 1 = 蔦

    ; セルの取得
    call    _MazeGetCell
    and     #MAZE_CELL_IVY
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; セル
mazeCellPatternName:

    .db     0x00, 0x00, 0x00, 0x00
    .db     0x50, 0x50, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x58, 0x59
    .db     0x00, 0x00, 0x5a, 0x5b
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x54, 0x00, 0x5e      ; 蔦（左）
    .db     0x5d, 0x00, 0x57, 0x00      ; 蔦（右）
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00
    .db     0x40, 0x40, 0x48, 0x48      ; 壁（上）
    .db     0x49, 0x49, 0x41, 0x41      ; 壁（下）
    .db     0x42, 0x4a, 0x42, 0x4a      ; 壁（左）
    .db     0x4b, 0x43, 0x4b, 0x43      ; 壁（右）
    .db     0x47, 0x4a, 0x48, 0x4f      ; 壁（凸上左）
    .db     0x4b, 0x46, 0x4e, 0x48      ; 壁（凸上右）
    .db     0x49, 0x4d, 0x45, 0x4a      ; 壁（凸下左）
    .db     0x4c, 0x49, 0x4b, 0x44      ; 壁（凸下右）
    .db     0x47, 0x40, 0x42, 0x4f      ; 壁（凹上左）
    .db     0x40, 0x46, 0x4e, 0x43      ; 壁（凹上右）
    .db     0x42, 0x4d, 0x45, 0x41      ; 壁（凹下左）
    .db     0x4c, 0x43, 0x41, 0x44      ; 壁（凹下右）

mazeCellPathUpExit:

    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00

mazeCellPathUpWall:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x10, 0x10, 0x10, 0x10, 0x00

mazeCellPathDownExit:

    .db     0x04, 0x00, 0x00, 0x00, 0x00, 0x04
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00

mazeCellPathDownWall:

    .db     0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    .db     0x00, 0x11, 0x11, 0x11, 0x11, 0x00

mazeCellPathLeftExit:

    .db     0x10, 0x10, 0x10, 0x10, 0x10, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    .db     0x11, 0x11, 0x11, 0x11, 0x11, 0x00

mazeCellPathLeftWall:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x12
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x12
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x12
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x12
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00

mazeCellPathRightExit:

    .db     0x00, 0x10, 0x10, 0x10, 0x10, 0x10
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x04, 0x04, 0x04, 0x04, 0x04, 0x04
    .db     0x00, 0x11, 0x11, 0x11, 0x11, 0x11

mazeCellPathRightWall:

    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x13, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x13, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x13, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x13, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00

mazeCellPathCorner:

    .db     0x14, 0x15, 0x16, 0x17
    .db     0x10, 0x10, 0x16, 0x17
    .db     0x14, 0x15, 0x11, 0x11
    .db     0x10, 0x10, 0x11, 0x11
    .db     0x12, 0x15, 0x12, 0x17
    .db     0x18, 0x10, 0x12, 0x17
    .db     0x12, 0x15, 0x1a, 0x11
    .db     0x18, 0x10, 0x1a, 0x11
    .db     0x14, 0x13, 0x16, 0x13
    .db     0x10, 0x19, 0x16, 0x13
    .db     0x14, 0x13, 0x11, 0x1b
    .db     0x10, 0x19, 0x11, 0x1b
    .db     0x12, 0x13, 0x12, 0x13
    .db     0x18, 0x19, 0x13, 0x13
    .db     0x12, 0x13, 0x1a, 0x1b
    .db     0x18, 0x19, 0x1a, 0x1b

mazeCellRoom:

    .db     0x18, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x19
    .db     0x12, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13
    .db     0x12, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x13
    .db     0x1a, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1b

mazeCellRoomLeftExit:

    .db     0x14, 0x00, 0x00, 0x00, 0x03, 0x11

mazeCellRoomRightExit:

    .db     0x15, 0x00, 0x00, 0x00, 0x03, 0x11

mazeCellIvy:

    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09
    .db     0x08, 0x09


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; フラグ
;
mazeFlag:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; クラスタ
;
mazeCluster:

    .ds     MAZE_CLUSTER_X * MAZE_CLUSTER_Y

; 順番
;
mazeOrder:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

mazeRoomOrder:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; ワーク
;
mazeWork:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y

; セル
;
mazeCell:

    .ds     MAZE_CELL_X * MAZE_CELL_Y

; パターンネーム
;
mazePatternName:

    .ds     MAZE_PATTERN_NAME_X * MAZE_PATTERN_NAME_Y

