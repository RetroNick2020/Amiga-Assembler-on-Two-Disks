
; Lesson7e.s	A SPRITE MOVED BOTH VERTICALLY AND HORIZONTALLY USING TWO 
;		TABLES OF PRESET VALUES (ie vertical and horizontal 
;		coordinates).
;		The final note explains how to make your own tables.


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

;	Data

GfxName:
	dc.b	"graphics.library",0,0

GfxBase:
	dc.l	0

OldCop:
	dc.l	0

; In this example we have included the routines and tables of the two previous 
; examples, so we act on both the x and y of the sprite.
; Since the two tables X and Y are both made up of 200 coordinates, the same 
; "couple" of coordinates always occurs:
; value 1 of table X + value 1 of table Y
; value 2 of table X + value 2 of table Y
; value 3 of table X + value 3 of table Y
; ....
; So the result is that the sprite waves diagonally, as we have already seen 
; by putting together addq.b #1,HSTART and addq.b #1,VSTART/VSTOP.


; This routine moves the sprite by acting on its HSTART byte, that is the byte 
; of its X position, by entering the coordinates already established in the 
; TABX table. (scatti di 2 pixel minimo e non 1 pixel)

MuoviSpriteX:
	ADDQ.L	#1,TABXPOINT	 ; Point to the next byte
	MOVE.L	TABXPOINT(PC),A0 ; address contained in longword TABXPOINT 
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTARTX	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT ; You start again from the first byte-1
NOBSTARTX:
	MOVE.b	(A0),HSTART	; copy the byte from the table to HSTART
	rts

TABXPOINT:
	dc.l	TABX-1		; NOTE: the values of the table here are
				; bytes, so we work with an ADDQ.L # 1,
				; TABXPOINT and not #2 as when they are words
				; or with #4 as when they are longwords.

; Table with pre-computed X coordinates for the sprite.
; Note that the X position to let the sprite enter the video window must be 
; between $40 and $d8, in fact in the table there are bytes not bigger than 
; $d8 and not smaller than $40.

TABX:
	dc.b	$91,$93,$96,$98,$9A,$9C,$9F,$A1,$A3,$A5,$A7,$A9 ; 200 values
	dc.b	$AC,$AE,$B0,$B2,$B4,$B6,$B8,$B9,$BB,$BD,$BF,$C0
	dc.b	$C2,$C4,$C5,$C7,$C8,$CA,$CB,$CC,$CD,$CF,$D0,$D1
	dc.b	$D2,$D3,$D3,$D4,$D5,$D5,$D6,$D7,$D7,$D7,$D8,$D8
	dc.b	$D8,$D8,$D8,$D8,$D8,$D8,$D7,$D7,$D7,$D6,$D5,$D5
	dc.b	$D4,$D3,$D3,$D2,$D1,$D0,$CF,$CD,$CC,$CB,$CA,$C8
	dc.b	$C7,$C5,$C4,$C2,$C0,$BF,$BD,$BB,$B9,$B8,$B6,$B4
	dc.b	$B2,$B0,$AE,$AC,$A9,$A7,$A5,$A3,$A1,$9F,$9C,$9A
	dc.b	$98,$96,$93,$91,$8F,$8D,$8A,$88,$86,$84,$81,$7F
	dc.b	$7D,$7B,$79,$77,$74,$72,$70,$6E,$6C,$6A,$68,$67
	dc.b	$65,$63,$61,$60,$5E,$5C,$5B,$59,$58,$56,$55,$54
	dc.b	$53,$51,$50,$4F,$4E,$4D,$4D,$4C,$4B,$4B,$4A,$49
	dc.b	$49,$49,$48,$48,$48,$48,$48,$48,$48,$48,$49,$49
	dc.b	$49,$4A,$4B,$4B,$4C,$4D,$4D,$4E,$4F,$50,$51,$53
	dc.b	$54,$55,$56,$58,$59,$5B,$5C,$5E,$60,$61,$63,$65
	dc.b	$67,$68,$6A,$6C,$6E,$70,$72,$74,$77,$79,$7B,$7D
	dc.b	$7F,$81,$84,$86,$88,$8A,$8D,$8F
FINETABX:


	even	; make following address an even number


; This routine moves the sprite up and down by acting on its VSTART and VSTOP 
; bytes, i.e. the bytes of its Y position of start and end, by using the 
; pre-calculated coordinates in the TABY table

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
	MOVE.b	d0,VSTART	; copy the byte to VSTART
	ADD.B	#13,D0		; Add sprite length to determine final 
				; position (VSTOP)
	move.b	d0,VSTOP	; Move the right value to VSTOP
	rts

