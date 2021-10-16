
; Lesson5f.s	EFFECT "DISSOLUTION" OR "FLOOD" MADE WITH NEGATIVE MODULOS

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist

;	POINTING TO OUR BITPLANES

	MOVE.L	#PIC,d0		; in d0 we put the address of the PIC,
	LEA	BPLPOINTERS,A1	; pointers in the COPPERLIST
	MOVEQ	#2,D1		; number of bitplanes -1 (here we have 3)
POINTBP:
	move.w	d0,6(a1)	; copy the LOW word of the bitplane address
	swap	d0		; swap the two words in d0 (ex: 1234 > 3412)
	move.w	d0,2(a1)	; copy the HIGH word of the plane address
	swap	d0		; swap the two words in d0 (ex: 3412 > 1234)
	ADD.L	#40*256,d0	; + length of bitplane -> next bitplane
	addq.w	#8,a1		; let's go to the next bplpointers in the COP
	dbra	d1,POINTBP	; Redo D1 times POINTBP (D1=num of bitplanes)
;
	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP
	move.w	#0,$dff1fc		; FMODE - Turn off AGA
	move.w	#$c00,$dff106		; BPLCON3 - Turn off AGA

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue

	btst	#2,$dff016	; if the right button is pressed, skip
	beq.s	Aspetta		; the routine of the scroll, blocking it

	bsr.w	Flood		; Moves a WAIT up and down followed by a -40
				; modulo, which causes the FLOOD effect

Aspetta:
	cmpi.b	#$ff,$dff006	; Are we still at line 255?
	beq.s	Aspetta		; If yes, do not continue, wait!

	btst	#6,$bfe001	; is left mouse-button pressed?
	bne.s	mouse		; if not, return to mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Point to system COP
	move.w	d0,$dff088		; COPJMP1 - let's start the COP

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - re-enable il Multitasking
	move.l	GfxBase(PC),a1	; Base of library to close
	jsr	-$19e(a6)	; Closelibrary - close la graphics lib
	rts			; EXIT THE PROGRAM

;	Data

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:	; Here we store the base address for the graphics.library
	dc.l	0

OldCop:		; Here we store the address of the old system COP
	dc.l	0

; Effect definable as "molten metal", obtained with the -40 modulos

Flood:
	TST.B	SuGiu		; Are we going up or down?
	beq.w	VAIGIU
	cmp.b	#$30,FWAIT	; are we high enough?
	beq.s	MettiGiu	; if yes, we are at the top and must come down
	subq.b	#1,FWAIT	; we scroll HIGHER
	rts

MettiGiu:
	clr.b	SuGiu		; resetting SuGiu
	rts

VAIGIU:
	cmp.b	#$f0,FWAIT	; are we low enough?
	beq.s	MettiSu		; if yes, we are at the bottom and must go up
	addq.b	#1,FWAIT	; we scroll LOWER
	rts

MettiSu:
	move.b	#$ff,SuGiu	; When the SuGiu label is not zero, it means
	rts			; we have to go up.


;	This byte, indicated by the SuGiu label, is a FLAG.

SuGiu:
	dc.b	0,0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registers with normal values)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 and 12 set!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;first	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;second  bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;third	 bitplane - BPL2PT

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

FWAIT:
	dc.w	$3007,$FFFE	; WAIT that precedes the negative modulo
	dc.w	$108,-40
	dc.w	$10a,-40

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	image

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

Note that -40 is assembled as $ ffd8 (try a "? -40").
Try to lock the routine with the right mouse button and verify that there is a
"lengthening" of the last line down to the end of the screen.
We have verified that with a negative module of -40 the copper does not
advance, in fact it goes forward by 40 and then goes back by 40. But if we set
the modulo at -80, what happens??? Countdown!!! in fact it reads and displays
40 bytes, then backs 80 bytes, going to the beginning of the previous line,
which is displayed, after which it jumps to the previous line and so on.
This system is mostly used for the MIRROR effects so frequent on the Amiga,
because you just need a couple of copper instructions:

	dc.w	$108,-80
	dc.w	$10a,-80

try to change the two -40 of the modulos in this example into two -80, and the
"MIRROR" will appear, even if this time the problem is that it also displays
something that is above the image (going backwards in memory).
A curiosity: you will notice that in the first line of the "DIRT" that appears
after the mirrored image there is a movement that affects the pixels: it is
the WAIT in the copperlist that we change every frame! In fact, what's in
memory before our image?? La copperlist!! So going backwards in reading memory
(modulo -80), what will be displayed?? The bytes of the copperlist, then what
comes before.

If we increase the negativity we will get more and more crushed mirrors, in
fact the same effect as of the positive modulos occurs, but on the reverse
side.

	dc.w	$108,-40*3
	dc.w	$10a,-40*3

For the half-mirrored image, etc.
