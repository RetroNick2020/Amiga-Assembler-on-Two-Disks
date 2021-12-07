
; Lesson7b.s	DISPLAYING A SPRITE - RIGHT BUTTON TO MOVE IT


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Library name
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; save old COP

;	We point to the "empty" PIC

	MOVE.L	#BITPLANE,d0	; where to point
	LEA	BPLPOINTERS,A1	; pointers COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

;	we point to the sprite

	MOVE.L	#MIOSPRITE,d0		; address of the sprite in d0
	LEA	SpritePointers,a1	; Pointers in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	move.l	#COPPERLIST,$dff080	; our COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Line 255?
	bne.s	mouse

	btst	#2,$dff016	; Right mouse button pressed?
	bne.s	Aspetta		; if not, skip the routine that moves the
				; sprite

	bsr.s	MuoviSprite	; Move sprite 0 to the right

Aspetta:
	cmpi.b	#$ff,$dff006	; line 255?
	beq.s	Aspetta

	btst	#6,$bfe001	; mouse pressed?
	bne.s	mouse

	move.l	OldCop(PC),$dff080	; We point to the system cop
	move.w	d0,$dff088		; let's start the old cop

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable
	move.l	gfxbase(PC),a1
	jsr	-$19e(a6)	; Closelibrary
	rts

;	Data

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

; This routine shifts the sprite to the right by acting on its HSTART byte, that
; is the byte of its X position. Note that it scrolls by 2 pixels every time


MuoviSprite:
	addq.b	#1,HSTART	; (same as writing addq.b #1,MIOSPRITE+1)
	rts


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
SpritePointers:
	dc.w	$120,0,$122,0,$124,0,$126,0,$128,0 ; SPRITE
	dc.w	$12a,0,$12c,0,$12e,0,$130,0,$132,0
	dc.w	$134,0,$136,0,$138,0,$13a,0,$13c,0
	dc.w	$13e,0

	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; access bit 12!! 1 bitplane lowres

BPLPOINTERS:
	dc.w $e0,0,$e2,0	;first bitplane

	dc.w	$180,$000	; color0	; black background
	dc.w	$182,$123	; color1	; color 1 of the bitplane,
						; which in this case is
						; empty, so it does not
						; appear.

	dc.w	$1A2,$F00	; color17, or COLOR1 of sprite0 - RED
	dc.w	$1A4,$0F0	; color18, or COLOR2 of sprite0 - GREEN
	dc.w	$1A6,$FF0	; color19, or COLOR3 of sprite0 - YELLOW

	dc.w	$FFFF,$FFFE	; End of copperlist


; *********** Here is the sprite: OBVIOUSLY it must be in CHIP RAM! ***********

MIOSPRITE:		; length 13 lines
VSTART:
	dc.b $30	; Vertical sprite start position ($2c to $f2)
HSTART:
	dc.b $90	; Horizontal sprite start position ($40 to $d8)
VSTOP:
	dc.b $3d	; $30+13=$3d	; vertical position of sprite bottom
	dc.b $00
 dc.w	%0000000000000000,%0000110000110000 ; Binary format for modifications
 dc.w	%0000000000000000,%0000011001100000
 dc.w	%0000000000000000,%0000001001000000
 dc.w	%0000000110000000,%0011000110001100 ;BINARY 00=COLOR 0 (TRANSPARENT)
 dc.w	%0000011111100000,%0110011111100110 ;BINARY 10=COLOR 1 (RED)
 dc.w	%0000011111100000,%1100100110010011 ;BINARY 01=COLOR 2 (GREEN)
 dc.w	%0000110110110000,%1111100110011111 ;BINARY 11=COLOR 3 (YELLOW)
 dc.w	%0000011111100000,%0000011111100000
 dc.w	%0000011111100000,%0001111001111000
 dc.w	%0000001111000000,%0011101111011100
 dc.w	%0000000110000000,%0011000110001100
 dc.w	%0000000000000000,%1111000000001111
 dc.w	%0000000000000000,%1111000000001111
 dc.w	0,0	; 2 cleared words define the end of the sprite.


	SECTION	PLANEVUOTO,BSS_C	; We use the zeroed bitplane, because
					; to see the sprites it is necessary
					; that there are bitplanes enabled
BITPLANE:
	ds.b	40*256		; bitplane zeroed lowres

	end

You can easily move the sprite, try these changes for the MuoviSprite routine:


	subq.b	#1,HSTART	; Move the sprite to the left

*

	ADDQ.B	#1,VSTART	; \ move the sprite down
	ADDQ.B	#1,VSTOP	; / (you have to act on both VSTART and VSTOP!)

*
	SUBQ.B	#1,VSTART	; \ move the sprite up
	SUBQ.B	#1,VSTOP	; / (you have to act on both VSTART and VSTOP!)

*

	ADDQ.B	#1,HSTART	;\
	ADDQ.B	#1,VSTART	; \ move diagonally bottom-right
	ADDQ.B	#1,VSTOP	; /

*

	SUBQ.B	#1,HSTART	;\
	ADDQ.B	#1,VSTART	; \ move diagonally bottom-left
	ADDQ.B	#1,VSTOP	; /

*

	ADDQ.B	#1,HSTART	;\
	SUBQ.B	#1,VSTART	; \ move diagonally up-right
	SUBQ.B	#1,VSTOP	; /

*

	SUBQ.B	#1,HSTART	;\
	SUBQ.B	#1,VSTART	; \ move diagonally up-left
	SUBQ.B	#1,VSTOP	; /

*

Then try to change the added / subtracted value to make more unusual 
trajectories.

	SUBQ.B	#3,HSTART	;\
	SUBQ.B	#1,VSTART	; \ move diagonally top-very left
	SUBQ.B	#1,VSTOP	; /

Etcetera Etcetera.

