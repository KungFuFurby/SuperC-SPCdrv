/**
 * SuperC SeqCmd Subroutine
 *
 *
 */

;------------------------------
; local values
;------------------------------
.enum	$00
	XXXXX		db
.ende
;------------------------------
; Level1 val
;------------------------------
.define		lSeqPointer	$08


; --- ���[�v�J�n�A�h���X�̃Z�b�g
CmdSubroutine:
	push	x
	mov	a, x
	asl	a
	mov	x, a
	call	readSeq
	mov	y, a

	mov	a, (loopStartAdrH+$100)+x
	beq	+			; ���݃��[�v�ݒ肪1���Ȃ��Ȃ玟���X�L�b�v

	inc	x			; ���݃��[�v����(�l�X�g)

	; --- ���[�v�񐔂̃Z�b�g
+	mov	a, y
	mov	(loopNumbers+$100)+x, a

	; --- ���[�`���A�h���X�ǂݏo��
	call	readSeq
	push	a
	call	readSeq
	mov	y, a

	; --- �߂�A�h���X�̃Z�b�g
	mov	a, lSeqPointer
	mov	(loopReturnAdrL+$100)+x, a
	mov	a, lSeqPointer+1
	mov	(loopReturnAdrH+$100)+x, a

	; --- ���[�`���J�n�A�h���X�̃Z�b�g
	pop	a
	call	SetRelativePointer
	mov	(loopStartAdrL+$100)+x, a
	mov	a, y
	mov	(loopStartAdrH+$100)+x, a
	
+	pop	x
	ret


; --- ���[�v�𔲂���
CmdSubroutineReturn:
	push	x
	setp
	call	checkLoopNums
	beq	_subReturn		; �K��񐔃��[�v���Ă���ꍇ�̓��[�v�𔲂���

	; --- �c���[�v������ꍇ�A���[�v�J�n�A�h���X�ɖ߂�
	dec	loopNumbers+x
	mov	a, loopStartAdrH+x
	mov	y, a
	mov	a, loopStartAdrL+x
	bra	_subShareCode

_subReturn:
	mov	loopStartAdrH+x, a
	mov	a, loopReturnAdrH+x
	mov	y, a
	mov	a, loopReturnAdrL+x
_subShareCode:
	pop	x
	clrp
	movw	lSeqPointer, ya
;	stop
	ret


; --- �ŏI���[�v���̂ݏ����𔲂���
CmdSubroutineBreak:
	push	x
	setp
	call	checkLoopNums
	beq	_subReturn
	clrp
	pop	x
	ret				; �c���[�v������ꍇ�͉������Ȃ�


checkLoopNums:
	mov	a, x
	asl	a
	mov	x, a
	inc	x
	mov	a, loopStartAdrH+x
	bne	+
	dec	x
+	mov	a, loopNumbers+x	; ���[�v�c��񐔃`�F�b�N
	ret


;------------------------------
; local values undefine
;------------------------------
.undefine	lSeqPointer


