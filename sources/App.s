; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Title.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _patternTable


; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; アプリケーションの初期化
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    inc     c
    ld      a, #<APP_SPRITE_GENERATOR_TABLE
    out     (c), a
    ld      a, #(>APP_SPRITE_GENERATOR_TABLE | 0b01000000)
    out     (c), a
    dec     c
    ld      hl, #(_patternTable + 0x0000)
    ld      d, #0x08
10$:
    ld      e, #0x10
11$:
    push    de
    ld      b, #0x08
;   otir
12$:
    outi
    jp      nz, 12$
    ld      de, #0x78
    add     hl, de
    ld      b, #0x08
;   otir
13$:
    outi
    jp      nz, 13$
    ld      de, #0x80
    or      a
    sbc     hl, de
    pop     de
    dec     e
    jr      nz, 11$
    ld      a, #0x80
    add     a, l
    ld      l, a
    ld      a, h
    adc     a, #0x00
    ld      h, a
    dec     d
    jr      nz, 10$
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0800)
    ld      de, #APP_PATTERN_GENERATOR_TABLE
    ld      bc, #0x1000
    call    LDIRVM
    
    ; カラーテーブルの初期化
    ld      hl, #(appColorTable + 0x0000)
    ld      de, #(APP_COLOR_TABLE_GAME_NORMAL)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(appColorTable + 0x0020)
    ld      de, #(APP_COLOR_TABLE_GAME_GREEN)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(appColorTable + 0x0040)
    ld      de, #(APP_COLOR_TABLE_GAME_BLUE)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(appColorTable + 0x0060)
    ld      de, #(APP_COLOR_TABLE_GAME_RED)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(appColorTable + 0x0080)
    ld      de, #(APP_COLOR_TABLE_TITLE)
    ld      bc, #0x0020
    call    LDIRVM
    
    ; パターンネームの初期化
    ld      hl, #APP_PATTERN_NAME_TABLE
    xor     a
    ld      bc, #0x0300
    call    FILVRM
    
    ; 割り込み禁止の解除
    ei

    ; デバッグの初期化
    ld      hl, #(_appDebug + 0x0000)
    ld      de, #(_appDebug + 0x0001)
    ld      bc, #(0x0008 - 0x0001)
    ld      (hl), #0xff
    ldir

    ; 状態の初期化
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_appState)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; デバッグの表示
;   call    AppPrintDebug

    ; 更新の終了
90$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; 処理なし
;
_AppNull::

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; デバッグ情報を表示する
;
AppPrintDebug:

    ; レジスタの保存

    ; SP の表示
    ld      de, #(_patternName + 0x02e0)
    ld      hl, #appDebugStringSp
    call    70$
    ld      hl, #0x0000
    add     hl, sp
    ld      a, h
    call    80$
    ld      a, l
    call    80$
19$:

    ; OPLL の表示
    ld      de, #(_patternName + 0x02e8)
    ld      hl, #appDebugStringOpllNg
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 20$
    ld      hl, #appDebugStringOpllOk
20$:
    call    70$
29$:

    ; デバッグの表示
;   jr      39$
    ld      de, #(_patternName + 0x02f0)
    ld      hl, #_appDebug
    ld      b, #0x08
30$:
    ld      a, (hl)
    call    80$
    inc     hl
    djnz    30$
39$:
    jr      90$

    ; 文字列の表示
70$:
    ld      a, (hl)
    sub     #0x20
    ret     c
    ld      (de), a
    inc     hl
    inc     de
    jr      70$

    ; 16 進数の表示
80$:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    81$
    pop     af
    call    81$
    ret
81$:
    and     #0x0f
    cp      #0x0a
    jr      c, 82$
    add     a, #0x07
82$:
    add     a, #0x10
    ld      (de), a
    inc     de
    ret

    ; デバッグ表示の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100011
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000000 ; 0b00000111

; カラーテーブル
;
appColorTable:

    ; Game - Normal
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_DARK_YELLOW
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_GREEN   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_RED    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_DARK_RED,   (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK

    ; Game - Green
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_GREEN   << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_GREEN   << 4) | VDP_COLOR_LIGHT_GREEN
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_RED    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_DARK_RED,   (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK

    ; Game - Blue
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_GREEN   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_RED    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_DARK_RED,   (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK

    ; Game - Red
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_LIGHT_RED
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_GREEN   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MAGENTA      << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_RED    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_GREEN  << 4) | VDP_COLOR_DARK_RED,   (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK

    ; Title
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_RED     << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_GREEN   << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_DARK_GREEN, (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_DARK_GREEN
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_LIGHT_BLUE   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK,      (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK

; 状態別の処理
;
appProc:
    
    .dw     _AppNull
    .dw     _TitleInitialize
    .dw     _TitleUpdate
    .dw     _GameInitialize
    .dw     _GameUpdate

; デバッグ
;
appDebugStringSp:

    .ascii  "SP="
    .db     0x00

appDebugStringOpllNg:

    .ascii  "OPLL=NG"
    .db     0x00

appDebugStringOpllOk:

    .ascii  "OPLL=OK"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
_appState::

    .ds     0x01

; デバッグ
;
_appDebug::

    .ds     0x08