TABYPOINT:
	dc.l	TABY-1		; NOTE: the values of the table here are
				; bytes, so we work with an ADDQ.L # 1,
				; TABXPOINT and not #2 as when they are words
				; or with #4 as when they are longwords.

; Table with pre-computed Y coordinates of the sprite.
; Note that the position Y to let the sprite enter the video window must be 
; between $2c and $f2, in fact in the table there are bytes not bigger than 
; $f2 and not smaller than $2c.

TABY:
	dc.b	$8E,$91,$94,$97,$9A,$9D,$A0,$A3,$A6,$A9,$AC,$AF ; sway
	dc.b	$B2,$B4,$B7,$BA,$BD,$BF,$C2,$C5,$C7,$CA,$CC,$CE ; 200 values
	dc.b	$D1,$D3,$D5,$D7,$D9,$DB,$DD,$DF,$E0,$E2,$E3,$E5
	dc.b	$E6,$E7,$E9,$EA,$EB,$EC,$EC,$ED,$EE,$EE,$EF,$EF
	dc.b	$EF,$EF,$F0,$EF,$EF,$EF,$EF,$EE,$EE,$ED,$EC,$EC
	dc.b	$EB,$EA,$E9,$E7,$E6,$E5,$E3,$E2,$E0,$DF,$DD,$DB
	dc.b	$D9,$D7,$D5,$D3,$D1,$CE,$CC,$CA,$C7,$C5,$C2,$BF
	dc.b	$BD,$BA,$B7,$B4,$B2,$AF,$AC,$A9,$A6,$A3,$A0,$9D
	dc.b	$9A,$97,$94,$91,$8E,$8B,$88,$85,$82,$7F,$7C,$79
	dc.b	$76,$73,$70,$6D,$6A,$68,$65,$62,$5F,$5D,$5A,$57
	dc.b	$55,$52,$50,$4E,$4B,$49,$47,$45,$43,$41,$3F,$3D
	dc.b	$3C,$3A,$39,$37,$36,$35,$33,$32,$31,$30,$30,$2F
	dc.b	$2E,$2E,$2D,$2D,$2D,$2D,$2C,$2D,$2D,$2D,$2D,$2E
	dc.b	$2E,$2F,$30,$30,$31,$32,$33,$35,$36,$37,$39,$3A
	dc.b	$3C,$3D,$3F,$41,$43,$45,$47,$49,$4B,$4E,$50,$52
	dc.b	$55,$57,$5A,$5D,$5F,$62,$65,$68,$6A,$6D,$70,$73
	dc.b	$76,$79,$7C,$7F,$82,$85,$88,$8b
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
	dc.b $50	; Vertical sprite start position ($2c to $f2)
HSTART:
	dc.b $90	; Horizontal sprite start position ($40 to $d8)
VSTOP:
	dc.b $5d	; $50+13=$5d	; vertical position of sprite end pos.
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

So far we have made the sprite go horizontally, vertically, and diagonally, 
but we have never made it make curves. Well, just modify this listing to make 
it make all the possible curves, in fact we can vary its X and Y coordinates 
through two tables. This listing shows two tables of equal length (200 values) 
for which the same "coupled" X and Y coordinates always occur:

 value 1 of table X + value 1 of table Y
 value 2 of table X + value 2 of table Y
 value 3 of table X + value 3 of table Y ....

Therefore the result is always the same diagonal oscillation.
If, however, one of the two tables were shorter, this would start again from 
the beginning of the other, creating new oscillations, and each time the two 
tables would make different couplings XX and YY, for example:

 value 23 of table X + value 56 of table Y
 value 24 of table X + value 57 of table Y
 value 25 of table X + value 58 of table Y
 ....

These couplings would translate into curvilinear oscillations of the sprite

Try replacing the current XX coordinate table with this one:
(Amiga+b+c+i to copy), (amiga+b+x to delete a piece)


