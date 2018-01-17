/*
SuperCollider (SC3) is an interpreted programming language for audio synthesis. SuperCollider offers powerful real-time synthesis, user interactivity, and algorithmic composition, all within one package.  The software is free and its open-source development is maintained on GitHub  by a  strong community of programmers, composers, and audio professionals.  Here is the link where you can download and begin to explore it

http://supercollider.github.io/

SC3 provides the same operating freedom as MAX/MSP or PD, but uses  the SuperCollider programming language to interactively design graphs of sound generators and processors.  The SC3 language itself is the user interface, without the limitations of a graphic interface that represents program modules.  It takes more time to learn how to unlock the power of a language than it does to create programs by patching GUI objects.  For simple tasks, a GUI-based environment is quicker and more intuitive.  But a language is more powerful.  You can realize your ideas more directly in code, than by interconnecting graphical objects.  You have greater freedom to design your instrument exactly how you want it, and you can provide it with GUI controls if and when you want them, and the GUI objects run at a much lower priority than synthesis, so they can't slow it down.  SC3's Client-Server architecture uses an Open Sound Control (OSC) messaging system, so programs interact effortlessly with different machines in any size of network.  Extensive MIDI and HCI libraries are also available for user controls.  The timing of any number of independent or interactive processes you choose to define is rock-solid.  The language is open-source, which not only means that it is free to download and use, but that it is grows through an online, international community of developers who offer their own software extensions for use, and are very accessible to the user-base through the SC-users listserver.
SC3 is a fully object-oriented language, which encourages the modular development of your programs, making it easier to develop your own software library that builds from piece to piece. SuperCollider has execution control structures similar to those used by programming languages you may already know, like if-else-then and loops,  and has a very strong set of Collection classes such as Arrays. Its object oriented design is modeled on and extends that of Smalltalk, and it is itself written in C++.
SuperCollider provides a cross-platform IDE code-editing environment.  We write code in files ( .scd files), then direct the SuperCollider language to compile and execute it .  The code editor will not crash even if your SuperCollider program does, and  your program runs independently of any other application or compilation process on your computer, making it very stable.

Finally, SC3 just sounds better! You can run it at any audio rate that your machine supports, and it is surprisingly efficient, in spite of its superior sound quality.

However ..   to learn this language you must accept that:
1) The computer will only accept syntactically correct statements.
2) You need to become familiar with standard mechanisms of computer languages, like iteration, conditional execution, messaging and containers.
3) While it can be frustrating to have to deal with  computer language stuff when you have a specific musical task in mind, patience pays off:   the language allows you to explore musical tasks that standard software doesn't give you as an option, you learn the programming aspects while hearing inspiring sounds easily, and you are working with free software which is designed to be extendable.

Here are three specific things to know before you run any code:

1. Use ENTER, not RETURN, to run lines of code.  [windows- ctrl+enter]
2. Before you can do any sound synthesis, boot the localhost server by choosing "Boot Server" from the "Language" menu, or typing its keyboard command (command-b on Mac).
3. To stop all running sounds,on Mac type [command+period] (or on Windows type [alt+.]) --  This editor MUST BE IN THE FOREGROUND TO HAVE ANY EFFECT!
*/

// this turns everything following it on a line into a COMMENT, which is ignored by the compiler

/* this is also a comment -- all typing inside it is ignored, so can be used for
multiple lines   */

// WARM-UP EXAMPLES

2+2   //run by pressing ENTER with the cursor on this line- a four should appear in the posting window

/*
All generated text will appear in the posting window. You'll often see the postln and Post instructions, which are useful for checking on the running state of variables and particularly debugging.
*/

2.postln;

/*
The reason you see more than one thing posted is that when you execute some code, SuperCollider always posts the last object it dealt with. This is the object '2' in the first example and the special 'Post' operator in the second.

When executing the code below, you'll see something posted about a Synth (the object that represents the sound synthesis asked for in the last line).  Try executing it several times in a row... each time creates a different pitched sine-wave that combines with the previous ones */

(
var freq;
freq=rrand(300,600);
{SinOsc.ar(freq,0,0.1)}.play;
)

// to STOP the sound, type cmd-period

// What happens when it all goes wrong?

/*
Types of Parentheses:
(  )  // regular parentheses, for grouping expressions together
{  }  // curly-brackets define a function, which when 'play'ed, generates a Synth that plays on the default Server.
[  ]  // square brackets enclose an Array (list of data)  */

(
if(4==4, {

	if(3==3, {
		"correct!".postln
	});

});
)

// double-click on the first parenthesis, the type ENTER to compile the whole block of code at once
(
s.boot;
Server.local.scope;  // create a Stethoscope to view audio busses on the default Server
)

(
{SinOsc.ar(440,0,0.1)}.play  // ENTER to play and see a sine-wave
)

/*
To do audio synthesis, we give SuperCollider a list of instructions for building a Synth, that is, a valid network of Unit Generators, or UGens.
SuperCollider code utilizes nested expressions - you look at the selections within brackets to check on the scope (level of nesting) of code fragments. In the next example
 a Mouse controller (or trackpad) is used to control parameters like frequency:
to explore how it works, delete a left-parenthesis to see the arguments of the code that precedes it
*/

{Pan2.ar(SinOsc.ar(MouseX.kr(440,880),0,0.1),0.0)}.play

// adding is mixing
(
{
SinOsc.ar(440,0,0.1)
	+
Pulse.ar(443,0.6,0.05)
}.play
)

