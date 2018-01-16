

Server.local.boot.scope(2);


(	// get audio input, and slow-pan it through stereo output
// SoundIn channels start at 0 ! (left input)
SynthDef("soundIn",{ arg in=0;
	Out.ar(0,
		Pan2.ar(SoundIn.ar(in),	// Pan2 mixes input between two adjacent outputs
			SinOsc.kr(0.2),		// use a sinewave to control pan pos
			0.5))
}).play;
)

/* Buffers are blocks of memory on the Server that are used for sample playback and manipulation, for streaming files off disk, for recording, making wavetables and FFT processing. The server defaults to having 1024 individual buffers, and more can be  allocated as needed from the operating system. */


//allocate a one channel buffer of 441000 sample frames (10 sec at standard sampling rate)

// execute these lines separately -- Buffer allocation takes a small but finite amount of time, so it wouldn't work properly if you executed them directly as a single block!  When you need to do that, use a 'completionMessage', which can be a Function that executes only after the Buffer has been allocated.

b=Buffer.alloc(s, 10*44100, 1);  // s= server, 10*44100 num frames, 1 = 1 channel, i.e. mono
b.bufnum 	// The bufnum is the identifier to keep track of the Buffer

b.free  //when finished with it, restore that memory and free that bufferID


// PlayBuf is the standard way to play back a sound from a Buffer.
(
//this loads into a buffer the default sound that comes with SuperCollider - .read brings in the whole sound at once

b = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef("playbuf",{ arg out=0,bufnum=0,rate=1,trigger=1,startPos=0,loop=1;
	Out.ar(out,
		Pan2.ar(
			PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum)*rate,trigger,
				BufFrames.ir(bufnum)*startPos, loop),0.0)
	)
}).add;
)

// BufRateScale adjusts for different possible sampling rates,  because the default soundfile is actually at 11025Hz sampling rate, and my audio output is at 44100Hz. The BufFrames UGen returns the number of frames in the soundfile. But note the .ir - this is initialisation rate, i.e. it the UGen only runs once when first created, it doesn't need to be continually recalculated.

// use cmd+period to kill it
Synth(\playbuf, [\out, 0, \bufnum, b.bufnum]);

 //play at half rate
Synth(\playbuf, [\out, 0, \bufnum, b.bufnum, \rate, 0.5]);

/* BufRd is similar to PlayBuf but lets you directly read from a buffer (note you could also use this with non-soundfiles) via a phase argument. This is more convenient for taking custom control of how you read through a sample, for example, using MouseX to scrub through the source file */

(
SynthDef("bufrd",{ arg bufnum=0;
	Out.ar(0,
		Pan2.ar(BufRd.ar(1, bufnum,
			K2A.ar(BufFrames.ir(b.bufnum)
				*MouseX.kr(0.0,1.0)).lag(MouseY.kr(0.0,1.0))),
		0.0)	// center pan
	)
}).add;
)
Synth(\bufrd,[\bufnum,b]);

/*  The K2A is needed to convert control rate Mouse to run at audio rate, because the BufRd needs to know where it is reading for every sample.

.lag (which is a shortcut to get a Lag UGen) puts a smooth 'catch-up delay' (amount controlled by MouseY) on the scratching.

[BufRd] //the help file has more examples

To stream a large file continuously from disc, use DiskIn.  A small Buffer is needed to smooth out data which arrives in bursts from the disc. Replace the filename here with one that is valid for your machine (on MacOS, drag a soundfile onto this editor window, and the correct pathname will be generated
*/

(
//Prepare to stream-
b=Buffer.cueSoundFile(s,"/Sounds/disco/zarathustra",0, 1);
)
// args are \numChannels, and \bufnum, and numChannels must match the channels in the Buffer
SynthDef(\diskin,{Out.ar(0,DiskIn.ar(1, b.bufnum ))}).play(s);

// You can only playback, you can't modulate the streaming rate in any way. But this allows you to bring in files for any processing you desire to do.  Note also that the number of channels of the soundfile must match those in the Buffer, and the DiskIn argument

[DiskIn] // see its help file

(	// define a sampler
SynthDef("sampler",{ arg sampbuf=0,rate=1,startPos=0,trg=0,loop=1.0;
	var out;
	out = PlayBuf.ar(1,			// numChannels
		sampbuf,			// which bufnum to play
		BufRateScale.kr(sampbuf)*rate,   // gets sampRate for this Buffer
		trg,		// trigger arg, causes jump to startPos when changing from 0 (or less) to positive
		startPos*BufFrames.kr(sampbuf),  // startPos, in sampleFrames of Buffer
		loop);			// 1 means loop, 0 means no loop
	Out.ar(0,out)
}).add;
)

