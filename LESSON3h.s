
; Lesson3h.s	SLIDE RIGHT AND LEFT THROUGH THE COPPER WAIT

	SECTION	CiriCop,CODE

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

	bsr.w	CopperDestSin	; Scroll right / left routine

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

; The routine is similar to LESSON3g.s, the only difference is that you act
; on 29 WAIT- instructions instead of 1 through a DBRA-loop that changes a
; WAIT, jumps to the next WAIT, changes the WAIT, jumps to the next WAIT, and
; so on.

CopperDESTSIN:
	CMPI.W	#85,DestraFlag		; Has "VAIDESTRA" been run 85 times?
	BNE.S	VAIDESTRA		; If not, execute it now

	CMPI.W	#85,SinistraFlag	; Has "VAISINISTRA" been run 85 times?
	BNE.S	VAISINISTRA		; If not, execute it now

	CLR.W	DestraFlag	; the VAISINISTRA routine has been performed
				; 85 times, so at this point the gray bar has
	CLR.W	SinistraFlag	; come back and the left-right cycle is
				; finished, so we zero the two flags/counters
				; and exit: the next FRAME will run 
				; VAIDESTRA, after 85 frames go left 85 times
				; for 85 frames, etc.
	RTS			; Return to mouse-loop


VAIDESTRA:			; this routine moves the bar towards RIGHT
	lea	CopBar+1,A0	; Let's put the address of the XX-value of
				; the first WAIT in A0, which is just 1 byte
				; after CopBar

	move.w	#29-1,D2	; we have to change 29 WAIT-instructions (we
				; use a DBRA)
DestraLoop:
	addq.b	#2,(a0)		; add 2 to the X coordinate of the WAIT
	ADD.W	#16,a0		; let's go to the next WAIT to change
	dbra	D2,DestraLoop	; loop executed d2 times
	addq.w	#1,DestraFlag	; we signal that we have performed another
				; VAIDESTRA:
				;In DestraFlag we keep he number of times we
				; have performed VAIDESTRA.
	RTS			; BACK TO THE mouse-LOOP


VAISINISTRA:			; this routine moves the bar to the LEFT
	lea	CopBar+1,A0
	move.w	#29-1,D2	; we have to change 29 WAIT-instructions
SinistraLoop:
	subq.b	#2,(a0)		; subtract 2 from the X coordinate of the WAIT
	ADD.W	#16,a0		; let's go to the next WAIT to change
	dbra	D2,SinistraLoop	; loop executed d2 times
	addq.w	#1,SinistraFlag ; We add 1 to the number of times that
				; VAISINISTRA has been performed.
	RTS			; BACK TO THE mouse-LOOP

; Pay attention to one thing: we change only 1 WAIT for every 2, not all the
; WAITs. Unlike when we position a bar vertically, where just 1 WAIT per line
; is needed:
;
;	dc.w	$YY07,$FFFE	; wait for line YY, line beginning (07)
;	dc.w	$180,$0RGB	; color
;	dc.w	$YY07,$FFFE	; wait for line YY, line beginning (07)
;	...
;
; In this case we have to put 2 WAIT for each line, that is one at the
; beginning of the line and another that runs right and left on that line:
;
;	dc.w	$YY07,$FFFE	; wait for line YY, line beginning (07)
;	dc.w	$180,$0RGB	; color GREY
;	dc.w	$YYXX,$FFFE	; wait for line YY, to the horizontal
				; position that we decide, advancing the GRAY
				; on RED.
;	dc.w	$180,$0RGB	; RED
;


DestraFlag:	; In this word the account of the times that VAIDESTRA: has
		; been performed is kept
	dc.w	0

SinistraFlag:	; In this word the account of the times that VAISINISTRA: has
		; been performed is kept
	dc.w    0


;	data for saving the system copperlist.

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

	dc.w	$2c07,$FFFE	; WAIT - a small green bar
	dc.w	$180,$010	; COLOR0
	dc.w	$2d07,$FFFE	; WAIT
	dc.w	$180,$020	; COLOR0
	dc.w	$2e07,$FFFE	; WAIT
	dc.w	$180,$030	; COLOR0
	dc.w	$2f07,$FFFE	; WAIT
	dc.w	$180,$040	; COLOR0
	dc.w	$3007,$FFFE
	dc.w	$180,$030
	dc.w	$3107,$FFFE
	dc.w	$180,$020
	dc.w	$3207,$FFFE
	dc.w	$180,$010
	dc.w	$3307,$FFFE
	dc.w	$180,$000


	dc.w	$9007,$fffe	; we wait for the first line of the gray bar
	dc.w	$180,$000	; which we set to black
CopBar:
	dc.w	$9031,$fffe	; WAIT that we change ($9033,$9035,$9037...)
	dc.w	$180,$100	; color red, that will start from higher and
				; higher position-values to the right, preceded
				; by the gray color that will progress
				; accordingly.
	dc.w	$9107,$fffe	; WAIT that we don't change (Beginning of line)
	dc.w	$180,$111	; color GRAY (the beginning of the line that
				; goes up to
	dc.w	$9131,$fffe	; this WAIT, that we will change...)
	dc.w	$180,$200	; after which the RED begins

;	let's continue saving space, look at the scheme:

