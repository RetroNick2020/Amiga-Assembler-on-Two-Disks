
; Lesson3a.s	HOW TO CALL AN OS FUNCTION

Inizio:
	move.l	$4.w,a6		; Execbase in a6
	jsr	-$78(a6)	; Disable – stop multitasking
mouse:
	move.w	$dff006,$dff180	; put VHPOSR in COLOR00 (flash background!!)
	btst	#6,$bfe001	; left mousebutton pressed?
	bne.s	mouse		; if no, loop back to mouse:

	move.l	4.w,a6		; Execbase in a6
	jsr	-$7e(a6)	; Enable - restart multitasking
	rts

This is the first listing in which we use an operating system routine! And
just look at the one that disables the operating system itself! In fact you
will notice that during the execution the arrow controlled by the mouse is
frozen, when pressing the right button, drop-down menus does not appear, the
disk drives they stop clicking. And be careful that even the AD command, or
the debugger, which uses the operating system, is disabled, remaining locked!

Remember then that when we disable the operating system, or even if we point
to our copperlist, the debugger serves until the operating system is alive!
Try however to do "AD" by pressing the right cursor key (with this key, in
fact, it "penetrates" into the BSRs and JSRs, while the down cursor key will
skip the debugging of BSR and JSR).

When the first instruction is passed, the MOVE.L 4.w,a6, the address that was
contained in the longword consisting of the 4 bytes in memory location $4, $5,
$6 and $7, will appear in the A6 register.

Press ESC and verify by making a "M 4", pressing 4 times return: you will
find in fact the same address. This address is placed in that location by the
kick every time you reset or turn on the Amiga.

Resume debugging, pass MOVE.L 4.w,a6, and "enter" into the JSR -$78(a6) with
the cursor: to follow the subroutine you have to look at the disassembly line
at the bottom of the screen, you will notice a JMP $fcxxxx or $f8xxxx
statement, depending on whether you have a 1.3 or 2.0 / 3.0 kick. You are at
the address that was in $4 minus $78, and you are in the RAM memory of your
Amiga again, where you find a JMP that will throw you into the ROM. Indeed,
whenever the Amiga uses that second or two during the RESET, or the ignition,
a JMP TABLE is created in memory, whose final address is put in $4.

Each JMP jumps to the address of that particular kickstart where the routine
corresponding to that JMP's position relative to its end is located. In
fact, doing JSR -$78(a6) disables multitasking on a 1.2 kick, on a 1.3 kick,
or 2.0 or 3.0, as well as for future ones.

If, for example, in kick 1.3 the routine in ROM was at $fc12345, the JMP
placed at $78 bytes below the base address will be JMP $fc12345, while if on
a kick 2.0 the routine in question was at $ f812345, the JMP in question will
be at $f812345. This system also allows you to load a kickstart in RAM: then
it will be enough to make a JMP TABLE that points to its routines.

Stop debugging with ESC after you have noted what the JMP address was, and
try to make a "D that address" (the address of the instruction is the first
number on the left at the bottom of the screen! or you can find it also in
bottom of the list of registers on the right, is the PC register, or Program
Counter, which records the address you are running, as long as you add to it
the $-sign in front). You will verify that there is a row of JMPs; this is
an example:

	JMP	$00F817EA	; -$78(a6), namely the DISABLE
	JMP	$00F833DC	; -$72(a6), another routine
	JMP	$00F83064	; -$6c(a6), and another routine...
	JMP	$00F80F74	; ....
	JMP	$00F80F0C
	JMP	$00F81B74
	JMP	$00F81AEC
	JMP	$00F8103A
	JMP	$00F80F3C
	JMP	$00F81444
	JMP	$00F813A0
	JMP	$00F814F8
	JMP	$00F82842
	JMP	$00F812F8
	JMP	$00F812D6
	JMP	$00F80B38
	JMP	$00F82C24
	JMP	$00F82C24
	JMP	$00F82C20
	JMP	$00F82C18

To insert disassembled pieces in the source I used the "ID" command, in which
we must specify the beginning and the end of the area to be inserted:

BEG> 	here you put the address or label, try the JMP address
END> 	put the final address, or $xxxxx + $80, $xxxxx meaning the starting
	address
	
In this case the disassembled source will be obtained starting at address
$xxxxx up to $80 bytes later.

REMOVE UNUSED LABELS? (Y / N); HERE YOU PUT A "Y". If you do not put it it
will be putting a label bearing the address on every line of code, rather
than just where the label is needed. Try to make an "ID" of this listing to
verify the difference.

Example: if the address was $32123

>ID

BEG> $32123
END> $32123 + $80; NOTE: to get back the previously entered addresses press
the cursor key upwards several times. (In fact, pressing the up arrow will
return the things you wrote before as in SHELL)

Now the disassembly required will appear, starting from the point where you
were with the cursor the last time in the editor.

Now you can imagine how many JSRs and JMPs must be run by the processor when
a program asks him to perform routines. And all this skip does waste time,
that's why we will use the operating system only for the minimum essentials.

If you continue with the DEBUG after the JMP, you will end up in the ROM, ie
at the JMP address: usually the DISABLE is like this:

	MOVE.W	#$4000,$dff09a	; INTENA – Stop all interrupts
	ADDQ.B	#1,$126(a6)	; Stop operating system
	RTS

If you enter it by pressing the arrow to the right the instructions will be
seen, but not executed (for safety debugging when running subroutine out from
the list, that is usually in the ROM, it just flows), in fact you can
continue and go into the mouse loop and you will notice that the mouse arrow
you can move and the drives click, ie they have not been executed those 2
operations. You can also switch between the JSR -$7e(a6) and exit.

Instead, try to go down using the down cursor key: this time passing from the
JSR -$78(a6) the program will escape your hand, because it is performed
(without however being shown). You can still exit with the left button, then
you have to press ESC to exit the DEBUG.

Try now to make these changes:

1) Assemble, make a "D start" and you will see this:

	MOVE.L	$0004.W,A6

Now try to remove the .w to 4 in the listing, assemble and repeat the "D":

	MOVE.L	$00000004,A6
	
As you can see, in this case all 4 bytes of the address were used, whereas
before with the .w option we saved 2 bytes. The option .w can be used on all
addresses one word or less in size.

2) Try replacing the line

	JSR	-$78(a6)

with the lines

	MOVE.W	#$4000,$dff09a	; INTENA - Stop all interrupts
	ADDQ.B	#1,$126(a6)	; Stop operating system

Or whatever you find in the ROM after the JMP (without the final RTS!). You
will notice that the operation is the same. You can do the same thing with
the JSR -$7e(a6).
