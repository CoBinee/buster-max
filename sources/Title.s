; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE_TITLE) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンネームのクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #0x02ff
    ld      (hl), #0x00
    ldir

    ; パターンネームの転送
    ld      hl, #_patternName
    ld      de, #APP_PATTERN_NAME_TABLE
    ld      bc, #0x0300
    call    LDIRVM

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; サウンドの停止
    call    _SystemStopSound
    
    ; タイトルの設定
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存

    ; 初期化処理
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x00)
    jr      nz, 09$

    ; 導入の描画
    call    TitlePrintIntro

    ; フレームの設定
    ld      a, #0x5a
    ld      (_title + TITLE_FRAME), a

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; スプライトのクリア
    call    _SystemClearSprite

    ; 乱数を回す
    call    _SystemGetRandom
    
    ; 導入
10$:
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x01)
    jr      nz, 20$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; フレームの設定
    xor     a
    ld      (_title + TITLE_FRAME), a

    ; パターンネームのクリア
    call    _SystemClearPatternName

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
19$:
    jp      90$

    ; ドラゴンのフェード
20$:
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x02)
    jr      nz, 30$

    ; フェード
    ld      a, (_title + TITLE_FRAME)
    ld      c, a
    and     #0x0f
    jr      nz, 21$
    ld      a, c
    rrca
    rrca
    rrca
    rrca

    ; ドラゴンの描画
    call    TitlePrintDragon

    ; SE の再生
    ld      a, #SOUND_SE_FADE
    call    _SoundPlaySe
21$:

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    inc     (hl)
    ld      a, (hl)
    cp      #(0x05 * 0x10)
    jr      c, 29$

    ; フレームの設定
;   ld      hl, #(_title + TITLE_FRAME)
    ld      (hl), #0x00

    ; BGM の再生
    ld      a, #SOUND_BGM_TITLE
    call    _SoundPlayBgm

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
29$:
    jr      90$

    ; ページの更新
30$:
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x03)
    jr      nz, 40$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    inc     (hl)

    ; タイルの描画
    ld      a, (hl)
    call    TitlePrintTile

    ; ドラゴンの描画
    ld      a, #0x04
    call    TitlePrintDragon

    ; ロゴの描画
    call    TitlePrintLogo

    ; OPLL の描画
    call    TitlePrintOpll

    ; 状態の更新
    ld      a, (_title + TITLE_FRAME)
    cp      #0x04
    jr      c, 39$
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
39$:
    jr      90$

    ; キー入力待ち
40$:
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x04)
    jr      nz, 50$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    inc     (hl)

    ; スタートの更新
    ld      hl, #(_title + TITLE_START)
    inc     (hl)

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; SPACE キーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 49$

    ; サウンドの停止
    call    _SoundStop

    ; SE の再生
    ld      a, #SOUND_SE_START
    call    _SoundPlaySe

    ; 状態の更新
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
49$:
    jr      90$

    ; ゲームの開始
50$:
    ld      a, (_title + TITLE_STATE)
    cp      #(TITLE_STATE_NULL + 0x05)
    jr      nz, 90$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    inc     (hl)

    ; スタートの更新
    ld      hl, #(_title + TITLE_START)
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; サウンドの監視
    call    _SoundIsPlaySe
    jr      c, 59$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
59$:    
    jr      90$

    ; 更新の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 導入を描画する
;
TitlePrintIntro:

    ; レジスタの保存

    ; 導入の描画
    ld      hl, #titleIntroPatternName
    ld      de, #(_patternName + 0x165)
    ld      bc, #0x15
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ビットを描画する
;
TitlePrintBit:

    ; レジスタの保存

    ; a  < パターンネーム
    ; hl < ビット

    ; ビットの描画
    ld      c, a
    ld      de, #_patternName
    ex      de, hl
    ld      b, #(0x04 * 0x18)
10$:
    push    bc
    push    de
    ld      a, (de)
    ld      b, #0x08
11$:
    rlca
    jr      nc, 12$
    ld      (hl), c
12$:
    inc     hl
    djnz    11$
    pop     de
    inc     de
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; ドラゴンを描画する
;
TitlePrintDragon:

    ; レジスタの保存

    ; a < フェード

    ; ドラゴンの描画
    or      a
    jr      z, 10$
    add     a, #(0x50 - 0x01)
10$:
    ld      hl, #titleDragonPatternName
    call    TitlePrintBit

    ; 目の描画
    ld      a, #0x58
    ld      (_patternName + 0x0093), a

    ; レジスタの復帰

    ; 終了
    ret

; タイルを描画する
;
TitlePrintTile:

    ; レジスタの保存

    ; a < フェード

    ; タイルの描画
    or      a
    jr      z, 10$
    add     a, #(0x40 - 0x01)
10$:
    ld      hl, #titleTilePatternName
    call    TitlePrintBit

    ; レジスタの復帰

    ; 終了
    ret

