
; Lesson5c.s	SCROLLING AN IMAGE UP AND DOWN BY MODIFYING BITPLANE
;		POINTERS IN THE COPPERLIST

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


	bsr.w	MuoviCopper	; slide the image up and down one line at a
				; time by changing the pointers to the
				; bitplanes in the copperlist

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


;	This routine moves the image up and down, acting on the pointers to
;	the bitplanes in the copperlist (through the BPLPOINTERS label)
;	The structure is similar to that of Lesson3d.s
;	First we put the address that are pointing the BPLPOINTERS in d0, then
;	add or subtract 40 to d0, and finally to change the BPLPOINTERS in the
;	copperlist we have to "re-point" the value changed in d0 with the same
;	POINTBP routine.

MuoviCopper:
	LEA	BPLPOINTERS,A1	; With these 4 instructions we copy the address
	move.w	2(a1),d0	; currently pointing the $dff0e0 from the
	swap	d0		; copperlist and place it in d0
	move.w	6(a1),d0	; the opposite of the routine that points the
				; bitplanes! Here instead of setting the
				; address we retrieve it !!!

	TST.B	SuGiu		; Are we going up or down? if SuGiu is cleared,
				; (ie the TST verifies the BEQ) then we jump to
				; VAIGIU, if instead it is $FF (if this TST is
				; not verified) we continue going up (doing
				; the SUBs)
	beq.w	VAIGIU
	cmp.l	#PIC-(40*30),d0	; are we high enough?
	beq.s	MettiGiu	; if yes, we are at the top and must come down
	sub.l	#40,d0		; we subtract 40, that is 1 line, thereby
				; pushing the image towards the BOTTOM
	bra.s	Finito

MettiGiu:
	clr.b	SuGiu		; By resetting SuGiu, at "TST.B SuGiu" the
	bra.s	Finito		; BEQ will jump to the VAIGIU routine

VAIGIU:
	cmpi.l	#PIC+(40*30),d0	; are we low enough?
	beq.s	MettiSu		; if yes, we are at the bottom and must go up
	add.l	#40,d0		; Add 40, that is 1 line, thereby scrolling
				; the image UP
	bra.s	finito

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

;	Insert the piece of copperlist here

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	image

	dcb.b	40*30,0	; this zeroed space is needed because moving to view
			; up and down we go out of the PIC area and display
			; what memory areas before and after the pic, which
			; would  otherwise display disturbing scattered bytes.
			; putting $00-bytes at this point displays $00, which
			; is the background color.

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	dcb.b	40*30,0	; see above

; NOTE: The dcb.b is used to put many equal bytes next to each other in
; memory. Writing "dcb.b 10,0" is like writing "dc.b 0" 10 times,
; or "dc.b 0,0,0,0,0,0,0,0,0,0"
;

	end

In practice this routine adds or subtracts 40 to the address to which the
BPLPOINTERS in copperlist point, first reading the "current" address with the
routine doing the reverse operation to that which points the bitplanes.
With this method you can also view larger images than the screen, displaying
one part at a time with the possibility of scrolling them up or down.
For example in FLIPPER games, like PINBALL DREAMS, the game screen is higher
than the visible one, and scrolls up or down, to display the part where the
ball bounces, changing the bitplanes pointers.
In this example, by moving, we also display lines outside of our image, as it
is 256 lines long only and we scroll 30 lines above and 30 below, ie 316 lines
in total. This is why there are dcb.b before and after the image, to "clean"
the area that is revealed when scrolling the RAW bitplanes. Try to change them
this way:

	dcb.b	40*30,%11001100

By executing the code you will notice that the parts outside the PIC are
"STRIPS" rather than zero, in fact we have filled them with

		%110011001100110011001100110011
		 110011001100110011001100110011
		 110011001100110011001100110011
		 
That is, bit strips.

You can also scroll the 3 bitplanes separately: to do this, just enable 1
bitplane in the $ dff100 only:

		    ; 5432109876543210
	dc.w	$100,%0001001000000000	; 1 bitplane

And change the maximum position reachable by the scroll:

VAISU:
	cmpi.l	#PIC+(40*530),d0; are we high enough?
	beq.s	MettiGiu	; if yes, we are at the top and we must go back
	...