TABX:
	dc.b	$8A,$8D,$90,$93,$95,$98,$9B,$9E,$A1,$A4,$A7,$A9 ; 150 values
	dc.b	$AC,$AF,$B1,$B4,$B6,$B8,$BA,$BC,$BF,$C0,$C2,$C4
	dc.b	$C6,$C7,$C8,$CA,$CB,$CC,$CD,$CE,$CE,$CF,$CF,$D0
	dc.b	$D0,$D0,$D0,$D0,$CF,$CF,$CE,$CE,$CD,$CC,$CB,$CA
	dc.b	$C8,$C7,$C6,$C4,$C2,$C0,$BF,$BC,$BA,$B8,$B6,$B4
	dc.b	$B1,$AF,$AC,$A9,$A7,$A4,$A1,$9E,$9B,$98,$95,$93
	dc.b	$90,$8D,$8A,$86,$83,$80,$7D,$7B,$78,$75,$72,$6F
	dc.b	$6C,$69,$67,$64,$61,$5F,$5C,$5A,$58,$56,$54,$51
	dc.b	$50,$4E,$4C,$4A,$49,$48,$46,$45,$44,$43,$42,$42
	dc.b	$41,$41,$40,$40,$40,$40,$40,$41,$41,$42,$42,$43
	dc.b	$44,$45,$46,$48,$49,$4A,$4C,$4E,$50,$51,$54,$56
	dc.b	$58,$5A,$5C,$5F,$61,$64,$67,$69,$6C,$6F,$72,$75
	dc.b	$78,$7B,$7D,$80,$83,$86
FINETABX:


Now you can admire the sprite swaying around the screen realistically and with 
a variable movement, due to the difference in length of the two tables

With two tables, one for position XX and one for position YY, the various 
curvilinear movements of the games and graphic demonstrations must be defined, 
for example the launch of a bomb:

		.  .
	     .	     .
	    .	      .
	 o /	      .
	/||	     
	 /\	   BOOM!!


The curve traveled by the bomb thrown by the protagonist of our game was 
simulated by precalculating it in terms of XX and YY.
Since the character at the time of launch could be in different positions on 
the screen, all moved to the right or left, just add the position of the 
throwing protagonist to the coordinates of the curve and the bomb will start 
and fall in the right place.
Or the movements of a squadron of enemy spaceships:


			     @  @  @  @  @  @  @  @ <--
			  @	  @
			@	    @
		
			@  	    @
			  @       @ 
	   <--  @  @  @  @  @  @


The uses of coordinates in tables are infinite.

You may be wondering: but the tables are made by hand by calculating the wave 
by eye?? Well NO, there is an ASMONE command, the "CS" (or "IS"), which can be 
enough to make the tables in this listing (in fact I made them with this 
command!). Or if you need some "special" table you can make a little program 
that does it.

Let's anticipate the topic "how to make a table":
The CS command means "CREATE SINUS", which for those who know trigonometry 
means "ALL THERE?", While for those who don't know it it means "WHAT IS IT?".
Since this is to be just a hint, I will only explain how to give the 
parameters to the "CS" or "IS" command.

The "CS" command creates the values in memory from the specified address or 
label, for example if there already is a 200 bytes table at the TABX label, if 
it is created at the "TABX" address, after assembling, another table of 200 
bytes, this will be "superimposed" on the previous one in memory, and running 
the listing you will see the effect of the last table created.
But by assembling, the previous table is reassembled, as we have not changed 
the text (dc.b $ xx, $ xx ..).
To save the table then, you can create one of the same size on top of another 
or you can make a "buffer", that is a memory area dedicated to the creation 
and saving of the table on disk.
Let's take a practical example: we want to make a particular table 512 bytes 
long, and we want to save it on disk to be able to reload it with the command 
incbin like this:

TABX:
	incbin	"TABELLA1"

To make TABLE1 to be saved we must first create an empty space of 512 bytes 
where we can create it with the "CS" command:

SPACE:
	dcb.b	512,0	; 512 bytes cleared where the table will be created
ENDSPACE:

Once assembled, we will create the table by defining "SPACE" as the target:

 DEST> SPACE

And of course 512 values to generate, of size BYTE:

 AMOUNT> 512
 SIZE (B/W/L)> B

At this point we will have the table generated in 512 bytes ranging from SPACE:
to ENDSPACE:, so we have to save that piece of memory to a file.
For this there is a command in ASMONE, the "WB" (ie Write Binary, ie WRITE A 
PIECE OF MEMORY). To save our table just perform these operations:

1) Write "WB" and define the name you want to give to the file, eg "TABLE1"
2) to the question BEG> (begin ie where to start from) write SPACE
3) to the question END> (ie END) write ENDSPACE

In this way we will obtain a TABLE1 file, 512 bytes long, which will contain 
the table, which can be reloaded with the INCBIN.

The WB command can be applied to save any piece of memory!
You can try to save a sprite and reload it with the incbin.

The other system is the "IS" command, that is INSERT SINUS, insert the sinus in
the text. In this case the table is created directly in the listing in dc.b 
format. It can be convenient for small tables.
Just position the cursor where you want the table to be written, for example 
under the label "TABX:"; at this point you must press ESC to go to the command 
line and make the table with the command "IS" instead of "CS", the procedure 
and the parameters to be passed are the same.
Pressing ESC again we will find the table made with dc.b under TABX:.

