

Patterns

// run this code to get ready
s = Server.local.boot.scope(2);

/* Patterns provide a facility for easily exploring generative music/algorithmic composition. Rather than making single synthesis events, we're scheduling lots of events over time.

To fully understand how Patterns do what they do requires some effort since much of the detail is hidden 'below the surface' in SuperCollider's libraries.  But you can begin using its  power without having to understand everything about its implementation.

In the following, all the names beginning with capital P are examples of Patterns.
*/

// run this line
a = Pbind.new.play(quant:1.0);

a.stop;		//  stop it with cmd+period;

// now run this line
Pbind(\freq, 440).play(quant:1.0);

// run this, go back and run some of the others at the same time
(
Pbind(
	\dur,0.125,
	\midinote, Pseq([0, 4, 0, 7, 4, 0, 0] + 60,inf),
	\amp, Prand([0.125, 0.2, 0.25],inf)
).play(quant:1.0)
)

// The quant parameter allows the delay of scheduling to the next beat, so that patterns started up at different times lock in to each other.

(
Pbind(
	\freq, 770		// try changing me to another number!
).play;
)

// The Pbind class allows you to match properties of a sound event (like its \freq) to your provided parameter values. Now compare this:

(
Pbind(
	\freq, Pseq([100,200,300],inf)       // try a different list
).play;
)

/* The Pseq is a Pattern that generates a sequence of values, like ...

 100, 200, 300, 100, 200, 300, ...

returning the next one in the sequence each time it is evaluated.

There are many useful types of Pattern classes to try. Here are a few examples:
*/

// loop through the sequence of the array, perpetually:
Pseq([0,1,2,3],inf)

// the next value is a randomly chosen member of the array, and stop after 5 selections:
Prand([0,1,2,3],5)

// the next value is a randomly chosen member of the array, but the previous value never repeats:
Pxrand([0,1,2,3],inf);

// the next value is a weighted choice from the first array, using the weights given in the second argument.
// Stop after returning one value:
Pwrand([0,1,2,3], [0.5,0.3,0.1,0.1], 1)
// next value is the result of evaluating the
// given function, in this case 4.rand (but you can use ANY function
Pfunc({ 4.rand })

// Patterns are generators for Streams

[Streams]	// select the text within the box then cmd+d

//  A Stream represents a sequence of values that are obtained incrementally by repeated 'next' messages.  A Routine is an example of a Stream.  A Pattern turns into a Stream by applying the 'asStream' method to it:

//run this one line at a time, observing the Post window

a = Pseq([1, 3, 400],1);  //make Pattern, a Pseq
x = a.asStream;			//turn this Pattern into a specific Stream
x.next;					//ask for the next value in the Stream
x.next;					//and so on ...
x.next;
x.next;

y=a.asStream
y.next
// this means that from one pattern one can generate many independent streams:

(
var a, x, y;
a = Pshuf([1, 2, 3], inf);  // shuffles the list
x = a.asStream;	// this creates a Stream from the Pattern.
y = a.asStream;
x.nextN(10).postln;
y.nextN(10);
)

// a sound example:
(
var a =  Pshuf([1, 1, 0, 1, 0], 5);
Pbind(
	\dur, 0.125,
	\midinote, a * 7 + 60,
	\amp, a * 0.1 // 0 will create a rest
).play
)

// Patterns can be built of arbitrary complexity by nesting -
(
Pbind(
	\freq, Pseq([Pseq([100, 200, 300], 2), 400, 500, 600],inf)
).play;
)

(
Pbind(
	\freq, Pseq([
		Prand([240, 242, 245, 248]), // default num times = 1
		Pxrand([840, 741, 642],2)
	], inf)
).play;
)
// Note how we get one random value from the first array,
// followed by two different values from the second.

( // same algorithm as above, but without Pbind, to see the data
	a = Pseq([Prand([240, 242, 245, 248]), Pxrand([840, 741, 642], 2)],inf).asStream;
	20.do({a.next.postln;});
)

// To get back to Pbind, there's stuff going on behind the scenes, which SuperCollider is doing for you...Let's bring some of the hidden variables into view!

(
var clock;
clock = TempoClock(1.5); // tempoclock at 90 bpm

Pbind(
	\freq, Pseq([440, 660, 990, 880, 770], inf),  // event frequency
	\dur, Pseq([1.0, 0.5],inf),	// duration of event in beats
	\legato, 0.5  // proportion of inter onset time to play
	\pan, Pseq([0.5, -0.5],inf),
	\instrument, \default
).play(clock);
)

// The Pbind class always takes pairs of arguments, a literal \parameter and an associated Pattern (or value, or stream) that returns the values used to set that parameter in the next event.  You can see the default properties by looking at the defaults defined in this class:

[Event]		// search for the class variable 'defaultParentEvent'

// An Event is an Environment that specifies an action to be taken in response to a .play message. The key/value pairs within the Event specify the parameters of that action.

// You can define your own parameters, and have the values passed directly to your own synthesis function.  The explanation is deferred until later at the end of this file as an optional topic but to prove it's possible:

// run me first
(
SynthDef(\alicepavelinstr, {arg out=0, alice=440, pavel=0.5, pan=0.0, gate=1;
	var z;
	z = Resonz.ar(
		Pulse.ar(alice, pavel),
		XLine.kr(5000,1000),0.1,5) *
	Linen.kr(gate, 0.01, 0.1, 0.3, 2);
	Out.ar(out, Pan2.ar(z, pan));
	}
).store // must use 'store' instead of 'add' to register the arguments as parameters for constructing an Event
)

