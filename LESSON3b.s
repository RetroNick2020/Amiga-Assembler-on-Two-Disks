
; Lesson3b.s	; LA PRIMA COPPERLIST


	SECTION	PRIMOCOP,CODE	; This directive makes the following
				; code load in FAST ram if available.
				; Otherwise it will load in CHIP.

Inizio:
	move.l	4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable - stop multitasking
	lea	GfxName,a1	; Address of name of library to open in a1
	jsr	-$198(a6)	; OpenLibrary, EXEC-routine that opens
				; libraries, by using the correct offset
				; from the base-address
	move.l	d0,GfxBase	; Save address of library base to GfxBase
	move.l	d0,a6
	move.l	$26(a6),OldCop	; Save address of system copperlist
	move.l	#COPPERLIST,$dff080	; COP1LC - pointing to our COP
	move.w	d0,$dff088		; COPJMP1 - Let's  start the COP
mouse:
	btst	#6,$bfe001	; tasto sinistro del mouse premuto?
	bne.s	mouse		; se no, torna a mouse:

	move.l	OldCop(PC),$dff080	; COP1LC - point to system COP
	move.w	d0,$dff088		; COPJMP1 - Let's start the COP

	move.l	4.w,a6
	jsr	-$7e(a6)	; Enable - restart Multitasking
	move.l	GfxBase(PC),a1	; Base of the library to be closed
				; (the libraries must be opened and closed!)
	jsr	-$19e(a6)	; Closelibrary – we close the
				; graphics library
	rts

GfxName:
	dc.b	"graphics.library",0,0	; NOTE: to put characters in memory
					; always use the dc.b and put them
					; between " " or ' ' and terminate
					; with ,0
					; make sure you have an even
					; number of bytes.

GfxBase:		; Here is the base address for the Offset
	dc.l	0	; of the graphics.library

OldCop:			; Here is the address of the old system COP 
	dc.l	0

	SECTION	GRAPHIC,DATA_C	; This command makes AmigaDOS load this
				; segment of data in CHIP RAM.
				; The copperlist MUST be in CHIP RAM!
COPPERLIST:
	dc.w	$100,$200	; BPLCON0 – No gfx, only the background
	dc.w	$180,$000	; Color 0 BLACK
	dc.w	$7f07,$FFFE	; WAIT – Wait for line $7f (127)
	dc.w	$180,$00F	; Color 0 BLUE
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

	end

This program points to our COPPERLIST, and can be used to run any COPPERLIST,
so it's useful for experimenting with the COPPER.

YOU SHOULD NOT BE DISCOURAGED BY THE USE OF OPERATING SYSTEM CALLS FOR
OPENING LIBRARIES AND SUCH, AS IN ALL THE COURSE YOU WILL FIND ONLY THE
OPENING OF THE GRAPHICS.LIBRARY TO RETURN THE OLD COPPERLIST AND A FEW
THINGS, THEREFORE YOU SHOULD LEARN THESE THINGS.

NOTE1: As you have already noted this listing contains the SECTION command,
which has the function of deciding the HUNK of the executable file that you
will save with the WO command: every file executable from the shell, such as
ASMONE, is put into RAM memory by the operating system copying it from the
disk or from the hard disk, and this copy action is performed according to
the HUNK of the file in question, which are nothing more than parts of that
file, in fact, a file is made up of one or more hunks. Every hunk has its
characteristic, in particular that of WHERE IT MUST BE LOADED, if only in
CHIP RAM or if it is possible to put it also in FAST RAM; it is necessary to
use the SECTION command if you want to generate an executable file with a
copperlist or with sounds, in fact this type of data must be loaded always in
CHIP RAM, otherwise, if you do not specify the _C, the file generated with WO
will have a generic hunk that can be loaded in any part of free memory, be it
CHIP or FAST.
Many old demos or even some Demos for Amiga 1200 do not work on Amiga with
Fast Ram just because the file has hunks that can be loaded into any kind of
free memory, and will not work on computers with FAST memory, as the
operating system tends to fill the FAST RAM before the precious CHIP RAM:
evidently those who did those old demos or games had the basic 500 amiga with
512k chip ram, without FAST, and the programs worked because they became
loaded in CHIP in any case, the same applies for those with an A500+ or an
A600, in fact they have 1MB of CHIP only, but when these programs are
loaded on a computer with FAST ram, GRAPHICS, SOUNDS and COPPERLISTs are
loaded into FAST RAM and since the CUSTOM CHIPs only are able to access the
CHIP memory they make random sounds and the video goes crazy, generating
system “inchiodamenti” sometimes.

The syntax of the SECTION command is as follows: after the word SECTION,
comes the name of that section, give a name as desired, after which we write
what kind of section we define: whether CODE or DATA, or if made of
INSTRUCTIONS or DATA, a difference that, however, is not very important, in
fact the CODE section is defined as the first of this listing, which also has
LABELS with texts (dc.b 'graphics library'); after which you decide the most
important: if it should be loaded in CHIP or if it is OK also in FAST memory:
to decide that it must be LOADED by force in CHIP just add a _C to the DATA
or CODE, if nothing is added, it means that the data or the instructions in
the section can be loaded in any type of memory.

