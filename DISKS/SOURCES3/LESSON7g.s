
; Lesson7g.s	A 16-COLOR SPRITE IN ATTACCHED MODE MOVES ON THE SCREEN USING
;		TWO TABLES OF PRESET VALUES (ie vertical and horizontal
;		coordinates).


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

; We set pointers for sprites 0 and 1, which ATTACHED will form a single 
; 16-color sprite. Sprite1, the odd one, must have bit 7 of the second 
; word at 1.

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

	bset	#7,MIOSPRITE1+3		; Set the attach bit on sprite 1.
					; By removing this instruction, the
					; sprites are not ATTACHED, but two 
					; 3-color overlapping ones.

	move.l	#COPPERLIST,$dff080	; our COP
	move.w	d0,$dff088		; START COP
	move.w	#0,$dff1fc		; NO AGA!
	move.w	#$c00,$dff106		; NO AGA!

mouse:
	cmpi.b	#$ff,$dff006	; Line 255?
	bne.s	mouse

	bsr.s	MuoviSpriteX	; Move sprite 0 horizontally
	bsr.w	MuoviSpriteY	; Move sprite 0 vertically

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

;	Dati

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

; This routine moves the sprite by acting on its HSTART byte, that is the byte
; of its X position, by entering the coordinates already established in the
; TABX table. (Move 2 pixels at a time)

MuoviSpriteX:
	ADDQ.L	#1,TABXPOINT	 ; Point to the next byte
	MOVE.L	TABXPOINT(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTX	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT ; You start again from the first byte-1
NOBSTARTX:
	MOVE.b	(A0),MIOSPRITE0+1 ; copy the byte from the table to HSTART0
	MOVE.b	(A0),MIOSPRITE1+1 ; copy the byte from the table to HSTART1
	rts

TABXPOINT:
	dc.l	TABX-1		; NOTE: the table values are bytes

; Table with pre-computed X coordinates of the sprite.

TABX:
	incbin	"XCOORDINAT.TAB"	; 334 values
FINETABX:


; This routine moves the sprite up and down by acting on its VSTART and VSTOP 
; bytes, i.e. the bytes of its Y position of start and end, by entering the 
; coordinates from the TABY table

MuoviSpriteY:
	ADDQ.L	#1,TABYPOINT	 ; Point to the next byte
	MOVE.L	TABYPOINT(PC),A0 ; address contained in longword TABXPOINT 
				 ; copied to a0
	CMP.L	#FINETABY-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTY	; not yet? then continue
	MOVE.L	#TABY-1,TABYPOINT ; Start pointing from the first byte (-1)
NOBSTARTY:
	moveq	#0,d0		; Clear d0
	MOVE.b	(A0),d0		; copy the byte from the table into d0
	MOVE.b	d0,MIOSPRITE0	; copy the byte to VSTART0
	MOVE.b	d0,MIOSPRITE1	; copy the byte to VSTART1
	ADD.B	#15,D0		; Add the length of the sprite to determine
				; the final position (VSTOP)
	move.b	d0,MIOSPRITE0+2	; Move the right value into VSTOP0
	move.b	d0,MIOSPRITE1+2	; Move the right value into VSTOP1
	rts

TABYPOINT:
	dc.l	TABY-1		; NOTE: the table values are bytes

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

;	Palette della PIC

	dc.w	$180,$000	; color0	; black background
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

MIOSPRITE0:		; length 15 lines
VSTART0:
	dc.b $00	; Vertical sprite start position ($2c to $f2)
HSTART0:
	dc.b $00	; Horizontal sprite start position ($40 to $d8)
VSTOP0:
	dc.b $00	; vertical sprite end position
	dc.b $00

	dc.w $0380,$0650,$04e8,$07d0,$0534,$1868,$1e5c,$1636 ; data for
	dc.w $377e,$5514,$43a1,$1595,$0172,$1317,$6858,$5035 ; sprite 0
	dc.w $318c,$0c65,$7453,$27c9,$5ece,$5298,$0bfe,$2c32
	dc.w $005c,$13c4,$0be8,$0c18,$03e0,$03e0

	dc.w	0,0	; 2 cleared words define the end of the sprite



MIOSPRITE1:		; length 15 lines
VSTART1:
	dc.b $00	; Vertical sprite start position ($2c to $f2)
HSTART1:
	dc.b $00	; Horizontal sprite start position ($40 to $d8)
VSTOP1:
	dc.b $00	; vertical sprite end position
	dc.b $00	; set bit 7 to attach sprites 0 and 1.

	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e ; data for
	dc.w $58f2,$600e,$5873,$600f,$5cf1,$600f,$1ff3,$600f ; sprite 1
	dc.w $4fe3,$701f,$47c7,$783f,$6286,$7d7e,$300e,$3ffe
	dc.w $1c3c,$1ffc,$0ff8,$0ff8,$03e0,$03e0

	dc.w	0,0	; 2 cleared words define the end of the sprite


	SECTION	PLANEVUOTO,BSS_C	; We use the zeroed bitplane, because
					; to see the sprites it is necessary
					; that there are bitplanes enabled
BITPLANE:
	ds.b	40*256		; bitplane zeroed lowres

	end

Apart from the novelty of the ATTACCHED bit to make a 16-color sprite instead 
of two 4-color sprites, there are a couple of things to note:
1) The X and Y tables have been saved with the "WB" command and are loaded 
with the incbin, in this way the tables can be loaded from the various 
listings that require them, as long as they are on the disk!
2) The labels VSTART0, VSTART1, HSTART0, HSTART1 etc. are no longer used to 
move the sprite. The labels remain in place in the sprite in this listing, but 
it is more convenient to "reach" the control bytes like this:

	MIOSPRITE	; Per VSTART
	MIOSPRITE+1	; Per HSTART
	MIOSPRITE+2	; Per VSTOP

