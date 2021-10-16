
; Lesson3e.s	Scroll effect of a gradient background


;	Routine performed 1 time every 3 frames


	SECTION	CiriCop,CODE	; even in Fast it's fine

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName(PC),a1	; Pointer to library name in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC-routine that
				; opens libraries, by using the
				; correct offset from the base-address
	move.l	d0,GfxBase	; Save address of library base to
							; GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop		; Save address of system copperlist
	move.l	#MIACOPPER,$dff080	; pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP

mouse:
	cmpi.b	#$ff,$dff006	; VHPOSR - Are we at line 255?
	bne.s	mouse		; If not yet, do not continue
frame:
	cmpi.b	#$fe,$dff006	; Are we at line 254? (must redo the ride!)
	bne.s	frame		; If not yet, do not continue
frame2:
	cmpi.b	#$fd,$dff006	; Are we at line 253? (must redo the ride!)
	bne.s	frame2		; If not yet, do not continue

	bsr.s	ScrollColors	; A so-called RASTER BAR!

	btst	#6,$bfe001	; is left mouse-button pressed?
	bne.s	mouse		; if not, return to mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - Point to system COP
	move.w	d0,$dff088		; COPJMP1 - let's start the COP

	move.l	4.w,a6		; Execbase in A6
	jsr	-$7e(a6)	; Enable - re-enable il Multitasking
	move.l	GfxBase(PC),a1	; Base of library to close (libraries should
				; be opened and closed!!!)
	jsr	-$19e(a6)	; Closelibrary - close la graphics lib
	rts


; This routine slides the 14 colors of our green copperlist in order to
; simulate a continuous upward sliding, as if we saw an unlimited series of
; faded bars through a crack. In practice, each time you move the colors by
; copying them, starting copying the second to the first, the third to the
; second, etc., as if we had a row of colored balls in series: suppose you
; take the second and put it in place of the first, which you put in
; pocket, creating a "hole": you will continue moving all the balls one to
; one of a place: the third in place of the second, the fourth in place
; of the third, and so on, until you reach the fourteenth (the last ) that
; moved where the thirteenth was, creating the "hole" that was previously
; in place of the first.
; To plug this hole take the first ball from the pocket and put it in place
; of the fourteenth (note the last statement that in fact is "move.w col1,
; col14", ie after having "scratched" the "hole" from the first position at
; the fourteenth, we "tap" it with the first ball, creating a cycle of
; continuity (infinity!) as the sliding of the bicycle chain:
;
;	 >>>>>>>>>>>>>>>>>>>>>	
;	^                     v
;	 <<<<<<<<<<<<<<<<<<<<<
;
; but without the lower part of the chain: simply when a link in the chain (a
; color) arrives at the end (v), it is copied to the first position (^),
; making the infinite loop possible:
;
;	 >>>>>>>>>>>>>>>>>>>>>	
;	^		      v
;
; In fact, to stop the routine just delete any of the instructions that copy:
; try for example to put a ";" to the first one: (move.w col2, col1) and you
; will verify that it will only write once, after which the colors will end,
; being "BROKEN A RING OF THE CHAIN", which no longer provides the previous
; color.


ScrollColors:	
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

GfxName:
	dc.b	"graphics.library",0,0	

GfxBase:	; Here we store the base address for the graphics.library
	dc.l	0

OldCop:		; Here we store the address of the old system COP
	dc.l	0


;=========== Copperlist ==========================


	section	cop,data_C

MIACOPPER:
	dc.w	$100,$200	; BPLCON0 - screen without bitplanes, only
				; the background color $180 is visible.

	DC.W	$180,$000	; COLOR0 - we start with the color BLACK

	dc.w	$9a07,$fffe	; wait for line 154 ($9a in hexadecimal)
	dc.w	$180		; COLOR0
col1:
	dc.w	$0f0		; VALUE OF COLOR 0 (will be modified)
	dc.w	$9b07,$fffe 	; wait for line 155 (will not be modified)
	dc.w	$180		; COLOR0 (will not be modified)
col2:
	dc.w	$0d0		; VALUE OF COLOR 0 (will be modified)
	dc.w	$9c07,$fffe	; wait for line 156 (will not be modified,
				; etc...)
	dc.w	$180		; COLOR0
col3:
	dc.w	$0b0		; VALUE OF COLOR 0
	dc.w 	$9d07,$fffe	; wait for line 157
	dc.w	$180		; COLOR0
col4:
	dc.w	$090		; VALUE OF COLOR 0
	dc.w	$9e07,$fffe	; wait for line 158
	dc.w	$180		; COLOR0
col5:
	dc.w	$070		; VALUE OF COLOR 0
	dc.w	$9f07,$fffe	; wait for line 159
	dc.w	$180		; COLOR0
col6:
	dc.w	$050		; VALUE OF COLOR 0
	dc.w	$a007,$fffe	; wait for line 160
	dc.w	$180		; COLOR0
col7:
	dc.w	$030		; VALUE OF COLOR 0
	dc.w	$a107,$fffe	; wait for line 161
	dc.w	$180		; color0... (now you understand the comments,
col8:				; I can even stop putting them here!)
	dc.w	$030
	dc.w	$a207,$fffe	; line 162
	dc.w	$180
col9:
	dc.w	$050
	dc.w	$a307,$fffe	; line 163
	dc.w	$180
col10:
	dc.w	$070
	dc.w	$a407,$fffe	; line 164
	dc.w	$180
col11:
	dc.w	$090
	dc.w	$a507,$fffe	; line 165
	dc.w	$180
col12:
	dc.w	$0b0
	dc.w	$a607,$fffe	; line 166
	dc.w	$180
col13:
	dc.w	$0d0
	dc.w	$a707,$fffe	; line 167
	dc.w	$180
col14:
	dc.w	$0f0
	dc.w 	$a807,$fffe	; line 168

	dc.w 	$180,$0000	; We decide the color BLACK for the part of
				; the screen under the effect

	DC.W    $FFFF,$FFFE	; Fine della Copperlist

	END

Modification: Try adding this command to the end of the "Scrollcolors" routine,
and you will get a change of colors (add 1 to the RED component, ie RED)

	add.w   #$100,col13

Try then to change the value that we add to col13, to get different color
variations. Clearly it is a somewhat approximate system to make nuances, but
it can be useful for making sure you understand the routine.
