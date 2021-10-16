
; Lesson5m3.s	"CLOSING" OF THE VIDEO WINDOW WITH DIWSTART/STOP ($8e/$90)

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

	bsr.w	DIWVERTICALE	; shows the function of DIWSTART and DIWSTOP

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

; This routine ends up with $95 DIWYSTART incrementing by one each time and
; to $95 DIWYSTOP decreasing by one each time. When both values are reached
; the routine leaves without changing anything
; Note that the DIWSTOP here starts at $fe and not $ff + $2c as usual.

DIWVERTICALE:
	CMPI.B	#$95,DIWYSTOP	; Siamo arrivati al DIWSTOP giusto?
	BEQ.S	FINITO		; se si, non dobbiamo procedere oltre
	ADDQ.B	#1,DIWYSTART	; aggiungiamo 1 allo start
	SUBQ.B	#1,DIWYSTOP	; sottraiamo 1 allo stop
FINITO:
	RTS			; Uscita dalla routine


	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000 ; SPRITE
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	dc.w	$8E		; DIWSTART - Inizio finestra video
DIWYSTART:
	dc.b	$2c		; DIWSTRT $YY
	dc.b	$81		; DIWSTRT $XX (lo incrementiamo fino a $ff)

	dc.w	$90		; DIWSTOP - Fine finestra video
DIWYSTOP:
	dc.b	$fe		; DiwStop YY (partiamo dalla linea $fe!!)
	dc.b	$c1		; DiwStop XX (lo caliamo fino a $00)
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

		    ; 5432109876543210
	dc.w	$100,%0011001000000000	; bits 13 e 12 accesi!! (3 = %011)
					; 3 bitplanes lowres, non lace
BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane
	dc.w $e4,$0000,$e6,$0000	;secondo bitplane
	dc.w $e8,$0000,$ea,$0000	;terzo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$475	; color1
	dc.w	$0184,$fff	; color2
	dc.w	$0186,$ccc	; color3
	dc.w	$0188,$999	; color4
	dc.w	$018a,$232	; color5
	dc.w	$018c,$777	; color6
	dc.w	$018e,$444	; color7

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;	figura

PIC:
	incbin	"amiga.320*256*3"	; qua carichiamo la figura in RAW,
					; convertita col KEFCON, fatta di
					; 3 bitplanes consecutivi

	end

Questo listato mostra come si possa diminuire la grandezza della finestra
video in senso verticale: se per esempio visualizzassimo solo delle figure
nella parte alta dello schermo, potremmo restringere la finestra, "tagliando"
la parte sotto una certa linea; il byte YY del diwstart/stop e' uguale a quello
del WAIT: un wait $2c07,$fffe aspetta la prima linea bitplane visualizzata,
infatti il DIWSTART e' $2c81. Giunto alla linea $FF, il DIWSTOP riparte da
ZERO: dunque aspettando col diwstop la posizione $2cc1, aspetta la linea
$ff+$2c, ossia 299, ma le linee effettiviamente usate per visualizzare i
bitplane sono 256: dalla $2c (44) alla 299.
In questo esempio influisce anche il fatto che la figura si sposta in basso
assieme all'inizio della visualizzazione della finestra video.
Per vedere meglio cosa succede sul video, sostituite 3 bitplanes "pieni" ossia
con tutti i bit ad 1:

PIC:
	dcb.b	40*256*3,$FF

