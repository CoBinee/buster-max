; Sound.inc : サウンド
;


; マクロの定義
;

; BGM
SOUND_BGM_NULL                  =   0x00
SOUND_BGM_TITLE                 =   0x01
SOUND_BGM_PATH                  =   0x02
SOUND_BGM_BOSS                  =   0x03
SOUND_BGM_IDOL                  =   0x04
SOUND_BGM_OVER                  =   0x05
SOUND_BGM_CLEAR                 =   0x06

; SE
SOUND_SE_NULL                   =   0x00
SOUND_SE_CLICK                  =   0x01
SOUND_SE_START                  =   0x02
SOUND_SE_FADE                   =   0x03
SOUND_SE_JUMP                   =   0x04
SOUND_SE_ATTACK_1               =   0x05
SOUND_SE_ATTACK_2               =   0x06
SOUND_SE_DEFENSE                =   0x07
SOUND_SE_DAMAGE                 =   0x08
SOUND_SE_ITEM                   =   0x09

; 外部関数宣言
;

    .globl  _SoundInitialize
    .globl  _SoundPlayBgm
    .globl  _SoundPlaySe
    .globl  _SoundStop
    .globl  _SoundIsPlayBgm
    .globl  _SoundIsPlaySe

; 外部変数宣言
;