This way you can simply start the sprite with:

MIOSPRITE:
	DC.W	0,0
	..data...

Without dividing the two words into single bytes, each with a LABEL that 
lengthens the listing.
Also to set bit 7 of word 2 of SPRITE1, that of ATTACCHED, this instruction 
was enough:

	bset	#7,MIOSPRITE1+3

Otherwise we could have set it "by hand" in the fourth byte:

MIOSPRITE1:
VSTART1:
	dc.b $00
HSTART1:
	dc.b $00
VSTOP1:
	dc.b $00
	dc.b %10000000		; or dc.b $80 ($80=%10000000)

If you have to use all 8 sprites you save a lot of labels and space. Even 
better would be to put the sprite's address in an Ax register and perform the 
offsets from that register:

	lea	MIOSPRITE,a0
	MOVE.B	#yy,(a0)	; For VSTART
	MOVE.B	#xx,1(A0)	; For HSTART
	MOVE.B	#y2,2(A0)	; For VSTOP

Defining a 16-color sprite in binary becomes problematic.
So you have to resort to a drawing program, just remember to use a 16-color 
screen and to draw sprites no wider than 16 pixels. Once you have saved the 16-
color PIC (or a smaller BRUSH with the sprite) in IFF format, converting it 
with the IFFCONVERTER is as easy as converting an image.

NOTE: By BRUSH we mean a small image of variable size.

Here's how you can convert a sprite with KEFCON:

1) Upload the IFF file, which must be 16 colors
2) You have to select only the sprite, to do this press the right button, then 
position yourself on the upper left corner of the future sprite, and press the 
left button. By moving the mouse you will see a grid which, as it happens, is 
divided into strips 16 pixels wide. However, you can control the width and 
length of the selected block. To include the sprite properly you have to 
consider that you have to go through the sprite border with the rectangle 
selection "strip", the last line included in the rectangle is the one that 
passes through the border strip, not the one inside the strip:

	<----- 16 pixel ----->

	|========####========| /\
	||     ########	    || ||
	||   ############   || ||
	|| ################ || ||
	||##################|| ||
	###################### ||
	###################### Length of the sprite, maximum 256 pixels
	###################### ||
	||##################|| ||
	|| ################ || ||
	||   ############   || ||
	||     ########     || ||
	|========####========| \/


If the sprite is smaller than 16 pixels you must leave an empty margin on the 
sides, or on one side only, so that the width of the block is always 16.

Once the sprite inside the rectangle has been selected, it must be saved as 
SPRITE16 if it is a 16-color sprite, or as SPRITE4 if it is a four-color 
sprite. The sprite is saved in "dc.b", ie in TEXT format, which you can 
include in the listing with the "I" command of the Asmone or by loading it in 
another text buffer and copying it with Amiga + b + c + i.

Here's how the KEFCON saves the attached sprite (16 colors):

	dc.w $0000,$0000
	dc.w $0380,$0650,$04e8,$07d0,$0534,$1868,$1e5c,$1636
	dc.w $377e,$5514,$43a1,$1595,$0172,$1317,$6858,$5035
	dc.w $318c,$0c65,$7453,$27c9,$5ece,$5298,$0bfe,$2c32
	dc.w $005c,$13c4,$0be8,$0c18,$03e0,$03e0
	dc.w 0,0

	dc.w $0000,$0000
	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e
	dc.w $58f2,$600e,$5873,$600f,$5cf1,$600f,$1ff3,$600f
	dc.w $4fe3,$701f,$47c7,$783f,$6286,$7d7e,$300e,$3ffe
	dc.w $1c3c,$1ffc,$0ff8,$0ff8,$03e0,$03e0
	dc.w 0,0

As you can see, these are the two sprites with the two control words cleared, 
the data in hexadecimal format and the two words cleared for END SPRITE.
Just put the two labels "MIOSPRITE0:" and "MIOSPRITE1:" at the beginning of the
two sprites, after which working with MIOSPRITE + x to reach the byte of the 
coordinates it is not necessary to add other LABELS. The only detail is that 
you have to set the ATTACHED bit with a BSET #7,MIOSPRITE+3 or directly in the 
sprite:

MIOSPRITE1:
	dc.w $0000,$0080	; $80, or %10000000 -> ATTACHED!
	dc.w $0430,$07f0,$0fc8,$0838,$0fe4,$101c,$39f2,$200e
	...

If you want to draw and convert the sprites to 4 colors too, the problem does 
not exist, because only one sprite is saved and there is no need to set the bit!

As for the color palette of the sprites, you have to save them from the KEFCON 
after saving the SPRITE16 or SPRITE4, with the COPPER option, just like for 
normal images. The problem is that the palette is saved as a 16-COLOR IMAGE, 
and not as a SPRITE.
Here's how the KEFCON saves the palette:

	dc.w $0180,$0000,$0182,$0ffc,$0184,$0eeb,$0186,$0cd9
	dc.w $0188,$0ac8,$018a,$08b6,$018c,$06a5,$018e,$0494
	dc.w $0190,$0384,$0192,$0274,$0194,$0164,$0196,$0154
	dc.w $0198,$0044,$019a,$0033,$019c,$0012,$019e,$0001

The colors are right, but the color registers refer to the first 16 colors and 
not the last 16. Just rewrite them "by hand" in the right color registers:

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

Note that in $1a2 you have to copy the color in $182, in $1a4 the color in 
$184 and so on.

Try replacing the 16-color sprite in this listing with your own, with your own 
color palette, and also converting a 4-color sprite to replace the one from 
the previous lessons. Doing so will serve as verification!!!

