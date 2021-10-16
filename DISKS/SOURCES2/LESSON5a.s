
; Lesson5a.s	SCROLLING OF AN IMAGE TO THE LEFT AND RIGHT WITH $dff102

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

	bsr.s	MuoviCopper	; scroll the image left and right using
				; $dff102 (maximum 16 pixels)

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

;	This routine is similar to that of Lesson3d.s, in this case we modify
;	the value of the scroll register BPLCON1 $dff102 to scroll the image
;	forward and backward.
;	Since it is possible to act separately on even and odd bitplanes, we
;	have to move them at the same time to move all bitplanes: $0011,
;	$0022, $0033 instead of $0001, $0002, $0003 that would only move the
;	odd bitplanes (1,3,5), or $0010, $0020, $0030 which would only move
;	the even bitplanes (2,4,6).
;	Try a "= c 102" to see the $dff102 bits

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
				; going to the LEFT
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

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

Moving the screen forward 16 pixels on the Amiga is a joke! just change a byte,
that of $dff102, and the game is done. On other computer graphics systems like
the MSDOS PC, on the other hand, it is necessary to modify the whole image and
"move it", with many instructions that slows everything down.

You can also move the even and odd planes separately, in order to easily
create parallax effects, just slide the background slowly, made from odd
bitplanes, and the first floor faster, made for example by even bitplanes. To
make a parallax on the PC you need to do very complicated and slow routines.
We verify that it is possible to scroll the odd and even bitplanes separately
with these two modifications; to scroll ONLY the EVEN bitplanes (in our case
only bitplane 2) change these instructions:


	sub.b	#$11,MIOCON1	; we subtract 1 from the bitplanes scroll

	cmpi.b	#$ff,MIOCON1	; have we arrived at the maximum scroll value?

	add.b	#$11,MIOCON1	; add 1 to the scroll of odd and even bitplanes
				; ($11,$22,$33,$44 etc..), GOING TO THE RIGHT

in this way:


	sub.b	#$10,MIOCON1	; only the even bitplanes!

	cmpi.b	#$f0,MIOCON1

	add.b	#$10,MIOCON1

You will notice that only one bitplane moves, the second, while the first and
the third remain in place. In moving bitplane 2 it remains "in the open", ie
loses the overlap with the other 2 showing its "REAL FACE", and takes COLOR2,
which is $FFF in the copperlist as you can see, in fact it is white. It takes
color2 because moving bitplane 2 it is "only" with the background, that is:
%010, with bitplanes 1 and 3 set to zero.
The binary number %010 is equal to 2, so its color will be decided by color
register 2, the $dff184. Change the value in the copperlist and verify that
bitplane 2 "alone" is controlled by that register:

	dc.w	$0184,$fff	; color2

In fact, by putting, for example, a $ff0, it will turn yellow. On the other
hand, the image remains "PUNCTURED" in the pixels where bitplane 2 is missing,
you can see it better by pressing the right button that blocks the scroll: in
particular you will notice the holes where the WHITE appears, ie where there
was only bitplane 2 without overlapping. In other cases, instead of forming a
HOLE, the color changes.

To scroll only the ODD bitplanes (1 and 3 in our image), instead, modify the
routine like this:

	subq.b	#$01,MIOCON1	; only the ODD planes!

	cmpi.b	#$0f,MIOCON1

	addq.b	#$01,MIOCON1

In this case the even bitplane 2 remains, and planes 1 and 3, the odd ones
move.
With this example you could also check the bitplane overlay method to display
the various colors.
