
; Lesson3d.s	BAR THAT GOES UP AND DOWN WITH THE COPPER MOVE & WAIT

;	In this listing a label is used as FLAG, ie as a signal to indicate
;	if the bar has to go up or down. Carefully analyze how this program
;	works, it is the first of the course that can present problems in the
;	conditional loops.


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

	move.l	4.w,a6			; Execbase in A6
	jsr	-$7e(a6)		; Enable - re-enable il Multitasking
	move.l	GfxBase(PC),a1		; Base of library to close (libraries
					; should be opened and closed!!!)
	jsr	-$19e(a6)		; Closelibrary - close la graphics lib
	rts

;
;
;
;


MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; Do we have to go up or down? If SuGiu is
				; reset, (ie the TST verifies the BEQ) then
				; we skip to VAIGIU, if instead it is set to
				; $FF (if this TST is not verified) we continue
				; going up (doing SUBQ)
	beq.w	VAIGIU
	cmpi.b	#$82,8*9(a0)	; have we arrived at line $82?
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
	cmpi.b	#$fc,8*9(a0)	; have we arrived at line $fc?
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

	SECTION	GRAPHIC,DATA_C	; This command makes AmigaDOS load this data
				; segment into CHIP RAM, which is mandatory.
				; The copperlist MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Start the cop with the color BLACK
	dc.w	$4907,$FFFE	; WAIT - wait for line $49 (73)
	dc.w	$180,$001	; COLOR0 - dark blue
	dc.w	$4a07,$FFFE	; WAIT - line 74 ($4a)
	dc.w	$180,$002	; blue a little more intense
	dc.w	$4b07,$FFFE	; line 75 ($4b)
	dc.w	$180,$003	; lighter blue
	dc.w	$4c07,$FFFE	; next line
	dc.w	$180,$004	; lighter blue
	dc.w	$4d07,$FFFE	; next line
	dc.w	$180,$005	; lighter blue
	dc.w	$4e07,$FFFE	; next line
	dc.w	$180,$006	; blue to 6
	dc.w	$5007,$FFFE	; jump 2 lines: from $4e to $50,
				; or from 78 to 80
	dc.w	$180,$007	; blue to 7
	dc.w	$5207,$FFFE	; jump 2 lines
	dc.w	$180,$008	; blue to 8
	dc.w	$5507,$FFFE	; jump 3 lines
	dc.w	$180,$009	; blue to 9
	dc.w	$5807,$FFFE	; jump 3 lines
	dc.w	$180,$00a	; blue to 10
	dc.w	$5b07,$FFFE	; jump 3 lines
	dc.w	$180,$00b	; blue to 11
	dc.w	$5e07,$FFFE	; jump 3 lines
	dc.w	$180,$00c	; blue to 12
	dc.w	$6207,$FFFE	; jump 4 lines
	dc.w	$180,$00d	; blue to 13
	dc.w	$6707,$FFFE	; jump 5 lines
	dc.w	$180,$00e	; blue to 14
	dc.w	$6d07,$FFFE	; jump 6 lines
	dc.w	$180,$00f	; blue to 15
	dc.w	$780f,$FFFE	; line $78
	dc.w	$180,$000	; color BLACK

BARRA:
	dc.w	$7907,$FFFE	; wait for line $79
	dc.w	$180,$300	; start of red zone: red to 3
	dc.w	$7a07,$FFFE	; next line
	dc.w	$180,$600	; red to 6
	dc.w	$7b07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$7c07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; red to 15 (maximum)
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; red to 6
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; red to 3
	dc.w	$8207,$FFFE
	dc.w	$180,$000	; color BLACK

	dc.w	$fd07,$FFFE	; wait for line $FD
	dc.w	$180,$00a	; blue intensity 10
	dc.w	$fe07,$FFFE	; next line
	dc.w	$180,$00f	; blue intensity maximum (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

Now the bar goes up and down, through the use of a label that marks if we are
going up or down: if the SuGiu label is zeroed, the instructions are made to
lower the bar, if it is not at zero the instructions that make it go up are
executed. At the beginning the label is zero, then the ADDQs are run that make
it go down, until, once the bottom is reached, the SuGiu label is written with
a $FF, then in the following cycles, when the "TST.b SuGiu" is done , instead
the series of SUBQ that execute it goes up, until it reaches the top, at which
point the SuGiu label is reset again, then the ADDQs that make it go down,
etc., are executed again.

With this routine you can check the effects of the changes well: Try putting a
";" to the instructions waiting for the $FF line with the $dff006:

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR
;	bne.s	mouse		; If not yet, do not go on

	bsr.s	MuoviCopper

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR
;	beq.s	Aspetta	


In this way we lose synchronization with the video, and the bar goes crazy, try
to run it so!!! As you may have noticed, you do not even have time to see its
movement! Especially if you have an Amiga 1200 or a faster computer. Now
instead we will go more slowly with the bar by executing it once every 2 frames
instead of 1 time per frame: make these changes: (Also remove the loop "Wait:")

mouse:
	cmpi.b	#$ff,$dff006	; Are we at line 255?
	bne.s	mouse		; If not yet, do not go on

frame:
	cmpi.b	#$fe,$dff006	; Are we at line 254? (must redo the ride!)
	bne.s	frame		; If not yet, do not go on

	bsr.s	MuoviCopper

;Aspetta:			; taken away, there is no more risk ...
;	cmpi.b	#$ff,$dff006
;	beq.s	Aspetta	

In this case 2 frames of time are lost, in fact when the electronic brush
reaches the line $ff, ie 255, the first loop is passed, and you enter the loop
frame:, which waits for you to arrive at line 254 !!!! To get there, however,
he must get to the bottom, start from the beginning and get to 254, then in
total expect 2 frames.

In fact, by executing the list as modified, it is noted that the speed is
halved. To make it go even slower, you can lose 3 frames:

mouse:
	cmpi.b	#$ff,$dff006	; Are we at line 255?
	bne.s	mouse		; If not yet, do not go on
frame:
	cmpi.b	#$fe,$dff006	; Are we at line 254? (must redo the ride!)
	bne.s	frame		; If not yet, do not go on
frame2:
	cmpi.b	#$fd,$dff006	; Are we at line 253? (must redo the ride!)
	bne.s	frame2		; If not yet, do not go on
	bsr.s	MuoviCopper
	...

With the same method, this time when arriving at line 254 we ask the beam to
get to line 253, which costs another whole frame.

To check which line you have reached, when you exit by pressing YOUR MOUSE,
try doing "M BARRA", and you will see the last value the WAIT had.
