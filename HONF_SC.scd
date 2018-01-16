


// play a  sine-wave -- try this with other UGens -- see Tour_of_UGens.html
x = { SinOsc.ar }.play;
x.free;

// same thing, using named arguments (between vertical braces)
x = { |freq=440, amp=0.2| SinOsc.ar(freq,0,amp) }.play;
x.set("freq",220);
x.free;

// same thing, as a SynthDef -- for use within more complex programs, like Ritmos
SynthDef("simpleSynth",{ |freq=440, amp=0.2| Out.ar(0,SinOsc.ar(freq,0,amp)) }).store;
x = Synth("simpleSynth");
x.set("freq",280);
x.free

// SynthDef that plays a short soundfile

// put any short soundfile in your Supercollider/sounds directory and load it


b = Buffer.read(s, "sounds/a11wlk01.wav");

// this SynthDef will play it
(
	x = SynthDef(\play_Buffer, { |out = 0, bufnum, rate=1.0,loop=1|
		Out.ar( out, PlayBuf.ar(1, bufnum, rate*BufRateScale.kr(bufnum),loop:loop))
	}).store;
)
// now play it


x = Synth("play_Buffer",["bufnum",b]);
x.set("rate",4.0)	// try rates also between 0 and 1, like 0.25


x.free; b.free;

/* For a full introduction to SuperCollider, work through Nick Collins' tutorial, which is in your
RitmosPC download

'Ritmos' is a library of SC classes I wrote to make my own polyrhythmic sequencer.  It makes
multitrack step sequencing available in an open-source program, with extremely flexible definition
of the rhythmic relationships between tracks.  It's a very complex program that I don't suggest
trying to understand how it works until you've used SC for a long time.  But it should be possible
to use it for sequencing samples, which we will try to do in this workshop!



