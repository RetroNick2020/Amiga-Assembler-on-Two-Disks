
; Lesson4a.s	UNIVERSAL BITPLANES POINTING ROUTINE

	SECTION	CiriBiri,CODE

Inizio:
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

	rts	; EXIT!!



COPPERLIST:
;	....	; here we will put the necessary registers...

;	We point the bitplanes directly by putting the registers $dff0e0 and
;	following in the copperlist, here with the addresses of the
;	bitplanes that will be set by the routine POINTBP

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;first	 bitplane - BPL0PT
	dc.w $e4,$0000,$e6,$0000	;second  bitplane - BPL1PT
	dc.w $e8,$0000,$ea,$0000	;third	 bitplane - BPL2PT
;	....
	dc.w	$FFFF,$FFFE	; fine della copperlist

;	Remember to select the directory where the image is, in this case
;	just write: "V df0:SOURCES2"

PIC:
	incbin	"amiga.320*256*3"	; here we load the image in RAW,
					; converted with KEFCON, made of 3
					; consecutive bitplanes

	end

Try to make an "AD", which is a DEBUG of this routine. While debugging pay
particular attention to the value of D0, visible at the top right, at the
time of the 2 swaps. To verify the operation, at the end of the execution
try to check with a "M BPLPOINTERS" if the words have been changed with the
SWAPPED words with the PIC: address. (With a "M PIC" you can see which
address the PIC has been loaded to through INCBIN, which as expected is 30720
bytes long: 40 * 256 * 3).
