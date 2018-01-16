//

s.boot.scope(2);

(  // some SynthDefs, all deallocate themselves after playing env
SynthDef(\ckick,{| dur = 0.15, atk = 0.015, amp = 0.8, pan = 0 |
	Out.ar(0,
		Pan2.ar(
			SinOsc.ar(
				EnvGen.ar(
					Env(\freq_l.kr([2960, 70, 90]),  // ????
						\freq_d.kr([0.07, 0.15]),
						\freq_c.kr([-13, -1]))),
				mul:EnvGen.ar(
					Env.perc( atk, max(dur - atk, atk),
						curve: \amp_c.kr([-1, 5])),
					doneAction: 2 ) ),
			pan, amp ))
}).add;

SynthDef(\tymp,{arg dur=1,note=60,pan=0;
	var klank, env;
	klank = Klank.ar(`[{Rand(note*0.5.midicps,note.midicps)} !12,  // make 12 element array
		{Rand(0.1,0.1)}!12], // amplitudes
		BrownNoise.ar(0.05)); // flt bank input
	env = EnvGen.kr(Env.perc(0.1,dur), doneAction:2);
	Out.ar(0, Pan2.ar(klank*env*0.25),pan);
}).add;

SynthDef(\bleep,{ arg note=60, harms=200, dur=1, amp=0.5, pan=0.0;
	var freq, env;
	freq = note.midicps;
	env = EnvGen.ar(
		Env([0,1,1,0],[0.01, 0.1, 0.2]),
		timeScale: dur,
		levelScale:amp,
		doneAction:2
	);
	Out.ar(0,
		Pan2.ar(Blip.ar(freq,harms) * env, pan)
	)
}).add;
)

/*
The most primitive way to make a function repeat over time uses
one global SystemClock which schedules in seconds: SystemClock is the most accurate clock:
*/

// start a process 0 seconds from now then repeat once per second
// All scheduling will stop when pressing CMD + period
(
SystemClock.sched(0.0,//start at 0.0 sec from now, i.e. immediately
	{
		Synth(\bleep,[\note,rrand(40,80),\harms,exprand(10,200)]);
		1
	}
)
)

/* The last thing returned from the function is the time until that function is called again; you MUST either return a number, or nil; nil will stop the scheduling.  if you leave out the number or nil, SC3 will go into an infinite loop, and you'll have to 'Quit Interpreter' (in the 'Language' menu), or force quit from the Finder to stop the program!!
*/

// here's a chaotic variation with more things changing automatically
(
~spd = 1;
SystemClock.sched(1.0,//start in 1.0 sec
	{ var dur = [0.25,0.5,0.75,1].choose;  // random choice of repeat time
		Synth([\bleep,\ckick,\tymp].choose.postln,
			[
				\note, (#[0,2,4,5,7,9] + 48).choose,  // midinote numbers
				\harms, exprand(1,200),
				\pan, 1.0.rand2,
				\dur,dur*~spd
			]
		);
	dur*~spd
})
)
// try changing ~spd, and recompiling the code above many times for fuller textures!
~spd = 0.5;

// You can get the current SystemClock time:

Main.elapsedTime; //gives a time since the application started

// And then use it to schedule with respect to an absolute time

(
SystemClock.schedAbs(Main.elapsedTime+5.0,//start at absolute system clock time now + 5 second
	{
		Synth(\bleep,
			[
				\note, (#[0,2,4,5,7,9] + 48).choose.postln,
				\pan, 1.0.rand2
			]
		);
	// random choice of repeat time:
	[0.25,0.3,0.7,0.1,nil].choose  // nil will stop it
})
)

/*  To work relative to some tempo, SuperCollider measures tempi in beats per second (bps) rather than beats per minute - multiply by 60 to go from bps to bpm, divide by 60 in the other direction

1 bps = 60 bpm
2 bps = 120 bpm

For beat-based scheduling use TempoClock:
*/
(
var t;
t = TempoClock(2); // make a new tempoclock at tempo 120 bpm = 2 beats per second
t.schedAbs(0,{ arg ... args;	// start at absolute beat 0 immediately
	var clock;
	args.postln;	//  post the input arguments to our event function
	//   it will post logical time in beats, elapsed time
	//  in seconds of enclosing thread and this clock
	if(args[0].mod(4)==0,{clock = args[2].tempo = [2,3,4,6].choose.postln;});
	Synth([\bleep,\ckick].choose);// make a bleep
	1.0	// reschedules every beat
})
)

// TempoClock will react appropriately to changes of tempo and timesig.
// There is an default available TempoClock already running

t= TempoClock.default;
// You can ask a tempoclock where it is in beats...
t.elapsedBeats;
//  ... or bars (default assumption is 4/4)
t.bar;				/
//find next beat
t.elapsedBeats.ceil;
//find last beat
t.elapsedBeats.floor;

// try compiling this several times to see how it stays locked on beat
(
var t;
t = TempoClock.default;	//
t.schedAbs(t.elapsedBeats.ceil, // start at next whole beat
	{
		Synth(\bleep, [\note, [36,40,43].choose, \pan, 1.0.rand2]);
		[0.25,0.5,1.0, nil].wchoose([0.5,0.4,0.05,0.05]); // repeat at some number of beats from the array- nil means stop
	})
)
//wchoose allows a weighted choice of values in one array with respect to the weights in a second array

[1,2,3,4].wchoose([0.8,0.1,0.07,0.03]);

// the second array must add up to equal 1 and there must be as many weights as items to pick from -- use 'normalizeSum' method to make this easy:

[1,2,3,4,5].normalizeSum.postln

// If you ask for a beat that has already occured, the scheduler will try to catch up with the queue of events as quickly as possible:

(
var u;
u = TempoClock(1.2);	// make our own Tempoclock at a tempo of 1.2 bps
// should have started 5 beats ago!
u.schedAbs(-5.0, { Synth(\bleep,[\note,rrand(30,80)]);  0.5 });
// you'll get a loud burst of events as it catches up
SystemClock.sched(5.0, {u.clear}); // schedule a stop for 5 seconds from now.
)

// If you change tempo at some point, the transition is fine:
(
var u;
u = TempoClock(3.5);
u.schedAbs(0.0, { arg beat, sec;
		[beat,sec].postln;
		Synth(\bleep, [\note, rrand(60.0,67.0)]);
		0.5
});
u.schedAbs(8.0, { u.tempo_(2); nil }); // just schedule tempo change
u.schedAbs(12.0, { u.tempo_(7); nil }); // just schedule tempo change
u.schedAbs(17.2, { u.tempo_(1); nil }); // just schedule tempo change
SystemClock.sched(7.0, { u.clear; }); // schedule a stop for 7 seconds from now.
)

// Note that there are two ways to set the value of an 'instance variable', like the tempo of a clock

t=TempoClock(2);

t.tempo; //gets current tempo

t.tempo_(4); //sets current tempo (the underscore character means set the value equal to the argument in parentheses)

t.tempo;

t.tempo= 2.3; //also assigns new tempo, same as the underscore

t.tempo;


// Changing Tempo via a UI control:
// slider range is always 0.0-1.0, so mapped in the code

(
	var w,u,slid, button;

	w = Window("tempo control test", Rect(100,100,200,40));
	slid = Slider(w, Rect(0,0,200,20));

	button = Button(w, Rect(60,20,40,20));
	button.states_([["kill"]]);

	w.front;

	slid.action_({u.tempo_(4*(slid.value)+1)});
	button.action_({u.clear; w.close;});

	u = TempoClock(1);

	u.schedAbs(0.0, { arg beat,sec;
		[beat,sec].postln;
		Synth(\bleep, [\note, rrand(40, 80)]);
		1.0
	});
)

// You can do multiple Tempi by creating two clocks at once
// Here's a tempo ratio of 12:13

(
var u,v;

u = TempoClock(1.2);
v = TempoClock(1.3);

u.schedAbs(0, { Synth(\bleep, [\note, rrand(41.8,47.5), \pan, -0.5]);  1.0 });
v.schedAbs(0, { Synth(\bleep,[\pan, 0.5]);  1.0 });

SystemClock.sched(10.9, { u.clear; v.clear; }); // schedule a stop for 10.9 seconds from now.
)

/* A note about GUIs and Clocks

GUIs can't be updated by direct call from the SystemClock!!
The operating system's AppClock must be used. Here is a quick programmatic demonstration of moving a window around - when running it always press cmd + period before attempting to close the window
*/
(
var w, i=0;
w = Window("My Window", Rect(100,0,200,200));
// A 200 by 200 window appears at screen co-ordinates (100, 0)
w.front;
//schedule moves and resizes for the window
AppClock.sched(0.0, {  // SystemClock.sched won't work for this function!!
	w.bounds_(Rect(100,(10 * i)%500,rrand(200,400),50));
	i=i+1;
	0.125
});
)

// But, if you within a SystemClock, you can wrap any GUI calls in function brackets followed by the 'defer' method, which reassigns the function to the AppClock.

{  // GUI code
}.defer

// This technique is needed often when scheduling timing changes, or Routines that run from action functions of GUI objects.


// Routine and Task

/* So far, scheduling was always achieved by scheduling a function for a specific time. In order to be able to step through different stages of a program, we need a function that can have a number of execution stages. It is not evaluated all at once, but can "yield" its current value at each of multiple stages.  A Routine does this.
*/

(
r=Routine({
	1.yield;
	2.yield;
	3.yield;
})
)

r.value; //run this line four times

//another example with more going on
(
var r;
r = Routine({
		var x;
		x = 1.0.rand;
		2.yield;
		x.yield;
		1000.yield;
		x.yield;
		x = 1.0.rand;
		x.yield;
	});

10.do({ r.value.postln });
)

// a routine can also have side effects

(
r = Routine({
		1.yield;
		Synth(\bleep);
		2.yield;
		1.yield;
		Synth(\bleep);
		1.yield;
	});
)

r.next; // btw. r.next is a synonym for r.value -  both return the "yield value".
r.next;
r.next;
r.next;

// we can now simply use the routine by playing it on a certain Clock

(
r = Routine({
		0.5.yield;
		Synth(\bleep);
		1.yield;
		0.5.yield;
		Synth(\bleep, [\note, 43]);
		0.5.yield;
	});

SystemClock.sched(0, r);
)

// However,  usually just to "play" the Routine, passing in the Clock

r.reset;	// reset transforms the routine back into its original state
r.play(SystemClock);

r.reset;
r.play(TempoClock(3));


// Yield can return any kind of object, but to specify time it needs to be a float or an integer.  To make that clear, we use the method 'wait'  instead of yield - but 'wait' just means the same as 'yield' !);

TempoClock.default.tempo_(1); //just making sure default is sensible. In actual fact, for a tempoclock going at 1 bps, time in beats is the same as time in seconds

(
var r;
r = Routine.new({
	"I just began!".postln;
	1.0.wait;
	"1 second later".postln;
	2.0.wait;
	"finished".postln;
});

r.play; //defaults to TempoClock.default;
)

(
var r;
r = Routine.new({
	16.do({ arg i;  // 'do' the following functions multiple times
		Synth(\bleep, [ \note, 36+(3*i) ]);
		0.25.yield;  //  yield and wait mean the same thing

	});
});

r.play;
)

// inf.do can be used to keep going forever; but you must be very careful never to omit some positive time.wait . Because otherwise, the loop will go infinitely fast and SuperCollider (and possibly also your computer) will crash.

(
var r;
r = Routine.new({
	inf.do({ arg i;
		// % is a symbol for 'modulo', which returns the remainder of a divide operation
		Synth(\bleep, [ \note, 36+(3*(i%10)) ]); // %10 stops it going up forever
		0.25.wait;   //do not leave me out!
	});
});
r.play;
)

// a Task is a Routine that can be paused and resumed:
(
t = Task.new({
		inf.do({ arg i; // keep going forever (until stopped externally)
			Synth(\bleep, [\note, 36+(2.3*(i%17))]);
			0.25.wait;
		});
});
)

t.play(TempoClock(1.4)); //start the Task going

t.pause;  //pause

t.resume;  //unpause

// There is a special shortcut for writing a Routine:

{}.fork

// This automatically wraps your function in a routine and plays it; you pass in the clock as an argument to fork:

{5.do{"hello".postln; 1.0.wait} }.fork(TempoClock(1))

(
{
	16.do{arg i;
		Synth(\bleep, [\note,rrand(48,84) ,\amp, rrand(0.0,0.125)]);
		0.125.wait
	}
}.fork(TempoClock(2))
)






