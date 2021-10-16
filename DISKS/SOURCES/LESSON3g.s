
; Lesson3g.s	SLIDE RIGHT AND LEFT THROUGH THE COPPER WAIT


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


; Up until now we have been acting on the first byte of thw word to the left
; of the WAIT-instrution, ie the one that determines the Y-position, by 
; lowering or raising the wait with the following colors. This routine on the
; other hand, acts on the second byte, that of the X, generating a shift to
; the right and left. Controlled by 2 similar flags, as we saw with the
; SuGiu-flag. In this routine they are called DestraFlag and
; SinistraFlag, where we store the number of times the VAIDESTRA or VAININTRA
; routines have been performed, to limit the displacement (ie to decide how
; much to go ahead before we go back): in fact every time the VAIDESTRA
; routine is performed, the "gray bar" advances to the right, so we have to
; stop it when it reaches the opposite edge of the screen, in this case when
; it was performed 85 times, after which we go back by doing another 85
; repetitions with the VAISINIST routine, which returns it to the initial
; position, and the cycle starts again to continue until we press the mouse
; button.

; NOTE THAT THIS ROUTINE GOES TO VAIDESTRA OR TO VAISINISTRA, YOU ARE NOT
; EXECUTING BOTH: WHEN ONE OF THE ROUTINES HAVE BEEN PERFORMED, THEN YOU GO
; BACK FROM THAT ROUTINE TO THE MOUSE:-LOOP. WHEN THE CYCLE OF THE VAIDESTRA
; AND VAISINISTRA IS FINISHED (AFTER 2 * 85 FRAMES), RETURN TO "MOUSE:" WITH
; THE RTS OF THE ROUTINE "CopperDestSin" directly, after having reset the 2
; flags.


CopperDestSin:
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
	addq.b	#2,CopBar	; add 2 to the X coordinate of the wait
	addq.w	#1,DestraFlag	; we signal that we now have performed
				; VAIDESTRA: in DestraFlag is the number of
				; times we have performed VAIDESTRA.
	RTS			; Return to mouse-loop


VAISINISTRA:			; this routine moves the bar to the LEFT
	subq.b	#2,CopBar	; we subtract 2 from the X coordinate
				; of the wait
	addq.w	#1,SinistraFlag ; We add 1 to the number of times that
				; VAISINISTRA has been performed.
	RTS			; Return to mouse-loop


DestraFlag:		; In this word the account of the times that
	dc.w	0	; VAIDESTRA has been performed is kept

SinistraFlag:		; In this word the account of the times that
	dc.w    0	; VAISINISTRA has been performed is kept


;	data to save the system copperlist.

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


	dc.w	$9007,$fffe	; WAIT for the start of line $90
	dc.w	$180,$AAA	; COLOR Grey

; Here we have "BROKEN" the first WORD of WAIT $9031 in 2 bytes in order to
; put a label (CopBar) to indicate the second byte, or $31 (The XX)

	dc.b	$90	; POSITION YY of the WAIT (first byte of the WAIT)
CopBar:
	dc.b	$31	; POSITION XX of the WAIT (The one we change!!!)
	dc.w	$fffe	; WAIT - (it will become $9033,$FFFE - $9035,$FFFE....)

	dc.w	$180,$700	; color RED, that will start from increasingly
				; greater positions to the right, preceded by
				; the gray that will progress accordingly.
	dc.w	$9107,$fffe	; A WAIT that we do not change (Start of line
	dc.w	$180,$000	; $91) which serves to change the color to
				; BLACK to the line following the bar.

; As you notice for the $90 line you need 2 WAIT-instrutions, one to wait for
; the beginning of the line (07) and one, the one that we modify (31), to
; define at which position of the line to change the color, that is to go
; from the grey that is present from position 07, to red that starts after
; the position taken by the WAIT that we change.
;
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

Nice Eh? An effect of this kind is often used to make bar equalizers for music.
The horizontal movement through the WAIT, however, has limits, in fact you can
only give odd values, and that is why we usually wait for line $yy07,$fffe and
not $yy08,$fffe.

