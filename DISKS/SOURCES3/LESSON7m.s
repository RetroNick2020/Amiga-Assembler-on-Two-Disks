
; Lesson7m.s	Sprite placement via a universal routine
; This example shows a universal routine for moving sprites that considers all 
; bits of the horizontal and vertical positions of the sprites.
; It also automatically adds offsets (128 for horizontal coordinates, $2c for 
; vertical).
; In this way the coordinates in the tables can be the real ones, that is from 
; 0 to 320 for the horizontal coordinates and from 0 to 256 for the vertical 
; coordinates.


	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase
	jsr	-$78(a6)	; Disable
	lea	GfxName(PC),a1	; Library Name
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

;	We point the sprite

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
	cmpi.b	#$aa,$dff006	; Line $aa?
	bne.s	mouse

	btst	#2,$dff016
	beq.s	aspetta
	bsr.w	MuoviSprite	; Move sprite 0

Aspetta:
	cmpi.b	#$aa,$dff006	; line $aa?
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

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0


;	To move the sprite correctly, first we read the tables to know which 
;	positions the sprite must assume, then we communicate these positions,
;	as well as the address and height of the sprites, to the
;	UniMuoviSprite routine, through the registers a1, d0, d1, d2

MuoviSprite:
	bsr.s	LeggiTabelle	; It reads the X and Y positions from the
				; tables, putting the address of the sprite in
				; register a1, in d0 the pos. Y, in d1 the
				; pos. X and in d2 the height of the sprite.

;
;	Incoming parameters of UniMuoviSprite:
;
;	a1 = Address of the sprite
;	d0 = vertical Y position of the sprite on the screen (0-255)
;	d1 = horizontal X position of the sprite on the screen (0-320)
;	d2 = height of the sprite
;

	bsr.w	UniMuoviSprite  ; runs the universal routine
				; that places the sprite
	rts




; This routine reads the real coordinates of the sprites from the 2 tables.
; That is, the X coordinate ranges from 0 to 320 and the Y from 0 to 256
; (without overscan).
; Since we don't use overscan in this example, the Y coordinate table is a byte
; table. The X coordinate table, on the other hand, is made up of words because
; it must also contain values greater than 256.
; This routine, however, does not directly position the sprite. It simply makes
; the universal routine do it, communicating the coordinates to it through
; registers d0 and d1

LeggiTabelle:
	ADDQ.L	#1,TABYPOINT	 ; Point to the next byte
	MOVE.L	TABYPOINT(PC),A0 ; address contained in long TABYPOINT copied
				 ; to a0
	CMP.L	#FINETABY-1,A0  ; Are we at the last byte of the TAB?
	BNE.S	NOBSTARTY	; not yet? then continue
	MOVE.L	#TABY-1,TABYPOINT ; You start again from the first byte
