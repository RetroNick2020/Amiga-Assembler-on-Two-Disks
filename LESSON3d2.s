
; Lesson3d2.s	BAR THAT GOES UP AND DOWN WITH THE COPPER MOVE & WAIT


;	Routine performed 1 time every 3 frames


	SECTION	CiriCop,CODE	; even in Fast it's fine

Inizio:
	move.l	4.w,a6			; Execbase in a6
	jsr		-$78(a6)		; Disable - stop multitasking
	lea		GfxName(PC),a1	; Pointer to library name in a1
	jsr		-$198(a6)		; OpenLibrary, EXEC-routine that
							; opens libraries, by using the
							; correct offset from the base-
							; address
	move.l	d0,GfxBase		; Save address of library base to
							; GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist
	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088			; COPJMP1 - Let's  start the COP

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse			; If not yet, do not continue
frame:
	cmpi.b	#$fe,$dff006	; Are we at line 254? (must redo the ride!)
	bne.s	frame			; If not yet, do not continue
frame2:
	cmpi.b	#$fd,$dff006	; Are we at line 253? (must redo the ride!)
	bne.s	frame2			; If not yet, do not continue

	bsr.s	MuoviCopper		; A routine that makes the bar go down and up


	btst	#6,$bfe001	; is left mouse-button pressed?
	bne.s	mouse		; if not, return to mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Point to system COP
	move.w	d0,$dff088			; COPJMP1 - let's start the COP

	move.l	4.w,a6			; Execbase in A6
	jsr		-$7e(a6)		; Enable - re-enable il Multitasking
	move.l	GfxBase(PC),a1	; Base of lirary to close
							; (libraries should be opened and closed!!!)
	jsr		-$19e(a6)		; Closelibrary - close la graphics lib
	rts

;	The "MuoviCopper"-routine modified in style with the "ZOOM" already seen

MuoviCopper:
	LEA	BARRA,a0
	TST.B	SuGiu		; Do we have to go up or down? If SuGiu is reset,
						; (ie the TST verifies the BEQ) then we skip to
						; VAIGIU, if instead it is set to $FF (if this TST
						; is not verified) we continue going up (doing SUBq)
	beq.w	VAIGIU
	cmpi.b	#$82,8*9(a0); have we arrived at line $82?
	beq.s	MettiGiu	; if yes, we are at the top and we have to go down
;	subq.b	#1,(a0)
	subq.b	#1,8(a0)	; now we change the other waits: the distance 
	subq.b	#2,8*2(a0)	; between a wait and the other is 8 bytes
	subq.b	#3,8*3(a0)
	subq.b	#4,8*4(a0)
	subq.b	#5,8*5(a0)
	subq.b	#6,8*6(a0)
	subq.b	#7,8*7(a0)	; here we have to change all 9 waits of the red bar
	subq.b	#8,8*8(a0)	; every time to make it go up!
	subq.b	#8,8*9(a0)
	rts

MettiGiu:
	clr.b	SuGiu		; By resetting SuGiu, at the "TST.B SuGiu" the BEQ
	rts					; will skip to the VAIGIU routine, and the bar will
						; go down

VAIGIU:
	cmpi.b	#$fa,8*9(a0)	; have we arrived at line $fa?
	beq.s	MettiSu			; if yes, we are at the bottom and we have to
							; go up
;	addq.b	#1,(a0)
	addq.b	#1,8(a0)	; now we change the other waits: the distance
	addq.b	#2,8*2(a0)	; between a wait and the other is 8 bytes
	addq.b	#3,8*3(a0)
	addq.b	#4,8*4(a0)
	addq.b	#5,8*5(a0)
	addq.b	#6,8*6(a0)
	addq.b	#7,8*7(a0)	; here we have to change all 9 waits of the red bar
	addq.b	#8,8*8(a0)	; every time to bring it down
	addq.b	#8,8*9(a0)
	rts

MettiSu:
	move.b	#$ff,SuGiu	; When the SuGiu label is not zero, it means we
	rts					; have to go up.

SuGiu:
	dc.b	0,0

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:		; Here we store the base address for the graphics.library
	dc.l	0

