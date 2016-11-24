/**
 * SuperC Library codes
 *
 *
 */

.incdir  "./include/"
.include "spc.inc"
.include "var.inc"
.include "seqcmd.inc"


.incdir "./seqcmd/"

.section "SEQCMD" free

;--------------------------------------------------
; Command Jump Table
;--------------------------------------------------
CmdTable:
	.dw	CmdSetInstrument
	.dw	CmdVolume
	.dw	CmdPanpot
	.dw	CmdJump
	.dw	CmdTempo
	.dw	CmdGlobalVolume
	.dw	CmdEchoOn
	.dw	CmdEchoOff
	.dw	CmdEchoParam
	.dw	CmdSetFIR
	.dw	CmdPortamentoOn
	.dw	CmdPortamentoOff
	.dw	CmdPitchModulation
	.dw	CmdTremolo
	.dw	CmdSubroutine
	.dw	CmdSubroutineReturn
	.dw	CmdSubroutineBreak
	.dw	CmdPitchBend
	.dw	CmdTempoFade
	.dw	CmdVolumeFade
	.dw	CmdGlobalVolumeFade
	.dw	CmdTranspose
	.dw	CmdRelativeTranspose
	.dw	CmdPanFade
	.dw	CmdPanVibration
	.dw	CmdPitchEnvelope
	.dw	CmdCmdCallArg0

CmdLengthTable:
	.db	1	; CmdSetInstrument
	.db	1	; CmdVolume
	.db	1	; CmdPanpot
	.db	2	; CmdJump
	.db	1	; CmdTempo
	.db	1	; CmdGlobalVolume
	.db	0	; CmdEchoOn
	.db	0	; CmdEchoOff
	.db	3	; CmdEchoParam
	.db	8	; CmdSetFIR
	.db	0	; CmdPortamentoOn
	.db	0	; CmdPortamentoOff
	.db	3	; CmdPitchModulation
	.db	3	; CmdTremolo
	.db	3	; CmdSubroutine
	.db	0	; CmdSubroutineReturn
	.db	0	; CmdSubroutineBreak
	.db	3	; CmdPitchBend
	.db	2	; CmdTempoFade
	.db	2	; CmdVolumeFade
	.db	2	; CmdGlobalVolumeFade
	.db	1	; CmdTranspose
	.db	1	; CmdRelativeTranspose
	.db	2	; CmdPanFade
	.db	2	; CmdPanVibration
	.db	3	; CmdPitchEnvelope
	.db	1	; CmdCmdCallArg0

;--------------------------------------------------
; Command Include
;--------------------------------------------------
.include	"CmdCmdCall.s"
.include	"CmdSetInstrument.s"
.include	"CmdVolume.s"
.include	"CmdPanpot.s"
.include	"CmdJump.s"
.include	"CmdTempo.s"
.include	"CmdGlobalVolume.s"
.include	"CmdEcho.s"
.include	"CmdPortamento.s"
.include	"CmdPitchModulation.s"
.include	"CmdTremolo.s"
.include	"CmdSubroutine.s"
.include	"CmdPitchBend.s"
.include	"CmdTempoFade.s"
.include	"CmdVolumeFade.s"
.include	"CmdGlobalVolumeFade.s"
.include	"CmdTranspose.s"
.include	"CmdPanFade.s"
.include	"CmdPanVibration.s"
.include	"CmdHWPitchModulation.s"
.include	"CmdPitchEnvelope.s"
.include	"CmdNotKeyOff.s"

.ends

