
; Lesson4c.s	FUSION OF 3 COPPER EFFECTS + 8 COLOR IMAGE

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
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue

	bsr.w	muovicopper	; red bar below line $ff
	bsr.w	CopperDestSin	; Scroll right / left routine
	BSR.w	scrollcolors	; cyclic color shift

Aspetta:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we still on line 255?
	beq.s	Aspetta		; If yes, wait for the following line ($00),
				; otherwise MuoviCopper will rerun.

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

; **************************************************************************
; *		HORIZONTAL SLIDING BAR (Lesson3h.s)			   *
; **************************************************************************

CopperDESTSIN:
	CMPI.W	#85,DestraFlag		; Has "VAIDESTRA" been run 85 times?
	BNE.S	VAIDESTRA		; If not, execute it now
	CMPI.W	#85,SinistraFlag	; Has "VAISINISTRA" been run 85 times?
	BNE.S	VAISINISTRA		; If not, execute it now
	CLR.W	DestraFlag	; the VAISINISTRA routine has been performed
	CLR.W	SinistraFlag	; 85 times, start again
	RTS			; Return to mouse-loop


VAIDESTRA:			; this routine moves the bar towards RIGHT
	lea	CopBar+1,A0	; Let's put the address of the first XX in A0
	move.w	#29-1,D2	; we have to change 29 wait (using a DBRA)
DestraLoop:
	addq.b	#2,(a0)		; add 2 to the X coordinate of the WAIT
	ADD.W	#16,a0		; let's go to the next WAIT to change
	dbra	D2,DestraLoop	; loop executed d2 times
	addq.w	#1,DestraFlag	; we signal that we have executed VAIDESTRA
	RTS			; BACK TO THE mouse-LOOP


VAISINISTRA:			; this routine moves the bar to the LEFT
	lea	CopBar+1,A0
	move.w	#29-1,D2	; we have to change 29 WAIT-instructions
SinistraLoop:
	subq.b	#2,(a0)		; subtract 2 from the X coordinate of the WAIT
	ADD.W	#16,a0		; let's go to the next WAIT to change
	dbra	D2,SinistraLoop	; loop executed d2 times
	addq.w	#1,SinistraFlag ; Let's note the move
	RTS			; BACK TO THE mouse-LOOP


DestraFlag:		; In this word the account of the times that
	dc.w	0	; VAIDESTRA: has been performed is kept

SinistraFlag:		; In this word the account of the times that
	dc.w    0	; VAISINISTRA: has been performed is kept

; **************************************************************************
; *		RED BAR UNDER THE LINE $FF (Lesson3f.s)			   *
; **************************************************************************

MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; We have to go up or down?
	beq.w	VAIGIU
	cmpi.b	#$0a,(a0)	; have we arrived at line $0a+$ff? (265)
	beq.s	MettiGiu	; if so, we are on top, and we must come down
	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; now we change the other waits: the distance
	subq.b	#1,8*2(a0)	; between a wait and the other is 8 bytes
	subq.b	#1,8*3(a0)
	subq.b	#1,8*4(a0)
	subq.b	#1,8*5(a0)
	subq.b	#1,8*6(a0)
	subq.b	#1,8*7(a0)	; here we have to change all 9 waits of the
	subq.b	#1,8*8(a0)	; red bar every time to make it go up!
	subq.b	#1,8*9(a0)
	rts

MettiGiu:
	clr.b	SuGiu		; By resetting SuGiu, at the "TST.B SuGiu"
				; the BEQ will skip to
	rts			; the VAIGIU routine, and the bar will go down

VAIGIU:
	cmpi.b	#$2c,8*9(a0)	; have we arrived at line $2c?
	beq.s	MettiSu		; if so, we are at the bottom, and we must
				; go up
	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; now we change the other waits: the distance
	addq.b	#1,8*2(a0)	; between a wait and the other is 8 bytes
	addq.b	#1,8*3(a0)
	addq.b	#1,8*4(a0)
	addq.b	#1,8*5(a0)
	addq.b	#1,8*6(a0)
	addq.b	#1,8*7(a0)	; here we have to change all 9 waits of the
	addq.b	#1,8*8(a0)	; red bar every time to bring it down
	addq.b	#1,8*9(a0)
	rts

