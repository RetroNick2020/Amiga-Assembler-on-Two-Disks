
; Lesson5h.s	HORIZONTAL RIPPLE OF AN IMAGE WITH $dff102

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

	btst	#2,$dff016	; if the right button is pressed, skip
	beq.s	Aspetta		; the routine of the scroll, blocking it

	bsr.w	Ondula		; makes the image ripple with a lot of $dff102
				; in copperlist

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

; This routine is similar to the one in Lesson3e.s, in fact "values" are
; moved as in a chain; you remember the system already used:
;	
;	move.w	col2,col1	; col2 copied to col1
;	move.w	col3,col2	; col3 copied to col2
;	move.w	col4,col3	; col4 copied to col3
;	move.w	col5,col4	; col5 copied to col4
;
; In this routine, instead of copying colors, values of $dff102 are copied, but
; the operation of the routine is the same. To save LABEL and time the routine
; has been provided with a DBRA loop that rotates as many words as we want:
; since the words to be changed have a distance of 8 bytes, it is sufficient
; to put the address of one in a0 and the other in a1 and the copying is made
; with a MOVE.W (a0),(a1). Then we move on to the next pair by adding 8 to a0
; and a1, which will point to the next word pair to be exchanged.
; Recall that in order to do the INFINITO cycle, the first value must always
; be replaced by the last one:
;
;	 >>>>>>>>>>>>>>>>>>>>>	
;	^ 		      v
; In this case, at the end of the cycle the first value is copied to the last
; one, for which the inflow is constant; the old routine actually ended like
; this:
;
;	move.w	col1,col14	; col1 copied to col14
;

Ondula:
	LEA	CON1EFFETTO+8,A0 ; Source word address in a0
	LEA	CON1EFFETTO,A1	; Address of the target word in a1
	MOVEQ	#44,D2		; 45 bplcon1 to change in COPLIST
SCAMBIA:
	MOVE.W	(A0),(A1)	; copy two consecutive words - scroll!
	ADDQ.W	#8,A0		; next word pair
	ADDQ.W	#8,A1		; next word pair
	DBRA	D2,SCAMBIA	; repeat "SCAMBIA" the right number of times

	MOVE.W	CON1EFFETTO,ULTIMOVALORE ; to make the cycle infinite we copy
	RTS				; the first value in the last one
					; every time.


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


	dc.w	$102		; BplCon1 - IL REGISTRO
	dc.b	$00		; BplCon1 - IL BYTE NON UTILIZZATO!!!
MIOCON1:
	dc.b	$00		; BplCon1 - IL BYTE UTILIZZATO!!!


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

;	The effect in the copperlist is composed of a WAIT and a BPLCON1, the
;	WAIT wait once every 4 lines: $34,$38,$3c....
;	The $dff102 already have the values of the "WAVE": 1,2,3,4...3,2,1.

	DC.W	$3007,$FFFE,$102
CON1EFFETTO:
	DC.W	$00
	DC.W	$3407,$FFFE,$102,$00
	DC.W	$3807,$FFFE,$102,$00
	DC.W	$3C07,$FFFE,$102,$11
	DC.W	$4007,$FFFE,$102,$11
	DC.W	$4407,$FFFE,$102,$11
	DC.W	$4807,$FFFE,$102,$11
	DC.W	$4C07,$FFFE,$102,$22
	DC.W	$5007,$FFFE,$102,$22
	DC.W	$5407,$FFFE,$102,$22
	DC.W	$5807,$FFFE,$102,$33
	DC.W	$5C07,$FFFE,$102,$33
	DC.W	$6007,$FFFE,$102,$44
	DC.W	$6407,$FFFE,$102,$44
	DC.W	$6807,$FFFE,$102,$55
	DC.W	$6C07,$FFFE,$102,$66
	DC.W	$7007,$FFFE,$102,$77
	DC.W	$7407,$FFFE,$102,$88
	DC.W	$7807,$FFFE,$102,$88
	DC.W	$7C07,$FFFE,$102,$99
	DC.W	$8007,$FFFE,$102,$99
	DC.W	$8407,$FFFE,$102,$aa
	DC.W	$8807,$FFFE,$102,$aa
	DC.W	$8C07,$FFFE,$102,$aa
	DC.W	$9007,$FFFE,$102,$99
	DC.W	$9407,$FFFE,$102,$99
	DC.W	$9807,$FFFE,$102,$88
	DC.W	$9C07,$FFFE,$102,$88
	DC.W	$A007,$FFFE,$102,$77
	DC.W	$A407,$FFFE,$102,$66
	DC.W	$A807,$FFFE,$102,$55
	DC.W	$AC07,$FFFE,$102,$44
	DC.W	$B007,$FFFE,$102,$44
	DC.W	$B407,$FFFE,$102,$33
	DC.W	$B807,$FFFE,$102,$33
	DC.W	$BC07,$FFFE,$102,$22
	DC.W	$C007,$FFFE,$102,$22
	DC.W	$C407,$FFFE,$102,$22
	DC.W	$C807,$FFFE,$102,$11
	DC.W	$CC07,$FFFE,$102,$11
	DC.W	$D007,$FFFE,$102,$11
	DC.W	$D407,$FFFE,$102,$11
	DC.W	$D807,$FFFE,$102,$00
	DC.W	$DC07,$FFFE,$102,$00
	DC.W	$E007,$FFFE,$102,$00
	DC.W	$E407,$FFFE,$102
ULTIMOVALORE:
	DC.W	$00

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	image

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

This ripple effect is a classic on the Amiga. To save time and space here it
does not ripple each line separately but every four lines, but at least it has
a routine with a fast loop to scroll through the 102 values in the copperlist.

The routine in this lesson can be used to "rotate" any word group, so it can
also be used for color scrolling effects, or any other effect.
