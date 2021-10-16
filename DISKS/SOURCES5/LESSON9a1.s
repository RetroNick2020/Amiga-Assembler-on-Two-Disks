
; Lesson9a1.s - RESET OF $ 10 words via the BLITTER
; Before seeing this example, take a look at LESSON2f.s
; where memory is cleared with the 68000

	SECTION Blit,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName,a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,a6		; use a graphics library routine:

	jsr	-$1c8(a6)	; OwnBlitter, which gives us the exclusivity
				; on the blitter preventing its use by the
				; operating system.

				; Before using the blitter we must wait for
				; it to finish any blits in progress.
				; The following instructions deal with this

	btst	#6,$dff002	; wait for the blitter to finish (blank test)
				; for Agnus' BUG
waitblit:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit

; Here's how to do a blitt !!! Only 5 instructions to reset !!!

;	     __
;	__  /_/\   __
;	\/  \_\/  /\_\
;	 __   __  \/_/   __
;	/\_\ /\_\  __   /\_\
;	\/_/ \/_/ /_/\  \/_/
;	     __   \_\/
;	    /\_\  __
;	    \/_/  \/

	move.w	#$0100,$dff040	 ; BLTCON0: only DESTINATION activated and
				 ; the MINTERMS (that is bits 0-7) are all
				 ; reset. This defines the delete operation

	move.w	#$0000,$dff042	 ; BLTCON1: this register we will explain later
	move.l	#START,$dff054	 ; BLTDPT: Destination channel address
	move.w	#$0000,$dff066	 ; BLTDMOD: this register we will explain later
	move.w	#(1*64)+$10,$dff058 ; BLTSIZE: defines the size of the
				    ; rectangle. In this case we have a width
				    ; of $ 10 words and a height of 1 line.
				    ; Since the height of the rectangle must
				    ; be written in bits 6-15 of BLTSIZE we
				    ; have to shift it to the left by 6 bits.
				    ; This is equivalent to multiplying
				    ; its value by 64.
				    ; The width is expressed in the low 6
				    ; bits and therefore is not changed.
				    ; Furthermore, this instruction initiates
				    ; the blitt.

	btst	#6,$dff002	; wait for the blitter to finish (blank test)
waitblit2:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit2

	jsr	-$1ce(a6)	; DisOwnBlitter, the operating system can now
				; use the blitter again
	move.l	a6,a1		; Base of the graphics library to be closed
	move.l	4.w,a6
	jsr	-$19e(a6)	; Closelibrary - I close the graphics lib
	jsr	-$7e(a6)	; Enable - re-enable Multitasking
	rts

******************************************************************************

	SECTION THE_DATA,DATA_C

; note that the data we delete must be in CHIP memory
; in fact the Blitter works only in CHIP memory

START:
	dcb.b	$20,$fe
THEEND:
	dc.b	'Qui non cancelliamo'

	even

GfxName:
	dc.b	"graphics.library",0,0

	end

This example is the blitter version of the Lesson2f.s listing, in which bytes 
were reset through a "clr.l (a0) +" loop.

As in that case, assemble, without Jump, and check with an "M START" that $20
bytes "$fe" are assembled under this label. At this point execute the listing,
activating, for the first time in the course, the blitter, then redo "M START"
and you will verify that these bytes have been reset, up to the THEEND label,
in fact with a "N THEEND" you will always find the text string in its place.

The deletion operation requires the use of channel D only.
Furthermore it is necessary to reset all MINTERMS. Therefore the value to be 
loaded into the BLTCON0 register is $0100.
Note the value that is written in the BLTSIZE register. We need to delete a 
rectangle $10 words wide and one line high. We must always write the width in
bits 0-5 of BLTSIZE and the height in bits 6-15.
To write the height in bits 6-15 we can therefore shift it to the left by 6 
bits, which is equivalent to multiplying it by 64. Therefore to write the 
dimensions of the rectangle to be blitted in the BLTSIZE register the 
following formula is used:

Value to write in BLTSIZE = (HEIGHT*64)+WIDTH

I remind you that the WIDTH is expressed in words.

NOTA: We used an operating system function that we have never covered before, 
namely the one that prevents the operating system from using the blitter to 
avoid using the blitter when the workbench also uses it.
To inhibit and reactivate the use of the blitter by the operating system just 
execute the appropriate routines already ready in the kickstart, more 
particularly in the graphics.library: having in A6 the GFXBASE, it will be 
enough to execute a

	jsr	-$1c8(a6)	; OwnBlitter, which gives us the blitter 
				; exclusively

To ensure that we are the only ones using the blitter, while a

	jsr	-$1ce(a6)	; DisOwnBlitter, the operating system can now 
				; use the blitter again

it will be necessary before exiting the program to reactivate the workbench.

So just remember that when we use the blitter in our masterpieces it is 
necessary to add the OwnBlitter at the beginning and the DisownBlitter at the
end, in addition to the well-known Disable and Enable.