As a result, you can scroll in increments of 2 at a time: 7, 9, $b, $d, $f,
$11, $13 ... or every 4 pixels in lores, or 8 in hires, keeping the odd number
anyway, or you risk causing the Amiga to explode.

Note: the maximum value of XX is $e1. (translators note: The Hardware
Reference Manual says $e2).

As a change then I can only advise you to add 4 or 8 instead of 2 to change
speed, in this case also remember to change the maximum number of iterations
of the routine:


	CMPI.W	#85/2,DestraFlag	; 85 times /2, or "divided by 2"
	BNE.S	VAIDESTRA
	CMPI.W	#85/2,SinistraFlag	; 85/2, or 42 times
	BNE.S	VAISINISTRA		; if not yet, re-run the routine
	....

	addq.b	#4,(a0)			; we add 4...
	....

Or for a "addq.b #8,a0":

	CMPI.W	#85/4,DestraFlag	; 85 times /4, or 21


If you are a sadist, try putting an ADDQ.B #1,(a0), creating even XX WAITs...
In the best case your screen will disappear to "flash" when the disparity 
occurs (in fact the screen is "switched off" when a naive programmer puts a
WAIT with equal XXs), or if you WAIT for a strange value you will sometimes
generate a total block of the computer, a kind of "GURU MEDITATION" of Copper.
So be careful!!!

I can point out some particular even coordinates that, instead of just making
the screen disappear, sends the copper right into the ball, forcing you to
reset. (at least on the Amiga 1200 where I tried them)

	dc.w	$79DC,$FFFE	; $dc = 220! even and particularly ACID!
				; it makes the copper go crazy, but it does
				; not stop the 68000, in fact you can
				; continue to work "blindly", without seeing
				; anything

	dc.w	$0100,$FFFE	; this instead BLOCKS everything, you can not
				; even exit the program, you have to reset

	dc.w	$0300,$FFFE	; Another total block...


These "ERRORS" can be useful if you want to protect programs:
In case a disk is badly copied or the password is incorrect, immediately
pointing to a copperlist with these jagged WAITs, you BLOCK the computer worse
than with a 68000 guru, and every Action Replay or other cartridges are
disabled and unusable.

Or could these WAITs be used as self-destruction, who knows if putting many
errors in a row can damage the computer PHYSICALLY ???

NOTE: You can get an effect like this by editing the example Lesson3c2.s that
moves a WAIT down just by editing the routine:

MuoviCopper:
	cmpi.b	#$fc,BARRA	; have we arrived at line $fc?
	beq.s	Finito		; if so, we are at the bottom and we do not
				; continue
	addq.b	#1,BARRA	; WAIT changed by one, the bar drops 1 line
Finito:
	rts

In this way, making it change position XX instead of YY (BAR + 1), and making
it advance by 2 instead of 1 at a time (ODD numbers!), without forgetting that
the maximum value is $e1, we need to replace the $fc:

MuoviCopper:
	cmpi.b	#$e1,BARRA+1	; have we arrived at position $e1?
	beq.s	Finito		; if so, we are at the end and we do not
				; continue
	addq.b	#2,BARRA+1	; WAIT changed by 2, the bar advances by 4
				; pixels
Finito:
	rts

You will see the first line moving to the right instead of falling. To
highlight the effect you can "INSULATE" the $79 line by turning the screen
from the next line to dark blue, that is, the $7a by adding these 2 lines
before the end of the copperlist:

	dc.w	$7a07,$FFFE	; wait for line $79
	dc.w	$180,$004	; start of red zone: red to 6

In lesson3g the difficulty is perhaps in the routine that moves the bar
forward and backward rather than in the fact that we operate on the XX
position rather than on the YY position. In fact, the last lessons where you
have dealt with 68000 routines are not too simple, but they are indispensable
to generate the effects with the copper, so to understand the copper itself;
in Lesson 4, the 68000 routines will be simpler than those in this lesson 3,
explaining how to display static images.

If you can not fully understand the routines of the last lessons then proceed
with Lesson 4, and try again to understand them when you find yourself later
in the course, when you will certainly be more familiar with the routines. The
Lesson3h.s is an extension of the Lesson3g.s.
