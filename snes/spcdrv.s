/**
 * SuperC SPC Player Interrupt Handler
 */
.incdir "include"
.include "map.inc"
.include "header.inc"
.incdir ""

/**************************************************/
/* �f�[�^�ǂݍ��݃}�N��                           */
/* �w��|�C���^����A���W�X�^��1�o�C�g�ǂݏo��     */
/*   pointer : �ǂݍ��݃A�h���X�|�C���^           */
/**************************************************/
.macro LoadData args pointer
	lda.b	[pointer]
	ldy.b	pointer
	iny
	bne	+
	inc	pointer+2
	ldy.w	#$8000
+	sty	pointer
.endm

/**************************************************/
/* SPC�h���C�o�ǂݍ��ݏ���                        */
/**************************************************/



.bank 0
.section "UPLOAD_SPCDRIVER" free

/**************************************************/
/* ���[�J���ϐ���`                               */
/**************************************************/
.enum Scratch
	lDataPointer	dsb 3
	lSyncCounter	db
.ende

UploadSPCDriver:
	php

	rep	#$30

	; SPC�̏����҂�
	lda.w	#$bbaa
-	cmp.w	SPC_PORT0
	bne	-

	sep	#$20
	lda.b	#$cc
	sta.b	lSyncCounter

_UploadLoop:
	LoadData lDataPointer	; �ǂݍ��݃T�C�Y Lo
	xba
	LoadData lDataPointer	; �ǂݍ��݃T�C�Y Hi
	pha
	LoadData lDataPointer	; �]���� Lo
	sta.w	SPC_PORT2
	LoadData lDataPointer	; �]���� Hi
	sta.w	SPC_PORT3
	pla
	xba
	rep	#$20
	cmp.w	#0
	beq	_ReturnUpload	; �ǂݍ��݃T�C�Y��0�̏ꍇ�A�]�����I������

	tax			; �]���T�C�Y��X�Ɉړ�
	sep	#$20
	; SPC�ɏ������ݏ���������ʒm���܂�
	lda.b	#1
	sta.w	SPC_PORT1
	lda.b	lSyncCounter
	sta.w	SPC_PORT0
-	cmp.w	SPC_PORT0	; SPC�̉�����҂��܂�
	bne	-
	stz.b	lSyncCounter

_SPCWriteLoop:
	LoadData lDataPointer
	sta.w	SPC_PORT1
	lda.b	lSyncCounter
	sta.w	SPC_PORT0
-	cmp.w	SPC_PORT0
	bne	-
	inc	lSyncCounter
	dex
	bne	_SPCWriteLoop

	; ���u���b�N�̓ǂݏo�������Ɉڍs���܂�
	inc	lSyncCounter
	jmp	_UploadLoop

_ReturnUpload:
	sep	#$20
	stz.w	SPC_PORT1
	lda.b	lSyncCounter
	sta.w	SPC_PORT0
-	cmp.w	SPC_PORT0
	bne	-

	; SPC�|�[�g�̌�n�������܂�
	stz.w	SPC_PORT0
	stz.w	SPC_PORT1
	stz.w	SPC_PORT2
	stz.w	SPC_PORT3

	; P���W�X�^�̓��e�𕜌����ď����𔲂��܂�
	plp
	rts

/**************************************************/
/* ���[�J���ϐ���`�̍폜                         */
/**************************************************/
.undefine	lDataPointer
.undefine	lSyncCounter

.ends


/**************************************************/
/* SPC�h���C�o�ǂݍ���                            */
/**************************************************/
.macro ReadDriver args fileName
	.fopen fileName fp
	.fsize fp size
	; "VER ", "DIR " �̏��ƁA"ESA "�̕����ǂݔ�΂�
	.rept 16
	.fread fp data
	.endr
	; esa���̊i�[�ʒu���擾
	.fread fp data
	.redefine ESA data
	.fread fp data
	.redefine ESA (ESA+(data<<8))
	; TBL���𓾂�
	.rept 4
	.fread fp data
	.endr
	.fread fp data
	.redefine TBL data
	.fread fp data
	.redefine TBL (TBL+(data<<8))
	; LOC���𓾂�
	.rept 4
	.fread fp data
	.endr
	.fread fp data
	.redefine LOC data
	.fread fp data
	.redefine LOC (LOC+(data<<8))
	.redefine MUSICDATA (size-34+LOC)
	.if (MUSICDATA & $ff) != 0
	.redefine MUSICDATA ((MUSICDATA&$ff00)+$100)
	.endif
	; SPC�h���C�o�\�[�X��}������
	.rept 4
	.fread fp data
	.endr
	.dw LOC
	.rept size-34
	.fread fp data
	.db data
	.endr
	.fclose fp
	.undef size,data
.endm

.bank 1
.org 0
.section "SPCDRIVER" semifree
.define ESA 0
.define TBL 0
.define LOC 0
.define MUSICDATA 0
SPCDriver:
	;ReadDriver "../spc/SuperC.bin"
	;.incbin "hc.bin"
	.incbin "x.bin"
.ends

