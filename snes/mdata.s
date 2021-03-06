/**
 * 音楽メインデータ
 */
.incdir "include"
.include "map.inc"
.include "header.inc"
.incdir ""

;-------------------------------------------------
; BANK 1 - 音楽関連テーブル
;-------------------------------------------------
.bank 1
.org 0

;---------------------------------------
; 曲番号に対応したBRRセット番号(256bytes)
;---------------------------------------
BrrSetNumber:
.org $100

;---------------------------------------
; EDL・BRRセットアドレス(2bytes * 256)
;---------------------------------------
BrrSetAddress:
.org $300

;---------------------------------------
; BRRデータアドレス(3bytes * 256)
;---------------------------------------
BrrDataAddress:
.org $600

;---------------------------------------
; シーケンスデータアドレス(3bytes * 256)
;---------------------------------------
SeqDataAddress:
.org $900

;---------------------------------------
; EDL・BRRセット
;  データ構成
;    +----------+
;    |   EDL    | ... 0x00 ~ 0x0f
;    +----------+
;    | BRR 0x20 | ... 0x01 ~ 0xff
;    +----------+
;    | BRR 0x21 | ... 0x01 ~ 0xff
;    +----------+
;    | BRR 0x22 | ... 0x01 ~ 0xff
;    +----------+
;    | BRR 0xnn | ... 0x00 (TERM)
;    +----------+
;---------------------------------------
BrrSet:
	; e.g.
	; .db $04                  ; EDL : 4
	; .db $01, $02, $04, $00   ; BRR No.1, No.2, No.4


;-------------------------------------------------
; BANK 1 - 音楽関連実データ
;-------------------------------------------------
.bank 2
.org 0

Brr:
	; BRR実データ
Music:
	; シーケンス実データ

