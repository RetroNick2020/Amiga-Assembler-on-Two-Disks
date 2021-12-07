
; Lesson7f.s	DISPLAY OF ALL 8 SPRITES OF THE AMIGA
;		In this listing it is verified that the 8 sprites have the 
;		palette in common in pairs, i.e. sprite 0 has the same colors 
;		as sprite 1, sprite 2 has the same colors as sprite 3 and so 
;		on. It is also verified that in the case of the overlapping of 
;		two sprites, the one with a lower number prevails over the one
;		with a higher number, so sprite 0 appears above all the others
;		and sprite 7 can be covered by  all the others, while sprite 3
;		covers sprites 4,5,6,7 and is covered by sprites 0,1,2
;		By pressing the left button the sprites overlap and you can 
;		see the overlapping priorities. Right click to exit.

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

	move.l	#COPPERLIST,$dff080	; our COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	btst	#6,$bfe001	; mouse pressed?
	bne.s	mouse

	MOVEQ	#$60,d0		; Initial HSTART coordinate
	ADDQ.B	#(10/2),d0	; distance to the next sprite
				; (note that the HSTART byte works on pixels 
				; at 2 to 2, so to move 10 pixels just add 5 
				; to HSTART!)
	MOVE.B	d0,HSTART1
	ADDQ.B	#(10/2),d0	; distance to the next sprite
	MOVE.B	d0,HSTART2
	ADDQ.B	#(10/2),d0	; distance to the next sprite
	MOVE.B	d0,HSTART3
	ADDQ.B	#(10/2),d0	; distance to the next sprite
	MOVE.B	d0,HSTART4
	ADDQ.B	#(10/2),d0	; distance to the next sprite
	MOVE.B	d0,HSTART5
	ADDQ.B	#(10/2),d0	; distance to the next sprite
	MOVE.B	d0,HSTART6
	ADDQ.B	#(10/2),d0	; distance to the next sprite
	MOVE.B	d0,HSTART7

MouseDestro:
	btst	#2,$dff016
	bne.s	MouseDestro

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

	dc.w	$1A2,$F00	; color17, - COLOR1 of sprite0/1 -RED
	dc.w	$1A4,$0F0	; color18, - COLOR2 of sprite0/1 -GREEN
	dc.w	$1A6,$FF0	; color19, - COLOR3 of sprite0/1 -YELLOW

	dc.w	$1AA,$FFF	; color21, - COLOR1 of sprite2/3 -WHITE
	dc.w	$1AC,$0BD	; color22, - COLOR2 of sprite2/3 -AQUA
	dc.w	$1AE,$D50	; color23, - COLOR3 of sprite2/3 -ORANGE

	dc.w	$1B2,$00F	; color25, - COLOR1 of sprite4/5 -BLUE
	dc.w	$1B4,$F0F	; color26, - COLOR2 of sprite4/5 -PINK
	dc.w	$1B6,$BBB	; color27, - COLOR3 of sprite4/5 -GRAY

	dc.w	$1BA,$8E0	; color29, - COLOR1 of sprite6/7 -LIME
	dc.w	$1BC,$a70	; color30, - COLOR2 of sprite6/7 -BROWN
	dc.w	$1BE,$d00	; color31, - COLOR3 of sprite6/7 -DARK RED

	dc.w	$FFFF,$FFFE	; End of copperlist


; *********** Here is the sprite: OBVIOUSLY it must be in CHIP RAM! ***********

 ; reference table to define the colors:


 ; for sprites 0 and 1
 ;BINARY 00=COLOR 0 (TRANSPARENT)
 ;BINARY 10=COLOR 1 (RED)
 ;BINARY 01=COLOR 2 (GREEN)
 ;BINARY 11=COLOR 3 (YELLOW)

MIOSPRITE0:		; height 13 lines
VSTART0:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART0:
	dc.b $60	; Horizontal pos. (from $40 to $d8)
VSTOP0:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0111111111111110,%1000010001000001
 dc.w	%0011111111111100,%1100010001000011
 dc.w	%0000111111110000,%1111001110001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite


MIOSPRITE1:		; height 13 lines
VSTART1:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART1:
	dc.b $60+14	; Horizontal pos. (from $40 to $d8)
VSTOP1:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000010001111
 dc.w	%0011111111111100,%1100000110000011
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0111111111111110,%1000000010000001
 dc.w	%0011111111111100,%1100000010000011
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

 ; for sprites 2 and 3
 ;BINARY 00=COLOR 0 (TRANSPARENT)
 ;BINARY 10=COLOR 1 (WHITE)
 ;BINARY 01=COLOR 2 (AQUA)
 ;BINARY 11=COLOR 3 (ORANGE)

MIOSPRITE2:		; height 13 lines
VSTART2:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART2:
	dc.b $60+(14*2)	; Horizontal pos. (from $40 to $d8)
VSTOP2:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111000111001111
 dc.w	%0011111111111100,%1100001000100011
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0111111111111110,%1000000111000001
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

