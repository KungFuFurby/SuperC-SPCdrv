/**
 * SuperC Sound Effect Program
 *
 *
 */

.incdir  "./include/"
.include "spc.inc"
.include "var.inc"

.section "SOUND" free
;------------------------------
; local values
;------------------------------
.define		lSeqPointer	$08

SoundEffectProcess:
	mov	x, #MUSICTRACKS

_TrackLoop
	call	LoadTrackBitMemory		; bit単位で管理するメモリをdpに読み出す
	mov	a, track.stepLeft+x
	beq	_SeqAna
	dec	a
	mov	track.stepLeft+x, a	; gate消化
	beq	_Release
	mov	a, track.releaseTiming+x
	beq	_Loop
	dec	a
	mov	track.releaseTiming+x, a
	bne	_Loop
	call	RRApply
	bra	_Loop
_Release:
	mov	a, tmpTrackSysBits
	and	a, #(TRKFLG_TIE | TRKFLG_PORTAM)
	bne	_Loop
	call	ReleaseChannel
	bra	_Loop

_SeqAna:
	mov	a, track.seqPointerH+x
	beq	_Loop
	mov	y, a
	mov	a, track.seqPointerL+x
	movw	lSeqPointer, ya

	call	AnalyzeSeq		; シーケンス解析

	movw	ya, lSeqPointer
	mov	track.seqPointerL+x, a
	mov	a, y
	mov	track.seqPointerH+x, a

_Loop:
	; --- フェーズ処理
	call	PhaseIncrease

	; --- ビット情報のリストア
	call	StoreTrackBitMemory		; bit単位で管理するメモリをdpからメモリに書き込む

	; --- 次トラック解析ループ
	inc	x
	cmp	x, #TRACKS
	bne	_TrackLoop

_EndRoutine:
	ret

;------------------------------
; local values undefine
;------------------------------
.undefine		lSeqPointer

.ends

