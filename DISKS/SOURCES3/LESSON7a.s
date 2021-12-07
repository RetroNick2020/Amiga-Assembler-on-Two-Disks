
; Lesson7a.s		DISPLAY OF A SPRITE


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

This is the first sprite we control in the course, you can easily define your 
own by changing its 2 planes, which in this listing are defined in binary; 
the color resulting from the various binary overlays can be guessed by 
reading the comment next to the sprite.
The colors of sprite 0 are defined by the COLOR registers 17, 18 and 19:

	dc.w	$1A2,$F00	; color17, or COLOR1 of sprite0 - RED
	dc.w	$1A4,$0F0	; color18, or COLOR2 of sprite0 - GREEN
	dc.w	$1A6,$FF0	; color19, or COLOR3 of sprite0 - YELLOW

To change the position of the sprite, act on its first bytes:

MIOSPRITE:		; length 13 lines
VSTART:
	dc.b $30	; Vertical sprite start position ($2c to $f2)
HSTART:
	dc.b $90	; Horizontal sprite start position ($40 to $d8)
VSTOP:
	dc.b $3d	; $30+13=$3d	; vertical position of sprite bottom
	dc.b $00

Just remember these two things:

1) The upper left corner of the screen is not the $00 position, in fact the 
screen with overscan can be wider; in the case of the normal width screen the 
initial horizontal position (HSTART) can range from $40 to $d8, otherwise the 
sprite is "cut" or goes right off the visible screen. In the same way, the 
initial vertical position, ie the VSTART, must be selected starting from $2c, 
ie from the beginning of the video window defined in DIWSTART (which here is 
$2c81).
To position the sprite on the 320x256 screen, for example at the central 
coordinate 160,128, it is necessary to take into account that the first 
coordinate in the upper left is $40, $2c instead of 0.0, so you have to add 
$40 to the X coordinate and $2c to the Y coordinate.
In fact, $40 + 160, $2c + 128, correspond to the coordinate 160,128 of a 
320x256 non overscan screen.
Not having the control of the horizontal position at the level of 1 pixel 
yet, but every 2 pixels, we have to add not 160, but 160/2 at the beginning 
to find the center of the screen:

HSTART:
	dc.b $40+(160/2)	; positioned in the center of the screen

So for other horizontal coordinates, for example position 50:

	dc.b $40+(50/2)

Later we will see how to position horizontally 1 pixel at a time.

2) The horizontal position can be varied by itself to move a sprite to the 
right and to the left, while if you intend to move the sprite up or down it 
is necessary each time to act on two bytes, i.e. on VSTART and VSTOP, i.e. 
the vertical position of the start and end of sprites. In fact, while the 
width of a sprite is always 16, so that the horizontal position of the start 
is determined, the end position is always 16 pixels more to the right. As 
regards the vertical length, being set at will, it is necessary define it by 
communicating the start and end position each time, so if we want to move the 
sprite up we have to subtract 1 from both VSTART and VSTOP, if we want to 
move it down we need to add 1 to both.
For example, if you want to change the VSTART to $55, to determine VSTOP you 
will need to add the length of the sprite (this is 13 lines high) to VSTART, 
so $55 + 13 = $62.

Move the sprite to various positions on the screen to check if you understand 
or if you just have the illusion that you understand.
Don't forget that HSTART moves 2 pixels each time and not 1 pixel as it might 
seem.
