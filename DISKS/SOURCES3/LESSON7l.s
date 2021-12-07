
; Lesson7l.s	VERTICAL SLIDING OF A SPRITE BELOW THE $FF LINE


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
	cmpi.b	#$ff,$dff006	; Line 255?
	bne.s	mouse

	btst	#2,$dff016
	beq.s	aspetta
	bsr.w	MuoviSpriteY	; Move sprite 0 vertically (below $FF)

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

; This routine moves the sprite up and down by acting on its VSTART and VSTOP 
; bytes, i.e. the bytes of its Y position of start and end, as well as the 
; high bits of the VSTART / VSTOP coordinates, allowing the sprite to be 
; positioned also in the lines below. $FF. The starting coordinate must be in 
; WORD format, from 0 to $FF to remain in the normal screen (the offset of $2c 
; is added by the routine) or you can go beyond $FF to make the sprite go up 
; to the hardware limit in the screens overscan.

MuoviSpriteY:
	ADDQ.L	#2,TABYPOINT	 ; Point to the next word
	MOVE.L	TABYPOINT(PC),A0 ; address contained in longword TABYPOINT
				 ; copied to a0
	CMP.L	#FINETABY-2,A0  ; Are we at the last word of the TAB?
	BNE.S	NOBSTARTY	; not yet? then continue
	MOVE.L	#TABY-2,TABYPOINT ; You start pointing from the first word (-2)
NOBSTARTY:
	moveq	#0,d0		; Clear d0
	MOVE.w	(A0),d0		; copy the word from the table to d0
	ADD.W	#$2c,d0		; add the offset of the beginning of the screen
	MOVE.b	d0,VSTART	; copy the byte (bits 0-7) into VSTART
	btst.l	#8,d0		; is the position greater than 255? ($FF)
	beq.s	NonVSTARTSET
	bset.b	#2,MIOSPRITE+3	; Set bit 8 of VSTART (value > $FF)
	bra.s	ToVSTOP
NonVSTARTSET:
	bclr.b	#2,MIOSPRITE+3	; Resets bit 8 of VSTART (value < $FF)
ToVSTOP:
	ADD.w	#13,D0		; Add sprite length to determine final
				; position (VSTOP)
	move.b	d0,VSTOP	; Move the right value (bits 0-7) into VSTOP
	btst.l	#8,d0		; is the position greater than 255? ($FF)
	beq.s	NonVSTOPSET
	bset.b	#1,MIOSPRITE+3	; Set bit 8 of VSTOP (value > $FF)
	bra.w	VstopFIN
NonVSTOPSET:
	bclr.b	#1,MIOSPRITE+3	; Resets bit 8 of VSTOP (value < $FF)
VstopFIN:
	rts

TABYPOINT:
	dc.l	TABY-2		; NOTE: the values of the table here are
				; words, so we work with an 
				; ADDQ.L #2,TABYPOINT and not #1 as when they
				; are bytes or with #4 as when they are
				; longwords.

; Table with pre-computed Y coordinates of the sprite.
; Note that the Y position for the sprite to enter the video window must be 
; between $0 and $ff, in fact the $2c offset is added by the routine. If you 
; are not using overscan screens, i.e. no longer than 255 lines, you can use a 
; table of dc.b values (from $ 00 to $ FF)


; How to redo the table:

; BEG> 0
; END> 360
; AMOUNT> 200
; AMPLITUDE> $f0/2
; YOFFSET> $f0/2
; SIZE (B/W/L)> b
; MULTIPLIER> 1


TABY:
	DC.W	$7A,$7E,$81,$85,$89,$8D,$90,$94,$98,$9B,$9F,$A2,$A6,$A9,$AD
	DC.W	$B0,$B3,$B7,$BA,$BD,$C0,$C3,$C6,$C9,$CC,$CE,$D1,$D3,$D6,$D8
	DC.W	$DA,$DC,$DE,$E0,$E2,$E4,$E5,$E7,$E8,$EA,$EB,$EC,$ED,$EE,$EE
	DC.W	$EF,$EF,$F0,$F0,$F0,$F0,$F0,$F0,$EF,$EF,$EE,$EE,$ED,$EC,$EB
	DC.W	$EA,$E8,$E7,$E5,$E4,$E2,$E0,$DE,$DC,$DA,$D8,$D6,$D3,$D1,$CE
	DC.W	$CC,$C9,$C6,$C3,$C0,$BD,$BA,$B7,$B3,$B0,$AD,$A9,$A6,$A2,$9F
	DC.W	$9B,$98,$94,$90,$8D,$89,$85,$81,$7E,$7A,$76,$72,$6F,$6B,$67
	DC.W	$63,$60,$5C,$58,$55,$51,$4E,$4A,$47,$43,$40,$3D,$39,$36,$33
	DC.W	$30,$2D,$2A,$27,$24,$22,$1F,$1D,$1A,$18,$16,$14,$12,$10,$0E
	DC.W	$0C,$0B,$09,$08,$06,$05,$04,$03,$02,$02,$01,$01,$00,$00,$00
	DC.W	$00,$00,$00,$01,$01,$02,$02,$03,$04,$05,$06,$08,$09,$0B,$0C
	DC.W	$0E,$10,$12,$14,$16,$18,$1A,$1D,$1F,$22,$24,$27,$2A,$2D,$30
	DC.W	$33,$36,$39,$3D,$40,$43,$47,$4A,$4E,$51,$55,$58,$5C,$60,$63
	DC.W	$67,$6B,$6F,$72,$76
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

MIOSPRITE:		; 13 lines long
VSTART:
	dc.b $50	; Vertical sprite start position ($2c to $f2)
HSTART:
	dc.b $90	; Horizontal sprite start position ($40 to $d8)
VSTOP:
	dc.b $5d	; $50+13=$5d	; vertical position of sprite end
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

This example is almost identical to that of the LESSON7d source. In this 
example, however, the vertical position of the sprite can go beyond line 255. 
I remind you that since the video window starts at the coordinates ($40, $2c) 
the line 255 corresponds to the 211th line visible on the screen (in fact 255- 
$2c = 211). So if we want our sprite to be able to move to all 256 lines 
visible on the screen, it is necessary that the vertical position reaches the 
value 299 = $12b. This value is too large to fit in one byte, 9 bits are 
required. To specify the starting position Y of the sprite, in addition to the 
8 bits of the VSTART byte (which we have used so far), an additional bit is 
therefore used, precisely bit 2 of the VHBITS byte, that is the fourth control 
byte. The same goes for the end position of the sprite, only that bit 1 of the 
VHBITS byte is used.
In the table, on the other hand, the vertical positions are stored as words.
The routine that reads the vertical coordinates from the table checks if the 
read values are greater than 255; if this happens it sets the right bit of the 
VHBITS register to 1, otherwise it resets it. It should be noted that the 
check is done independently for the start position and for the end position;
in fact it can happen that a sprite starts at a position lower than 255, but 
ends at a position higher than 255. In this case, bit 2 of VHBITS is reset, 
while bit 1 of VHBITS is set to 1.