but let's see how to CREATE a SINTAB using the ASMONE CS or IS command:


 DEST> destination address or label, for example: DEST>tabx
 BEG> start angle (0-360) (values higher than 360 can also be given)
 END> end angle (0-360)
 AMOUNT> number of values to generate (example: 200 as in this listing)
 AMPLITUDE> amplitude, that is the highest value to be reached
 YOFFSET> offset (number added to all values to move "up")
 SIZE (B/W/L)> size of values (byte,word,long)
 MULTIPLIER> multiply the amplitude
 HALF CORRECTION>Y/N		\ these take care of "smoothing" the 
 ROUND CORRECTION>Y/N		/ wave to "correct" any swings.


Those who knows what the SINUS and COSINE are will understand on the fly how 
to do it, for those who do not know I can say that with BEG> and END> the 
start angle and the end angle of the wave are defined, that is the shape of 
the wave, if this will start going down and then going up, or if it will start 
going up and then going up again. Here are some examples with the curve 
drawing alongside.

- With AMOUNT> you decide how many values the table should have.
- With AMPLITUDE the amplitude of the wave is defined, that is the maximum
  value that it will reach at the top, or in negative, if the negative part of 
  the curve is present.
- With YOFFSET you decide how much to "raise" the entire curve, ie how much 
  you want to add to each value in the table. For example, if a table were 
  composed of 0,1,2,3,4,5,4,3,2,1,0 with a YOFFSET of 0, setting a YOFFSET of 
  10 we would get 10,11,12,13,14,15,14,13,12,11,10. In the case of sprite 
  positions, we know that the X starts at $40 and goes up to $d8, so the 
  YOFFSET will be $40, to transform any $00 into $40, $01 into $41 and so on.
- With "SIZE" we define whether the table values will be bytes, words or 
  longwords. In the case of the sprite coordinates, they are BYTES.
- The MULTIPLIER> is a multiplier of the amplitude, if you don't want to 
  multiply it just define it as 1.


Now it remains to be clarified how to define the "wave shape", that is the most
important thing, and for this we can only use BEG> and END> which refer to the 
starting angle and the ending angle of this curve from the point of 
trigonometric view. For those unfamiliar with trigonometry, I recommend 
studying it a little, also because it is important for three-dimensional 
routines.
I can briefly summarize as follows: imagine a circumference with a center O and
radius as you like (for technical reasons the circle is not round ..) inserted 
in the Cartesian axes X and Y, so the center O is at the position 0,0: (redraw 
these passages on paper)


			   |
			   | y
			   |
			  _L_
			 / | \	x axis
		--------|--o--|---------»
			 \_L_/
			   |
			   |

Now, for a moment, suppose it is a single-hand clock that goes backwards (what 
a twisted example!) starting from this position:


			      90 degrees
			    _____
			   /	 \
			  /	  \
			 /	   \
	    180 degrees	(     O---» ) 0 degrees
			 \	   /
			  \	  /
			   \_____/

			 270 degrees