In this way you will see the 3 bitplanes scroll separately, in fact they are
placed one after the other.

* Here is a change to be made to the copperlist: What happens if we change all
the 8 colors of the image every 2 lines? Copy (with Amiga + b + c + i) this
piece of copperlist and insert it before the end of the copperlist:

; Inserite qua il pezzo di copperlist

Changing the palette of 8 colors 52 times, you will get 8 * 52 = 416 colors
changed, but considering that the color0, being the background, must always
remain BLACK, it is not changed, only the other 7, and not in the "numeric"
order , but in "sparse" order, in fact the order with which the colors are
updated does not count on the result, you can change color2 first, then color3
etc., while in this example "we start" from color5 ($ dff18a) , then you
change color7 etc.
Changing 7 colors 52 times by inserting this copperlist we get 364 effective
colors on the screen at the same time, which is not bad, considering that the
screen "officially" displays only 8 colors. (7 * 52 = 364)


;2
	dc.w $18a,$102,$18e,$212,$182,$223	; color5,color7,color2
	dc.w $18c,$323,$188,$323,$186,$334,$184,$434 ; col6,col4,col3,col2
	dc.w $5007,$fffe
;3
	dc.w $18a,$104,$18e,$214,$182,$225
	dc.w $18c,$324,$188,$324,$186,$335,$184,$435
	dc.w $5207,$fffe
;4
	dc.w $18a,$203,$18e,$313,$182,$324
	dc.w $18c,$423,$188,$423,$186,$434,$184,$534
	dc.w $5407,$fffe
;5
	dc.w $18a,$213,$18e,$313,$182,$324
	dc.w $18c,$433,$188,$433,$186,$434,$184,$534
	dc.w $5607,$fffe
;6
	dc.w $18a,$114,$18e,$214,$182,$224
	dc.w $18c,$323,$188,$323,$186,$334,$184,$434
	dc.w $5807,$fffe
;7
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$322,$186,$333,$184,$433
	dc.w $5a07,$fffe
;8
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $5c07,$fffe
;9
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $5e07,$fffe
;10
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$322,$188,$312,$186,$323,$184,$433
	dc.w $6007,$fffe
;11
	dc.w $18a,$110,$18e,$210,$182,$221
	dc.w $18c,$321,$188,$311,$186,$322,$184,$432
	dc.w $6207,$fffe
;12
	dc.w $18a,$210,$18e,$310,$182,$321
	dc.w $18c,$421,$188,$411,$186,$422,$184,$532
	dc.w $6407,$fffe
;13
	dc.w $18a,$210,$18e,$320,$182,$331
	dc.w $18c,$431,$188,$421,$186,$432,$184,$542
	dc.w $6607,$fffe
;14
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $6807,$fffe
;15
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$440,$188,$430,$186,$441,$184,$551
	dc.w $6a07,$fffe
;16
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $6c07,$fffe
;17
	dc.w $18a,$120,$18e,$230,$182,$331
	dc.w $18c,$341,$188,$331,$186,$342,$184,$452
	dc.w $6e07,$fffe
;18
	dc.w $18a,$120,$18e,$230,$182,$341
	dc.w $18c,$351,$188,$341,$186,$352,$184,$462
	dc.w $7007,$fffe
;19
	dc.w $18a,$121,$18e,$231,$182,$332
	dc.w $18c,$342,$188,$332,$186,$343,$184,$453
	dc.w $7207,$fffe
;20
	dc.w $18a,$021,$18e,$131,$182,$232
	dc.w $18c,$242,$188,$232,$186,$243,$184,$353
	dc.w $7407,$fffe
;21
	dc.w $18a,$022,$18e,$132,$182,$233
	dc.w $18c,$243,$188,$233,$186,$244,$184,$354
	dc.w $7607,$fffe
;22
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
	dc.w $7807,$fffe
;23
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $7a07,$fffe
;24
	dc.w $18a,$013,$18e,$023,$182,$124
	dc.w $18c,$134,$188,$124,$186,$135,$184,$245
	dc.w $7c07,$fffe
;25
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $7e07,$fffe
;26
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
	dc.w $8007,$fffe