x = Synth(\sampler,[\sampbuf,b]);
x.set(\rate,exprand(0.125,8));   // random choice with exponential curve
(
x.set(\startPos,rand(1.0));
x.set(\trg,1); SystemClock.sched(0.01, { x.set(\trg,0)});
)

// this sampler allows you to set its loop endPos too
(
SynthDef("loopSampler",{ arg sampbuf=0, rate=1, startPos=0, endPos=1.0,loop=1;
	var thisRate, thisDur, loopFrq;
	thisRate = BufRateScale.kr(sampbuf)*rate;  // BufRateScale converts for differences in samplerate between different recorded samples and your playback rate
	thisDur = ((endPos-startPos).abs*BufDur.kr(sampbuf)); // BufDur gets the duration of the Buffer, 'abs' method gets absolute value, to convert negative results to positive durations
	loopFrq = (thisDur.reciprocal).min(100);  // frequency of looping is the reciprocal of the loop duration -- also guard against Infinite frequency using 'min' -- this returns the smaller of the reciprocal or its argument (100)
	Out.ar(0,
		PlayBuf.ar(1,			// numChannels
			sampbuf,				// which bufnum to play
			thisRate,   			// rate
			Impulse.kr(loopFrq),	// Impulse Ugen retriggers sample
			startPos*BufFrames.kr(sampbuf),  // startPos*BufFrames gets the starting position sample number
			loop)
		)
}).add;
)

//  play the loopSampler
(
	var buf, filename;
	filename = "/Sounds/latin/las mulatas";  // choose your own soundfile
	buf = Buffer.read(s,filename);	// read the file into a Buffer
	x = Synth("loopSampler",
		["sampbuf",buf,"startPos",0.3,"endPos",0.5]);
)
x.set("startPos",0.2);
x.set("endPos",0.7);
x.set("rate",-1.0);	// note that negative rate, plays backwards
x.set("rate",1.0);

// the first time the sampler plays, it sometimes plays from the start of the sample -- why?  because the sample hasn't loaded yet, so there is no accurate count of the number of frames in the Buffer -- so, it is usually better to load your samples first, before starting any Synths that play them -- alternatively, you can use the 'action' argument of Buffer.read to start the Synth after reading is complete -- see the help-file for Buffer to see explanation, and here is an implemented version:

(
	var filename;
	filename = "/Sounds/latin/las mulatas";
	Buffer.read(s,filename,	// read the file into a Buffer
		action: { arg buf;	// pass the new Buffer as an arg to the completionMessage
			x = Synth("loopSampler",
			["sampbuf",buf.bufnum,"startPos",0.15,"endPos",0.25]);
		}
	);
)

// create another Buffer to record Audio input -- note that it's assigned to environmental variable 'b', so that we can continue to reference it in the next compilations

b = Buffer.alloc(s,s.sampleRate*4.0,1); // a 4 second, 1 channel Buffer

( // record into it
SynthDef("recSoundIn",{ arg bufnum=0, in=0;
	RecordBuf.ar(SoundIn.ar(in),bufnum, loop:1) // record over and over
	// RecordBuf.ar(SoundIn.ar(in),bufnum, loop:0)  // or just once!
}).play(s,[\bufnum,b.bufnum]);
)

// then play it
x = Synth("loopSampler",["sampbuf",b.bufnum]);

( // make some generic GUI Controls for loopSampler
	var myWind;
	myWind =  Window.new("sampler"); // create a window
// you can position it by providing a "bounds" arg, in the form or a Rect (rectangle), like this: Rect.new(leftPos, topPos, width, height) -- all argument numbers are in pixels
	myWind.front;	// and display it
	 // create a slider, with dimensions relative to myWind given by Rect
	Slider(myWind,Rect(120,20,40,200)).value_(1)
		.action = { arg slider; // give it an action to do when moved
			x.set("rate",slider.value)
		};
	// make a text label for the slider
	StaticText(myWind,Rect(120,230,40,20)).string_(" rate");
	Slider(myWind,Rect(180,20,40,200)).value_(0)
		.action = { arg slider;
			x.set("startPos",slider.value)
		};
	StaticText(myWind,Rect(180,230,40,20)).string_(" start");
	Slider(myWind,Rect(240,20,40,200)).value_(1)
		.action = { arg slider;
			x.set("endPos",slider.value)
		};
	StaticText(myWind,Rect(240,230,40,20)).string_(" end");
)

