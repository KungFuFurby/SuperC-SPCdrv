/**
 * SuperC SeqCmd Tremolo
 *
 *
 */

/* TODO: ��������`�Ǝ����̏������� */

CmdTremolo:
	call	readSeq
	mov	track.modulationDelay+x, a
	call	readSeq
	mov	track.modulationRate+x, a
	mov	a, #0
	mov	track.PitchSpan+x, a
	call	readSeq
-	mov	track.modulationDepth+x, a
	ret

CmdTremoloOff:
	mov	a, #0
	bra	-

