
; Lesson5b.s	SCROLLING OF AN IMAGE TO THE LEFT AND RIGHT WITH $dff102

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

	bsr.s	MuoviCopper	; scrolls the image to the right and left
				; (maximum 16 pixels) with the $dff102, here
				; the word COMMODORE

	btst	#2,$dff016	; if the right button is pressed, skip
	beq.s	Aspetta		; the routine of the scroll, blocking it

	bsr.w	MuoviCopper2	; scrolls the image to the right and left
				; (maximum 16 pixels) with the $dff102, here
				; the word AMIGA

Aspetta:
	cmpi.b	#$ff,$dff006	; Are we at line 255?
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

;	This routine moves the word "COMMODORE", acting on MIOCON1

MuoviCopper:
	TST.B	FLAG		; We have to move forwards or backwards?? if
				; FLAG is reset, (that is, the TST verifies
				; the BEQ) then we jump to AVANTI, if instead
				; it is at $FF (if the TST does not verify)
				; we continue going backwards (with SUB)
	beq.w	AVANTI
	cmpi.b	#$00,MIOCON1	; have we reached the normal position, that
				; is, all the way back?
	beq.s	MettiAvanti	; if yes, we must move forward!
	sub.b	#$11,MIOCON1	; we subtract 1 from the scroll of odd and even
	rts			; bitplanes ($ff,$ee,$dd,$cc,$bb,$aa,$99....)

MettiAvanti:
	clr.b	FLAG		; Resetting FLAG, at TST.B FLAG the BEQ will
	rts			; jump to the AVANTI routine, and the image
				; will move forward (to the right)

AVANTI:
	cmpi.b	#$ff,MIOCON1	; have we reached the maximum scroll forward,
				; or $FF?? ($f even and $f odd)
	beq.s	MettiIndietro	; if yes, we have to go back
	add.b	#$11,MIOCON1	; add 1 to the scroll of odd and even bitplanes
				; ($11,$22,$33,$44 etc..), GOING TO THE RIGHT
	rts

MettiIndietro:
	move.b	#$ff,FLAG	; When the FLAG label is not zero, it means
	rts			; that we have to move back to the left

;	This byte is a FLAG, which is used to indicate whether to go forward or
;	backward.

FLAG:
	dc.b	0,0

;************************************************************************

;	This routine moves the word "AMIGA", acting on MIACON1
;	(comments not translated, same code as above, only different labels)

MuoviCopper2:
	TST.B	FLAG2		; Dobbiamo avanzare o indietreggiare?
	beq.w	AVANTI2
	cmpi.b	#$00,MIACON1	; siamo arrivati alla posizione normale?
	beq.s	MettiAvanti2	; se si, dobbiamo avanzare!
	sub.b	#$11,MIACON1	; sottraiamo 1 allo scroll dei bitplanes
	rts			; ($ff,$ee,$dd,$cc,$bb,$aa,$99....)

MettiAvanti2:
	clr.b	FLAG2		; Azzerando FLAG, al TST.B FLAG il BEQ
	rts			; fara' saltare alla routine AVANTI

AVANTI2:
	cmpi.b	#$ff,MIACON1	; siamo arrivati allo scroll massimo in
				; avanti, ossia $FF? ($f pari e $f dispari)
	beq.s	MettiIndietro2	; se si, siamo dobbiamo tornare indietro
	add.b	#$11,MIACON1	; aggiungiamo 1 allo scroll dei bitplanes
				; pari e dispari ($11,$22,$33,$44 etc..)
	rts

MettiIndietro2:
	move.b	#$ff,FLAG2	; Quando la label FLAG non e' a zero,
	rts			; significa che dobbiamo indietreggiare.

Finito2:
	rts

;	Questo byte e' un FLAG, ossia serve per indicare se andare avanti o
;	indietro.

FLAG2:
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

	dc.w	$7007,$fffe	; We wait until under the word "COMMODORE"

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIACON1:
	dc.b	$ff		; BplCon1 - IL BYTE UTILIZZATO!!!


	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	image

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

This example was obtained by copying the routine Muovicopper, and changing its
labels by adding a 2 to "change its name", not to rewrite it all. To add
similar routines, we often use the copy of the affected piece with Amiga+b+c+i,
then change the name of the labels. As for the copperlist it was enough to add
another $dff102, whose name is MIACON1, after a WAIT $7007, ie under the word
"Commodore", so it acts on the bottom part of the image, which is the design
"AMIGA".
To create the "DISCORDANCE" movement, so that one part goes to the right when
the other goes to the left and vice versa, it was enough to start the loop
from $FF instead of $00, that is from position 15, so the two cycles
Muovicopper and Muovicopper2 start from the 2 opposite positions.

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!

	...

	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIACON1:
	dc.b	$ff		; BplCon1 - IL BYTE UTILIZZATO!!!

Try changing the byte MIACON1:, instead of $ff try with $55 and $aa or other
values, and it will be clearer.

With the right mouse button only the second $102 locks.
Try changing the WAIT to move the scroll-split to other positions, for example:

	dc.w	$a007,$fffe

It "divides" the image in the middle of the word "AMIGA".
