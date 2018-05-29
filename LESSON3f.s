
; Lesson3f.s	          BAR UNDER LINE $FF

;	This listing is identical to Lesson3d.s, except that the bar is below
;	the $ FF line that we have never passed.

	SECTION	CiriCop,CODE	; even in Fast it's fine

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC-routine that
				; opens libraries, by using the
				; correct offset from the base-address
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist
	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue

	bsr.s	MuoviCopper	; A routine that makes the bar go down and up

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we still on line 255?
	beq.s	Aspetta		; If yes, wait for the following line ($00),
				; otherwise MuoviCopper will rerun.

	btst	#6,$bfe001	; is left mouse-button pressed?
	bne.s	mouse		; if not, return to mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Point to system COP
	move.w	d0,$dff088		; COPJMP1 - let's start the COP

	move.l	4.w,a6		; Execbase in A6
	jsr	-$7e(a6)	; Enable - re-enable il Multitasking
	move.l	GfxBase(PC),a1	; Base of library to close
				; (libraries should be opened and closed!!!)
	jsr	-$19e(a6)	; Closelibrary - close la graphics lib
	rts

; The MuoviCopper routine is the same, only the values of the maximum
; achievable vertical positions are changed, ie $0a and of the bottom of the
; screen, $2c.

MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; Do we have to go up or down? If SuGiu is
				; reset, (ie the TST verifies the BEQ) then
				; we skip to VAIGIU, if instead it is set to
				; $FF (if this TST is not verified) we continue
				; going up (doing SUBQ)
	beq.w	VAIGIU
	cmpi.b	#$0a,(a0)	; have we arrived at line $0a+$ff? (265)
	beq.s	MettiGiu	; if yes, we are at the top and we have to go
				; down
	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; now we change the other waits: the distance
	subq.b	#1,8*2(a0)	; between a wait and the other is 8 bytes
	subq.b	#1,8*3(a0)
	subq.b	#1,8*4(a0)
	subq.b	#1,8*5(a0)
	subq.b	#1,8*6(a0)
	subq.b	#1,8*7(a0)	; here we have to change all 9 waits of the
	subq.b	#1,8*8(a0)	; red bar every time to make it go up!
	subq.b	#1,8*9(a0)
	rts

MettiGiu:
	clr.b	SuGiu		; By resetting SuGiu, at the "TST.B SuGiu"
				; the BEQ will skip to
	rts			; the VAIGIU routine, and the bar will go down

VAIGIU:
	cmpi.b	#$2c,8*9(a0)	; have we arrived at line $2c?
	beq.s	MettiSu		; if yes, we are at the bottom and we have to
				; go up
	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; now we change the other waits: the distance
	addq.b	#1,8*2(a0)	; between a wait and the other is 8 bytes
	addq.b	#1,8*3(a0)
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)	; here we have to change all 9 waits of the
	addq.b	#1,8*8(a0)	; red bar every time to bring it down
	addq.b	#1,8*9(a0)
	rts

MettiSu:
	move.b	#$ff,SuGiu	; When the SuGiu label is not zero, it means
	rts			; we have to go up.

;	This byte, indicated by the SuGiu label, is a FLAG. In fact it is
;	either $ff or $00, depending on the direction to follow (up or down!).
;	It is just like a flag, which when lowered ($00) indicates that we
;	must go down and when it is up ($FF) we have to go up. It is in fact
;	performed a comparison of the line reached to see if we have reached
;	the top or bottom, and if we have arrived we change the direction
;	(with clr.b SuGiu or move.b #$ff, Sugiu)

SuGiu:
	dc.b	0,0

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:	; Here we store the base address for the graphics.library
	dc.l	0

OldCop:		; Here we store the address of the old system COP
	dc.l	0

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Start the cop with the color BLACK

	dc.w	$2c07,$FFFE	; WAIT - a small green fixed bar
	dc.w	$180,$010	; COLOR0
	dc.w	$2d07,$FFFE	; WAIT
	dc.w	$180,$020	; COLOR0
	dc.w	$2e07,$FFFE
	dc.w	$180,$030
	dc.w	$2f07,$FFFE
	dc.w	$180,$040
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000

	dc.w	$ffdf,$fffe	; WARNING! WAIT FOR THE END OF LINE $FF!
				; the wait after this is under the $FF line
				; and start from $00 !!

	dc.w	$0107,$FFFE	; a fixed green bar UNDER line $FF!
	dc.w	$180,$010
	dc.w	$0207,$FFFE
	dc.w	$180,$020
	dc.w	$0307,$FFFE
	dc.w	$180,$030
	dc.w	$0407,$FFFE
	dc.w	$180,$040
	dc.w	$0507,$FFFE
	dc.w	$180,$030
	dc.w	$0607,$FFFE
	dc.w	$180,$020
	dc.w	$0707,$FFFE
	dc.w	$180,$010
	dc.w	$0807,$FFFE
	dc.w	$180,$000

BARRA:
	dc.w	$0907,$FFFE	; wait for line $79
	dc.w	$180,$300	; start of red bar: red to 3
	dc.w	$0a07,$FFFE	; next line
	dc.w	$180,$600	; red to 6
	dc.w	$0b07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$0c07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$0d07,$FFFE
	dc.w	$180,$f00	; red to 15 (maximum)
	dc.w	$0e07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$0f07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$1007,$FFFE
	dc.w	$180,$600	; red to 6
	dc.w	$1107,$FFFE
	dc.w	$180,$300	; red to 3
	dc.w	$1207,$FFFE
	dc.w	$180,$000	; color BLACK

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

MIRACOLO! We put colored bars under the infamous $FF line!
And just by inserting the command:

	dc.w	$ffdf,$fffe

And start again at $0107,$fffe to wait in the bottom of the screen.
This is because as you know a byte contains only 255 values, ie up to $FF, so
to wait for a line higher than $ff just get there with $FFdf,$FFFE, then the
numbering starts from 0, until the last visible line arrives, around $30.

Note that the American television standard NTSC goes up to the $FF line only,
or slightly more in overscan, so the Americans do not see the bottom of the
PAL-screen on their TVs, but we don't care, because the Amiga is widespread
especially in Europe where we have the PAL standard, in fact the demos and
games are almost always in PAL.

In some cases, programmers make NTSC versions of the game exclusively for
distribution in the USA.

NOTE: For now we have been able to wait with $DFF006 for only one line from
$01 to $FF; I'll explain later how to wait with $dffxxx for a line after $FF
correctly.
