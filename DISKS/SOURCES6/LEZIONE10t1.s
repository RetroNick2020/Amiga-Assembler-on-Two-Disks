
; Lezione10t1.s	Disegna una linea larga 2 pixel

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

	bsr.w	InitLine	; inizializza line-mode

	move.w	#$ffff,d0	; linea continua
	bsr.w	SetPattern	; definisce pattern

	move.w	#100,d0		; x1
	move.w	#100,d1		; y1
	move.w	#70,d2		; x2
	move.w	#220,d3		; y2
	lea	bitplane,a0
	bsr.s	Drawline

	move.w	#160,d0		; x1
	move.w	#85,d1		; y1
	move.w	#160,d2		; x2
	move.w	#140,d3		; y2
	lea	bitplane,a0
	bsr.s	Drawline

	move.w	#$f0f0,d0	; linea trattegiata
	bsr.w	SetPattern	; definisce pattern

	move.w	#300,d0		; x1
	move.w	#200,d1		; y1
	move.w	#240,d2		; x2
	move.w	#90,d3		; y2
	lea	bitplane,a0
	bsr.s	Drawline

mouse:
	btst	#6,$bfe001	; mouse premuto?
	bne.s	mouse

	rts


;******************************************************************************
; Questa routine effettua il disegno della linea. prende come parametri gli
; estremi della linea P1 e P2, e l'indirizzo del bitplane su cui disegnarla.
; D0 - X1 (coord. X di P1)
; D1 - Y1 (coord. Y di P1)
; D2 - X2 (coord. X di P2)
; D3 - Y2 (coord. Y di P2)
; A0 - indirizzo bitplane
;******************************************************************************

Drawline:

* scelta ottante

	sub.w	d0,d2		; D2=X2-X1
	bmi.s	DRAW4		; se negativo salta, altrimenti D2=DiffX
	sub.w	d1,d3		; D3=Y2-Y1
	bmi.s	DRAW2		; se negativo salta, altrimenti D3=DiffY
	cmp.w	d3,d2		; confronta DiffX e DiffY
	bmi.s	DRAW1		; se D2<D3 salta..
				; .. altrimenti D3=DY e D2=DX
	moveq	#$10,d5		; codice ottante
	bra.s	DRAWL
DRAW1:
	exg.l	d2,d3		; scambia D2 e D3, in modo che D3=DY e D2=DX
	moveq	#$00,d5		; codice ottante
	bra.s	DRAWL
DRAW2:
	neg.w	d3		; rende D3 positivo
	cmp.w	d3,d2		; confronta DiffX e DiffY
	bmi.s	DRAW3		; se D2<D3 salta..
				; .. altrimenti D3=DY e D2=DX
	moveq	#$18,d5		; codice ottante
	bra.s	DRAWL
DRAW3:
	exg.l	d2,d3		; scambia D2 e D3, in modo che D3=DY e D2=DX
	moveq	#$04,d5		; codice ottante
	bra.s	DRAWL
DRAW4:
	neg.w	d2		; rende D2 positivo
	sub.w	d1,d3		; D3=Y2-Y1
	bmi.s	DRAW6		; se negativo salta, altrimenti D3=DiffY
	cmp.w	d3,d2		; confronta DiffX e DiffY
	bmi.s	DRAW5		; se D2<D3 salta..
				; .. altrimenti D3=DY e D2=DX
	moveq	#$14,d5		; codice ottante
	bra.s	DRAWL
DRAW5:
	exg.l	d2,d3		; scambia D2 e D3, in modo che D3=DY e D2=DX
	moveq	#$08,d5		; codice ottante
	bra.s	DRAWL
DRAW6:
	neg.w	d3		; rende D3 positivo
	cmp.w	d3,d2		; confronta DiffX e DiffY
	bmi.s	DRAW7		; se D2<D3 salta..
				; .. altrimenti D3=DY e D2=DX
	moveq	#$1c,d5		; codice ottante
	bra.s	DRAWL
DRAW7:
	exg.l	d2,d3		; scambia D2 e D3, in modo che D3=DY e D2=DX
	moveq	#$0c,d5		; codice ottante

; Quando l'esecuzione raggiunge questo punto, abbiamo:
; D2 = DX
; D3 = DY
; D5 = codice ottante

