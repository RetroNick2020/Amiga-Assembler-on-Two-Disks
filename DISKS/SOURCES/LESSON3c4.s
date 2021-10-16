
; Lesson3c4.s	; BAR GOING DOWN MADE WITH COPPER MOVE & WAIT
		; (TO GO DOWN, USE THE RIGHT MOUSE BUTTON)

;	In this listing we move a gradient bar composed of 10 wait downwards,
;	so you act on 10 wait!
;	The difference with Lezione3c3.s is the use of only one label,
;	"BAR", instead of 10 labels, thanks to the addressing distance.

	SECTION	BarraRossa,CODE	; even in Fast it's fine

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

	btst	#2,$dff016	; POTINP - Right mouse button pressed?
	bne.s	Aspetta		; If no, don't execute Muovicopper

	bsr.s	MuoviCopper	; Always more difficult

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
	move.l	GfxBase(PC),a1		; Base of lirary to close
					; (libraries should be opened and
					; closed!!!)
	jsr	-$19e(a6)		; Closelibrary - close la graphics lib
	rts


;	This routine moves down a bar consisting of 10 wait-instructions

MuoviCopper:
	LEA	BARRA,a0	; put address of BARRA: in a0
	cmpi.b	#$fc,8*9(a0)	; have we arrived at line $fc?
	beq.s	Finito		; if yes, we are at the bottom, don't continue
	addq.b	#1,(a0)		; WAIT changed by 1 (indirect without offset).
	addq.b	#1,8(a0)	; Now we change the other WAIT with offset.
	addq.b	#1,8*2(a0)	; between a WAIT and the other is 8 bytes, in
	addq.b	#1,8*3(a0)	; fact dc.w $xx07,$FFFE,$180,$xxx are two
	addq.b	#1,8*4(a0)	; longwords. So if we make an addressing
	addq.b	#1,8*5(a0)	; distance of 8 from the current WAIT to the
	addq.b	#1,8*6(a0)	; following, we modify the dc.w $xx07,$fffe.
	addq.b	#1,8*7(a0)	; We have to change all 9 WAITs of the red
	addq.b	#1,8*8(a0)	; bar on every execution of the routine to
				; make it go down!
	addq.b	#1,8*9(a0)	; last WAIT! (BARRA10 of the previous source)
Finito:
	rts	; P.S: With this RTS you return to the MOUSE loop
		; that waits for timing.

;	NOTE: "*" means "multiplication", "/" means "division"

	; data

GfxName:
	dc.b	"graphics.library",0,0	; NOTE: to put characters in
					; memory always use the dc.b
					; and put them between " " or ''
					; and terminate with 0
					; make sure you have an even
					; number of bytes. (Here we have added
					; an extra 0 to make the GfxBase-
					; longword begin on an even address)

GfxBase:	; Here we store the base address for the graphics.library
	dc.l	0

OldCop:		; Here we store the address of the old system COP
	dc.l	0

	SECTION	GRAPHIC,DATA_C	; The copperlist MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$000	; COLOR0 - Start the cop with the color BLACK

BARRA:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79
	dc.w	$180,$300	; COLOR0 - start the red bar: red to 3
	dc.w	$7a07,$FFFE	; WAIT - following line
	dc.w	$180,$600	; COLOR0 -red to 6
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

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

To make the bar go down, just change the COPPERLIST, in particular in this
example, the various WAITs that make up the bar are changed in their first
byte, that is the one defining the vertical line to wait for:

BARRA:
	dc.w	$7907,$FFFE	; WAIT - I'm waiting for line $79
	dc.w	$180,$300	; COLOR0 - start the red bar: red to 3
	dc.w	$7a07,$FFFE	; following line
	dc.w	$180,$600	; red to 6
	...

By putting a label to that byte, you can change it by acting on the label
itself, in this case BARRA. However, the bar in question is made of 9 WAIT +
color0, so to "move" you have to change all 9 WAITs, while the colors0
(dc.w $ 180, $ xxx) that are below the WAIT remain unaffected. To reach all
9 WAITs, rather than putting a LABEL to all, it is faster to load the address
of the first in a register and change the others by making addressing
distances:

MuoviCopper:
	LEA	BARRA,a0
	cmpi.b	#$fc,8*9(a0)	; let's check the last wait, that defines the
	beq.s	Finito		; lower part of the bar.
	addq.b	#1,(a0)		; change tha byte at BARRA:
	addq.b	#1,8(a0)	; change the byte 2 longwords after BARRA:
	addq.b	#1,8*2(a0)	; change the byte 4 longwords after BARRA:
	addq.b	#1,8*3(a0)	; change the byte 2 longwords after...
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)
	addq.b	#1,8*8(a0)
	addq.b	#1,8*9(a0)
Finito:
	rts

NOTE: Try to make a "D MuoviCopper", and you will verify that the 8*2, 8*3
etc. are assembled like:

	ADDQ.B	#1,$8(A0)
	ADDQ.B	#1,$10(A0)
	ADDQ.B	#1,$18(A0)
	ADDQ.B	#1,$20(A0)
	ADDQ.B	#1,$28(A0)

That is with the result of 8*2 (ie 16, or $10), of 8*3 ($18) ...

As a last modification, try changing the $fc of the line

	cmpi.b	#$fc,8*9(a0)

Input lower values, and you will verify that the bar goes down to the
line you specify.
