; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; サウンドを初期化する
;
_SoundInitialize:

    ; レジスタの保存

    ; 

    ; レジスタの復帰

    ; 終了
    ret

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmTitle0, soundBgmTitle1, soundBgmTitle2
    .dw     soundBgmPath0, soundBgmPath1, soundBgmPath2
    .dw     soundBgmBoss0, soundBgmBoss1, soundBgmBoss2
    .dw     soundBgmIdol0, soundBgmIdol1, soundBgmIdol2
    .dw     soundBgmOver0, soundBgmOver1, soundBgmOver2
    .dw     soundBgmClear0, soundBgmClear1, soundBgmClear2

; タイトル
soundBgmTitle0:

    .ascii  "T4@*@16V15,6L8"
    .ascii  "O5EO4BFEABO5CD"
    .ascii  "O5EDCO4BABO5CO4B"
    .ascii  "O4A9R"
    .db     0xff

soundBgmTitle1:

    .ascii  "T4@16V15,6L8"
    .ascii  "O4EDCDEDCD"
    .ascii  "O4EDCDEDCD"
    .ascii  "O4C9R"
    .db     0xff
    
soundBgmTitle2:

    .ascii  "T4@16V15,6L8"
    .ascii  "O3AGFEAGFE"
    .ascii  "O3AGFEAGFE"
    .ascii  "O3F9R"
    .db     0xff

; 通路
soundBgmPath0:

    .ascii  "T6@3V15,4L5"
    .ascii  "O2GGGG3A3O2GGGG3A3"
    .ascii  "O2GGGG3A3O2GGGG3A3O2GGGG3A3O2GGGG3A3"
    .ascii  "O2GGGG3A3O2GGGG3A3O2GGGG3A3O2GGGG3A3"
    .db     0xff

soundBgmPath1:

    .ascii  "T6@12V15,8L9"
    .ascii  "RR"
    .ascii  "O5DEFE"
    .ascii  "O5DEFE"
    .db     0xff

soundBgmPath2:

    .ascii  "T6@12V15,8L9"
    .ascii  "RR"
    .ascii  "O4GAB-A"
    .ascii  "O4GAB-A"
    .db     0xff

; ボス
soundBgmBoss0:

    .ascii  "T3@11V15,3"
    .ascii  "L3O3GGGGFFFFAAAAG+G+G+G+"
    .ascii  "L3BA+BA+BA+BA+O4CO3BO4CO3BO4DC+DC+"
    .db     0xff

soundBgmBoss1:

    .ascii  "T3@15V13,3"
    .ascii  "L3O3GO2GO3GO2GO3F+O2F+O3F+O2F+O3FO2FO3FO2FO3EO2EO3EO2E"
    .ascii  "L3O2D+D+D+RD+D+RD+RC+C+C+RC+C+R"
    .db     0xff

soundBgmBoss2:

    .ascii  "T3@15V13,3"
    .ascii  "L9RR"
    .ascii  "L9RR"
    .db     0xff

; アイドル
soundBgmIdol0:

    .ascii  "T3@12V15,5"
    .ascii  "L3RO5DFAO6C"
    .ascii  "L3O6EDEDEDF9"
    .db     0x00

soundBgmIdol1:

    .ascii  "T3@12V15,5"
    .ascii  "L3R1O4AO5CDF"
    .ascii  "L3O5AGAGAGO5F9R1"
    .db     0x00

soundBgmIdol2:
   
    .ascii  "T3@12V15,5"
    .ascii  "L3R0O4DFAO5C"
    .ascii  "L3O5EDEDEDO5F9R0R1"
    .db     0x00

; ゲームオーバー
soundBgmOver0:

    .ascii  "T4@14V15,9L9"
    .ascii  "O4ADDR"
    .db     0x00

soundBgmOver1:

    .ascii  "T4@14V15,9L9"
    .ascii  "O4DO3BBR"
    .db     0x00

soundBgmOver2:

    .ascii  "T4@14V15,9L9"
    .ascii  "O3GDO2AR"
    .db     0x00

; クリア
soundBgmClear0:

    .ascii  "T3@2V15,5"
    .ascii  "L3O5F7EFD8"
    .ascii  "L3O5G7FGE+8"
    .ascii  "L3O6C7O5BO6CE8"
    .ascii  "L8O5BA"
    .db     0x00

soundBgmClear1:

    .ascii  "T3@2V15,5"
    .ascii  "L8O4AG"
    .ascii  "L8O4BB"
    .ascii  "L8O4FG-"
    .ascii  "L8O4FE-"
    .db     0x00

soundBgmClear2:

    .ascii  "T3@3V13,5"
    .ascii  "L6O3GGO4CC"
    .ascii  "L6O3AAO4DD"
    .ascii  "L6O3BBBB"
    .ascii  "L6O3AADD"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeClick
    .dw     soundSeStart
    .dw     soundSeFade
    .dw     soundSeJump
    .dw     soundSeAttack1
    .dw     soundSeAttack2
    .dw     soundSeDefense
    .dw     soundSeDamage
    .dw     soundSeItem

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; ゲームスタート
soundSeStart:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; フェード
soundSeFade:

    .ascii  "T2@0V16S4M5N7X5X5"
    .db     0x00

; ジャンプ
soundSeJump:

    .ascii  "T1@0V13L0O2AO3AAO4AO5ABO6CD+E+"
    .db     0x00

; 攻撃１
soundSeAttack1:

    .ascii  "T1@0V13L0O4CG+EO5CO4G+O5ECG+EO6CO5EO6CO5EG+CE"
    .db     0x00

; 攻撃２
soundSeAttack2:

    .ascii  "T1@0V13L0O4G+O5CO4EG+CG+CG+CG+CG+CG+CG+"
    .db     0x00

; 防御
soundSeDefense:

    .ascii  "T1@0V13,1L4O6B"
    .db     0x00

; ダメージ
soundSeDamage:

    .ascii  "T1@0V13,1L4O2E"
    .db     0x00

; アイテム
soundSeItem:

    .ascii  "T1@0V13L3O5EE-G-FA"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