(
var clock;

clock = TempoClock(1.5); // tempoclock at 90 bpm

Pbind(
	\alice, Pseq(440*[1,2,3],inf),   // freq
	\pavel, Pseq([0.1,0.5, 0.8],inf), // pulse width
	\dur, Pseq([0.5,0.25,0.25],inf), // duration of event in beats
	\legato, 0.5, // proportion of inter onset time to play
	\instrument, \alicepavelinstr	// your own synthesiser
).play(clock);
)


// You can bind parameters together in a Pbind -- Here, frequency and amplitude are always paired
(
Pbind(// cobinding of properties
	[\freq, \amp],
	Pseq([
		[440,0.4],
		[330,0.1],
		Pfuncn({
			[550.rand, 0.8.rand]
		}, 1)
	], inf)
).play
)

// an Event can alter its behavior based on the values of parameters it has already chosen -- in this case, the next note is very soft unless it is over 350 Hz
(
Pbind(
	\freq, Pseq([ 440, 330, Pfuncn({ 550.rand + 40 }, 1)], inf),
	\amp, Pfunc({ arg event;
			event.postln;
			if(event.freq > 350, {
				"here".postln;
				rrand(0.25,0.5);
			}, 0.05);
		}),
	\dur, 0.25
).play
)

// Here's how to begin with polyphonic Patterns

// two simultaneous patterns using Ppar
(
var melodypat, basspat;

melodypat = Pbind(
	[\midinote, \dur],
	Prand([
		[60, 0.75],[64, 0.5],[66, 0.5],[69, 0.25],
		[67,0.75],[64,0.5],[60,0.5],[57,0.25]
	],inf)
);

basspat = Pbind(
	\midinote, Pseq([48, 42], inf),
	\dur, 1,
	\legato,0.5,
	\amp,0.5
);

Ppar([ melodypat, basspat ]).play(TempoClock(3));
)

// Henon map / attractor (returns points in -1.5<x<1.5, -0.4<y<0.4), which are then used for pan (x values) and degrees from a dorian scale (y values) (code adapted from Staffan Liljegren)

(
p = Prout({   // Prout creates a routine
	var x0, y0, x, y;
	x0 = 0; y0 = 0;

	loop({
		x = y0 + 1 - (1.4 * x0 * x0);
		y = 0.3 * x0;
		x0=x; y0=y;
		[x, (y*14).asInteger].yield;
	});
});

// \degree is the degree of the scale provided by \scale

b = Pbind(\scale, [0,2,4,5,7,9,11],  // dorian scale degrees
	\dur,0.125,
	[\pan, \degree], p);

// Ptpar combines more than one event stream into one, each with its own time offset, provided in pairs" [time,pat, time, pat ... ]

Ptpar(
	[ 0.0, Pbindf(b, \octave, 4,\stretch, 3.0),
		4.0, b]  // 4 beats later, play b
).play(TempoClock(1));
)

// Pbindf is a filter Pbind - this means it operates on the Pattern b, adjusting the current properties of the environment - in this case \octave and \stretch.  This allows a slow version of b in the bass and a faster version higher up coming in after 4 seconds.


// Remember that you can use normal Patterns without Pbind, using instead a Routine:  the Pattern is just a way to quickly generate sequences of values for algorithmic composition.

(
// run me first-
SynthDef(\pulsepan,{arg freq;
		Out.ar(0,
			Pan2.ar(
				LFCub.ar(freq*0.5, Rand(0.4, 0.6), 0.2)
				* (XLine.kr(0.001, 1, 0.9, doneAction:2)),
				Rand(-1.0, 1.0)
			)
		)
}).send(s)
)

(
var p, t;

p = Pseq([100, 200, 300, 330, 478, Prand([987, 789], 1)],
	inf).asStream;  // you must provide 'asStream' method, which Pbind provides for you, but Routine does not!

t = Routine({
	loop({
		Synth(\pulsepan,[\freq,p.next]); // get next frequency value from pattern
		0.1.wait;
	});
});
SystemClock.sched(0.0,t)
)

/* A little more detail about .store and SynthDescLib:

The SynthDescLib facility allows you to use your own SynthDefs with patterns and bind to the SynthDef arguments.

The command

SynthDescLib.global.read

will prepare a library of SynthDesc objects - SynthDef descriptions - from all the synthdefs in your synthdefs folder.

This then allows those SynthDefs to be used in Pbind as an \instrument target, and for the properties of the Event to be passed through to the spawned Synths that use that definition.

To make a new SynthDef and make sure it is ready for use with Pbind you use .store rather than .add or .send. This will save a SynthDef file on disk, read it into the SynthDescLib and send it to the active Server.

Your synth should use a doneAction to release the enclosing Synth at some point to prevent build up of Synths and eventual overload of the Server.
*/

(
SynthDef(\myInstr, { arg out=0, freq=440, amp=0.1, pan=0, gate=1;
	var z;
	z = LPF.ar(
		Mix.ar(LFSaw.ar(freq*[0.99,1,1.01],0.0,amp)),
		XLine.kr(5000, 1000, 1.5))
	* EnvGen.kr(Env.new([0,1,0],[0.01,0.01],\lin,1), gate, doneAction:2);
	Out.ar(out, Pan2.ar(z, pan));
}).store;
)

( // alternately plays events on \myInstr and on \default synths
Pbind(
	\dur, 0.25,
	\midinote, Pseq([0,5,0,7,4,0,0]+60,inf),
	\amp, Prand([0.125,0.2,0.25],inf),
	\instrument, Pseq([\myInstr,\default],inf),
	\pan, Prand([-1,0,1],inf)
).play
)