// The next example is a granular sampler, which will get rid of the click at the beginning and end of the sampler
(
SynthDef("granSampler",{ arg sampbuf=0, rate=1, startPos=0, endPos=1.0, dir=1, loop=1.0;
	var thisRate, thisDur, loopFrq, env;
	thisRate = BufRateScale.kr(sampbuf)*rate;
	thisDur = ((endPos-startPos).abs*BufDur.kr(sampbuf));
	loopFrq = (thisDur.reciprocal).min(100);
	env = Env.new([0,1,1,0],[0.0125,1.0-0.025,0.0125]);
	Out.ar(0,PlayBuf.ar(1,			// numChannels
		sampbuf,				// which bufnum to play
		thisRate,   			// rate
		Impulse.kr(loopFrq),		// Impulse Ugen retriggers sample
		startPos*BufFrames.kr(sampbuf),  // startPos
		loop)*
		// trigger an envelope on the sample "grain" in sync with loop
		EnvGen.ar(env,Impulse.kr(loopFrq), // Impulse is 'gate' arg of EnvGen
					timeScale: thisDur.max(BufRateScale.kr(sampbuf)*0.01));
	)
}).add;
)
x = Synth("granSampler",[\sampbuf, b, \startPos,0.2,\endPos,0.4]);
x.set(\endPos,0.05);

// This next SynthDef plays just a single grain of sound before deAllocating itself using an EnvGen with doneAction: 2.  We will use the timeScale arg of the same EnvGen to adjust the length of the grain.
(
SynthDef("grain",{ arg bufnum=0, rate=1.0, startPos=0, size=1;
	Out.ar(0,
		Pan2.ar(
			PlayBuf.ar(1,bufnum,
				rate*BufRateScale.kr(bufnum),1,
				startPos*BufSamples.kr(bufnum),1)
			*EnvGen.kr(
				Env([0,0.2,0],[0.05,0.05],\sine), // a sinusoidal envelope
			// timeScale will lengthen durations proportionally
				timeScale: size, doneAction: 2),
			0)	// pan position
	);
}).add;
)
x = Synth("grain",["bufnum",b,"startPos",0.5,"size",10]);

// Now we make a GUI to control a Routine that automatically plays grains with different argument values.  This GUI will use a convenience class called EZSlider that easily links a Slider with a number readout of its value and a label.  It also includes a ControlSpec, that automatically scales the slider's range and sets other useful characteristics like its default value, step resolution, and "warp", which allows for non-linear scaling of graphical controls.

// EZSlider(window, dimensions, label, controlSpec, action, initVal, initAction, labelWidth, numberWidth)

//	ControlSpec.new( minval, maxval, warp, step, default,units);

(	// play the grain sampler from a gui - try moving the start slider slowly through its range -- you will hear a granular scan through the soundfile

var myWind,rate=1.0,startPos=0,size=1;
myWind = Window.new("granSamp", 350@200);
myWind.front;  // you must do this, or no display!

//	 a FlowLayout allows automated placement of GUI objects in a window
myWind.view.decorator = FlowLayout(myWind.view.bounds);

EZSlider(myWind,300 @ 20,"rate",[0.25,4.0,\exp,0,1.0].asSpec,
	{ arg slider; rate = slider.value },1.0,numberWidth:40);

myWind.view.decorator.nextLine;

EZSlider(myWind,300 @ 20,"start",[0.0,1.0,\lin,0,0.0].asSpec,
	{ arg slider; startPos = slider.value },0.0,numberWidth:40);

myWind.view.decorator.nextLine;

EZSlider(myWind,300 @ 20,"size",[1.0,10.0,\lin,0,1.0].asSpec,
	{ arg slider; size = slider.value },1.0,numberWidth:40);

// a Routine is a function that can pause (or wait), then resume
Routine({
	loop({
		Synth("grain",["bufnum",b,
			"rate",rate,"startPos",startPos,
			"size",size]);
			(0.1*size).wait;  // make sure that this is never zero, or nil!
		});
}).play;
)
// in the above code, a new Synth is created with every loop, and each Synth is deallocated after its amplitude envelope completes --  there are always 5 Synths active at any one time -- why?)


// RECORDING SC music:

// recordings are automatically stored here:
thisProcess.platform.recordingsDir  // run this to see where the file will turn up - you can also give it your own pathname (drag a folder to this window to see the format) to put it somewhere else

(  // set up the file format, otherwise, you'll get a floating-point file because SuperCollider output defaults to "float"  -- a recording in float format cannot be opened in many commercial sound editors, although the freeware "Audacity" will open it; but to record your output in 16bit format, first execute:

(
s.recHeaderFormat_("wav");  // or "aiff"
s.recSampleFormat_("int16");  // or "int24" or "float"
s.prepareForRecord; // you always have to call this first before recording
)

 // start recording
s.record;

// play your sounds!!
{ SinOsc.ar }.play

// stop recording
s.stopRecording  // or if you use command-period, your recording will stop at the same time as the sounds do, but abruptly



