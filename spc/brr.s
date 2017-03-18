/**
 * SuperC brr Table
 *
 *
 */

.incdir  "./include/"
.include "spc.inc"
.include "var.inc"

.incdir  "./macro/"
.include "readbrr.mac"

.bank 3 slot 3
;.orga (DIR<<8)

.section "__DIR__" size $180 align 256 free
DirTbl:
; --- DIR情報
;     ※注 : BRR実データと読み込み順を合わせること
	.dw	SPWAV0, SPWAV0+9
	DirInfo "./brr/p0.brr"	
	DirInfo "./brr/p1.brr"	
	DirInfo "./brr/poke-rgb_tri.brr"	
	DirInfo "./brr/kick.brr"
	DirInfo "./brr/snare.brr"
	DirInfo "./brr/pi_d6.brr"
;	DirInfo "./brr/smwpiano.brr"
.ends

.ifdef _MAKESPC

.orga (DIR<<8 + $100)
.section "BRR" force
BrrData:
; --- BRR実データ
;     ※注 : DIR情報と読み込み順を合わせること
	BrrData "./brr/p0.brr"	
	BrrData "./brr/p1.brr"	
	BrrData "./brr/poke-rgb_tri.brr"	
	BrrData "./brr/kick.brr"
	BrrData "./brr/snare.brr"
	BrrData "./brr/pi_d6.brr"
;	BrrData "./brr/smwpiano.brr"
.ends

.endif


/**
 * 特殊波形生成機能
 */
.org 0
.section "SPECIALWAVE" free
SpecialWavFunc:
	mov	a, specialWavPtr
	lsr	a
+	mov	x, a
	mov	a, !SPWAV0+9+x
	bcc	+
	eor	a, #$0f
	bra	++
+	eor	a, #$f0
++	mov	!SPWAV0+9+x, a
	inc	specialWavPtr
	mov	a, specialWavPtr
	mov	y, #0
	mov	x, #18
	div	ya, x
	mov	a, y
	bne	+
	inc	specialWavPtr
	inc	specialWavPtr
;	bra	++
+	mov	a, specialWavPtr
	cmp	a, #SPWAV_MAX
	bmi	++
	mov	a, #SPWAV_MIN
	mov	specialWavPtr, a
++	ret

.define SPWAVN 1

.if SPWAVN == 1
SPWAV0:
	.db	$02, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$b2, $78, $88, $88, $88, $88, $88, $88, $88
	.db	$b2, $88, $88, $88, $88, $88, $88, $88, $88
	.db	$b2, $77, $77, $77, $77, $77, $77, $77, $77
	.db	$b3, $77, $77, $77, $77, $77, $77, $77, $78
;	.db	$b2, $88, $88, $88, $88, $88, $88, $88, $88
;	.db	$b3, $88, $88, $88, $88, $88, $88, $88, $88
.endif

.if SPWAVN == 2
   ; 出力元波形を違うものにすれば面白い音になるかな？と思ったけど
   ; SPWAV0と大差なかったので、コメントアウト
SPWAV0:
	.db	$02, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$b2, $00, $11, $22, $33, $44, $55, $66, $77
	.db	$b2, $00, $11, $22, $33, $44, $55, $66, $77
	.db	$b2, $88, $99, $aa, $bb, $cc, $dd, $ee, $ff
	.db	$b3, $88, $99, $aa, $bb, $cc, $dd, $ee, $ff
.endif

.if SPWAVN == 3
   ; これはある意味面白い音だけど、あまり有用じゃなかった
SPWAV0:
	.db	$02, $00, $00, $00, $00, $00, $00, $00, $00
	.db	$c2, $01, $23, $45, $67, $76, $54, $32, $10
	.db	$c2, $01, $23, $45, $67, $76, $54, $32, $10
	.db	$c2, $fe, $dc, $ba, $98, $89, $ab, $cd, $ef
	.db	$c3, $fe, $dc, $ba, $98, $89, $ab, $cd, $ef
.endif

.ends
