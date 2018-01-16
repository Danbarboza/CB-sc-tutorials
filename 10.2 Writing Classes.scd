/*
Writing Classes

At some point, programs that you write start to become unwieldy due to size, and redundancy (the same kind of procedure, written again and again.)  At this point, if not earlier, you should define classes that implement key aspects of the program.  Experienced programmers actually begin a project by defining classes for the different structures that they know they will need.  Classes encourage structured programming, and structuring your programming is the only way to really make it work well!

The main components you need to understand are:  Class, instance, method, variable, getter and setter.  Methods and variables can be either of an instance or of a class (thus 'instance variable' or 'class variable' or 'instance method' or 'class method'.  These are all defined in the help-file.


Making a new class:

Classes need not be complex!  Any function or SynthDef can be one.

Here's an example from Chapter five of the SuperCollider book (recommended reading!) of making a Counter class.

First to make a counting function, you might write: */

(
~current_count=1;
~count1 = {|max_count=10|
	if((~current_count >= max_count),{
			"max_reached".postln;
		},{
			~current_count = ~current_count + 1;
			"current count = ".post; ~current_count.postln;
	})
};
)
10.do { ~count1.value(10) };


// now we make it into a Class, where max_count and current_count are  instance variables -- this allows us to make many counters that can run simultaneously without having to create multiple variables

Counter {
	// variables: maximum count, current count
	var <>max_count, <>current_count = 1;
	// class method for creating a new instance
	*new { | max_count = 10 |
		^super.new.max_count_(max_count)  // uses the superclass Object's *new method, but extends it by taking a number as an argument for max_count
	}
	// if maximum count not reached, increment count by 1
	count1 {
		if ((current_count >= max_count),{
			"max_reached".postln;
		},{
			current_count = current_count + 1;
			"current count = ".post; current_count.postln;
		})
	}
	// reset count
	reset {
		current_count = 1;
		"RESET, current count = 1".postln;
	}
}

// put this in a new file, save as Counter.sc into your Extensions folder, then recompile

// testing...
a = Counter.new(10);
10.do { a.count1.value };
a.reset;
// and two at once ...
a = Counter.new(10); b = Counter.new(20);
20.do { a.count1.value; b.count1.value; };


/* Here's a SynthDef and Class definition written by Nick Collins that shows how to make a Class from a SynthDef.  First, here's the SynthDef we will use: */

(
SynthDef(\nastySynth,{|wackymult=1,wackiness=200|
	Out.ar(0,CombN.ar(
		(SinOsc.ar(
			LFNoise0.ar(9, wackymult*wackiness, MouseY.kr(100,400)),
			7, MouseX.kr(0.0,0.75)
		)%0.3)  // same as mod(0.3)
		,0.3,0.3, 5))}).add;
);
Synth(\nastySynth)

// now, as a Class, to be run within {}.play, or as part of another SynthDef

NastySynth {
	classvar <>wackiness=200;  // this was an arg before, now it will be common to all nastySynths

	*ar {arg wackymult=1;  // class definition

		^CombN.ar(  // will return this Comb delay
			(SinOsc.ar(
				LFNoise0.ar(9, wackymult*wackiness, MouseY.kr(100,400)), 7, MouseX.kr(0.0,0.75)
			)%0.3)
		,0.3,0.3, 5)
	}

}

// Put this definition in a new window, save it as NastySynth.sc in the your user extensions folder.  Recompile - the class count should go up. Now run this client code one line at a time-

NastySynth.wackiness= 200;
{NastySynth.ar}.play
{NastySynth.ar(0.01)}.play
{NastySynth.ar(SinOsc.kr(MouseX.kr(0,100)))}.play
NastySynth.wackiness= 4000;
{NastySynth.ar}.play
{NastySynth.ar(0.01)}.play
{NastySynth.ar(SinOsc.kr(MouseX.kr(0,100)))}.play

/* On the other hand, Classes can become quite complex, and are in fact a way to handle and make compact very complex entities.  A case in point is my own Console library.  This is a system that combines a GUI interface to control sets of signal and effect synths that can be patched to each other and have their settings saved and recalled as presets.  I use it for most things I do in SuperCollider.  I have uploaded its component classes and some Synths designed for it here:

http://www.cbmuse.com/code/CBconsole.sit

Put the folder into your extensions  folder and recompile SC.  Type: 'Console.new' and you should get a pop-up window where you can set default parameters.  For now, just accept the defaults, and when you do, the Console window itself opens.

The use of Console is explained in the 'console interface.rtf' file.