; ロゴを描画する
;
TitlePrintLogo:

    ; レジスタの保存

    ; ロゴの描画
    ld      hl, #titleLogoPatternName
    ld      de, #(_patternName + 0x00e9)
    ld      b, #0x08
10$:
    push    bc
    ld      bc, #0x000e
    ldir
    ex      de, hl
    ld      bc, #(0x0020 - 0x000e)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; OPLL アイコンを描画する
;
TitlePrintOpll:

    ; レジスタの保存

    ; OPLL の描画
    ld      a, (_title + TITLE_PAGE)
    or      a
    jr      nz, 10$
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 10$
    ld      hl, #titleOpllPatternName
    ld      de, #(_patternName + 0x2a1)
    ld      bc, #0x0002
    ldir
    ld      de, #(_patternName + 0x2c1)
    ld      bc, #0x0002
    ldir
10$:

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を描画する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; HIT SPACE BAR の描画
    ld      hl, #(_title + TITLE_START)
    ld      a, (hl)
    and     #0x10
    ld      hl, #titleHitSpaceBarPatternName
    ld      de, #(_patternName + 0x022a)
    ld      bc, #0x000c
    jr      nz, 10$
    add     hl, bc
10$:
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_FRAME_NULL
    .db     TITLE_PAGE_LOGO
    .db     TITLE_START_NULL

; 導入
;
titleIntroPatternName:

    .db     0x39, 0x2f, 0x35, 0x00, 0x26, 0x2f, 0x35, 0x2e, 0x24, 0x00, 0x39, 0x2f, 0x35, 0x32, 0x33, 0x25, 0x2c, 0x26, 0x00, 0x29, 0x2e

; ドラゴン
;
titleDragonPatternName:

    .db     0b00000000, 0b00000000, 0b00000000, 0b00000111
    .db     0b00000000, 0b00000000, 0b00000001, 0b11101110
    .db     0b00000000, 0b00000000, 0b00100011, 0b11011110
    .db     0b00000000, 0b00000000, 0b00111011, 0b11111110
    .db     0b00000000, 0b00000000, 0b00101111, 0b10111100
    .db     0b00000000, 0b00000000, 0b00110111, 0b10111000
    .db     0b00000000, 0b00000000, 0b00100011, 0b11111000
    .db     0b00000000, 0b00000000, 0b00000001, 0b11110000
    .db     0b00000000, 0b00000000, 0b00000001, 0b11100000
    .db     0b00000000, 0b00000000, 0b01100111, 0b11110000
    .db     0b00000000, 0b00000000, 0b00011001, 0b11111000
    .db     0b00000000, 0b00000000, 0b00110011, 0b00011000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00001100
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000100
    .db     0b00000000, 0b00000000, 0b00000000, 0b01000100
    .db     0b00000000, 0b00000000, 0b00000000, 0b00111000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000000

; タイル
;
titleTilePatternName:

    .db     0b11111111, 0b11111111, 0b11111111, 0b11111111
    .db     0b10011100, 0b00011111, 0b11111011, 0b11111111
    .db     0b00000000, 0b00001111, 0b01111001, 0b10011111
    .db     0b00000000, 0b00000100, 0b00100000, 0b00001111
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000011
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000001
    .db     0b10000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b10000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b10000000, 0b00000000, 0b00000000, 0b00000001
    .db     0b10000000, 0b00000000, 0b00000000, 0b00000011
    .db     0b11000000, 0b00000000, 0b00000000, 0b00000111
    .db     0b11000000, 0b00000000, 0b00000000, 0b00000111
    .db     0b10000000, 0b00000000, 0b00000000, 0b00000011
    .db     0b10100000, 0b00000000, 0b00000000, 0b00000011
    .db     0b11000000, 0b00000000, 0b00000000, 0b00000101
    .db     0b11000000, 0b00000000, 0b00000000, 0b00000001
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000001
    .db     0b00000000, 0b00000000, 0b00000000, 0b00000001
    .db     0b10000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b11000000, 0b00000000, 0b00000000, 0b00000000
    .db     0b11110000, 0b00000100, 0b00100000, 0b00000000
    .db     0b11111001, 0b10011110, 0b11110000, 0b00000000
    .db     0b11111111, 0b11011111, 0b11111000, 0b00110001
    .db     0b11111111, 0b11111111, 0b11111111, 0b11111111

; ロゴ
;
titleLogoPatternName:

    .db     0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d
    .db     0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0x70, 0x71, 0xaa, 0xab, 0x72, 0x73
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0x74, 0x75, 0xbc, 0xbd
    .db     0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0x78, 0x79, 0xcb, 0xcc, 0x7a
    .db     0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd
    .db     0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed
    .db     0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd

    .db     0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d
    .db     0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad
    .db     0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd
    .db     0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd
    .db     0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd
    .db     0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed
    .db     0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd


; カーソル
;
titleCursorPatternName:

    .db     0x48, 0x49, 0x4a

; OPLL
;
titleOpllPatternName:

    .db     0x4c, 0x4d, 0x4e, 0x4f

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    .db     0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::
    
    .ds     TITLE_LENGTH