DRAWL:
	mulu.w	#40,d1		; offset Y
	add.l	d1,a0		; aggiunge l'offset Y all'indirizzo

	move.w	d0,d1		; copia la coordinata X
	and.w	#$000F,d0	; seleziona i 4 bit piu` bassi della X..
	ror.w	#4,d0		; .. e li sposta nei bit da 12 a 15
	or.w	#$0B4A,d0	; con un OR ottengo il valore da scrivere
				; in BLTCON0. Con questo valore di LF ($4A)
				; si disegnano linee in EOR con lo sfondo.

	lsr.w	#4,d1		; cancella i 4 bit bassi della X
	add.w	d1,d1		; ottiene l'offset X in bytes
	add.w	d1,a0		; aggiunge l'offset X all'indirizzo

	move.w	d2,d1		; copia DX in D1
	addq.w	#1,d1		; D1=DX+1
	lsl.w	#$06,d1		; calcola in D1 il valore da mettere in BLTSIZE
	addq.w	#2,d1		; aggiunge la larghezza, pari a 2 words

	lsl.w	#$02,d3		; D3=4*DY
	add.w	d2,d2		; D2=2*DX

	btst	#$06,$02(a5)
WaitLine:
	btst	#$06,$02(a5)	; aspetta blitter fermo
	bne.s	WaitLine

	move.w	d3,$62(a5)	; BLTBMOD=4*DY
	sub.w	d2,d3		; D3=4*DY-2*DX
	move.w	d3,$52(a5)	; BLTAPTL=4*DY-2*DX

				; prepara valore da scrivere in BLTCON1
	or.w	#$0001,d5	; setta bit 0 (attiva line-mode)
	tst.w	d3
	bpl.s	OK1		; se 4*DY-2*DX>0 salta..
	or.w	#$0040,d5	; altrimenti setta il bit SIGN
OK1:
	move.w	d0,$40(a5)	; BLTCON0
	move.w	d5,$42(a5)	; BLTCON1
	sub.w	d2,d3		; D3=4*DY-4*DX
	move.w	d3,$64(a5)	; BLTAMOD=4*DY-4*DX
	move.l	a0,$48(a5)	; BLTCPT - indirizzo schermo
	move.l	a0,$54(a5)	; BLTDPT - indirizzo schermo
	move.w	d1,$58(a5)	; BLTSIZE
	rts
	

;******************************************************************************
; Questa routine setta i registri del blitter che non devono essere
; cambiati tra una line e l'altra, settando BLTADAT in modo da tracciare
; linee doppie.
;******************************************************************************

InitLine:
	btst	#6,2(a5) ; dmaconr
WBlit_Init:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Init

	moveq	#-1,d5
	move.l	d5,$44(a5)		; BLTAFWM/BLTALWM = $FFFF

;	  )\._.,--....,'``.
;	 /,   _.. \   _\  (`._ ,.
;	`._.-(,_..'--(,_..'`-.;.'

	move.w	#$C000,$74(a5)		; BLTADAT = $C000 - linee doppie
	move.w	#40,$60(a5)		; BLTCMOD = 40
	move.w	#40,$66(a5)		; BLTDMOD = 40
	rts

;******************************************************************************
; Questa routine definisce il pattern che deve essere usato per disegnare
; le linee. In pratica si limita a settare il registro BLTBDAT.
; D0 - contiene il pattern della linea 
;******************************************************************************
SetPattern:
	btst	#6,2(a5) ; dmaconr
WBlit_Set:
	btst	#6,2(a5) ; dmaconr - attendi che il blitter abbia finito
	bne.s	Wblit_Set

	move.w	d0,$72(a5)	; BLTBDAT = pattern linee
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

	dc.w	$100,$1200	; Bplcon0 - 1 bitplane lowres

BPLPOINTERS:
	dc.w	$e0,$0000,$e2,$0000	;primo	 bitplane

	dc.w	$0180,$000	; color0
	dc.w	$0182,$eee	; color1
	dc.w	$FFFF,$FFFE	; Fine della copperlist

;****************************************************************************

	Section	IlMioPlane,bss_C

BITPLANE:
	ds.b	40*256		; bitplane azzerato lowres

	end

;****************************************************************************

In questo esempio vediamo come sia possibile tracciare linee larghe 2 pixel.
Si procede esattamente come per le linee normali ma si inizializza BLTADAT
con il valore $C000.