NOBSTARTY:
	moveq	#0,d0		; Clear d0
	MOVE.b	(A0),d0		; copies the byte from the table, that is the Y
				; coordinate in d0, so that it can be found by
				; the universal routine

	ADDQ.L	#2,TABXPOINT	 ; Point to the next word
	MOVE.L	TABXPOINT(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-2,A0  ; Are we at the last word of the TAB?
	BNE.S	NOBSTARTX	; not yet? then continue
	MOVE.L	#TABX-2,TABXPOINT ; You start pointing from the first word-2
NOBSTARTX:
	moveq	#0,d1		; we reset d1
	MOVE.w	(A0),d1		; we put the value from the table, that is the
				; X coordinate, in d1

	lea	MIOSPRITE,a1	; address of the sprite in A1
	moveq	#13,d2		; height of the sprite in d2
	rts


TABYPOINT:
	dc.l	TABY-1		; NOTE: the values of the table here are bytes,
				; so we work with an ADDQ.L #1,TABYPOINT and
				; not #2 as when they are words or with #4 as
				; when they are longwords.
TABXPOINT:
	dc.l	TABX-2		; NOTE: the values of this table are words.

; Table with pre-computed Y coordinates of the sprite.
; Note that the Y position for the sprite to enter the video window must be 
; between $0 and $ff, in fact the $2c offset is added by the routine. If you 
; are not using overscan screens, i.e. no longer than 255 lines, you can use a
; table of dc.b values (from $00 to $FF)


; How to redo the table:

; BEG> 0
; END> 360
; AMOUNT> 200
; AMPLITUDE> $f0/2
; YOFFSET> $f0/2
; SIZE (B/W/L)> b
; MULTIPLIER> 1


TABY:
	incbin	"ycoordinatok.tab"	; 200 values .B
FINETABY:

; Table with pre-calculated sprite X coordinates. This table contains the REAL
; values of the screen coordinates, not the "halved" values for two-pixel jog
; scrolling as we have seen so far. In fact, in the table there are bytes not
; bigger than 304 and not smaller than zero.

TABX:
	incbin	"xcoordinatok.tab"	; 150 values .W
FINETABX:




; Universal sprite placement routine.
; This routine modifies the position of the sprite whose address is contained 
; in register a1 and whose height is contained in register d2, and places the
; sprite at the Y and X coordinates contained in registers d0 and d1
; respectively.
; Before calling this routine it is necessary to put the address of the sprite
; in register a1, its height in register d2, the Y coordinate in register d0,
; the X in register d1

; This procedure is called by "passing parameters".
; Note that this routine modifies registers d0 and d1.

;
;	Incoming parameters of UniMuoviSprite:
;
;	a1 = Address of the sprite
;	d0 = vertical Y position of the sprite on the screen (0-255)
;	d1 = horizontal X position of the sprite on the screen (0-320)
;	d2 = height of the sprite
;

UniMuoviSprite:
; vertical placement
	ADD.W	#$2c,d0		; add the offset of the beginning of the screen

; a1 contains the address of the sprite

	MOVE.b	d0,(a1)		; copy the byte to VSTART
	btst.l	#8,d0
	beq.s	NonVSTARTSET
	bset.b	#2,3(a1)	; Set bit 8 of VSTART (value > $ FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,3(a1)	; Resets bit 8 of VSTART (value < $FF)
ToVSTOP:
	ADD.w	D2,D0		; Add the height of the sprite to determine 
				; the final position (VSTOP)
	move.b	d0,2(a1)	; Move the right value to VSTOP
	btst.l	#8,d0
	beq.s	NonVSTOPSET
	bset.b	#1,3(a1)	; Set bit 8 of VSTOP (value > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,3(a1)	; Resets bit 8 of VSTOP (value < $FF)
VstopFIN:

; horizontal placement

	add.w	#128,D1		; 128 - to center the sprite.
	btst	#0,D1		; low bit of the X coordinate cleared?
	beq.s	BitBassoZERO
	bset	#0,3(a1)	; Let's set the low bit of HSTART
	bra.s	PlaceCoords

BitBassoZERO:
	bclr	#0,3(a1)	; Let's clear the low bit of HSTART
PlaceCoords:
	lsr.w	#1,D1		; SHIFT, ie we shift the value of HSTART by 1
				; bit to the right, to "transform" it into the
				; value it places in the HSTART byte, ie
				; without the low bit.
	move.b	D1,1(a1)	; We put the value XX in the HSTART byte
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

	dc.w	$180,$000	; color0	; background black
	dc.w	$182,$123	; color1	; color 1 of the bitplane,
						; which in this case is
						; empty, so it does not
						; appear.

	dc.w	$1A2,$F00	; color17, or COLOR1 of sprite0 - RED
	dc.w	$1A4,$0F0	; color18, or COLOR2 of sprite0 - GREEN
	dc.w	$1A6,$FF0	; color19, or COLOR3 of sprite0 - YELLOW

	dc.w	$FFFF,$FFFE	; end of copperlist


; *********** Here is the sprite: OBVIOUSLY it must be in CHIP RAM! ***********

MIOSPRITE:		; length 13 lines
	dc.b $50	; Vertical sprite start position ($2c to $f2)
	dc.b $90	; Horizontal sprite start position ($40 to $d8)
	dc.b $5d	; $50+13=$5d	; posizione verticale di fine sprite
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

In this lesson we present a universal routine for moving sprites, called 
"UniMuoviSprite".
This routine takes care of all aspects of sprite positioning, correctly
handles all bits of the position and also adds offsets so that the real
coordinates of the sprites can be stored in the tables.
This routine works with any sprite. In fact, the address of the sprite is not 
fixed, but is read in register a1. This means that:

  VSTART is located at the address contained in a1

  HSTART is found in the following byte, ie in the address contained in a1+1

  VSTOP is found 2 bytes later, ie in the address contained in a1+2

  the fourth byte is found 3 bytes later, that is in the address contained in
  a1+3.

UniMuoviSprite accesses these bytes through indirect register addressing with 
displacement:

 to access VSTART you use (a1)
 to access HSTART use 1(a1)
 to access VSTOP you use 2(a1)
 to access the fourth control byte we use 3(a1)

The height of the sprite is also not fixed, but is contained in register d2.
In this way the routine can be used to move sprites of different heights. 
Furthermore, this routine does not read the coordinates from the table directly,
but takes them from registers d0 and d1.

Who puts the data in these registers? Another "ReadTable" routine takes care of
this, which takes the coordinates from the tables, puts them in registers d0 
and d1, and executes the "UniMuoviSprite" routine. Basically we divided the 
tasks between the 2 routines, as if they were 2 employees. The "Leggitabelle" 
routine does its job, then says:"Hey UniMUoviSprite routine, here is the 
sprite to move, I'll send you the address in register a1. I send you the 
height of the sprite in d2. Here are also the coordinates, I am sending them 
to you through registers d0 and d1. You know what to do with it!".
The "UniMuoviSprite" routine receives the address of the sprite and the 
coordinates and puts them in the right bytes of the sprite.
The "sending" of the coordinates through the registers is called "passing 
parameters".
The division of labor is a very convenient thing. In fact, suppose we want to 
move a sprite using a table for the Ys, while for the Xs a separate continuous 
increment and decrement routine, ADDQ / SUBQ, in order to create a sprite that 
always moves from left to right, but which oscillates upwards and downwards.
Since the universal routine we have just seen takes the coordinates from the 
registers, regardless of whether this data came from a table before, we can use
 it again as it is in this listing, without having to modify it at all.
Also, since it takes the address of the sprite from one register, and its 
height from another, it can be used for any sprite.
From now on, for every other sprite example, we will therefore always use the 
"UniMuoviSprite" routine, without having to modify it every time.

