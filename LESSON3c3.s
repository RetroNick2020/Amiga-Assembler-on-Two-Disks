
; Lesson3c3.s	; BAR GOING DOWN MADE WITH COPPER MOVE & WAIT
		; (TO GO DOWN, USE THE RIGHT MOUSE BUTTON)


	SECTION	SfumaCop,CODE	; even in Fast it's fine

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

	bsr.s	MuoviCopper	; Routine timed to 1 frame

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
	move.l	GfxBase(PC),a1	; Base of lirary to close
				; (libraries should be opened and closed!!!)
	jsr	-$19e(a6)	; Closelibrary - close la graphics lib
	rts


;	This routine moves a bar consisting of 10 wait-instructions downwards

MuoviCopper:
	cmpi.b	#$fa,BARRA10	; have we arrived at the $fa line?
	beq.s	Finito		; if yes, we are at the bottom and we do not
				; continue
	addq.b	#1,BARRA	; WAIT 1 change
	addq.b	#1,BARRA2	; WAIT 2 change
	addq.b	#1,BARRA3	; WAIT 3 change
	addq.b	#1,BARRA4	; WAIT 4 change
	addq.b	#1,BARRA5	; WAIT 5 change
	addq.b	#1,BARRA6	; WAIT 6 change
	addq.b	#1,BARRA7	; WAIT 7 change
	addq.b	#1,BARRA8	; WAIT 8 change
	addq.b	#1,BARRA9	; WAIT 9 change
	addq.b	#1,BARRA10	; WAIT 10 change
Finito:
	rts

	; From here we put the data ...


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


; Here is the COPPERLIST, pay attention to the BARRA labels !!!!


	SECTION	CoppyMagic,DATA_C ; The copperlist MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - only background color
	dc.w	$180,$000	; COLOR0 - Start the cop with the color BLACK

BARRA:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79
	dc.w	$180,$300	; COLOR0 - start the red bar: red to 3
BARRA2:
	dc.w	$7a07,$FFFE	; WAIT - following line
	dc.w	$180,$600	; COLOR0 - red to 6
BARRA3:
	dc.w	$7b07,$FFFE
	dc.w	$180,$900	; red to 9
BARRA4:
	dc.w	$7c07,$FFFE
	dc.w	$180,$c00	; red to 12
BARRA5:
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; red to 15 (maximum)
BARRA6:
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; red to 12
BARRA7:
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; red to 9
BARRA8:
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; red to 6
BARRA9:
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; red to 3
BARRA10:
	dc.w	$8207,$FFFE
	dc.w	$180,$000	; color BLACK

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

To make the bar go down, just change the COPPERLIST, in particular
in this example the various WAITs that make up the bar are changed in
their first byte, that is the one defining the vertical line to wait:

BARRA:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79
	dc.w	$180,$300	; COLOR0 - start of red bar: red to 3
BARRA2:
	dc.w	$7a07,$FFFE	; following line
	dc.w	$180,$600	; red to 6
	...

By putting a label to that byte, you can change that byte by acting on the
label itself, in this case BARRA.

*******************************************************************************

I advise you to make many changes, even the most random, to get familiar
with COPPER: I recommend some:

MODIFICATION1: try to comment out the first 5 ADDQ.b in this way:

;	addq.b	#1,BARRA	; WAIT 1 cambiato
;	addq.b	#1,BARRA2	; WAIT 2 cambiato
;	addq.b	#1,BARRA3	; WAIT 3 cambiato
;	addq.b	#1,BARRA4	; WAIT 4 cambiato
;	addq.b	#1,BARRA5	; WAIT 5 cambiato
	addq.b	#1,BARRA6	; WAIT 6 cambiato
	addq.b	#1,BARRA7	; WAIT 7 cambiato
	....

You will get the "CALA IL SIPARIO" effect, in fact the descent starts in this
way from the middle of the bar. As the last color is valid until it is changed,
it seems that the bar is stretched to the bottom of the screen.
Remove the ";" and we move on to the modification 2.

MODIFICATION2: To get a "ZOOM" effect modify like this: (Use Amiga + b, c, i)

	addq.b	#1,BARRA
	addq.b	#2,BARRA2
	addq.b	#3,BARRA3
	addq.b	#4,BARRA4
	addq.b	#5,BARRA5
	addq.b	#6,BARRA6
	addq.b	#7,BARRA7
	addq.b	#8,BARRA8
	addq.b	#8,BARRA9
	addq.b	#8,BARRA10

Did you understand why the bar is expanded? Because instead of going down
together the WAITs have different "speeds", so the lower ones are distanced
from the upper ones.

MODIFICATION3: This time we will "expand" the bar not downwards, as in the
previous case, but centrally:

	subq.b	#5,BARRA
	subq.b	#4,BARRA2
	subq.b	#3,BARRA3
	subq.b	#2,BARRA4
	subq.b	#1,BARRA5
	addq.b	#1,BARRA6
	addq.b	#2,BARRA7
	addq.b	#3,BARRA8
	addq.b	#4,BARRA9
	addq.b	#5,BARRA10

In fact we changed the first 5 addqs to subq, in this case the upper part
rises instead of going down, and rises similarly to that of the previous
"zoom", in fact the "velocities" are 5,4,3,2,1, while the 5 ADDQs do the same
for the lower part.
