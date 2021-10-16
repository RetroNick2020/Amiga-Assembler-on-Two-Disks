
; Lezione9d3.s	BLITTA VERSO DESTRA, a scatti di 1 word (senza usare shift)


	SECTION	CiriCop,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup1.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001111000000	; copper,bitplane,blitter DMA


START:
;	Puntiamo la PIC "vuota"

	MOVE.L	#BITPLANE,d0	; dove puntare
	LEA	BPLPOINTERS,A1	; puntatori COP
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)

	lea	$dff000,a5		; CUSTOM REGISTER in a5
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	lea	bitplane,a0		; destinazione
	moveq	#50-1,d7		; Num. di spostamenti a destra
MoveLoop:
	MOVE.L	#$1ff00,d1	; bit per la selezione tramite AND
	MOVE.L	#$10800,d2	; linea da aspettare = $108
Waity1:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	BNE.S	Waity1
Waity2:
	MOVE.L	4(A5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	ANDI.L	D1,D0		; Seleziona solo i bit della pos. verticale
	CMPI.L	D2,D0		; aspetta la linea $108
	Beq.S	Waity2

	btst	#6,2(a5) ; dmaconr
WBlit1:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit1

;	Cancellazione dello schermo

	move.w	#$0100,$40(a5)		; BLTCON0 - accende solo il canale D,
					; questo provoca la cancellazione della
					; DESTINAZIONE, dato che non c'e' la
					; sorgente!!!
	move.w	#$0000,$42(a5)		; BLTCON1 - lo spieghiamo dopo
	move.w	#$0000,$66(a5)		; BLTDMOD = 0
	move.l	#bitplane,$54(a5)	; BLTDPT - destinazione = bitplane
	move.w	#(64*256)+20,$58(a5)	; BLTSIZE - alt.256 linee, largh. 20 w.
					; cancella TUTTO LO SCHERMO, infatti
					; le linee sono 256, (64*256) e i
					; byte per linea sono 40 (20 words)

	btst	#6,2(a5) ; dmaconr
WBlit2:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit2

;	  ..........
;	.� ..  ...  :
;	|.� _�� _ �.|
;	l  �_   _�  |
;	|  (�),(�)  |
;	| \_______/ |
;	|  |-+-+-|  |
;	l__`-^-^-'__|xCz
;	  `-------'

	move.w	#$ffff,$44(a5)		; BLTAFWM lo spieghiamo dopo
	move.w	#$ffff,$46(a5)		; BLTALWM lo spieghiamo dopo
	move.w	#$09f0,$40(a5)		; BLTCON0 (usa A+D)
	move.w	#$0000,$42(a5)		; BLTCON1 lo spieghiamo dopo
	move.w	#0,$64(a5)		; BLTAMOD (=0)
	move.w	#36,$66(a5)		; BLTDMOD (40-4=36)
	move.l	#figura,$50(a5)		; BLTAPT  (fisso alla figura sorgente)
	move.l	a0,$54(a5)		; BLTDPT  (linee di schermo)
	move.w	#(64*6)+2,$58(a5)	; BLTSIZE (via al blitter !)
					; adesso, blitteremo una figura di
					; 2 word X 6 linee con una sola
					; blittata dai moduli opportunamente
					; settati correttamente per lo schermo.

	addq.w	#2,a0			; modifica l'indirizzo, puntando alla
					; word seguente per la prossima
					; blittata. La figura scatta in avanti
					; di 16 pixel
	dbra	d7,moveloop

mouse:

	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	btst	#6,2(a5) ; dmaconr
WBlit3:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	wblit3

	rts

;****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$38		; DdfStart
	dc.w	$94,$d0		; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
	dc.w	$100,$1200	; bplcon0 - 1 bitplane Lowres

BPLPOINTERS:
	dc.w $e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1

	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

; Definiamo in binario la figura, che e' larga 16 bits, ossia 2 words, e alta
; 6 linee

Figura:
	dc.l	%00000000000000000000110001100000
	dc.l	%00000000000000000011000110000000
	dc.l	%00000000000000001100011000000000
	dc.l	%00000110000000110001100000000000
	dc.l	%00000001100011000110000000000000
	dc.l	%00000000011100011000000000000000

;****************************************************************************

	SECTION	PLANEVUOTO,BSS_C	

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

Questo esempio e` analogo a lezione9d2.s, solo che ci spostiamo a destra invece
che in basso. Lo spostamento avviane modificando l'indirizzo destinazione
sul quale blittiamo, spostandoci di una word alla volta. Cio` equivale
a spostarci di 16 pixel alla volta (bleah!).