MettiSu:
	move.b	#$ff,SuGiu	; When the SuGiu label is not zero, it means
	rts			; we have to go up.


SuGiu:
	dc.b	0,0

; **************************************************************************
; *		COLOR CYCLIC SCROLL (Lesson3E.s)			   *
; **************************************************************************

Scrollcolors:	
	move.w	col2,col1	; col2 copied to col1
	move.w	col3,col2	; col3 copied to col2
	move.w	col4,col3	; col4 copied to col3
	move.w	col5,col4	; col5 copied to col4
	move.w	col6,col5	; col6 copied to col5
	move.w	col7,col6	; col7 copied to col6
	move.w	col8,col7	; col8 copied to col7
	move.w	col9,col8	; col9 copied to col8
	move.w	col10,col9	; col10 copied to col9
	move.w	col11,col10	; col11 copied to col10
	move.w	col12,col11	; col12 copied to col11
	move.w	col13,col12	; col13 copied to col12
	move.w	col14,col13	; col14 copied to col13
	move.w	col1,col14	; col1 copied to col14
	rts

; **************************************************************************
; *				SUPER COPPERLIST			   *
; **************************************************************************

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

;	L'effetto di Lezione3e.s spostato piu' in ALTO

	dc.w	$3a07,$fffe	; wait for line 58 ($3a in hexadecimal)
	dc.w	$180		; COLOR0
col1:
	dc.w	$0f0		; VALUE OF COLOR 0 (will be modified)
	dc.w	$3b07,$fffe 	; wait for line 59 (will not be modified)
	dc.w	$180		; COLOR0 (will not be modified)
col2:
	dc.w	$0d0		; VALUE OF COLOR 0 (will be modified)
	dc.w	$3c07,$fffe	; wait for line 60 (will not be modified), etc
	dc.w	$180		; COLOR0
col3:
	dc.w	$0b0		; VALUE OF COLOR 0
	dc.w 	$3d07,$fffe	; wait for line 61
	dc.w	$180		; COLOR0
col4:
	dc.w	$090		; VALUE OF COLOR 0
	dc.w	$3e07,$fffe	; wait for line 62
	dc.w	$180		; COLOR0
col5:
	dc.w	$070		; VALUE OF COLOR 0
	dc.w	$3f07,$fffe	; wait for line 63
	dc.w	$180		; COLOR0
col6:
	dc.w	$050		; VALUE OF COLOR 0
	dc.w	$4007,$fffe	; wait for line 64
	dc.w	$180		; COLOR0
col7:
	dc.w	$030		; VALUE OF COLOR 0
	dc.w	$4107,$fffe	; wait for line 65
	dc.w	$180		; color0... (now you understand the comments,
col8:				; I can even stop putting them here!)
	dc.w	$030
	dc.w	$4207,$fffe	; line 66
	dc.w	$180
col9:
	dc.w	$050
	dc.w	$4307,$fffe	;  line 67
	dc.w	$180
col10:
	dc.w	$070
	dc.w	$4407,$fffe	;  line 68
	dc.w	$180
col11:
	dc.w	$090
	dc.w	$4507,$fffe	;  line 69
	dc.w	$180
col12:
	dc.w	$0b0
	dc.w	$4607,$fffe	;  line 70
	dc.w	$180
col13:
	dc.w	$0d0
	dc.w	$4707,$fffe	;  line 71
	dc.w	$180
col14:
	dc.w	$0f0
	dc.w 	$4807,$fffe	;  line 72

	dc.w 	$180,$0000	; We decide the color BLACK for the part of
				; the screen under the effect


	dc.w	$0180,$000	; color0
	dc.w	$0182,$550	; color1	; we redefine the color of
	dc.w	$0184,$ff0	; color2	; the word COMMODORE! YELLOW!
	dc.w	$0186,$cc0	; color3
	dc.w	$0188,$990	; color4
	dc.w	$018a,$220	; color5
	dc.w	$018c,$770	; color6
	dc.w	$018e,$440	; color7

	dc.w	$7007,$fffe	; Wait for the end of the word COMMODORE

