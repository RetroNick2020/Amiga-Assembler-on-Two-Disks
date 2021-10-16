
; Lesson9a1.s - RESET OF $ 10 words via the BLITTER
; Before seeing this example, take a look at LESSON2f.s
; where memory is cleared with the 68000

	SECTION Blit,CODE

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName,a1	; Address of the name of the lib to open in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,a6		; use a graphics library routine:

	jsr	-$1c8(a6)	; OwnBlitter, which gives us the exclusivity on the
				; blitter preventing its use by the operating system.

				; Before using the blitter we must wait for it to
				; finish any blits in progress.
				; The following instructions deal with this

	btst	#6,$dff002	; wait for the blitter to finish (blank test) for Agnus'
				; BUG
waitblit:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit

; Here's how to do a blitt !!! Only 5 instructions to reset !!!

;	     __
;	__  /_/\   __
;	\/  \_\/  /\_\
;	 __   __  \/_/   __
;	/\_\ /\_\  __   /\_\
;	\/_/ \/_/ /_/\  \/_/
;	     __   \_\/
;	    /\_\  __
;	    \/_/  \/

	move.w	#$0100,$dff040	 ; BLTCON0: only DESTINATION activated and the MINTERMS
				 ; (that is bits 0-7) are all reset. This defines the
				 ; delete operation

	move.w	#$0000,$dff042	 ; BLTCON1: this register we will explain later
	move.l	#START,$dff054	 ; BLTDPT: Destination channel address
	move.w	#$0000,$dff066	 ; BLTDMOD: this register we will explain later
	move.w	#(1*64)+$10,$dff058 ; BLTSIZE: defines the size of the rectangle. In
				    ; this case we have a width of $ 10 words and a
				    ; height of 1 line.
				    ; Since the height of the rectangle must be written
				    ; in bits 6-15 of BLTSIZE we have to shift it to the
				    ; left by 6 bits.
				    ; This is equivalent to multiplying its value by 64.
				    ; The width is expressed in the low 6 bits and
				    ; therefore is not changed.
				    ; Furthermore, this instruction initiates the blitt

	btst	#6,$dff002	; attendi che il blitter finisca (test a vuoto)
waitblit2:
	btst	#6,$dff002	; blitter libero?
	bne.s	waitblit2

	jsr	-$1ce(a6)	; DisOwnBlitter, il sistema operativo ora
				; puo' nuovamente usare il blitter
	move.l	a6,a1		; Base della libreria grafica da chiudere
	move.l	4.w,a6
	jsr	-$19e(a6)	; Closelibrary - chiudo la graphics lib
	jsr	-$7e(a6)	; Enable - riabilita il Multitasking
	rts

******************************************************************************

	SECTION THE_DATA,DATA_C

; notate che i dati che cancelliamo devono essere in memoria CHIP
; infatti il Blitter opera solo in memoria CHIP

START:
	dcb.b	$20,$fe
THEEND:
	dc.b	'Qui non cancelliamo'

	even

GfxName:
	dc.b	"graphics.library",0,0

	end

Questo esempio e' la versione per blitter del listato Lezione2f.s, in cui si
azzeravano dei bytes tramite un loop di "clr.l (a0)+".

Come in quel caso, assemblate, senza Jumpare, e controllate con un "M START"
che sotto tale label sono assemblati $20 bytes "$fe". A questo punto eseguite
il listato, attivando, per la prima volta nel corso, il blitter, dopodiche'
rifate "M START" e verificherete che tali bytes sono stati azzerati, fino alla
label THEEND, infatti con un "N THEEND" troverete la scritta sempre al suo
posto.

L'operazione di cancellazione richiede l'uso del solo canale D.
Inoltre e` necessario azzerare tutti i MINTERMS. Pertanto il valore da caricare
nel registro BLTCON0 e` $0100.
Notate bene il valore che viene scritto nel registro BLTSIZE. Dobbiamo
cancellare un rettangolo largo $10 words e alto una riga. Dobbiamo scrivere
la larghezza nei bit 0-5 di BLTSIZE e l'altezza nei bit 6-15 sempre di BLTSIZE.
Per scrivere l'altezza nei bit 6-15 possiamo quindi shiftarla a sinistra di
6 bit, il che equivale a moltiplicarla per 64. Dunque per scrivere le
dimensioni del rettangolo da blittare nel registro BLTSIZE si usa la seguente
formula:

Valore da scrivere in BLTSIZE = (ALTEZZA*64)+LARGHEZZA

Vi ricordo che la LARGHEZZA e` espressa in words.

NOTA: E' stata usata una funzione del sistema operativo che non abbiamo mai
trattato prima, cioe' quella che impedisce l'uso del blitter al sistema
operativo per evitare di usare il blitter quando anche il workbench lo usa.
Per inibire e riattivare l'uso del blitter da parte del sistema operativo basta
eseguire le apposite routines gia' pronte nel kickstart, piu' in particolare
nella graphics.library: avendo in A6 il GFXBASE, bastera' eseguire un

	jsr	-$1c8(a6)	; OwnBlitter, che ci da l'esclusiva sul blitter

Per garantirci che siamo i soli a cercare il blitter, mentre un

	jsr	-$1ce(a6)	; DisOwnBlitter, il sistema operativo ora
				; puo' nuovamente usare il blitter

sara' necessario prima di uscire dal programma per riattivare il workbench.

Dunque basta ricordarsi che quando usiamo il blitter nei nostri capolavori e'
necessario aggiungere l'OwnBlitter all'inizio e il DisownBlitter alla fine,
oltre al noto Disable ed Enable.

