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

3) While it can be frustrating to have to deal with  computer language stuff, when you have a specific musical task in mind, but patience pays off:   the language allows you to explore musical tasks that standard software doesn't give you as an option, you learn the programming aspects while hearing inspiring sounds easily, and you are working with free software which is easily extendable.

Here are three specific things before you dare to run any code:

(Mac version- there may be keyboard shortcut variations for Linux/Windows)

1. Use enter, not return, to run lines of code.  [windows- ctrl+enter]

2. Before doing any sound synthesis, boot the localhost server, by choosing "Boot Server" from the "Language" menu, or typing its keyboard characters (command-b on Mac).

3. To stop all running sounds,on Mac type [command+period] (or on Windows type [alt+.]) --   THE PROGRAMMING DOCK MUST BE IN THE FOREGROUND FOR THIS TO HAVE ANY EFFECT!

*/

// WARM-UP EXAMPLES

2+2   //run me by pressing enter with the cursor on this line- a four should appear in the posting window

// double-click on the first parenthesis, the type ENTER to compile the whole block of code at once

(
s.boot;
Server.local.scope;  // create a Stethoscope to view audio busses on the default Server
)
(
{SinOsc.ar(440,0,0.1)}.play // play and see a sine-wave
)

// using the Mouse controller (or trackpad) for controlling parameters like frequency is easy:

{Pan2.ar(SinOsc.ar(MouseX.kr(440,880),0,0.1),0.0)}.play

//a more complex example - You can't use enter each single line of this example since many of its lines are not complete statements.  The indentation, which is generated automatically by the editor, clarifies the functions

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
}.scope
)

// this is a comment

/* this is also a comment */

/*
To do audio synthesis, we give SuperCollider a list of instructions for building a Synth, that is, a valid network of Unit Generators, or UGens.  Using the Help browser, select Browse, then choose UGens
to explore their help-files, which include code that you can run.

*/

{Pan2.ar(SinOsc.ar(440,0,0.1),0.0)}.play //In this code a sine oscillator is the input argument to a panner

/* When you run this code, note the display of Server info on the lower right of this window, showing  average CPU load, peak CPU load,  the number of UGens playing ('u'), and the number of Synths playing ('s') when synthesis is underway.

Select this code within the outer parentheses, then ENTER key-command. A selection is either the blued out area, or the current line of the cursor.
*/
(
{
SinOsc.ar(440,0,0.1)
	+  // adding is mixing
Pulse.ar(443,0.6,0.05)
}.play
)

/*

Types of Parentheses

(  )  // regular parentheses, for grouping expressions together

{  }  // curly-brackets define a function, which when 'play'ed, generates a Synth that plays on the default Server.

[  ]  // square brackets enclose an Array (list of data)

SuperCollider code gets full of nested expressions- you look at the selections within brackets to check on the scope (level of nesting) of code fragments. Try double clicking around any of the brackets in the following code:

*/

(

if(4==4, {

	if(3==3, {
		"correct!".postln
	});

});

)

/*

Accessing Help-files:

Use Cmd+d without any text selected to bring up the Help browser window, which is a table of contents to comprehensive information about SC3.  Much of this is written more for a computer scientist than for a musician; but after working through this tutorial, try browsing through 'Tour_of_UGens' (select 'browse', then 'UGens', and you'll find it) and running the examples.

You can use Cmd+d on selected text that begins with a capital letter (which represents a Class) to open its help-file (not all have them, but the most commonly used ones do).  Help files usually contain examples that can get you started programming with many different sound-making generators and processors.

*/

LFSaw		//select and use Cmd+d

//You can also use Cmd+i go to source code to find out more:

LFSaw 	//select and use Cmd+i

/*

All generated text will appear in the posting window.
You'll often see the postln and Post instructions, which are useful for checking
on the running state of variables and particularly debugging.

Run these lines of code by using enter with the cursor on each line:
*/
2.postln;

Post << [2,3,4,5] <<nl;

/*
The reason you see more than one thing posted is that when you execute some code, SuperCollider always posts the last object it dealt with. This is the object '2' in the first example and the special 'Post' operator in the second. If you run this:
*/

(
var freq;
freq=rrand(300,600);
{SinOsc.ar(freq,0,0.1)}.play;
)

/*
You'll see something posted about a Synth (the object that represents the sound synthesis asked for in the last line).

What happens when it all goes wrong?
*/

{SinOsc.ar(nil)}.play   //This will crash!

Array.series(9,0,1)+nil  // So will this:

/*
Don't be scared! You get a trace of the stack (execution order of functions in SuperCollider code).  This is very helpful in telling you what caused the error (debugging). Don't be intimidated by it: everyone's code crashes, especially when you're developing it.  The skill is in learning to decipher the error messages!

Occasionally, you may crash the entire language. This happens most often when programming big loops, where your instructions cause the computer to get locked in repetitions of some task. SuperCollider will not prevent you from doing this, and it is not doing anything wrong - it is faithfully following your instructions. But if you did not anticipate the consequences of your program, such an error may occur. This happens to everyone at some point, we can't anticipate every aspect of every line of code we program!  This current version of SC3 allows you to
'Quit the Interpreter' (top choice of the 'Language' menu), which can release you from the endless loop.  Sometimes it's also advisable to 'Recompile Class Library' (third choice on the same menu, or shift-command-L on the Mac, which is like erasing the system and starting fresh.
*/


/*
Getting around in SC3:

unix Commands can be used within SC3 using the unixCmd method for String
*/

"ls -l".unixCmd	//run by pressing enter

"grep -r 'TempoClock.default' SCClassLibrary/*".unixCmd

// Looking at source code:

//to see class definitions

Object //highlight Object and then press cmd+i, then RETURN to open

//  to see which classes respond to a particular method

series //highlight 'series' and then press cmd+i

// to find out class hierarchies - what derives from this?

Clock.dumpClassSubtree	//run this by pressing enter with cursor on the line

// to see the interface (methods of a class)

Array.dumpInterface		//see instance methods

Meta_Array.dumpInterface	//see class methods

/* If things can't be stopped!

first -  Cmd+period (.)

second - quit the Server

third- Recompile the library cmd+L

Occasionally a Server/Lang crash might require you to "Kill All Servers"
before it will allow you to restart a new one.

Extending SuperCollider with plugins and Quarks:

As well as rich libraries of classes and UGens which come with SuperCollider, there are many third party extensions (examples, classes and UGens) which you can download from gitHub

http://supercollider.github.io/download.html

Quarks are language extensions that can be conveniently managed from within SC3 by following the setup directions in this file.  Browse your Quarks directory by typing enter with the cursor on the line below:

Quarks.gui

To install, click on the box to the left of the Quark (it turns green), then after selecting all you want to install, click on the 'save' button at the top right.  The post window will show when they have been installed, after which you recompile SC3 (quit and restart, or shift-Cmd-L).

*/

















