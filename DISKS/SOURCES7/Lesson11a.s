
; Lesson11a.s		Execution of a couple of privileged instructions.

Inizio:
	move.l	4.w,a6			; ExecBase in a6
	lea	SuperCode(PC),a5	; Routine to be run in supervisor
	jsr	-$1e(a6)		; LvoSupervisor - run the routine
					; (does not save registers! attention!)
	rts				; exit, after running the "SuperCode" 
					; routine in supervisor.

; Routine performed in supervisor mode
;	  __
;	  \/
;	-    -
;	
;	 /  \
		
SuperCode:
	move.w	SR,d0		; privileged instruction
	move.w	d0,sr		; privileged instruction
	RTE	; Return From Exception: like RTS, but for exceptions.

	end

Executing this listing take the value of the Status Register at the moment of 
the exception, so at the end of the execution in d0 there will be a value, 
usually $2000, which is also the proof that it was being executed in exception,
since bit 13 of the SR indicates the supervisor mode if set.

 (((
oO Oo
 \"/
  ~		5432109876543210
	($2000=%0010000000000000)

NOTE: move.w SR,destination is privileged only from 68010 onwards, in 68000 it 
is also executable in user mode. In fact, those who used it in the old demos 
or games in user mode, made sure that it only works on 68000, with the launch 
of curses and damnations for owners of 68020+.