Some examples: 

	SECTION FIGURE,DATA_C	; section of data to be loaded into CHIP
	SECTION LISTANOMI,DATA	; data section that can be loaded
				; in CHIP or FAST 
	SECTION Program,CODE_C	; section of code to be loaded into CHIP 
	SECTION Program2,CODE	; section of code that can be loaded
				; in CHIP or FAST 

Put the first SECTION always as CODE or CODE_C, obviously starting with
instructions, after which you can make section DATA or DATA_C where there are
no instructions, let's give an example:

	SECTION	Myprogram,CODE	; Can be loaded in both CHIP and FAST 
	move...
	move...

	SECTION	COPPER,DATA_C	; Assemblable only in CHIP

	dc.w	$100,$200....	; $0100,$0200, but you can remove the
				; initial zeros, if for example we have to
				; write dc.l $00000001, it will be more
				; convenient to write dc.l 1
				; in the same way dc.b $0a can be written
				; dc.b $a, in memory it will be assembled
				; as $0a. 

	SECTION	MUSIC,DATA_C	; Assemblable only in CHIP

	dc.b	Pavarotti.....

	SECTION	GRAPHICS,DATA_C	; only in CHIP!

	dc.l	piramidi egizie

	END

You can also do a single CODE_C section, but fragmenting the graphic or sound
data at least in pieces of 50k makes the program easier to allocate in the
memory holes compared to a single piece of 300k or more.

Also, consider that loading the instructions into CHIP RAM is a pity also
because if they are loaded in FAST RAM, especially on an Amiga with 68020+,
they are performed faster, even 4 times faster, than in the CHIP mem.

There are also sections of type BSS or BSS_C, we will talk about them when we
use them.

NOTE2: You will also notice the use of (PC) in the instruction:

	move.l	OldCop(PC),$dff080	; COP1LC – Point to system COP

This (PC) added after the name of the label does not change the FUNCTION of
the command, in fact if you remove the (PC) the same thing happens; rather
you need it to change the FORM of the command, in fact try to assemble and
make a D Mouse: 

	...				BTST	#$06,$00BFE001
	...				BNE.B	$xxxxxxxx
	23FA003400DFF080	MOVE.L	$xxxxxx(PC),$00DFF080
	...				MOVE.W	D0,$00DFF088

You will notice that the move.l Oldcop(PC),$dff080 is assembled as $23fa...

Now try to remove the (PC), assemble and redo D MOUSE: 

	23F900xxxxxx00DFF080	MOVE.L	$xxxxxx,$00DFF080

This time the instruction is assembled in 10 bytes instead of 8, and can be
read directly after the $23f9, which means MOVE.L, the address of Oldcop,
while in the case of move.l with PC the command starts with $ 23fa and there
is seen as $34 instead of the OldCop address!!!

The difference is that when there is no PC, the instruction refers to a
DEFINED ADDRESS, in fact it is assembled, while an instruction with the (PC)
instead of writing the address writes the distance there is from itself to
the label in question, in this case $34 bytes.

The strings with the (PC) are said to be RELATIVE TO the PC, that is to the
Program Counter, that is the register where the address of the running
instruction is written:

when the 68000 arrives to execute the MOVE.L OLDCOP (PC), it calculates the
address in PC + $34 and get the address of Oldcop, precisely located $34
bytes further on. This way is faster and the instructions as already seen are
shorter, but can only be used for labels no more than 32768 bytes away (as
per the BSR), and can not be used between one section and the other, just
because the sections are loaded in 'who knows what point'  in memory and
therefore they would be too far.

In fact, try adding the line LEA COPPERLIST(PC),a0 at the beginning of the
listing and you will find that when assembling, ASMONE tells you that you
have a RELATIVE MODE ERROR, while removing the (PC) the instruction is
assembled. I advise you to always put the (PC) at labels when it is possible:

	LEA	LABEL(PC),a0
	MOVE.L	LABEL(PC),d0
	MOVE.L	LABEL1(PC),LABEL2	; only the first label can be
					; followed by the PC, the second
					; NEVER.
	MOVE.L	#LABEL1,LABEL2		; in this case, in fact, you can not
					; put the (PC) on the first operand
					; or the second.

NOTIFICATIONS: Now you can make any copperlist! Start by changing the 2
colors knowing that the format is this: $ 0RGB, in which only 3 numbers
count, $RGB, with R = RED, G = GREEN, B = BLUE.

Each of these 3 numbers can go from 0 to 15, in hexadecimal notation, that
is, from 0 to F (0123456789ABCDEF), and depending on how they are mixed, 3
basic colors can form all the 4096 colors of the Amiga (16 * 16 * 16).

To get the black you need a $000, for a white a $FFF, a $999 is gray.

