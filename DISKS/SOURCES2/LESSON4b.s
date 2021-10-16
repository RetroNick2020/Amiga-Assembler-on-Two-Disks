
; Lesson4b.s	DISPLAYING AN IMAGE OF 320*256 in 3 planes (8 colors)

	SECTION	CiriCop,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist

;*****************************************************************************
;	WE PUT THE BPLPOINTERS TO OUR BITPLANES IN THE COPPERLIST
;*****************************************************************************

	MOVE.L	#PIC,d0		; in d0 we put the address of the PIC, that
				; is, where the first bitplane starts

	LEA	BPLPOINTERS,A1	; in a1 we put the address of the pointers to
				; the bitplanes from the COPPERLIST
	MOVEQ	#2,D1		; number of bitplanes -1 (we have 3)
				; to execute a DBRA-loop
POINTBP:
	move.w	d0,6(a1)	; copy the LOW word of the bitplane address
				; to the correct word in the copperlist
	swap	d0		; exchange the 2 words of d0 (eg: 1234> 3412)
				; by putting the HIGH word instead of the
				; word LOW, allowing it to be copied with the
				; move.w !!
	move.w	d0,2(a1)	; copy the HIGH word of the bitplane address
				; to the correct word in the copperlist
	swap	d0		; it exchanges the 2 words of d0
				;(ex: 3412> 1234) obtaining the original
				; address.
	ADD.L	#40*256,d0	; Add 10240 to D0, making it point to the
				; second bitplane (it is after the first)
				; (ie we add the length of a plane)
				; In the cycles following the first we will
				; aim at the third, fourth bitplane and so on.

	addq.w	#8,a1		; a1 now contains the address of the next
				; bplpointers in the copperlist to be written.
	dbra	d1,POINTBP	; Redo D1 times POINTBP (D1 = num of
				; bitplanes)

;

	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP

	move.w	#0,$dff1fc		; FMODE - Turn off AGA
	move.w	#$c00,$dff106		; BPLCON3 - Turn off AGA

mouse:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

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

	; We point the sprites to ZERO, to eliminate them, otherwise we find
	; them to disturb by going crazy!!!

	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
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

; The BPLCON0 ($dff100) For a 3 bitplanes screen: (8 colors)

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 and 12 set!! (3 = %011)

;	We point the bitplanes directly putting the registers $dff0e0 and
;	following in the copperlist, here with the addresses of the
;	bitplanes set to zero that will be set at runtime by the routine
;	POINTBP

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;first	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;second  bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;third	 bitplane - BPL2PT

;	The 8 colors of the image are defined here:

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

;	Enter any effects with WAIT-instructions here

	dc.w	$FFFF,$FFFE	; Fine della copperlist


;	Remember to select the directory where the image is, in this case
;	just write: "V df0:SOURCES2"


PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

As you have seen, there are no synchronized routines in this example, only
routines that point to the bitplanes and the copperlist.

First of all try to delete the sprite pointers with the ";":

;	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
;	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
;	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
;	dc.w	$13e,$0000

You will notice that sometimes they pass like "STRISCIATE" (?), those are sprites madly out of control. We will learn to tame them later.

Now try to add some WAITs before the end of the copperlist, and you will see
how useful the WAIT+COLOR is for ADDING HORIZONTAL SHADES or CHANGING COLORS
totally FREE, that is, with an 8-color shape like this we can work with
MOVE + WAIT making a background with a hundred colors by fading them, or even
changing the "overlay" colors, ie $182, $184, $186, $188, $18a, $18c, $18e.

As a first 'embellishment', copy and insert this prefabricated piece of
nuance between the colors and the end of the copperlist: (dc.w $FFFF,$FFFE)
REMEMBER THAT YOU MUST SELECT THE BLOCK WITH Amiga + b, Amiga + c, then place
the cursor where you want to copy the text, and insert it with Amiga + i.


	dc.w	$a907,$FFFE	; Wait for line $a9
	dc.w	$180,$001	; dark blue
	dc.w	$aa07,$FFFE	; line $aa
	dc.w	$180,$002	; blue a bit more intense
	dc.w	$ab07,$FFFE	; line $ab
	dc.w	$180,$003	; lighter blue
	dc.w	$ac07,$FFFE	; next line
	dc.w	$180,$004	; lighter blue
	dc.w	$ad07,$FFFE	; next line
	dc.w	$180,$005	; lighter blue
	dc.w	$ae07,$FFFE	; next line
	dc.w	$180,$006	; blue to 6
	dc.w	$b007,$FFFE	; jump 2 lines
	dc.w	$180,$007	; blue to 7
	dc.w	$b207,$FFFE	; jump 2 lines
	dc.w	$180,$008	; blue to 8
	dc.w	$b507,$FFFE	; jump 3 lines
	dc.w	$180,$009	; blue to 9
	dc.w	$b807,$FFFE	; jump 3 lines
	dc.w	$180,$00a	; blue to 10
	dc.w	$bb07,$FFFE	; jump 3 lines
	dc.w	$180,$00b	; blue to 11
	dc.w	$be07,$FFFE	; jump 3 lines
	dc.w	$180,$00c	; blue to 12
	dc.w	$c207,$FFFE	; jump 4 lines
	dc.w	$180,$00d	; blue to 13
	dc.w	$c707,$FFFE	; jump 7 lines
	dc.w	$180,$00e	; blue to 14
	dc.w	$ce07,$FFFE	; jump 6 lines
	dc.w	$180,$00f	; blue to 15
	dc.w	$d807,$FFFE	; jump 10 line
	dc.w	$180,$11F	; brighten up...
	dc.w	$e807,$FFFE	; jump 16 lines
	dc.w	$180,$22F	; brighten up...
	dc.w	$ffdf,$FFFE	; END OF NTSC-ZONE (line $FF)
	dc.w	$180,$33F	; brighten up...
	dc.w	$2007,$FFFE	; line $20+$FF = line $11f (287)
	dc.w	$180,$44F	; brighten up...

We created from scratch, without counterproductive effects, a nuance bringing
the actual number of colors on screen from 8 to 27!!!!

Add another 7 colors, this time not by changing the background color, the
$dff180, but the other 7 colors: insert this piece of copperlist between the
bitplane pointers and the colors: (leave the others unchanged)

	dc.w	$0180,$000	; color0
	dc.w	$0182,$550	; color1	; we redefine the color of
	dc.w	$0184,$ff0	; color2	; the word COMMODORE! YELLOW!
	dc.w	$0186,$cc0	; color3
	dc.w	$0188,$990	; color4
	dc.w	$018a,$220	; color5
	dc.w	$018c,$770	; color6
	dc.w	$018e,$440	; color7

	dc.w	$7007,$fffe	; Wait for the end of the word COMMODORE

With 45 "dc.w" added to the copperlist we have turned a harmless PIC of
only 8 colors into a PIC of 34 colors, even exceeding the limit of the 32
colors of 5 bitplanes!!!

Only by programming the copperlist in assembler, you can make the most of
Amiga's graphics: now you could also make pictures with 320 clean colors
simply by changing the entire palette of a 32-color image 10 times, putting
a wait + palette every 25 lines...

Now maybe you will explain why some games have 64, 128 or more colors on the
screen!!! They have very long copperlists where they change color at
different lines of the screen!

Make some changes, which are always good, and if you go ahead trying to use
the examples of Lesson3 with the bars in the background, just load them in
other buffers and insert the right routine and copperlist pieces, it's a
good workout. Try to walk (?) the bar "under" the drawing, if you succeed you
are tough.
