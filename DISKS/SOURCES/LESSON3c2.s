
; Lesson3c2.s	; BAR GOING DOWN MADE WITH COPPER MOVE & WAIT
		; (TO GO DOWN, USE THE RIGHT MOUSE BUTTON)

;	Added a control of the line reached to stop the scroll


	SECTION	MaremmaCop,CODE	; even in Fast it's fine

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
	move.l	#COPPEROZZA,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue

	btst	#2,$dff016	; POTINP - Right mouse button pressed?
	bne.s	Aspetta		; If no, don't execute Muovicopper

	bsr.s	MuoviCopper	; This subroutine delays the WAIT! and is
				; executed once every video frame
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

;
; This little routine makes the copper-wait go down on the screen, increasing
; it, in fact the first time performed it will change the
;
;	dc.w	$2007,$FFFE	; WAIT - wait for la linea $20
;
;	into:
;
;	dc.w	$2107,$FFFE	; WAIT - wait for la linea $21!
;
;	and so on, up to the specified maximum, in this case $fc
;

MuoviCopper:
	cmpi.b	#$fc,BARRA	; have we arrived at the $fc line?
	beq.s	Finito		; if yes, we are at the bottom and we do not
				; continue
	addq.b	#1,BARRA	; add 1 to WAIT-instruction, the bar drops
				; by 1 line
Finito:
	rts

;	In this case, if BARRA: has reached the value $fc, the addq is skipped

;	P.S: for now you can not reach the final part of the screen after
;	$FF, I'll explain later why and how.

GfxName:
	dc.b	"graphics.library",0,0	; NOTE: to put characters in  memory
					; always use the dc.b and put them
					; between " " or '' and terminate
					; with 0
					; make sure you have an even number
					; of bytes. (Here we have added an
					; extra 0 to make the GfxBase-longword
					; begin on an even address)

GfxBase:	; Here is the base address for the graphics.library
	dc.l	0

OldCop:		; Here is the address where we store the old system COP
	dc.l	0

	SECTION	MiaCoppy,DATA_C	; The copperlist MUST be in CHIP RAM!

COPPEROZZA:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, only background.

	dc.w	$180,$004	; COLOR0 - Start the cop with the DARK BLUE
				; color

BARRA:
	dc.w	$7907,$FFFE	; WAIT - wait for line $79

	dc.w	$180,$600	; COLOR0 - start the red zone: red to 6

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

As a change, try changing the $fc of the line:

	cmpi.b	#$fc,BARRA

Putting different values you will verify that the bar goes down to the line
you specify.