;27
	dc.w $18a,$022,$18e,$132,$182,$233
	dc.w $18c,$243,$188,$233,$186,$244,$184,$354
	dc.w $8207,$fffe
;28
	dc.w $18a,$112,$18e,$132,$182,$233
	dc.w $18c,$233,$188,$233,$186,$244,$184,$344
	dc.w $8407,$fffe
;29
	dc.w $18a,$102,$18e,$222,$182,$223
	dc.w $18c,$323,$188,$323,$186,$334,$184,$443
	dc.w $8607,$fffe
;30
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$322,$188,$322,$186,$333,$184,$433
	dc.w $8807,$fffe
;31
	dc.w $18a,$104,$18e,$214,$182,$225
	dc.w $18c,$324,$188,$324,$186,$335,$184,$435
	dc.w $8a07,$fffe
;32
	dc.w $18a,$203,$18e,$313,$182,$324
	dc.w $18c,$423,$188,$423,$186,$434,$184,$534
	dc.w $8c07,$fffe
;33
	dc.w $18a,$213,$18e,$313,$182,$324
	dc.w $18c,$433,$188,$433,$186,$434,$184,$534
	dc.w $8e07,$fffe
;34
	dc.w $18a,$114,$18e,$214,$182,$224
	dc.w $18c,$323,$188,$323,$186,$334,$184,$434
	dc.w $9007,$fffe
;35
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$322,$186,$333,$184,$433
	dc.w $9207,$fffe
;36
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $9407,$fffe
;37
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$312,$188,$312,$186,$323,$184,$423
	dc.w $9607,$fffe
;38
	dc.w $18a,$101,$18e,$211,$182,$222
	dc.w $18c,$322,$188,$312,$186,$323,$184,$433
	dc.w $9807,$fffe
;39
	dc.w $18a,$110,$18e,$210,$182,$221
	dc.w $18c,$321,$188,$311,$186,$322,$184,$432
	dc.w $9a07,$fffe
;40
	dc.w $18a,$210,$18e,$310,$182,$321
	dc.w $18c,$421,$188,$411,$186,$422,$184,$532
	dc.w $9c07,$fffe
;41
	dc.w $18a,$210,$18e,$320,$182,$331
	dc.w $18c,$431,$188,$421,$186,$432,$184,$542
	dc.w $9e07,$fffe
;42
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $a007,$fffe
;43
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$440,$188,$430,$186,$441,$184,$551
	dc.w $a207,$fffe
;44
	dc.w $18a,$220,$18e,$330,$182,$431
	dc.w $18c,$441,$188,$431,$186,$442,$184,$552
	dc.w $a407,$fffe
;45
	dc.w $18a,$120,$18e,$230,$182,$331
	dc.w $18c,$341,$188,$331,$186,$342,$184,$452
	dc.w $a607,$fffe
;46
	dc.w $18a,$120,$18e,$230,$182,$341
	dc.w $18c,$351,$188,$341,$186,$352,$184,$462
	dc.w $a807,$fffe
;47
	dc.w $18a,$121,$18e,$231,$182,$332
	dc.w $18c,$342,$188,$332,$186,$343,$184,$453
	dc.w $aa07,$fffe
;48
	dc.w $18a,$021,$18e,$131,$182,$232
	dc.w $18c,$242,$188,$232,$186,$243,$184,$353
	dc.w $ac07,$fffe
;49
	dc.w $18a,$022,$18e,$132,$182,$233
	dc.w $18c,$243,$188,$233,$186,$244,$184,$354
	dc.w $ae07,$fffe
;50
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
	dc.w $b007,$fffe
;51
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $b207,$fffe
;52
	dc.w $18a,$013,$18e,$023,$182,$124
	dc.w $18c,$134,$188,$124,$186,$135,$184,$245
	dc.w $b407,$fffe
;53
	dc.w $18a,$013,$18e,$123,$182,$224
	dc.w $18c,$234,$188,$224,$186,$235,$184,$345
	dc.w $b607,$fffe
;54
	dc.w $18a,$012,$18e,$122,$182,$223
	dc.w $18c,$233,$188,$223,$186,$234,$184,$344