// this is a more complex example - You can't use ENTER to compile each single line of this example since many of its lines are not complete statements.  The indentation, which is generated automatically by the editor after RETURN, clarifies the functions
(
{var n;
	n=34;
	Resonz.ar(
		Mix.arFill(n,{
			var freq, numcps;
			freq= rrand(50,560.3);
			numcps= rrand(2,20);
		Pan2.ar(
			Gendy1.ar(6.rand,6.rand,1.0.rand,1.0.rand,freq ,freq, 1.0.rand, 1.0.rand,numcps, SinOsc.kr(exprand(0.02,0.2), 0, numcps/2, numcps/2), 0.5/(n.sqrt)), 1.0.rand2)
		})
		,MouseX.kr(100,2000), MouseY.kr(0.01,1.0))
	;
}.play
)

/* When you run this code, note the display of Server info on the lower right of this window, showing  average CPU load, peak CPU load,  the number of UGens playing ('u'), and the number of Synths playing ('s') when synthesis is underway.
Select this code within the outer parentheses, then ENTER key-command. A selection is either the blued out area, or the current line of the cursor.

Accessing Help-files:
Thee Help browser window contains a table of contents to comprehensive information about SC3.  Much of this is written more for a computer scientist than for a musician; but after working through this tutorial, try browsing through 'Tour_of_UGens' (select 'browse', then 'UGens', and you'll find it) and running the examples.

You can use Cmd+d on any selected text that begins with a capital letter (which represents a Class) to open its help-file (not all have them, but the most commonly used ones do).  Help files usually contain examples that can get you started programming with many different sound-making generators and processors.
*/

LFSaw		//select and use Cmd+d

//You can also use Cmd+i go to source code to find out more:

LFSaw 	//select and use Cmd+i


{SinOsc.ar(nil)}.play   //This will crash!

Array.series(9,0,1)+nil  // So will this:

/*
Don't be scared! You get a trace of the stack (execution order of functions in SuperCollider code).  This is very helpful in telling you what caused the error (debugging). Don't be intimidated by it: everyone's code crashes, especially when you're developing it.  The skill is in learning to decipher the error messages!

Occasionally, you may crash the entire language. This happens most often when programming big loops, where your instructions cause the computer to get locked in repetitions of some task. SuperCollider will not prevent you from doing this, and it is not doing anything wrong - it is faithfully following your instructions. But if you did not anticipate the consequences of your program, such an error may occur.
When this happens, recover by:

1) -  Cmd+period (.)
2) - quit the Server
3)- Recompile the library cmd+L

Occasionally a Server/Lang crash might require you to "Kill All Servers" before it will allow you to restart a new one.
*/

// Lower-case letters by themselves are predefined as variables:
(
a = 4;
a.postln
)
s   // this one is preassigned to the Server.localhost
a = 1; // assigns the value one to the variable 'a';

// also define new variables using the reserved word 'var' (this must be done as the first line in a function or compilation block)

a = { var myFreq=600; SinOsc.ar(myFreq,0,0.1) }.play;
a.free;   // immediately stops Synth 'a'

/*
1) Function	{ }
	.value	method to do what's in the function
	.play, to create a temporary SynthDef and play it

2) Arguments are named inputs to a function
*/
a= { arg freq, amp; freq.postln; amp.postln } ;
// or, like this:
a = {| freq, amp|  freq.postln; amp.postln } ;
a.value(40,0.1);
// or as a short-cut, 'value' can be omitted
a.(40,0.1);

/*
3) Collection [  ]  ',' is used to separate things inside a Collection
*/
b=[1,2,3,4];
b.class;

/*
4) Routines  Routine({ })	a function that can  leave and return to its process
*/

c = Routine({ loop({ 'hello'.postln; 1.wait }) }).play;	// 'wait' means pause
c.stop;
c.reset;
c.play;

// Looking at source code:
// SC3 is case sensitive:  all words beginning in capitals are Classes, which can create instances of a class, that do specific things.  The Class Library is a tree structure in which every Class inherits from a previous SuperClass and extends it with new capabilities.  To see class definitions:

Object //highlight Object and then press cmd+i, then RETURN to open

//  lower-case words are 'methods', which do defined things to classes defined by that class -- to see what classes use the same method...

series //highlight 'series' and then press cmd+i

//  to find out the inheritance hierarchy of any Class...

Clock.dumpClassSubtree	//run this by pressing enter with cursor on the line

// to see the interface (methods of a class)

Array.dumpInterface		//see instance methods

Meta_Array.dumpInterface	//see class methods


/*
Extending SuperCollider with plugins and Quarks:
As well as rich libraries of Classes and UGens which come with SuperCollider, there are many third party extensions (classes and UGens) which you can also download from gitHub

http://supercollider.github.io/download.html

Quarks are language extensions that can be conveniently managed from within SC3 by following the setup directions in the Quarks helpfile.  Browse your Quarks directory by typing enter with the cursor on the line below:  */

Quarks.gui

// To install, click on the box to the left of the Quark (it turns green), then after selecting all you want to install, click on the 'save' button at the top right.  The post window will show when they have been installed, after which you recompile SC3 (quit and restart, or shift-Cmd-L).

// unix Commands can be used within SC3 using the unixCmd method for String


"ls -l".unixCmd	//run by pressing enter

"grep -r 'TempoClock.default' SCClassLibrary/*".unixCmd










