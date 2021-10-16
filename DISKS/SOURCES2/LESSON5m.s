
; Lesson5m.s	MOVING THE VIDEO WINDOW WITH THE DIWSTART ($dff08e)

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist

;	Pointing the bitplanes in copperlist

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

	bsr.w	SuGiuDIW	; scroll up and down with the DIWSTART

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

;	This routine simply acts on the YY byte of the $ dff08e in the
;	copperlist, the DIWSTART; this register defines the beginning of the
;	video window, which can be "centered", as you can do from the
;	WorkBench preferences. In our case, we simply "start" the video window
;	below, and move the one that contains it. In this case, unlike the
;	scroll we saw with the bitplanes, nothing is displayed "above" the
;	image, because we just move the "window", and outside it the bitplane
;	is not displayed.
;	An interesting aspect of the routine may be the fact that a word
;	labeled as COUNTER is used to wait 35 frames before acting, to create a
;	delay when the logo is up before going down; I have also used two "new"
;	instructions, which we have not yet seen, but which are very useful in
;	this routine; this is the BHI, which is an instruction of the BEQ/BNE
;	family, which jumps to the routine if the result of the CMP, or
;	COMPARE, is that the value is HIGHER, in this case BHI.s LOGOD jumps
;	to LOGOD only when the COUNTER has reached the value 35, as well as the
;	times after, in which it will be at 36, 37, etc., however, HIGHER
;	than 35.
;	The other instruction is the BCHG, which means BIT CHANGE, ie
;	"exchange the bit", of the BTST family, and "exchange" the indicated
;	bit, that is: a "BCHG #1,Label" acts on bit 1 of that label making it
;	become 1 if it was 0, 0 if it was 1.

SuGiuDIW:
	ADDQ.W	#1,COUNTER	; we mark the execution
	CMPI.W	#35,COUNTER	; I've spent at least 35 frames?
	BHI.S	LOGOD		; if yes, run the routine
	RTS			; otherwise return without executing it

LOGOD:
	BTST	#1,FLAGDIW	; Do we have to go up?
	BEQ.S	UP		; If yes, we perform the "UP" routine
	SUBQ.B	#2,DIWSCX	; Go up in steps of 2, faster
	CMPI.B	#$2c,DIWSCX	; Are we on top? (normal value $2c81)
	BEQ.S	CHANGEUPDOWN2	; if yes, we change the direction of scroll
	RTS

UP:
	ADDQ.B	#1,DIWSCX	; Go down by 1, slowly
	CMPI.B	#$70,DIWSCX	; Are we at the bottom? (position $70)
	BEQ.S	CHANGEUPDOWN	; if yes, we change the scrolling direction
	RTS

CHANGEUPDOWN
	BCHG	#1,FLAGDIW	; we exchange the direction bit
	RTS

CHANGEUPDOWN2
	BCHG	#1,FLAGDIW	; we exchange the direction bit
	CLR.W	COUNTER		; and we reset the COUNTER, we are at the end!
	RTS

FLAGDIW:
	dc.w	0

COUNTER:
	dc.w	0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E
DIWSCX:
	dc.w	$2c81	; DIWSTRT = $YYXX Video window start

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

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	image

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end
