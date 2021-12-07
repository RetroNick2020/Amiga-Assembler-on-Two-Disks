
; Lesson7h.s	4 SPRITES AT 16 COLORS IN ATTACHED MODE MOVES ON THE SCREEN
;		USING TWO TABLES OF PRESET VALUES (ie vertical and horizontal
;		coordinates).
;		** NOTE ** To see the program and exit press:
;		LEFT BUTTON, RIGHT BUTTON, LEFT BUTTON, RIGHT BUTTON.

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

;	We point the 8 sprites, which ATTACHED will form 4 16-color sprites.
;	Sprites 1, 3, 5, 7, the odd ones, must have bit 7 of the second word
;	set to 1.


	MOVE.L	#MIOSPRITE0,d0		; address of the sprite in d0
	LEA	SpritePointers,a1	; Pointers in copperlist
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE1,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE2,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE3,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE4,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE5,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE6,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	MOVE.L	#MIOSPRITE7,d0		; address of the sprite in d0
	addq.w	#8,a1			; next SPRITEPOINTERS
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

; Let's set the ATTACHED bits

	bset	#7,MIOSPRITE1+3		; Set the attached bit on sprite 1. By
					; removing this instruction, the
					; sprites are not ATTACHED, but two
					; 3-color overlapping ones.

	bset	#7,MIOSPRITE3+3
	bset	#7,MIOSPRITE5+3
	bset	#7,MIOSPRITE7+3

	move.l	#COPPERLIST,$dff080	; our COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

;	We create a position offset in the pointers to the tables between the
;	4 sprites to make them make different movements from each other.

	MOVE.L	#TABX+55,TABXPOINT0
	MOVE.L	#TABX+86,TABXPOINT1
	MOVE.L	#TABX+130,TABXPOINT2
	MOVE.L	#TABX+170,TABXPOINT3
	MOVE.L	#TABY-1,TABYPOINT0
	MOVE.L	#TABY+45,TABYPOINT1
	MOVE.L	#TABY+90,TABYPOINT2
	MOVE.L	#TABY+140,TABYPOINT3


Mouse1:
	bsr.w	MuoviGliSprite	; It waits for a frame, moves the sprites and
				; returns.

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse1

	MOVE.L	#TABX+170,TABXPOINT0
	MOVE.L	#TABX+130,TABXPOINT1
	MOVE.L	#TABX+86,TABXPOINT2
	MOVE.L	#TABX+55,TABXPOINT3
	MOVE.L	#TABY-1,TABYPOINT0
	MOVE.L	#TABY+45,TABYPOINT1
	MOVE.L	#TABY+90,TABYPOINT2
	MOVE.L	#TABY+140,TABYPOINT3

Mouse2:
	bsr.w	MuoviGliSprite	; It waits for a frame, moves the sprites and
				; returns.

	btst	#2,$dff016	; right mouse button pressed?
	bne.s	mouse2

; SPRITE IN INDIAN ROW

	MOVE.L	#TABX+30,TABXPOINT0
	MOVE.L	#TABX+20,TABXPOINT1
	MOVE.L	#TABX+10,TABXPOINT2
	MOVE.L	#TABX-1,TABXPOINT3
	MOVE.L	#TABY+30,TABYPOINT0
	MOVE.L	#TABY+20,TABYPOINT1
	MOVE.L	#TABY+10,TABYPOINT2
	MOVE.L	#TABY-1,TABYPOINT3

Mouse3:
	bsr.w	MuoviGliSprite	; It waits for a frame, moves the sprites and
				; returns.

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse3

; DRUNK SPRITES FOR THE SCREEN

	MOVE.L	#TABX+220,TABXPOINT0
	MOVE.L	#TABX+30,TABXPOINT1
	MOVE.L	#TABX+102,TABXPOINT2
	MOVE.L	#TABX+5,TABXPOINT3
	MOVE.L	#TABY-1,TABYPOINT0
	MOVE.L	#TABY+180,TABYPOINT1
	MOVE.L	#TABY+20,TABYPOINT2
	MOVE.L	#TABY+100,TABYPOINT3


Mouse4:
	bsr.w	MuoviGliSprite	; It waits for a frame, moves the sprites and
				; returns.

	btst	#2,$dff016	; right mouse button pressed?
	bne.s	mouse4

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


; This routine performs the individual sprite motion routines and also 
; includes the frame wait loop for timing.

