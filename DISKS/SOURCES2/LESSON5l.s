
; Lesson5l.s	"STRETCH" effect made by alternating normal and -40 modulos

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

	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP

	move.w	#0,$dff1fc		; FMODE - Turn off AGA
	move.w	#$c00,$dff106		; BPLCON3 - Turn off AGA

mouse:
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
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 and 12 set!! (3 = %011)

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

; COPPERLIST THAT "STRETCH"

	dc.l	$8907fffe		; wait line $89
	dc.w	$108,-40,$10a,-40	; modulo -40, repeat last line
	dc.l	$9007fffe		; wait 7 lines - they will all be equal
	dc.w	$108,0,$10a,0		; then I move forward one line
	dc.l	$9107fffe		; and the following line...
	dc.w	$108,-40,$10a,-40	; I put the modulo back to FLOOD
	dc.l	$9807fffe		; wait 7 lines - they will all be equal
	dc.w	$108,0,$10a,0		; I advance to the following line
	dc.l	$9907fffe		; then...
	dc.w	$108,-40,$10a,-40	; I repeat the line for 7 lines with
	dc.l	$a007fffe		; modulo to -40
	dc.w	$108,0,$10a,0		; advance one line... ETC.
	dc.l	$a107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$a807fffe
	dc.w	$108,0,$10a,0
	dc.l	$a907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$b007fffe
	dc.w	$108,0,$10a,0
	dc.l	$b107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$b807fffe
	dc.w	$108,0,$10a,0
	dc.l	$b907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$c007fffe
	dc.w	$108,0,$10a,0
	dc.l	$c107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$c807fffe
	dc.w	$108,0,$10a,0
	dc.l	$c907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$d007fffe
	dc.w	$108,0,$10a,0
	dc.l	$d107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$d807fffe
	dc.w	$108,0,$10a,0
	dc.l	$d907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$e007fffe
	dc.w	$108,0,$10a,0
	dc.l	$e107fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$e807fffe
	dc.w	$108,0,$10a,0
	dc.l	$e907fffe
	dc.w	$108,-40,$10a,-40
	dc.l	$f007fffe
	dc.w	$108,0,$10a,0	; return to normal

	dc.w	$FFFF,$FFFE	; Fine della copperlist

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

This is one of the other uses of the "FLOOD" effect made with the modulos, in
fact it is rather easy to "stretch" an image or simulate pixels longer than
normal by alternating modulos -40, which lengthen, and normal modulos at zero,
which trigger the next line, which will then be lengthened by being followed
by another -40 modulo maintained for some lines.
In this example the elongation is a *8, in fact the line is advanced only once
every 8 pixels, in fact the -40 modulos are spaced with the 7 lines WAIT, and
between these extensions are lines with normal modulo , which then trigger the
next line, but next line there is immediately another negative modulo that
makes the new line repeat for 7 lines, plus the one with normal modulo that
triggers the new line when "wrapping".
By changing the distance between the WAITs, you can create interesting "zoom"
ripple effects.