OldCop:			; Here we store the address of the old system COP
	dc.l	0

	SECTION	GRAPHIC,DATA_C	; This command makes AmigaDOS load this data
							; segment into CHIP RAM, which is mandatory.
							; The copperlist MUST be in CHIP RAM!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0
	dc.w	$180,$000	; COLOR0 - Start the cop with the color BLACK
	dc.w	$4907,$FFFE	; WAIT - wait for line $49 (73)
	dc.w	$180,$001	; COLOR0 - dark blue
	dc.w	$4a07,$FFFE	; WAIT - line 74 ($4a)
	dc.w	$180,$002	; blue a little more intense
	dc.w	$4b07,$FFFE	; line 75 ($4b)
	dc.w	$180,$003	; lighter blue
	dc.w	$4c07,$FFFE	; next line
	dc.w	$180,$004	; lighter blue
	dc.w	$4d07,$FFFE	; next line
	dc.w	$180,$005	; lighter blue
	dc.w	$4e07,$FFFE	; next line
	dc.w	$180,$006	; blue to 6
	dc.w	$5007,$FFFE	; jump 2 lines: from $4e to $50, or from 78 to 80
	dc.w	$180,$007	; blue to 7
	dc.w	$5207,$FFFE	; jump 2 lines
	dc.w	$180,$008	; blue to 8
	dc.w	$5507,$FFFE	; jump 3 lines
	dc.w	$180,$009	; blue to 9
	dc.w	$5807,$FFFE	; jump 3 lines
	dc.w	$180,$00a	; blue to 10
	dc.w	$5b07,$FFFE	; jump 3 lines
	dc.w	$180,$00b	; blue to 11
	dc.w	$5e07,$FFFE	; jump 3 lines
	dc.w	$180,$00c	; blue to 12
	dc.w	$6207,$FFFE	; jump 4 lines
	dc.w	$180,$00d	; blue to 13
	dc.w	$6707,$FFFE	; jump 5 lines
	dc.w	$180,$00e	; blue to 14
	dc.w	$6d07,$FFFE	; jump 6 lines
	dc.w	$180,$00f	; blue to 15
	dc.w	$780f,$FFFE	; line $78
	dc.w	$180,$000	; color BLACK

BARRA:
	dc.w	$7907,$FFFE	; wait for line $79
	dc.w	$180,$300	; start of red zone: red to 3
	dc.w	$7a07,$FFFE	; next line
	dc.w	$180,$600	; red to 6
	dc.w	$7b07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$7c07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; red to 15 (maximum)
	dc.w	$7e07,$FFFE
	dc.w	$180,$c00	; red to 12
	dc.w	$7f07,$FFFE
	dc.w	$180,$900	; red to 9
	dc.w	$8007,$FFFE
	dc.w	$180,$600	; red to 6
	dc.w	$8107,$FFFE
	dc.w	$180,$300	; red to 3
	dc.w	$8207,$FFFE
	dc.w	$180,$000	; color BLACK

	dc.w	$fd07,$FFFE	; wait for line $FD
	dc.w	$180,$00a	; blue intensity 10
	dc.w	$fe07,$FFFE	; next line
	dc.w	$180,$00f	; blue intensity maximum (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST


	end

In this example, the Muovicopper routine is executed once every 3 FRAMES,
ie once every 3 fiftieths of a second, to slow down the excessive speed,
through the stratagem of the various cmp with the $ dff006.
On the other hand, the fact that it is performed every 3 frames makes it
less smooth, as you can see from the jerky movements in the lower part.

This is the time to teach you some tricks of the trade. If you need to make
changes to long COPPERLISTs, for example you have to change all 07 to 87,
to wait for the middle of the line instead of the beginning, you can use
the editors REPLACE command, that allows you to change a given string of
characters with another.

To make the change I said, you must position the cursor at the beginning of
the COPPERLIST, then press 'AMIGA + SHIFT + R' together, and the word
"Search For:" will appear in the menu-bar. Here you have to write the text
to search for, in this case write "07,$fffe" and press return.

Now the words "Replace with:" will appear. Here you have to put in the
changes that you intend to do: that is "87,$fffe". At this point the cursor
will go to the first 07,$fffe and the prompt "Replace: (Y / N / L / G)"
will appear. At this point you have to decide whether or not to exchange 07
with 87. If you want to change it, press Y, if you do not want to change,
press N. Wen the choice is made, the cursor will go to the next 07,$fff,
and the prompt repeats its question. Feel free to change all until the
end of the copperlist, then stop with ESC, to avoid changing those in the
comment below.

If you press G, all "07,$fffe", will be replaced until the end of the
text.  Think twice before using the G (GLOBAL), you could change something
that was not meant to be changed. It is best to proceed by doing Y or N
until the end of the area to change, then press ESC to end, or press L to
change the last one to be replaced (indicates LOCALE, ie LAST CHANGE TO DO).

Once you have made this change, execute the listing: you will notice that
the bar and the other "nuances" have a slope towards the center. This is
just because we change color in the middle ($87) instead of at the
beginning of the line.

Try now to return everything: do the REPLACE, giving as original string
"87,$ff" and as new string "67,$ff". You will notice that the scaling is
more to the right.

Finally, do another effect: now you have all the waits changed to
$xx67,$fffe, well, try to change them to $xx69,$fffe, but one yes and one
no, that is, enter the replace question as the first string "67,$ff" and
second "69,$ff", after which you press Y on the first, N on the second, Y
on the third and so on, one Y and one N.

In this way, when the colors changes alternatively at position $67 and $69,
creating an effect similar to the interlocking of bricks, try to execute it.

The joint will be similar to this:

	ooooooo+++++
	oooo++++++++
	oooooo++++++
	oooo++++++++
	oooooo++++++

