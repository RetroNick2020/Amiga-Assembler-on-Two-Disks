
; Lesson5d.s	SCROLLING AN IMAGE UP AND DOWN BY MODIFYING BITPLANE-POINTERS
;		IN THE COPPERLIST AND SCROLLING LEFT AND RIGHT THROUGH $dff102

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

	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP

	move.w	#0,$dff1fc		; FMODE - Turn off AGA
	move.w	#$c00,$dff106		; BPLCON3 - Turn off AGA

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue


	bsr.w	MuoviCopper	; slide the image up and down one line at a
				; time by changing the pointers to the
				; bitplanes in the copperlist

	btst	#2,$dff016	; if the right button is pressed, skip
	beq.s	Aspetta		; the routine of the scroll, blocking it

	bsr.w	MuoviCopper2	; scrolls the image to the right and left
				; (maximum 16 pixels) with the $dff102

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


;	This routine moves the image up and down, acting on the pointers to
;	the bitplanes in the copperlist (through the BPLPOINTERS label)
;	The structure is similar to that of Lesson3d.s

MuoviCopper:
	LEA	BPLPOINTERS,A1	; With these 4 instructions we copy the address
	move.w	2(a1),d0	; currently pointing the $dff0e0 from the
	swap	d0		; copperlist and place it in d0
	move.w	6(a1),d0
	TST.B	SuGiu		; Are we going up or down?
	beq.w	VAIGIU		; ("VAIGIU" = "GO DOWN")
	cmp.l	#PIC-(40*30),d0	; are we high enough?
	beq.s	MettiGiu	; if yes, we are at the top and must come down
	sub.l	#40,d0		; we subtract 40, that is 1 line
	bra.s	Finito

MettiGiu:
	clr.b	SuGiu		; By resetting SuGiu, at "TST.B SuGiu" the
	bra.s	Finito		; BEQ will jump to the VAIGIU routine

VAIGIU:
	cmpi.l	#PIC+(40*30),d0	; are we low enough?
	beq.s	MettiSu		; if yes, we are at the bottom and must go up
	add.l	#40,d0		; We add 40, that is 1 line
	bra.s	Finito

MettiSu:
	move.b	#$ff,SuGiu	; When the SuGiu label is not zero, it means
	rts			; we have to go up.

Finito:				; WE POINT THE BITPLANES POINTERS
	LEA	BPLPOINTERS,A1	; pointers in the COPPERLIST
	MOVEQ	#2,D1		; number of bitplanes -1 (here we have 3)
POINTBP2:
	move.w	d0,6(a1)	; copy the LOW word of the bitplane address
	swap	d0		; swap the two words in d0 (ex: 1234 > 3412)
	move.w	d0,2(a1)	; copy the HIGH word of the plane address
	swap	d0		; swap the two words in d0 (ex: 3412 > 1234)
	ADD.L	#40*256,d0	; + length of bitplane -> next bitplane
	addq.w	#8,a1		; let's go to the next bplpointers in the COP
	dbra	d1,POINTBP2	; Redo D1 times POINTBP (D1=num of bitplanes)
	rts

;	This byte, indicated by the SuGiu label, is a FLAG.

SuGiu:
	dc.b	0,0

;***************************************************************************
MuoviCopper2:
	TST.B	FLAG		; We have to move forwards or backwards?
	beq.w	AVANTI
	cmpi.b	#$00,MIOCON1	; have we reached the normal position?
	beq.s	MettiAvanti	; if yes, we must move forward!
	sub.b	#$11,MIOCON1	; subtract 1 from the scroll of the bitplanes
	rts

MettiAvanti:
	clr.b	FLAG		; Resetting FLAG, at TST.B FLAG the BEQ will
	rts			; jump to the AVANTI routine

AVANTI:
	cmpi.b	#$ff,MIOCON1	; have we reached the maximum scroll forward,
				; or $FF?? ($f even and $f odd)
	beq.s	MettiIndietro	; if yes, we have to go back
	add.b	#$11,MIOCON1	; add 1 to the scroll of the bitplanes
	rts

MettiIndietro:
	move.b	#$ff,FLAG	; When the FLAG label is not zero, it means
	rts			; that we have to move back to the left

;	This byte is a FLAG, which is used to indicate whether to go forward or
;	backward.

FLAG:
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

	dc.w	$102		; BplCon1 - THE REGISTER
	dc.b	$00		; BplCon1 - THE BYTE NOT USED!!!
MIOCON1:
	dc.b	$00		; BplCon1 - THE BYTE USED!!!

	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210	; BPLCON0:
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

	dcb.b	40*30,0			; zeroed space

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	dcb.b	40*30,0			; zeroed space

	end

Nothing new, the previous sources of Lesson 5 were simply joined.