;	The 8 colors of the image are defined here:

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

;	EFFECT OF THE LESSON3h.s

	dc.w	$9007,$fffe	; we wait for the first line of the gray bar
	dc.w	$180,$000	; which we set to black
CopBar:
	dc.w	$9031,$fffe	; WAIT that we change ($9033,$9035,$9037...)
	dc.w	$180,$100	; color red
	dc.w	$9107,$fffe	; WAIT that we don't change (Beginning of line)
	dc.w	$180,$111	; color GRAY (the beginning of the line that
				; goes up to
	dc.w	$9131,$fffe	; this WAIT, that we will change...)
	dc.w	$180,$200	; after which the RED begins

;	    FIXED WAITs (then gray) - WAITs TO CHANGE (followed by red)

	dc.w	$9207,$fffe,$180,$222,$9231,$fffe,$180,$300 ; line 3
	dc.w	$9307,$fffe,$180,$333,$9331,$fffe,$180,$400 ; line 4
	dc.w	$9407,$fffe,$180,$444,$9431,$fffe,$180,$500 ; line 5
	dc.w	$9507,$fffe,$180,$555,$9531,$fffe,$180,$600 ; ...
	dc.w	$9607,$fffe,$180,$666,$9631,$fffe,$180,$700
	dc.w	$9707,$fffe,$180,$777,$9731,$fffe,$180,$800
	dc.w	$9807,$fffe,$180,$888,$9831,$fffe,$180,$900
	dc.w	$9907,$fffe,$180,$999,$9931,$fffe,$180,$a00
	dc.w	$9a07,$fffe,$180,$aaa,$9a31,$fffe,$180,$b00
	dc.w	$9b07,$fffe,$180,$bbb,$9b31,$fffe,$180,$c00
	dc.w	$9c07,$fffe,$180,$ccc,$9c31,$fffe,$180,$d00
	dc.w	$9d07,$fffe,$180,$ddd,$9d31,$fffe,$180,$e00
	dc.w	$9e07,$fffe,$180,$eee,$9e31,$fffe,$180,$f00
	dc.w	$9f07,$fffe,$180,$fff,$9f31,$fffe,$180,$e00
	dc.w	$a007,$fffe,$180,$eee,$a031,$fffe,$180,$d00
	dc.w	$a107,$fffe,$180,$ddd,$a131,$fffe,$180,$c00
	dc.w	$a207,$fffe,$180,$ccc,$a231,$fffe,$180,$b00
	dc.w	$a307,$fffe,$180,$bbb,$a331,$fffe,$180,$a00
	dc.w	$a407,$fffe,$180,$aaa,$a431,$fffe,$180,$900
	dc.w	$a507,$fffe,$180,$999,$a531,$fffe,$180,$800
	dc.w	$a607,$fffe,$180,$888,$a631,$fffe,$180,$700
	dc.w	$a707,$fffe,$180,$777,$a731,$fffe,$180,$600
	dc.w	$a807,$fffe,$180,$666,$a831,$fffe,$180,$500
	dc.w	$a907,$fffe,$180,$555,$a931,$fffe,$180,$400
	dc.w	$aa07,$fffe,$180,$444,$aa31,$fffe,$180,$301
	dc.w	$ab07,$fffe,$180,$333,$ab31,$fffe,$180,$202
	dc.w	$ac07,$fffe,$180,$222,$ac31,$fffe,$180,$103
	dc.w	$ad07,$fffe,$180,$113,$ad31,$fffe,$180,$004

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
	dc.w	$d807,$FFFE	; jump 10 lines
	dc.w	$180,$11F	; brighten up...
	dc.w	$e807,$FFFE	; jump 16 lines
	dc.w	$180,$22F	; brighten up...

