
; Lesson5e.s	DIVIDING THE HEIGHT OF AN IMAGE BY MODIFYING THE MODULOS

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist

;	POINTING TO OUR BITPLANES

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
frame:
	cmpi.b	#$fe,$dff006	; Are we at line 254? (must do another round!)
	bne.s	frame		; If not yet, do not continue
frame2:
	cmpi.b	#$fd,$dff006	; Are we at line 253?
	bne.s	frame2		; If not yet, do not continue
frame3:
	cmpi.b	#$fc,$dff006	; Are we at line 252?
	bne.s	frame3
frame4:
	cmpi.b	#$fb,$dff006	; Are we at line 251?
	bne.s	frame4

	btst	#2,$dff016	; if the right button is pressed, skip
	beq.s	Aspetta		; the routine of the scroll, blocking it

	bsr.s	MuoviCopper	; The modulo routine

NonMuovere
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

; With this routine, we add or subtract 40 from the modulo registers to reduce
; the height of the image. I kept the labels of the previous example to save
; time.

MuoviCopper:
	TST.B	SuGiu		; Are we going up or down?
	beq.w	VAIGIU
	tst.w	MOD1		; Are we at the normal value of the modulo?
				; (ZERO)
	beq.s	MettiGiu	; if yes, we must increase the value
	sub.w	#40,MOD1	; we subtract 40, that is 1 line, sliding the
				; image down (enlarging it)
	sub.w	#40,MOD2	; we subtract 40 from modulo 2
	rts

MettiGiu:
	clr.b	SuGiu		; By resetting SuGiu, at "TST.B SuGiu" the
	bra.s	Finito		; BEQ will jump to the VAIGIU routine

VAIGIU:
	cmpi.w	#40*20,MOD1	; have we halved enough??
	beq.s	MettiSu		; if so, we must return to the normal pic
	add.w	#40,MOD1	; Add 40, that is 1 line, by scrolling the
				; image up (halving)
	add.w	#40,MOD2	; Add 40 to modulo 2
	rts

MettiSu:
	move.b	#$ff,SuGiu	; When the SuGiu label is not zero, it means
	rts			; we have to go back.


;	This byte, indicated by the SuGiu label, is a FLAG.

SuGiu:
	dc.b	0,0


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registers with normal values)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108
MOD1:
	dc.w	0		; Bpl1Mod
	dc.w	$10a
MOD2:
	DC.W	0		; Bpl2Mod

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

To do something more "clean" I would have to put a WAIT under the image that
would remove the "impurities" that you see below, ie the bytes in memory after
the image and the bitplanes that "appear" under the first and the second one.
But the main purpose is to explain the function of the modulos.
The routine, among other things, is performed once every 4 frames to slow it
down.
