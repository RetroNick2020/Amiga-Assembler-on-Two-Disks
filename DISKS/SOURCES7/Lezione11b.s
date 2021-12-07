
; Lesson11b.s - First use of the new startup2.s and an interrupt.

	Section	PrimoInterrupt,CODE

;	Include	"DaWorkBench.s"	; remove the ";" before saving with "WO"

*****************************************************************************
	include	"startup2.s"	; save interrupt, dma etc.
*****************************************************************************


; With DMASET we decide which DMA channels to open and which to close

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA enabled

WaitDisk	EQU	30	; 50-150 to save (as appropriate)

START:
	move.l	BaseVBR(PC),a0	   ; In a0 the value of the VBR
	move.l	#MioInt6c,$6c(a0)  ; I put my routine in interrrupt level 3

	MOVE.W	#DMASET,$96(a5)		; DMACON - enable bitplane, copper
					; and sprites.
	move.l	#COPPERLIST,$80(a5)	; We point to our COP
	move.w	d0,$88(a5)		; Let's start the COP
	move.w	#0,$1fc(a5)		; Disable the AGA
	move.w	#$c00,$106(a5)		; Disable the AGA
	move.w	#$11,$10c(a5)		; Disable the AGA

	movem.l	d0-d7/a0-a6,-(SP)
	bsr.w	mt_init		; initialize the music routine
	movem.l	(SP)+,d0-d7/a0-a6

	move.w	#$c020,$9a(a5)	; INTENA - I enable level 3 "VERTB" interrupt
				; ($6c), the one that is generated once per
				; frame (at line $00).

mouse:
	btst	#6,$bfe001	; Mouse pressed? (the processor runs this
	bne.s	mouse		; loop in user mode, and each vertical blank
				; cuts it off to play the music!).

	bsr.w	mt_end		; end of replay!

	rts			; exit

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (level 3) - used only by VERTB.
*****************************************************************************
;	     ..,..,.,
;	   /~""~""~""~\
;	  /_____ ¸_____)
;	 _) ¬(_° \°_)¬\
;	( __   (__)    \
;	 \ \___ _____, /
;	  \__  Y  ____/xCz
;	    `-----'

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - bit 5, VERTB, is cleared?
	beq.s	NointVERTB	; If so, it's not a "real" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; save the registers on the stack
	bsr.w	mt_music		; I play music
	movem.l	(SP)+,d0-d7/a0-a6	; I take the reg. from the stack
nointVERTB:	 ;6543210
	move.w	#%1110000,$dff09c ; INTREQ - cancel rich. BLIT, COPER, VERTB
				; since the 680x0 does not erase it by itself!!!
	rte	; exit from int COPER / BLIT / VERTB

*****************************************************************************
;	Protracker / soundtracker / noisetracker replay routine
;
	include	"assembler2:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$00e	; color0 BLUE
	dc.w	$FFFF,$FFFE	; End of copperlist

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler2:sorgenti4/mod.yellowcandy"

	end

If we didn't set the VERTB interrupt of level 3 ($6c), this listing would end
in a single loop:

mouse:
	btst	#6,$bfe001	; Mouse pressed? (the processor runs this
	bne.s	mouse		; loop in user mode, and each vertical blank
				; cuts it off to play the music!).

Instead the processor works in "multitasking" blocking the loop every time the 
electronic brush reaches the $00 line, executing MT_MUSIC and returning to 
execute the sterile loop.

Instead of this vile mouse wait loop, we could have put in a routine for
calculating a fractal, which could take several seconds, during which the music
would play "contemporary" and synchronized, without disturbing the calculation 
of the fractal, slowing it down only by the small amount of time it takes to 
play the music every frame.

Note the 2 EQUATES at the beginning of the program, one for switching on the 
DMAs, which we know by now, and the new one:

WaitDisk	EQU	30	; 50-150 to save (as appropriate)

Which "waits" for a while before taking control of the hardware.
To calculate the expected time, consider 50 as 1 second, the Vblank being used,
which goes to the "conquantism". So 150 is 3 seconds.

However, if your program is a fairly large and compacted file, unpacking will 
take just that second or two, so you can leave it at a low value. If, on the 
other hand, you saved the uncompressed file, and started it from floppy disk, 
the execution would start before the drive light goes out, and once in 5 it 
happens that at the exit the DOS went into total coma. To avoid this, always 
calculate that between unpacking and time lost with the "waitdisk" loop, the 
program starts at least 3 seconds after the end of loading.

