
; Lesson7c.s	A SPRITE MOVED HORIZONTALLY USING A TABLE OF PRESET VALUES.
;		(that is, of horizontal coordinates)


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

	bsr.s	MuoviSprite	; Move sprite 0 horizontally

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

; This routine moves the sprite by acting on its HSTART byte, that is the byte
; of its X position, by entering the coordinates already established in the 
; TABX table. Acting only on HSTART, the scrolling is in steps of 2 pixels 
; each time and not of 1 pixel at a time, so it is slightly "jerky" especially 
; in slowdowns. We will make the horizontal scroll more fluid later, making it 
; faithful to the single pixel.

MuoviSprite:
	ADDQ.L	#1,TABXPOINT	 ; Point to the next byte
	MOVE.L	TABXPOINT(PC),A0 ; address contained in longword TABXPOINT
				 ; copied to a0
	CMP.L	#FINETABX-1,A0  ; Are we at the last longword of the TAB?
	BNE.S	NOBSTART	; not yet? then continue
	MOVE.L	#TABX-1,TABXPOINT ; You start pointing from the first longword
NOBSTART:
	MOVE.b	(A0),HSTART	; copy the byte from the table to HSTART
	rts

TABXPOINT:
	dc.l	TABX-1		; NOTE: the values of the table here are
				; bytes, so we work with an ADDQ.L # 1,
				; TABXPOINT and not #2 as when they are words
				; or with #4 as when they are longwords.

; Table with pre-computed X coordinates of the sprite.
; Note that the X position to let the sprite enter the video window must be
; between $40 and $d8, in fact in the table there are bytes not bigger than
; $d8 and not smaller than $40.

TABX:
	dc.b	$41,$43,$46,$48,$4A,$4C,$4F,$51,$53,$55,$58,$5A ; 200 values
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
FINETABX:



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

Complex and realistic movements are done with tables!
Try replacing the current table with this one, and you will reverse the bounce of the sprite. (Amiga+b+c+i to copy), (amiga+b+x to delete a piece)

TABX:
	dc.b	$CF,$CD,$CA,$C8,$C6,$C4,$C1,$BF,$BD,$BB,$B8,$B6 ; 200 values
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
FINETABX:


Now replace it with this one, which makes the sprite wobble both ways.

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