MuoviGliSprite:
	cmpi.b	#$ff,$dff006	; Line 255?
	bne.s	MuoviGliSprite

	bsr.s	MuoviSpriteX0	; Move sprite 0 horizontally
	bsr.w	MuoviSpriteX1	; Move sprite 1 horizontally
	bsr.w	MuoviSpriteX2	; Move sprite 2 horizontally
	bsr.w	MuoviSpriteX3	; Move sprite 3 horizontally
	bsr.w	MuoviSpriteY0	; Move sprite 0 vertically
	bsr.w	MuoviSpriteY1	; Move sprite 1 vertically
	bsr.w	MuoviSpriteY2	; Move sprite 2 vertically
	bsr.w	MuoviSpriteY3	; Move sprite 3 vertically

Aspetta:
	cmpi.b	#$ff,$dff006	; line 255?
	beq.s	Aspetta

	rts		; Go back to the MOUSE loop


; ********************* ROUTINES OF HORIZONTAL MOVEMENT *******************

; These routines move the sprite by acting on its HSTART byte, that is the byte
; of its X position, by entering the coordinates already established in the
; TABX table (Horizontal scrolling in steps of 2 pixels and not 1)

; For sprite0 ATTACHED: (i.e. Sprite0 + Sprite1)

MuoviSpriteX0:
	ADDQ.L	#1,TABXPOINT0	 ; Point to the next byte
	MOVE.L	TABXPOINT0(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTX0	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT0 ; You start again from the first byte-1
NOBSTARTX0:
	MOVE.b	(A0),MIOSPRITE0+1 ; copy the byte from the table to HSTART0
	MOVE.b	(A0),MIOSPRITE1+1 ; copy the byte from the table to HSTART1
	rts

TABXPOINT0:
	dc.l	TABX+55		; NOTE: the table values are bytes



; For sprite1 ATTACHED: (or Sprite2+Sprite3)

MuoviSpriteX1:
	ADDQ.L	#1,TABXPOINT1	 ; Point to the next byte
	MOVE.L	TABXPOINT1(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTX1	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT1 ; You start again from the first byte-1
NOBSTARTX1:
	MOVE.b	(A0),MIOSPRITE2+1 ; copy the byte from the table to HSTART2
	MOVE.b	(A0),MIOSPRITE3+1 ; copy the byte from the table to HSTART3
	rts

TABXPOINT1:
	dc.l	TABX+86		; NOTE: the table values are bytes



; For sprite2 ATTACHED: (or Sprite4+Sprite5)

MuoviSpriteX2:
	ADDQ.L	#1,TABXPOINT2	 ; Point to the next byte
	MOVE.L	TABXPOINT2(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTX2	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT2 ; You start again from the first byte-1
NOBSTARTX2:
	MOVE.b	(A0),MIOSPRITE4+1 ; copy the byte from the table to HSTART4
	MOVE.b	(A0),MIOSPRITE5+1 ; copy the byte from the table to HSTART5
	rts

TABXPOINT2:
	dc.l	TABX+130	; NOTE: the table values are bytes



; For sprite3 ATTACHED: (or Sprite6+Sprite7)

MuoviSpriteX3:
	ADDQ.L	#1,TABXPOINT3	 ; Point to the next byte
	MOVE.L	TABXPOINT3(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTX3	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT3 ; You start again from the first byte-1
NOBSTARTX3:
	MOVE.b	(A0),MIOSPRITE6+1 ; copy the byte from the table to HSTART6
	MOVE.b	(A0),MIOSPRITE7+1 ; copy the byte from the table to HSTART7
	rts

TABXPOINT3:
	dc.l	TABX+170	; NOTE: the table values are bytes

; ********************* VERTICAL MOVEMENT ROUTINES *******************

; These routines move the sprite up and down by acting on its VSTART and VSTOP
; bytes, i.e. the bytes of its start and end Y position, by entering
; coordinates already established in the TABY table.

; For sprite0 ATTACCHED: (or Sprite0+Sprite1)

MuoviSpriteY0:
	ADDQ.L	#1,TABYPOINT0	 ; Point to the next byte
	MOVE.L	TABYPOINT0(PC),A0 ; address contained in longword TABYPOINT0
				 ; copied to a0
	CMP.L	#FINETABY-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTY0	; not yet? then continue
	MOVE.L	#TABY-1,TABYPOINT0 ; Start pointing from the first byte (-1)
NOBSTARTY0:
	moveq	#0,d0		; Clear d0
	MOVE.b	(A0),d0		; copy the byte from the table into d0
	MOVE.b	d0,MIOSPRITE0	; copy the byte to VSTART0
	MOVE.b	d0,MIOSPRITE1	; copy the byte to VSTART1
	ADD.B	#15,D0		; Add sprite length to determine final
				; position (VSTOP)
	move.b	d0,MIOSPRITE0+2	; Move the right value to VSTOP0
	move.b	d0,MIOSPRITE1+2	; Move the right value to VSTOP1
	rts

TABYPOINT0:
	dc.l	TABY-1		; NOTE: the table values are bytes



; For sprite1 ATTACCHED: (or Sprite2+Sprite3)

MuoviSpriteY1:
	ADDQ.L	#1,TABYPOINT1	 ; Point to the next byte
	MOVE.L	TABYPOINT1(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABY-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTY1	; not yet? then continue
	MOVE.L	#TABY-1,TABYPOINT1 ; Start pointing from the first byte (-1)
NOBSTARTY1:
	moveq	#0,d0		; Clear d0
	MOVE.b	(A0),d0		; copy the byte from the table into d0
	MOVE.b	d0,MIOSPRITE2	; copy the byte to VSTART2
	MOVE.b	d0,MIOSPRITE3	; copy the byte to VSTART3
	ADD.B	#15,D0		; Add sprite length to determine final
				; position (VSTOP)
	move.b	d0,MIOSPRITE2+2	; Move the right value to VSTOP2
	move.b	d0,MIOSPRITE3+2	; Move the right value to VSTOP3
	rts

TABYPOINT1:
	dc.l	TABY+45		; NOTE: the table values are bytes



; For sprite2 ATTACCHED: (or Sprite4+Sprite5)

MuoviSpriteY2:
	ADDQ.L	#1,TABYPOINT2	 ; Point to the next byte
	MOVE.L	TABYPOINT2(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABY-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTY2	; not yet? then continue
	MOVE.L	#TABY-1,TABYPOINT2 ; Start pointing from the first byte (-1)
NOBSTARTY2:
	moveq	#0,d0		; Clear d0
	MOVE.b	(A0),d0		; copy the byte from the table into d0
	MOVE.b	d0,MIOSPRITE4	; copy the byte to VSTART4
	MOVE.b	d0,MIOSPRITE5	; copy the byte to VSTART5
	ADD.B	#15,D0		; Add sprite length to determine final
				; position (VSTOP)
	move.b	d0,MIOSPRITE4+2	; Move the right value to VSTOP4
	move.b	d0,MIOSPRITE5+2	; Move the right value to VSTOP5
	rts

TABYPOINT2:
	dc.l	TABY+90		; NOTE: the table values are bytes



; For sprite3 ATTACCHED: (or Sprite5+Sprite6)

MuoviSpriteY3:
	ADDQ.L	#1,TABYPOINT3	 ; Point to the next byte
	MOVE.L	TABYPOINT3(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABY-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTY3	; not yet? then continue
	MOVE.L	#TABY-1,TABYPOINT3 ; Start pointing from the first byte (-1)
NOBSTARTY3:
	moveq	#0,d0		; Clear d0
	MOVE.b	(A0),d0		; copy the byte from the table into d0
	MOVE.b	d0,MIOSPRITE6	; copy the byte to VSTART6
	MOVE.b	d0,MIOSPRITE7	; copy the byte to VSTART7
	ADD.B	#15,D0		; Add sprite length to determine final
				; position (VSTOP)
	move.b	d0,MIOSPRITE6+2	; Move the right value to VSTOP6
	move.b	d0,MIOSPRITE7+2	; Move the right value to VSTOP7
	rts

TABYPOINT3:
	dc.l	TABY+140	; NOTE: the table values are bytes



; Table with pre-calculated sprite X coordinates.

TABX:
	incbin	"XCOORDINAT.TAB"	; 334 values
FINETABX:


; Table with pre-computed Y coordinates of the sprite.

TABY:
	incbin	"YCOORDINAT.TAB"	; 200 values
FINETABY:


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

;	Palette of PIC

	dc.w	$180,$000	; color0	; background black
	dc.w	$182,$123	; color1	; color 1 of the bitplane,
						; which in this case is
						; empty, so it does not
						; appear.

;	Palette for attached SPRITES

	dc.w	$1A2,$FFC	; color17, COLOR 1 for the attached sprites
	dc.w	$1A4,$EEB	; color18, COLOR 2 for the attached sprites
	dc.w	$1A6,$CD9	; color19, COLOR 3 for the attached sprites
	dc.w	$1A8,$AC8	; color20, COLOR 4 for the attached sprites
	dc.w	$1AA,$8B6	; color21, COLOR 5 for the attached sprites
	dc.w	$1AC,$6A5	; color22, COLOR 6 for the attached sprites
	dc.w	$1AE,$494	; color23, COLOR 7 for the attached sprites
	dc.w	$1B0,$384	; color24, COLOR 7 for the attached sprites
	dc.w	$1B2,$274	; color25, COLOR 9 for the attached sprites
	dc.w	$1B4,$164	; color26, COLOR 10 for the attached sprites
	dc.w	$1B6,$154	; color27, COLOR 11 for the attached sprites
	dc.w	$1B8,$044	; color28, COLOR 12 for the attached sprites
	dc.w	$1BA,$033	; color29, COLOR 13 for the attached sprites
	dc.w	$1BC,$012	; color30, COLOR 14 for the attached sprites
	dc.w	$1BE,$001	; color31, COLOR 15 for the attached sprites

	dc.w	$FFFF,$FFFE	; end of copperlist


; *********** Here is the sprite: OBVIOUSLY it must be in CHIP RAM! ***********

MIOSPRITE0:				; 15 lines long
	incbin	"Sprite16Col.PARI"

MIOSPRITE1:				; 15 lines long
	incbin	"Sprite16Col.DISPARI"

MIOSPRITE2:				; 15 lines long
	incbin	"Sprite16Col.PARI"

MIOSPRITE3:				; 15 lines long
	incbin	"Sprite16Col.DISPARI"

MIOSPRITE4:				; 15 lines long
	incbin	"Sprite16Col.PARI"

MIOSPRITE5:				; 15 lines long
	incbin	"Sprite16Col.DISPARI"

MIOSPRITE6:				; 15 lines long
	incbin	"Sprite16Col.PARI"

MIOSPRITE7:				; 15 lines long
	incbin	"Sprite16Col.DISPARI"


	SECTION	PLANEVUOTO,BSS_C	; We use the zeroed bitplane, because
					; to see the sprites it is necessary
					; that there are bitplanes enabled
BITPLANE:
	ds.b	40*256		; bitplane zeroed lowres

	end

In this listing, all 4 ATTACHED 16-color sprites are displayed.
The sprites were saved (including control words) in files, using the "WB" 
command. This is to save space in the listing and to reuse the sprite attached 
in other listings and several times in the same listing, in fact the same 
sprite (divided into EVEN and ODD SPRITES) is used for all four sprites.
As for the movement of the sprites, each has an autonomous movement routine, 
with an autonomous pointer to the X and Y tables.
In this way, starting the movement from different phases (ie different points 
of the table) for each sprite, the most disparate movements are generated.
However, the two tables X and Y are the same for all the routines, between one 
routine and the other only the starting position of the pointer changes, so 
while a sprite starts from position X, Y, another starts from position X + n, 
Y + n, creating sprites further and further back in the curve (IN THE CASE OF 
THE "INDIAN ROW"), or seemingly random trajectories.
A peculiarity of the structure of the routines in this listing is noteworthy:
having to wait for the left and right button to be pressed several times to 
change the movement of the sprites before exiting, it would have been necessary
to rewrite each time the two loops waiting for the $FF line of the electronic 
brush and all 8 "BSR move sprites":

; wait for line $FF
; bsr muovisprite
; wait for the left mouse

; change the trajectory of the sprites

; wait for line $FF
; bsr muovisprite
; wait for the right mouse

; change the trajectory of the sprites

; wait for line $FF
; bsr muovisprite
; wait for the left mouse

; change the trajectory of the sprites

; wait for line $FF
; bsr muovisprite
; wait for the right mouse

To save listing lines, a solution is to include the loop waiting for the 
electron brush for timing in the BSR move sprite subroutine:

; This routine performs the individual sprite motion routines and also 
; includes the frame wait loop for timing.

MuoviGliSprite:
	cmpi.b	#$ff,$dff006	; Line 255?
	bne.s	MuoviGliSprite

	bsr.s	MuoviSpriteX0	; Move sprite 0 horizontally
	bsr.w	MuoviSpriteX1	; Move sprite 1 horizontally
	bsr.w	MuoviSpriteX2	; Move sprite 2 horizontally
	bsr.w	MuoviSpriteX3	; Move sprite 3 horizontally
	bsr.w	MuoviSpriteY0	; Move sprite 0 vertically
	bsr.w	MuoviSpriteY1	; Move sprite 1 vertically
	bsr.w	MuoviSpriteY2	; Move sprite 2 vertically
	bsr.w	MuoviSpriteY3	; Move sprite 3 vertically

Aspetta:
	cmpi.b	#$ff,$dff006	; line 255?
	beq.s	Aspetta

	rts		; return to MOUSE loop

In this way, just wait for the mouse button to be pressed, if it is not pressed,
execute MuovigliSprite:


Mouse1:
	bsr.w	MuoviGliSprite	; It waits for a frame, moves the sprites and
				; returns.

	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse1

	MOVE.L	#TABX+170,TABXPOINT0	; change the trajectory of the sprites
	...

Mouse2:
	bsr.w	MuoviGliSprite	; It waits for a frame, moves the sprites and
				; returns.

	btst	#2,$dff016	; right mouse button pressed?
	bne.s	mouse2