; NOTE: with a "dc.w $1234" we put 1 word in memory, with "dc.w $1234,$1234"
; we put 2 consecutive words in memory, ie the longword "dc.l $12341234" that
; we could put into memory with a "dc.b $12, $34, $12, $34 ", so we can also
; put in memory 8 or more words with only one dc.w!

; For example, line 3 could be rewritten with the dc.l in this way:
; dc.l $9207fffe, $1800222, $9231fffe, $1800300 that is:
; dc.l $9207fffe, $01800222, $9231fffe, $01800300 with *INITIAL* zeros, pay
; attention to the initial zeroes! I write a dc.w $0180 with dc.w $180 simply
; for convenience, but the zero exists, it must be kept in mind!

; To clarify, line 3 complete with initial zeroes would be:
; dc.w $9207, $fffe, $0180, $0222, $9231, $fffe, $0180, $0300 (1 word = $ xxxx)

Ultimately, the "useless" initial zeros of the .b, .w, .l are OPTIONAL.

;		FIXED WAITs (gray)   ,WAITs TO CHANGE (followed by red)

	dc.w	$9207,$fffe,$180,$222,$9231,$fffe,$180,$300 ; line 3
	dc.w	$9307,$fffe,$180,$333,$9331,$fffe,$180,$400 ; line 4
	dc.w	$9407,$fffe,$180,$444,$9431,$fffe,$180,$500 ; line 5
	dc.w	$9507,$fffe,$180,$555,$9531,$fffe,$180,$600 ; ....
	dc.w	$9607,$fffe,$180,$666,$9631,$fffe,$180,$700
	dc.w	$9707,$fffe,$180,$777,$9731,$fffe,$180,$800
	dc.w	$9807,$fffe,$180,$888,$9831,$fffe,$180,$900
	dc.w	$9907,$fffe,$180,$999,$9931,$fffe,$180,$a00
	dc.w	$9a07,$fffe,$180,$aaa,$9a31,$fffe,$180,$b00
	dc.w	$9b07,$fffe,$180,$bbb,$9b31,$fffe,$180,$c00
	dc.w	$9c07,$fffe,$180,$ccc,$9c31,$fffe,$180,$d00
	dc.w	$9d07,$fffe,$180,$ddd,$9d31,$fffe,$180,$e00
	dc.w	$9e07,$fffe,$180,$eee,$9e31,$fffe,$180,$f00
	dc.w	$9f07,$fffe,$180,$fff,$9f31,$fffe,$180,$e00
	dc.w	$a007,$fffe,$180,$eee,$a031,$fffe,$180,$d00
	dc.w	$a107,$fffe,$180,$ddd,$a131,$fffe,$180,$c00
	dc.w	$a207,$fffe,$180,$ccc,$a231,$fffe,$180,$b00
	dc.w	$a307,$fffe,$180,$bbb,$a331,$fffe,$180,$a00
	dc.w	$a407,$fffe,$180,$aaa,$a431,$fffe,$180,$900
	dc.w	$a507,$fffe,$180,$999,$a531,$fffe,$180,$800
	dc.w	$a607,$fffe,$180,$888,$a631,$fffe,$180,$700
	dc.w	$a707,$fffe,$180,$777,$a731,$fffe,$180,$600
	dc.w	$a807,$fffe,$180,$666,$a831,$fffe,$180,$500
	dc.w	$a907,$fffe,$180,$555,$a931,$fffe,$180,$400
	dc.w	$aa07,$fffe,$180,$444,$aa31,$fffe,$180,$300
	dc.w	$ab07,$fffe,$180,$333,$ab31,$fffe,$180,$200
	dc.w	$ac07,$fffe,$180,$222,$ac31,$fffe,$180,$100
	dc.w	$ad07,$fffe,$180,$111,$ad31,$fffe,$180,$000
	dc.w	$ae07,$fffe,$180,$000

;		FIXED WAITs (gray)   ,WAITs TO CHANGE (followed by red)
;
;	As you notice for each line you need 2 WAIT, one to wait for the
;	beginning of the line and one, the one that we modify, to define at
;	which point of the line to change color, that is to go from the gray
;	that is present from the position 07, to the red part after the
;	position taken by the WAIT that we change.
;
	dc.w	$fd07,$FFFE	; I'm waiting for the line $FD
	dc.w	$180,$00a	; blue intensity 10
	dc.w	$fe07,$FFFE	; following line
	dc.w	$180,$00f	; blue intensity maximum (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end


Last little thing: if you're not clear with the initial zeros speech 
addressed earlier, here are some "right" and "wrong" conversions:

	dc.b	1,2	=	dc.w	$0102	or	dc.w	$102

	dc.b	42,$2	=	dc.w	$2a02	(42 decimal = $2a Hex)

	dc.b	12,$2,$12,41	=	dc.w $c02,$1229	=	dc.l $c021229

	dc.b	12,$22,0 = dc.w $000c,$2200 = dc.w $c,$2200 = dc.l $c2200

	dc.w	1,2,3,432 = dc.l $00010002,$000301b0 = dc.l $10002,$301b0

	dc.l	$1234567	=	dc.b 1,$23,$45,$67

	dc.l	$2342		=	dc.b 0,0,$23,$42

	dc.l	4		=	dc.b 0,0,0,4
