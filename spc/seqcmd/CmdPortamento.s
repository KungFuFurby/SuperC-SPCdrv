/**
 * SuperC SeqCmd Portamento
 *
 *
 */


CmdPortamentoOn:
	set1	tmpTrackSysBits.7
	ret

CmdPortamentoOff:
	;clr1	tmpTrackSysBits.7	; music.s�̐�ǂݏ����ŃN���A����ׁA����Ȃ�
	ret

