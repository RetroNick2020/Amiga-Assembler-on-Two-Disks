
; Lesson5i.s	SCROLLING UP AND DOWN OF AN IMAGE SHOWING ALL CHIP MEMORY
;		THE BITPLANE POINTERS IN THE COPPERLIST
;		LEFT KEY TO MOVE FORWARD, RIGHT TO MOVE BACK, BOTH TO EXIT.

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist

;	Note: here we let the bitplanes aim for $000000, ie at the beginning
;	of the CHIP MEMORY

	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP
	move.w	#0,$dff1fc		; FMODE - Turn off AGA
	move.w	#$c00,$dff106		; BPLCON3 - Turn off AGA

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue
Aspetta:
	cmpi.b	#$ff,$dff006	; Are we still at line 255?
	beq.s	Aspetta		; If yes, do not continue, wait!

	btst	#2,$dff016	; if the right button is pressed scroll down!,
	bne.s	NonGiu		; or go to NonGiu

	bsr.s	VaiGiu		; right click, scroll down!

NonGiu:
	btst	#6,$bfe001	; left mouse button pressed?
	beq.s	Scorrisu	; if yes, scroll up
	bra.s	mouse		; no? then repeat the cycle in the next FRAME

Scorrisu:
	bsr.w	VaiSu		; scroll the image up

	btst	#2,$dff016	; if also the right button is pressed then both
	bne.s	mouse		; are pressed, exit, or "MOUSE"

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

VaiGiu:
	LEA	BPLPOINTERS,A1	; With these 4 instructions we copy the address
	move.w	2(a1),d0	; currently pointing the $dff0e0 from the
	swap	d0		; copperlist and place it in d0
	move.w	6(a1),d0
	sub.l	#80*3,d0	; we subtract 80 * 3, that is 3 lines,
				; thereby scrolling the image down
	bra.s	Finito


VaiSu:
	LEA	BPLPOINTERS,A1	; With these 4 instructions we copy the address
	move.w	2(a1),d0	; currently pointing the $dff0e0 from the
	swap	d0		; copperlist and place it in d0
	move.w	6(a1),d0
	add.l	#80*3,d0	; Add 80*3, or 3 lines, scrolling the image up
	bra.w	Finito


Finito:				; WE POINT THE BITPLANES POINTERS
	move.w	d0,6(a1)	; copy the LOW word of the bitplane address
	swap	d0		; swap the two words in d0 (ex: 1234 > 3412)
	move.w	d0,2(a1)	; copy the HIGH word of the plane address
	rts


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8e,$2c81	; DiwStrt	(registers with normal values)
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$003c	; DdfStart HIRES normal
	dc.w	$94,$00d4	; DdfStop HIRES normal
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%1001001000000000	; bits 12/15 set!! 1 bitplane
					; hires 640x256, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;first	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$2ae	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

With this program you can see the contents of your CHIP RAM, in fact 1 bitplane
in hires is displayed, pointing at the address $00000 or at the beginning of
the Amiga's CHIP RAM. By pressing the left mouse button you can increase the
displayed address, scrolling through all the memory, in which you will notice
the screen of the wordbench, the ASMONE, as well as any images left in memory,
for example if you played a game before running this code you will probably
find the backgrounds and the characters of the game in memory, as the memory is
not deleted at the reset, but only by turning off the cumputer. With the right
button you can back up to center an image that interests you; to exit, you must
press both buttons. try to experiment by loading various videogames, resetting
and executing this program, to track down what is left.
If you want to speed up scrolling you have to increase the value added to the
bitplane, as long as it is a multiple of 80 (in fact to scroll a line in HIRES,
being 640 pixels wide per line instead of 320, you need twice as much as 40,
which we have until now used for screens in LOWRES).
In the listing the screen scrolls 3 lines at a time:

	sub.l	#80*3,d0	; we subtract 80 * 3, or 3 lines

To scroll with the TURBO, try 80 * 10 or more.
If, out of curiosity, you want to know the address of a bitplane you see on the
screen, exit at that point and type "M BPLPOINTERS":

XXXXXX 00 E0 00 02 00 E2 10 C0 ... (00 e0 = bplpointerH, 00 e2 = bplpointerL)

namely $00E0,$0002,$00E2,$10C0 ......

In this example the address is $0002 10c0, that is $210c0