MIOSPRITE3:		; height 13 lines
VSTART3:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART3:
	dc.b $60+(14*3)	; Horizontal pos. (from $40 to $d8)
VSTOP3:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0111111111111110,%1000000111100001
 dc.w	%0111111111111110,%1000000000100001
 dc.w	%0011111111111100,%1100000000100011
 dc.w	%0000111111110000,%1111001111101111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

 ; for sprites 4 and 5
 ;BINARY 00=COLOR 0 (TRANSPARENT)
 ;BINARY 10=COLOR 1 (BLUE)
 ;BINARY 01=COLOR 2 (PINK)
 ;BINARY 11=COLOR 3 (GRAY)

MIOSPRITE4:		; height 13 lines
VSTART4:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART4:
	dc.b $60+(14*4)	; Horizontal pos. (from $40 to $d8)
VSTOP4:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001001001111
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

MIOSPRITE5:		; height 13 lines
VSTART5:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART5:
	dc.b $60+(14*5)	; Horizontal pos. (from $40 to $d8)
VSTOP5:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

 ; for sprites 6 and 7
 ;BINARY 00=COLOR 0 (TRANSPARENT)
 ;BINARY 10=COLOR 1 (LIME)
 ;BINARY 01=COLOR 2 (BROWN)
 ;BINARY 11=COLOR 3 (DARK RED)

MIOSPRITE6:		; height 13 lines
VSTART6:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART6:
	dc.b $60+(14*6)	; Horizontal pos. (from $40 to $d8)
VSTOP6:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100001000000011
 dc.w	%0111111111111110,%1000001111000001
 dc.w	%0111111111111110,%1000001001000001
 dc.w	%0011111111111100,%1100001001000011
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

MIOSPRITE7:		; height 13 lines
VSTART7:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART7:
	dc.b $60+(14*7)	; Horizontal pos. (from $40 to $d8)
VSTOP7:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00
 dc.w	%0000001111000000,%0111110000111110
 dc.w	%0000111111110000,%1111001111001111
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0111111111111110,%1000000001000001
 dc.w	%0011111111111100,%1100000001000011
 dc.w	%0000111111110000,%1111000001001111
 dc.w	%0000001111000000,%0111110000111110
 dc.w	0,0	; end of sprite

	SECTION	PLANEVUOTO,BSS_C	; We use the zeroed bitplane, because
					; to see the sprites it is necessary
					; that there are bitplanes enabled
BITPLANE:
	ds.b	40*256		; bitplane zeroed lowres

	end

In this listing all 8 sprites are "pointed", which also has their number in 
the image to make their arrangement clearer.
As explained in the theory, the 8 sprites have 4 distinct color palettes, so 
the adjacent sprites share the same palette:

	dc.w	$1A2,$F00	; color17, - COLOR1 of sprite0/1 -RED
	dc.w	$1A4,$0F0	; color18, - COLOR2 of sprite0/1 -GREEN
	dc.w	$1A6,$FF0	; color19, - COLOR3 of sprite0/1 -YELLOW

	dc.w	$1AA,$FFF	; color21, - COLOR1 of sprite2/3 -WHITE
	dc.w	$1AC,$0BD	; color22, - COLOR2 of sprite2/3 -AQUA
	dc.w	$1AE,$D50	; color23, - COLOR3 of sprite2/3 -ORANGE

	dc.w	$1B2,$00F	; color25, - COLOR1 of sprite4/5 -BLUE
	dc.w	$1B4,$F0F	; color26, - COLOR2 of sprite4/5 -PINK
	dc.w	$1B6,$BBB	; color27, - COLOR3 of sprite4/5 -GRAY

	dc.w	$1BA,$8E0	; color29, - COLOR1 of sprite6/7 -LIME
	dc.w	$1BC,$a70	; color30, - COLOR2 of sprite6/7 -BROWN
	dc.w	$1BE,$d00	; color31, - COLOR3 of sprite6/7 -DARK RED

It should be noted that the colors Color16, Color20, Color24 and Color28 are 
not used by the sprites, they are skipped, as they would correspond to the 
color of the sprite, the TRANSPARENT one, which is not, in fact, a color, but 
a "HOLE" which assumes the color of the underlying bitplanes (or sprites).
Each sprite has its own VSTART, HSTART and VSTOP, let's see for example SPRITE2:

MIOSPRITE2:		; height 13 lines
VSTART2:
	dc.b $60	; Vertical pos. (from $2c to $f2)
HSTART2:
	dc.b $60+(14*2)	; Horizontal pos. (from $40 to $d8)
VSTOP2:
	dc.b $68	; $60+13=$6d	; Vertical end
	dc.b $00

Each sprite is at the beginning spaced from the others, by adding (14 * x) to 
the HSTARTs. After pressing the left mouse button, all the HSTARTs except the 
first are changed in order to overlap the sprites and show the display 
priorities between them.