(pretend it's a circle!!!) In practice it marks 3 o'clock. Instead of the hours
here we have the degrees formed by the hand with respect to the X axis, in 
fact when it marks 12 it is at 90 degrees with respect to the X axis:

			      90 degrees
			    _____
			   /  ^  \
			  /   |   \
			 /    |    \
	    180 degrees	(     O     ) 0 degrees
			 \	   /
			  \	  /
			   \_____/

			 270 degrees


Similarly, these are 45 degrees:

			      90 degrees
			    _____
			   /     \
			  /     / \
			 /     /   \
	    180 degrees	(     O     ) 0 degrees (or even 360, the full circle)
			 \	   /
			  \	  /
			   \_____/

			 270 degrees

Are we there with this stupid clock that goes backwards and has degrees instead
of hours? Now we come to the link with the BEG> and END> of the "CS" command.
Having this clock, you can study the trend of the SINUS function (and COSINE, 
why not). Let's imagine making a full turn of the hand, starting from 0 
degrees to 360, i.e. the same position after a full turn: if we record in a 
graph next to the clock the movements of the tip of the hand with respect to 
the Y axis we will notice that it starts from zero, then rises to the maximum 
height reached at 90 degrees, after which it drops again, returning to zero 
once it reaches 180 degrees , and continues to drop below zero to the minimum 
of 270 degrees, and then go back up to the initial zero of 360 degrees (same 
position as the start):


	      90 degrees
	    _____
	   /	 \
	  /	  \
	 /	   \
 180 d.	(     O---» ) 0 deg.	*-----------------------------------
	 \	   /		0	90	180	270	360 (degrees)
	  \	  /
	   \_____/
	 270 degrees


	      90 degrees
	    _____
	   /	 \ 	45 degrees
	  /	/ \- - - - - - - - *
	 /     /   \		 *
 180 d.	(     O     ) 0 deg.	*-------------------------------------
	 \	   /		0	90	180	270	360 (degrees)
	  \	  /
	   \_____/
	 270 degrees


	      90 degrees
	    _____ _ _ _ _ _ _ _ _ _ _ _ *
	   /  ^  \ 		     * 
	  /   |   \ 		   *
	 /    |    \		 *
 180 d.	(     O     ) 0 deg.	*-----------------------------------
	 \	   /		0	90	180	270	360 (degrees)
	  \	  /
	   \_____/
	 270 degrees


	      90 degrees
	    _____ 		       * *
	   /     \ 	135 deg.     *     *
	  / \     \- - - - - - - - * - - - - *
	 /   \     \		 *
 180 d.	(     O     ) 0 deg.	*-----------------------------------
	 \	   /		0	90	180	270	360 (degrees)
	  \	  /
	   \_____/
	 270 degrees


	      90 degrees
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 d.	( <---O     ) 0 deg.	*---------------*---------------------
	 \	   /		0	90	180	270	360 (degrees)
	  \	  /
	   \_____/
	 270 degrees


	      90 degrees
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 d.	(     O     ) 0 deg.	*---------------*---------------------
	 \   /	   /		0	90	180	270	360 (degrees)
	  \ /	  /- - - - - - - - - - - - - - - - -*
	   \_____/		225 degrees
	 270 degrees


	      90 degrees
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 d.	(     O     ) 0 deg.	*---------------*---------------------
	 \    |	   /		0	90	180	270	360 (degrees)
	  \   |	  /				   *
	   \__L__/				     *
	 270 degrees - - - - - - - - - - - - - - - - - - *


	      90 degrees
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 d.	(     O     ) 0 deg.	*---------------*---------------------
	 \     \   /		0	90	180	270	360 (degrees)
	  \	\ /- - - - - - - - - - - - - - - - * - - - - *
	   \_____/		315 degrees	     *	   *
	 270 degrees				       * *


	      90 degrees
	    _____ 		       * *
	   /     \ 		     *     *
	  /	  \		   *	     *
	 /	   \		 *	       *
 180 d.	(     O---> ) 0 deg.	*---------------*----------------*----
	 \ 	   /		0	90	180	270    *360 (degrees)
	  \	  /				   *	     *
	   \_____/		360 degrees	     *	   *
	 270 degrees				       * *


I hope I was clear enough for those who refrains maths:
to make a curve that goes up and down just give the start angle 0 and 180 as 
the end angle!!! To make a curve that goes down and up it is enough to give 
start angle BEG> 180 and as end angle END> 360, so for all the other curves. 
By changing AMPLITUDE, YOFFSET and MULTIPLIER you will make curves longer and 
tighter or shorter or longer. You can also use values greater than 360 to use 
the curve of the second "turn of the clock", since the function is continuous: 
/\/\/\/\/\/\/\/\/\/\/\.....

Let's take some examples:  (under the drawing is given a hint on the actual
			   (table: 0,1,2,3 ... 999,1000 .. that is its content

  AN EXAMPLE OF SINUS:
			   +	 __
  DEST>cosintabx	   _ _ _/_ \_ _ _ _ _ _  = 512 words:
  BEG>0				    \__/
  END>360		   -	0      360
  AMOUNT>512	0,1,2,3...999,1000,999..3,2,0,-1,-2,-3..-1000,-999,...-2,-1,0
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>1


  AN EXAMPLE OF COSINUS:
 			    +	  _	 _
  DEST>cosintabx	    _ _ _ _\_ _ /_ _ _ _  = 512 words:
  BEG>90			    \__/
  END>360+90		   -	90      450
  AMOUNT>512	1000,999..3,2,0,-1,-2,-3..-1000,-999,...-2,-1,0,1,2...999,1000
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>1


ANOTHER EXAMPLE:
 			   +	 ___
  DEST>cosintabx	   _ _ _/_ _\_ _ _ _  = 800 words:
  BEG>0				    
  END>180		   -	0  180
  AMOUNT>800		0,1,2,3,4,5...999,1000,999..3,2,1,0 (800 valori)
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>1


ANOTHER EXAMPLE:		  _
 			   +	 / \
  DEST>cosintabx	   _ _ _/_ _\_ _ _ _  = 800 words:
  BEG>0				    
  END>180		   -	0  180
  AMOUNT>800		0,1,2,3,4,5...1999,2000,1999..3,2,1,0 (800 valori)
  AMPLITUDE>1000
  YOFFSET>0
  SIZE (B/W/L)>W
  MULTIPLIER>2	<--


ANOTHER EXAMPLE:		 _	_
			    +	  \    /
  DEST>cosintabx	    _ _ _ _\__/_ _ _ _  = 512 words:
  BEG>90			   
  END>360+90		   -	90      450
  AMOUNT>512	     2000,1999..3,2,0,1,2...1999,2000
  AMPLITUDE>1000
  YOFFSET>1000
  SIZE (B/W/L)>W
  MULTIPLIER>1


 LAST EXAMPLE:		 _	_
			    +	  \    /
  DEST>cosintabx	    _ _ _ _\__/_ _ _ _  = 360 words:
  BEG>90			   
  END>360+90		   -	90      450
  AMOUNT>360	     304,303..3,2,0,1,2...303,304
  AMPLITUDE>152
  YOFFSET>152
  SIZE (B/W/L)>W
  MULTIPLIER>1
  HALF CORRECTION>Y
  ROUND CORRECTION>N

Here is how to remake the tables of XX and YY coordinates used in the previous 
examples on sprites: (parameters for the CS and final table)

For the X coordinates, they must range from $40 to $d8 at most

; DEST> tabx
; BEG> 0		 ___ $d0
; END> 180		/   \40
; AMOUNT> 200
; AMPLITUDE> $d0-$40	; $40,$41,$42...$ce,$cf,d0,$cf,$ce...$43,$41....
; YOFFSET> $40	 ; zero must be transformed into $40
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$41,$43,$46,$48,$4A,$4C,$4F,$51,$53,$55,$58,$5A
	dc.b	$5C,$5E,$61,$63,$65,$67,$69,$6B,$6E,$70,$72,$74
	dc.b	$76,$78,$7A,$7C,$7E,$80,$82,$84,$86,$88,$8A,$8C
	dc.b	$8E,$90,$92,$94,$96,$97,$99,$9B,$9D,$9E,$A0,$A2
	dc.b	$A3,$A5,$A7,$A8,$AA,$AB,$AD,$AE,$B0,$B1,$B2,$B4
	dc.b	$B5,$B6,$B8,$B9,$BA,$BB,$BD,$BE,$BF,$C0,$C1,$C2
	dc.b	$C3,$C4,$C5,$C5,$C6,$C7,$C8,$C9,$C9,$CA,$CB,$CB
	dc.b	$CC,$CC,$CD,$CD,$CE,$CE,$CE,$CF,$CF,$CF,$CF,$D0
	dc.b	$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$D0,$CF,$CF,$CF
	dc.b	$CF,$CE,$CE,$CE,$CD,$CD,$CC,$CC,$CB,$CB,$CA,$C9
	dc.b	$C9,$C8,$C7,$C6,$C5,$C5,$C4,$C3,$C2,$C1,$C0,$BF
	dc.b	$BE,$BD,$BB,$BA,$B9,$B8,$B6,$B5,$B4,$B2,$B1,$B0
	dc.b	$AE,$AD,$AB,$AA,$A8,$A7,$A5,$A3,$A2,$A0,$9E,$9D
	dc.b	$9B,$99,$97,$96,$94,$92,$90,$8E,$8C,$8A,$88,$86
	dc.b	$84,$82,$80,$7E,$7C,$7A,$78,$76,$74,$72,$70,$6E
	dc.b	$6B,$69,$67,$65,$63,$61,$5E,$5C,$5A,$58,$55,$53
	dc.b	$51,$4F,$4C,$4A,$48,$46,$43,$41

--	--	--	--	--	--	--	--	--	--

; DEST> tabx			$d0
; BEG> 180		\____/  $40
; END> 360
; AMOUNT> 200
; AMPLITUDE> $d0-$40	; $cf,$cd,$ca...$42,$41,$40,$41,$42...$ca,$cd,$cf
; YOFFSET> $d0	 ; curve below zero! then you have to add $d0
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$CF,$CD,$CA,$C8,$C6,$C4,$C1,$BF,$BD,$BB,$B8,$B6
	dc.b	$B4,$B2,$AF,$AD,$AB,$A9,$A7,$A5,$A2,$A0,$9E,$9C
	dc.b	$9A,$98,$96,$94,$92,$90,$8E,$8C,$8A,$88,$86,$84
	dc.b	$82,$80,$7E,$7C,$7A,$79,$77,$75,$73,$72,$70,$6E
	dc.b	$6D,$6B,$69,$68,$66,$65,$63,$62,$60,$5F,$5E,$5C
	dc.b	$5B,$5A,$58,$57,$56,$55,$53,$52,$51,$50,$4F,$4E
	dc.b	$4D,$4C,$4B,$4B,$4A,$49,$48,$47,$47,$46,$45,$45
	dc.b	$44,$44,$43,$43,$42,$42,$42,$41,$41,$41,$41,$40
	dc.b	$40,$40,$40,$40,$40,$40,$40,$40,$40,$41,$41,$41
	dc.b	$41,$42,$42,$42,$43,$43,$44,$44,$45,$45,$46,$47
	dc.b	$47,$48,$49,$4A,$4B,$4B,$4C,$4D,$4E,$4F,$50,$51
	dc.b	$52,$53,$55,$56,$57,$58,$5A,$5B,$5C,$5E,$5F,$60
	dc.b	$62,$63,$65,$66,$68,$69,$6B,$6D,$6E,$70,$72,$73
	dc.b	$75,$77,$79,$7A,$7C,$7E,$80,$82,$84,$86,$88,$8A
	dc.b	$8C,$8E,$90,$92,$94,$96,$98,$9A,$9C,$9E,$A0,$A2
	dc.b	$A5,$A7,$A9,$AB,$AD,$AF,$B2,$B4,$B6,$B8,$BB,$BD
	dc.b	$BF,$C1,$C4,$C6,$C8,$CA,$CD,$CF

--	--	--	--	--	--	--	--	--	--

;			            ___$d8
; DEST> tabx	                   /   \ $d0-$40 ($90)
; BEG> 0		      \___/     $48
; END> 360
; AMOUNT> 200
; AMPLITUDE> ($d0-$40)/2 ; amplitude both above zero and below zero, then it
			 ; must be half above zero and half below, i.e. divide
			 ; by 2 the AMPLITUDE
; YOFFSET> $90		; and move everything above to turn -72 into $48
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$91,$93,$96,$98,$9A,$9C,$9F,$A1,$A3,$A5,$A7,$A9
	dc.b	$AC,$AE,$B0,$B2,$B4,$B6,$B8,$B9,$BB,$BD,$BF,$C0
	dc.b	$C2,$C4,$C5,$C7,$C8,$CA,$CB,$CC,$CD,$CF,$D0,$D1
	dc.b	$D2,$D3,$D3,$D4,$D5,$D5,$D6,$D7,$D7,$D7,$D8,$D8
	dc.b	$D8,$D8,$D8,$D8,$D8,$D8,$D7,$D7,$D7,$D6,$D5,$D5
	dc.b	$D4,$D3,$D3,$D2,$D1,$D0,$CF,$CD,$CC,$CB,$CA,$C8
	dc.b	$C7,$C5,$C4,$C2,$C0,$BF,$BD,$BB,$B9,$B8,$B6,$B4
	dc.b	$B2,$B0,$AE,$AC,$A9,$A7,$A5,$A3,$A1,$9F,$9C,$9A
	dc.b	$98,$96,$93,$91,$8F,$8D,$8A,$88,$86,$84,$81,$7F
	dc.b	$7D,$7B,$79,$77,$74,$72,$70,$6E,$6C,$6A,$68,$67
	dc.b	$65,$63,$61,$60,$5E,$5C,$5B,$59,$58,$56,$55,$54
	dc.b	$53,$51,$50,$4F,$4E,$4D,$4D,$4C,$4B,$4B,$4A,$49
	dc.b	$49,$49,$48,$48,$48,$48,$48,$48,$48,$48,$49,$49
	dc.b	$49,$4A,$4B,$4B,$4C,$4D,$4D,$4E,$4F,$50,$51,$53
	dc.b	$54,$55,$56,$58,$59,$5B,$5C,$5E,$60,$61,$63,$65
	dc.b	$67,$68,$6A,$6C,$6E,$70,$72,$74,$77,$79,$7B,$7D
	dc.b	$7F,$81,$84,$86,$88,$8A,$8D,$8F

--	--	--	--	--	--	--	--	--	--

 TABLE OF Y:
; Note that the position Y to let the sprite enter the video window must be 
; between $2c and $f2, in fact in the table there are bytes not bigger than $f2
; and not smaller than $2c.

; DEST> taby			$f0 (d0)
; BEG> 180		\____/  $2c (40)
; END> 360
; AMOUNT> 200
; AMPLITUDE> $f0-$2c	; $ef,$ed,$ea...$2c...$ea,$ed,$ef
; YOFFSET> $f0
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$EE,$EB,$E8,$E5,$E2,$DF,$DC,$D9,$D6,$D3,$D0,$CD ; record high
	dc.b	$CA,$C7,$C4,$C1,$BE,$BB,$B8,$B5,$B2,$AF,$AC,$A9 ; jump!
	dc.b	$A6,$A4,$A1,$9E,$9B,$98,$96,$93,$90,$8E,$8B,$88
	dc.b	$86,$83,$81,$7E,$7C,$79,$77,$74,$72,$70,$6D,$6B
	dc.b	$69,$66,$64,$62,$60,$5E,$5C,$5A,$58,$56,$54,$52
	dc.b	$51,$4F,$4D,$4B,$4A,$48,$47,$45,$44,$42,$41,$3F
	dc.b	$3E,$3D,$3C,$3A,$39,$38,$37,$36,$35,$34,$33,$33
	dc.b	$32,$31,$30,$30,$2F,$2F,$2E,$2E,$2D,$2D,$2D,$2C
	dc.b	$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2D,$2D,$2D
	dc.b	$2E,$2E,$2F,$2F,$30,$30,$31,$32,$33,$33,$34,$35
	dc.b	$36,$37,$38,$39,$3A,$3C,$3D,$3E,$3F,$41,$42,$44
	dc.b	$45,$47,$48,$4A,$4B,$4D,$4F,$51,$52,$54,$56,$58
	dc.b	$5A,$5C,$5E,$60,$62,$64,$66,$69,$6B,$6D,$70,$72
	dc.b	$74,$77,$79,$7C,$7E,$81,$83,$86,$88,$8B,$8E,$90
	dc.b	$93,$96,$98,$9B,$9E,$A1,$A4,$A6,$A9,$AC,$AF,$B2
	dc.b	$B5,$B8,$BB,$BE,$C1,$C4,$C7,$CA,$CD,$D0,$D3,$D6
	dc.b	$D9,$DC,$DF,$E2,$E5,$E8,$EB,$EE


--	--	--	--	--	--	--	--	--	--


;			            ___ ($f0) $d8
; DEST> taby	                   /   \ ($f0-$2c) $d0-$40 ($90)
; BEG> 0		      \___/      ($2c) $48
; END> 360
; AMOUNT> 200
; AMPLITUDE> ($f0-$2c)/2 ;
; YOFFSET> $8e		; would be $f0-(($f0-$2c)/2)
; SIZE (B/W/L)> b
; MULTIPLIER> 1

	dc.b	$8E,$91,$94,$97,$9A,$9D,$A0,$A3,$A6,$A9,$AC,$AF
	dc.b	$B2,$B4,$B7,$BA,$BD,$BF,$C2,$C5,$C7,$CA,$CC,$CE
	dc.b	$D1,$D3,$D5,$D7,$D9,$DB,$DD,$DF,$E0,$E2,$E3,$E5
	dc.b	$E6,$E7,$E9,$EA,$EB,$EC,$EC,$ED,$EE,$EE,$EF,$EF
	dc.b	$EF,$EF,$F0,$EF,$EF,$EF,$EF,$EE,$EE,$ED,$EC,$EC
	dc.b	$EB,$EA,$E9,$E7,$E6,$E5,$E3,$E2,$E0,$DF,$DD,$DB
	dc.b	$D9,$D7,$D5,$D3,$D1,$CE,$CC,$CA,$C7,$C5,$C2,$BF
	dc.b	$BD,$BA,$B7,$B4,$B2,$AF,$AC,$A9,$A6,$A3,$A0,$9D
	dc.b	$9A,$97,$94,$91,$8E,$8B,$88,$85,$82,$7F,$7C,$79
	dc.b	$76,$73,$70,$6D,$6A,$68,$65,$62,$5F,$5D,$5A,$57
	dc.b	$55,$52,$50,$4E,$4B,$49,$47,$45,$43,$41,$3F,$3D
	dc.b	$3C,$3A,$39,$37,$36,$35,$33,$32,$31,$30,$30,$2F
	dc.b	$2E,$2E,$2D,$2D,$2D,$2D,$2C,$2D,$2D,$2D,$2D,$2E
	dc.b	$2E,$2F,$30,$30,$31,$32,$33,$35,$36,$37,$39,$3A
	dc.b	$3C,$3D,$3F,$41,$43,$45,$47,$49,$4B,$4E,$50,$52
	dc.b	$55,$57,$5A,$5D,$5F,$62,$65,$68,$6A,$6D,$70,$73
	dc.b	$76,$79,$7C,$7F,$82,$85,$88,$8B,$8d

--	--	--	--	--	--	--	--	--	--

Since you have all these XX and YY tables ready, try to replace them with those
in the listing, to create many different effects, and try to make others with 
100, 120, 300 values instead of 200 (AMOUNT> 100), to create infinite 
trajectories of the sprite.