Warning! Do not mix like tempera or oil colors! For example to make the
yellow you need RED + GREEN, $dd0 for example, to make a purple you must mix
RED + BLUE, for example $d0e.

This color mixing system is the same you find in PREFERENCES of the WorkBench
or in the DPAINT palette, with the 3 RGB controllers.

Once you've done some testing by changing the first copperlist, you can
create nuances, adding WAIT and COLOR 0 ($180, xxx), similar to sunsets you
have seen in the backgrounds of SHADOW OF THE BEAST or other games, or the
bar shades of many demos: now you know how they work!

Replace this copperlist with the one in the listing with Amiga + B + C + I,
observe what it displays and why, and change it to make sure you are clear
with everything, or to make the background shades for your first game!!!

COPPERLIST:
	dc.w	$100,$200	; BPLCON0 – only background
	dc.w	$180,$000	; COLOR0 - Start the cop with the color BLACK
	dc.w	$4907,$FFFE	; WAIT – Wait for line $49 (73)
	dc.w	$180,$001	; COLOR0 – very dark blue
	dc.w	$4a07,$FFFE	; WAIT - line 74 ($4a)
	dc.w	$180,$002	; COLOR0 - blue a little more intense
	dc.w	$4b07,$FFFE	; WAIT - line 75 ($4b)
	dc.w	$180,$003	; COLOR0 - lighter blue
	dc.w	$4c07,$FFFE	; WAIT - next line
	dc.w	$180,$004	; COLOR0 - lighter blue
	dc.w	$4d07,$FFFE	; WAIT - next line
	dc.w	$180,$005	; COLOR0 - lighter blue 
	dc.w	$4e07,$FFFE	; WAIT - next line
	dc.w	$180,$006	; COLOR0 - blue to 6
	dc.w	$5007,$FFFE	; WAIT – jump 2 lines: from $4e to $50,
				; or rather from 78 to 80
	dc.w	$180,$007	; COLOR0 - blue to 7
	dc.w	$5207,$FFFE	; WAIT - jump 2 lines
	dc.w	$180,$008	; COLOR0 - blue to 8
	dc.w	$5507,$FFFE	; WAIT - jump 3 lines
	dc.w	$180,$009	; COLOR0 - blue to 9
	dc.w	$5807,$FFFE	; WAIT - jump 3 lines
	dc.w	$180,$00a	; COLOR0 - blue to 10
	dc.w	$5b07,$FFFE	; WAIT - jump 3 lines
	dc.w	$180,$00b	; COLOR0 - blue to 11
	dc.w	$5e07,$FFFE	; WAIT – jump 3 lines
	dc.w	$180,$00c	; COLOR0 - blue to 12
	dc.w	$6207,$FFFE	; WAIT - jump 4 lines
	dc.w	$180,$00d	; COLOR0 - blue to 13
	dc.w	$6707,$FFFE	; WAIT - jump 5 lines
	dc.w	$180,$00e	; COLOR0 - blue to 14
	dc.w	$6d07,$FFFE	; WAIT - jump 6 lines
	dc.w	$180,$00f	; COLOR0 - blue to 15
	dc.w	$7907,$FFFE	; WAIT – wait for line $79
	dc.w	$180,$300	; COLOR0 - start the red bar:
				; red to 3
	dc.w	$7a07,$FFFE	; WAIT – following line
	dc.w	$180,$600	; COLOR0 - red to 6
	dc.w	$7b07,$FFFE	; WAIT - 
	dc.w	$180,$900	; COLOR0 - red to 9
	dc.w	$7c07,$FFFE	; WAIT - 
	dc.w	$180,$c00	; COLOR0 - red to 12
	dc.w	$7d07,$FFFE
	dc.w	$180,$f00	; red to 15 (at maximum)
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
	dc.w	$fe07,$FFFE	; following line
	dc.w	$180,$00f	; blue intensity maximum (15)
	dc.w	$FFFF,$FFFE	; FINE DELLA COPPERLIST

In summary, if for example at line $50 we set the color0 to green, le $50 and
following lines will be green, until the color is changed again after a wait,
for example a wait $6007.

A tip: to make this copperlist OBVIOUSLY I did not write all of them times
dc.w $180, $ ... dc.w $xx07, $FFFE!!!! Just take the two instructions:

	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0

Select them with Amiga + B, and Amiga + C, then make a long list by pressing
several times Amiga + I:

	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0
	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0
	dc.w	$xx07,$FFFE	; WAIT
	dc.w	$180,$000	; COLOR0
	.....

At this point, just change the XX of the wait and the value of $ 180 each
time, and delete redundant instructions with Amiga + B and Amiga + X.

NOTE: This can also be done between different ASMONE text buffers, if for
example in the F2 buffer I have a listing with a copperlist I want to change,
as long as you select it normally with Amiga + B and Amiga + C, then I go
back to my listing, for example in F5, and insert the piece taken on the
other side listed with Amiga + I.