;	Effect of the lesson3f.s

	dc.w	$ffdf,$fffe	; WARNING! WAIT FOR THE END OF LINE $FF!
				; the wait after this is under the $FF line
				; and start from $00 !!

	dc.w	$0107,$FFFE	; a fixed green bar UNDER line $FF!
	dc.w	$180,$010
	dc.w	$0207,$FFFE
	dc.w	$180,$020
	dc.w	$0307,$FFFE
	dc.w	$180,$030
	dc.w	$0407,$FFFE
	dc.w	$180,$040
	dc.w	$0507,$FFFE
	dc.w	$180,$030
	dc.w	$0607,$FFFE
	dc.w	$180,$020
	dc.w	$0707,$FFFE
	dc.w	$180,$010
	dc.w	$0807,$FFFE
	dc.w	$180,$000

BARRA:
	dc.w	$0907,$FFFE	; wait for line $79
	dc.w	$180,$300	; start of red bar: red to 3
	dc.w	$0a07,$FFFE	; next line
	dc.w	$180,$600	; red to 6
	dc.w	$0b07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$0c07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$0d07,$FFFE
	dc.w	$180,$f00	; red to 15 (maximum)
	dc.w	$0e07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$0f07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$1007,$FFFE
	dc.w	$180,$600	; red to 6
	dc.w	$1107,$FFFE
	dc.w	$180,$300	; red to 3
	dc.w	$1207,$FFFE
	dc.w	$180,$000	; color BLACK

	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


; **************************************************************************
; *			IMAGE IN 8 COLORS 320x256			   *
; **************************************************************************

;	Remember to select the directory where the image is, in this case
;	just write: "V df0:SOURCES2"


PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

In this example there is nothing new, but we have put together many of the
copper effects studied so far: Lesson3h.s, Lesson3f.s, Lesson3e.s,
simply loading those sources into other text buffers, copying the routine and
the copperlist part of the effect: the routines as you can see are one below
the other in the order with which I have uploaded the examples, while the WAITs
for the copperlist are "ADDED" according to a specific order, so that they do
not overlap: in fact I had to move more than one WAIT in the effect of
Lesson3f.s, while the other 2 could be left unchanged.

It will suffice then that the routines are recalled in the synchronized loop:

	bsr.w	muovicopper	; red bar below line $ff
	bsr.w	CopperDestSin	; Scroll right / left routine
	BSR.w	scrollcolors	; cyclic color shift

We often program the individual routines separately and then put them together
as in this example; it is good practice to mount and disassemble graphic
demos as in this example, because basically a good part of the programming is
constituted by the assembly of the routines. Each routine can then be reused
in many sources, with simple modifications: for example, the TEAM 17
programmer certainly used the same joystick and disk load management routines
on all of his games, and probably the routines that move the characters on the
screen are derived from each other with little change. Every routine you plan
or find around can be used many times, both as an example and to put it right
in your programs. If you had all the routines necessary for the programming of
a separate game, let's assume a joystick.s, a diskload.s, a playmusic.s, a
scrollscreen.s, etc., doing the game would be limited to an operation similar
to those who set the table:
that is to put the napkins, the plates, the cutlery at the right point, so you
should put the game together as a puzzle, which would require at least the
knowledge of the functioning of the routines.
The problem of so many demos and games is in fact that the routines are well
combined, the graphics and the sound if they are made, but it is suspected
that the routines come from other programmers, stolen or granted.
On the other hand, if the game works, what does it matter? It will always be a
good game but similar to some others, a crossbreed.

Quando le routines uno se le programma da solo, si riconosce sempre perche' o
le ha fatte peggio degli altri, o le ha fatte meglio. (Does not make sense
translating with Google)

So the ugly and beautiful games are the most "HONESTLY" programmed. But I
advise you to leave aside the pride for now that you are learning, I do not
think you can innovate the Amiga programming now! So you break down and re-add
the routines you find in the course as in this source, the purpose is to learn,
and there's no better way to learn than adding and disassembling routines.
But then you do not go around with MY routines and say that you have 
programmed them all by yourself. When you have finished this course, then you
will be able to make them, and maybe to have innovative ideas, the assembler
does not set limits.
