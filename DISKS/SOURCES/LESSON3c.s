
; Lesson3c.s	; BAR THAT GOES DOWN MADE WITH THE COPPER MOVE & WAIT
		; (TO MAKE IT GO DOWN, USE THE RIGHT MOUSE BUTTON)

	SECTION	SECONDCOP,CODE	; even in Fast it's fine

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

	bsr.s	MuoviCopper	; The first movement on the screen !!!!!
				; This subroutine delays the WAIT!
				; and every video screen is executed once
				; in fact bsr.s Muovicopper makes it
				; happen with the routine named Muovicopper,
				; at the end of which, with RTS, the 68000
				; come back here to perform the Wait-routine
				; and so on.

Aspetta:			; if we are still at the $ff line we have
				; waited on before, do not go on.

	cmpi.b	#$ff,$dff006	; are we at $ FF yet? if yes, wait for the
	beq.s	Aspetta		; following line ($00), otherwise MuoviCopper
				; will rerun. This problem is there only for
				; the very short routines that can be
				; run in less than "a line of the electronic
				; brush", called "raster line":
				; the mouse cycle:
				; wait for the $ FF line, then run
				; MuoviCopper, but if it does too much in a
				; hurry we are still on the $ FF line and
				; when we get back to the mouse, to the $FF
				; line we are already there, and Muovicopper
				; re-runs, therefore the routine is
				; performed more than one time each FRAME!!!
				; Especially on A4000!
				; this control avoids the problem by waiting
				; on the next line, so returning to the mouse:
				; to reach the classic fiftieth of a second,
				; $ff line wait is necessary.
				; NOTE: All monitors and TVs they draw the
				; screen at the same speed, while from
				; computer to computer it can vary with the
				; speed of the processor. And for this a
				; timed program with $dff006 go at the same
				; speed on an A500 and up to an A4000. The
				; timing will be dealt with better later,
				; for now worry about understanding the
				; copper-operations.

	btst	#6,$bfe001	; is left mouse-button pressed?
	bne.s	mouse		; if not, return to mouse:

	move.l	OldCop(PC),$dff080	; Point to system-COP
	move.w	d0,$dff088		; let's start the cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable il Multitasking
	move.l	gfxbase(PC),a1	; Base of lirary to close
				; (libraries should be opened and closed!!!)
	jsr	-$19e(a6)	; Closelibrary - close la graphics lib
	rts

;
; This little routine makes the copper-wait go down on the screen, increasing
; it, in fact the first time performed it will change the
;
;	dc.w	$2007,$FFFE	; wait for la linea $20
;
;	into:
;
;	dc.w	$2107,$FFFE	; wait for la linea $21! (then $22,$23 etc.)
;
;	NOTE: once the maximum value for a byte has been reached, ie $ FF,
;	if you execute an additional ADDQ.B #1, BARRA starts again from 0,
;	until you get back to $ ff and so on.

Muovicopper:
	addq.b	#1,BARRA	; WAIT changed by +1, the bar drops 1 line
	rts

; Try changing this ADDQ to SUBQ and the bar will go up !!!!

; Try changing the addq / subq #1,BARRA into #2, #3 or more and the speed
; will increase, since for every FRAME the wait will move by 2, 3 or more
; lines. (if the number is greater than 8 instead of ADDQ.B you have to use
; ADD.B)

;	DATA...

GfxName:
	dc.b	"graphics.library",0,0	; NOTE: to put characters in
					; memory always use the dc.b
					; and put them between " " or ''
					; and terminate with 0
					; make sure you have an even
					; number of bytes. (Here we have added
					; an extra 0 to make the
					; GfxBase-longword
					; begin on an even address)

GfxBase:		; Here is the base address for the graphics.library
	dc.l	0

OldCop:			; Here is the address of the old system COP
	dc.l	0

;	DATI GRAFICI...

	SECTION	GRAPHIC,DATA_C	; This command makes AmigaDOS load
				; this segment of data in CHIP RAM.
				; The copperlist MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, only background.
	dc.w	$180,$004	; COLOR0 - Start the cop with the DARK BLUE
				; color
BARRA:
	dc.w	$7907,$FFFE	; WAIT - wait for la linea $79
	dc.w	$180,$600	; COLOR0 - start the red zone: red to 6
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

Ahh! I had forgotten to put the (PC) in "lea GfxName,a1", but now it's there.
Those who had noticed that it could be put in took a positive notice.
In this program we have a synchronized movement with the electronic brush,
in fact the bar drops fluidly.

NOTE1: In this listing you can confuse the cycle structure with the mouse-test
and the test of the position of the electronic brush; what you must
have clear is that the routines, or subroutines, that lie between
mouse: and the aspetta: (wait) is executed once every video frame:
try to replace the bsr.s Muovicopper with the subroutine itself,
without the final RTS of course:

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue

;	bsr.s	MuoviCopper	; A routine performed every frame (For
				; smoothness)
	addq.b	#1,BARRA	; WAIT-value changed by +1, the bar drops 1
				; line

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we still at line 255?
	beq.s	Aspetta		; If so, don't continue, wait for next line.
				; Otherwise MuoviCopper is replayed.

In this case the result does not change because instead of executing the
ADDQ from a subroutine, we execute it directly, and maybe in this case it is
even more comfortable; but when the subroutines are longer it is better to
do various BSRs for easier navigation. For example if you duplicate the
"bsr.s Muovicopper", the routine will be performed twice per frame, and will
double the speed:

	bsr.s	MuoviCopper	; A routine performed every frame (For
				; smoothness)
	bsr.s	MuoviCopper	; A routine performed every frame (For
				; smoothness)

The benefits of the subroutines lies precisely in the better readability of
the program, imagine if our routines between mouse: and aspetta: were made of
thousands of lines! the succession of things would appear less clear. instead
if we call every single routine by name, everything will appear easier.

*

To make the bar go down, just change the COPPERLIST, in particular
in this example the WAITs are changed, in their first byte, that is
where we define what vertical line to wait for:

BARRA:
	dc.w	$2007,$FFFE	; WAIT - wait for line $20
	dc.w	$180,$600	; COLOR0 - start the red zone: red to 6

By putting a label to that byte, you can change that byte by acting on the
label itself, in this case BARRA.

MODIFICATIONS:
Try to change the color instead of the wait: just put a label
where you want in the copperlist and you can change what you want.
Put the color bar like this:

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes, only background.

	dc.w	$180,$004	; COLOR0 - Start the cop with a DARK BLUE
				; color

;;;;BARRA:			; ** REPLACE THE OLD LABEL with the ;;
	dc.w	$7907,$FFFE	; WAIT - wait for line $79

	dc.w	$180		; COLOR0
BARRA:				; ** PUT THE NEW LABEL TO THE VALUE OF COLOR.
	dc.w	$600		; start the red zone: red to 6

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

You will get a variation of the intensity of red, in fact we change the
first byte of the color: $0RGB, or $0R, or RED !!!!

Try now to act on the whole WORD of the color: change the routine so:

	addq.w	#1,BARRA	; instead of .b we operate on the .w
	rts

Try it and check that the colors follow each other irregularly, in fact they
are the result of the increasing number: $601, $602 ... $631, $632 ...
generating colors in a strange way.

NOTE: the dc directive stores bytes, words or longs, so you can get the same
result by writing:

	dc.w	$180,$600	; Color0

	or:

	dc.w	$180	; Register Color0
	dc.w	$600	; value of Color0

	There are no syntax problems like with MOVEs.
