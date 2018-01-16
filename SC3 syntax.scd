
~me = 3

~me

// SC3 syntax:

; // complete a statement, or execute commands to this point before starting anew
. // apply what follows to what comes before
" " // turns inside into text (a String)
\Chris   // creates a Symbol, like a String, but it is unique, so it is used to identify specific things
(  ) used to group expressions, like (5 / 3) + 4, or 5 / (3 + 4)


/*
Cmd+period stops all synths and processes on the Server

SC3 is case sensitive:  all words beginning in capitals are Classes, which can create instances of a class, that do specific things.

Lower-case letters by themselves are predefined as variables:
*/
(
a = 4;
a.postln
)
s
mine.postln
a = 1; // assigns the value one to the variable 'a';
// also define new variables using the reserved word 'var' (must be done as the first line in a function or compilation block)

a = { var myFreq=600; SinOsc.ar(myFreq,0,0.1) }.play;
a.free;

/*
1) Arguments  {  }   inputs to a process, like numbers, names, things

2) Functions	{ }
	.value	method to do what's in the function
	.play, to create a temporary SynthDef and play it

3) Collections [  ]
	',' used to separate things inside a Collection

4) Routines  Routine({ })	execute function, but able to leave and return
*/

b = Routine({ loop({ 'hello'.postln; 1.wait }) }).play;	// 'wait' means pause
b.free
b.stop
/*
5) GUI - QtGUI is now the cross-platform standard -- ignore other kits
 CV - control-value, allow association of of data, and its valid range and curve (Spec)
	ControlSpec

6) OSC - Open Sound Control

7) Patterns - SC3's sequencer, or its score-generator, algorithmic composition

*/