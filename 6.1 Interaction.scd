

Interaction via Mouse, Keyboard, MIDI, SoundIn...

Let's return to the localhost Server now:

(
Server.default=s=Server.local;
s.boot;
)

MouseX/Y

Using the mouse as a controller is a quick and easy way of interacting with a patch

MouseX.kr(leftval, rightval, warp)	//warp can be 'linear' or 'exponential' depending on the way the parameter varies

MouseY.kr(topscreenval, bottomscreenval, warp)

Compare these hearing tests (be careful, they're piercing)

{SinOsc.ar(MouseX.kr(20,20000, 'linear'),0,0.1)}.play

and

{SinOsc.ar(MouseY.kr(20,20000, 'exponential'),0,0.1)}.play

The exponential mapping is far more comforting as a proportion of screen space than the linear one!

(	// The Mouse might also be used as a trigger
{
var trig,mx;
mx=MouseX.kr(0.0,1.0);
trig= mx>0.5;	//this is a UGen which compares mx to the constant signal 0.5 at krate
SinOsc.ar(440,0,0.1*trig)
}.play;
)

(	//trigger in a given region
{
var trig,mx,my;
mx=MouseX.kr(0.0,1.0);
my=MouseY.kr(0.0,1.0);
trig= if((mx>0.3) * (mx<0.5) * (my>0.3) * (my<0.7),1,0); //if is a UGen here, * is equivalent to logical AND
SinOsc.ar(440,0,0.1*trig)
}.play;
)

To show a more involved example of the principle, here's one of my favourite
SuperCollider example patches (by James McCartney):

(
    // strummable guitar
    // use mouse to strum strings
{
	var pitch, mousex, out;
	pitch = [ 52, 57, 62, 67, 71, 76 ];		// e a d g b e
	mousex = MouseX.kr;
	out = Mix.fill(pitch.size, { arg i;
		var trigger, pluck, period, string;
		// place trigger points from 0.25 to 0.75
		trigger = HPZ1.kr(mousex > (0.25 + (i * 0.1))).abs;
		pluck = PinkNoise.ar(Decay.kr(trigger, 0.05));
		period = pitch.at(i).midicps.reciprocal;
		string = CombL.ar(pluck, period, period, 4);
		Pan2.ar(string, i * 0.2 - 0.5);
	});
	LPF.ar(out, 12000);
	LeakDC.ar(out);
}.play;
)

Keyboard

You can use the keyboard to trigger things by setting action functions. These are usually connected to GUIs,  but here is an example of  a callbacks from the Document as you type:



(


var doc;

SynthDef("typeofsound",{Out.ar(0,Line.kr(1,0,0.1,doneAction:2)*VarSaw.ar(Rand(100,1000),0,Rand(0.1,0.8),0.1))}).send(s);

doc = Document.current; //this text window you're reading from!


doc.keyDownAction_({arg ...args;
	[args[1],args[3]].postln;
	Synth("typeofsound");
});
)



//turn this off


(


Document.current.keyDownAction_(nil);
)
[Document] //the Document help file has other examples of this

// here's a simple GUI example
(

w =  Window("keytrg",Rect(128, 64, 440, 480)).front;
w.view.keyDownAction_({  arg view, key, modifiers, unicode;
	switch(key,	// if input key matches an item on the list, then do the function
		$q,{ Synth(\default) },
		$w,{ Synth(\typeofsound) }
	)
})
)



MIDI

To access your MIDI interface you must initialise: MIDIClient.init and then MIDIConnect  each port you need to use.
For obtaining incoming MIDI messages see the MIDIIn help file: [MIDIIn]
For sending MIDI messages out see the MIDIOut help file: [MIDIOut]
There are also some helper classes:[MIDIResponder]


// here's a simple program to turn on/off notes, and control faders with MIDI controllers
// first, a synth to trigger and control
(
SynthDef(\mmfmCascade,{ arg carFreq=440, carAmp=0.2, cmRatio1=1, cmRatio2=1,index1=0.5, index2=0.1;
	var mod1Freq, mod2Freq;
	mod1Freq = cmRatio1*carFreq;
	mod2Freq = cmRatio2*mod1Freq;
	Out.ar(0,SinOsc.ar(
		SinOsc.ar(
			SinOsc.ar(mod2Freq,0,mod2Freq*index2,mod1Freq),
			0, mod1Freq*index1,carFreq),0,carAmp
	))
}).store;

MIDIClient.init;	// note post to see how many source and destination ports you use
2.do {|i| MIDIIn.connect(i,MIDIClient.sources.at(i)) }; // each port you need must be connected


CCResponder.removeAll; NoteOnResponder.removeAll; NoteOffResponder.removeAll;  // clear any old responders, because they don't replace each other, just acculumulate otherwise


// 'src' arg refers to the MIDI input port
NoteOnResponder({arg src, chan, num, vel;
	~synth = Synth(\mmfmCascade,[\carFreq,num.midicps,\carAmp,vel/127])
},nil,nil);	// 'nil' means respond to any src and any chan, but you can choose!

NoteOffResponder({ arg src, chan, num, vel;  // executes with every noteOff received
	~synth.free
},nil,nil);

CCResponder ({ arg src, chan, num, val;  // this is the vector for controller events
	switch(num,	// 'switch' matches a value with an appropriate response
		1,{ ~synth.set(\carFreq,\freq.asSpec.map(val/127)) },
		2,{ ~synth.set(\carAmp,\amp.asSpec.map(val/127)) },
		3,{ ~synth.set(\cmRatio1,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		4,{ ~synth.set(\index1,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		5,{ ~synth.set(\cmRatio2,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		6,{ ~synth.set(\index2,[0.1,20,\lin,0.1].asSpec.map(val/127)) }
	)
},nil,nil)
)



SoundIn

To obtain an audio input stream, use the simple SoundIn UGen

{ SoundIn.ar(0,0.1) }.play;	      // mono on input channel 1;
{ SoundIn.ar([0,1],0.1) }.play;	      // stereo through patching from 2 inputs to output won't work if you don't have at least 2 inputs!

So it's easy to build effects processors for live audio:

(
{ //ring modulator
SinOsc.ar(MouseX.kr(0.001,110,'exponential' ))*SoundIn.ar(0,0.5)
}.play;	      // stereo through patching from input to output
)

SuperCollider comes with an amplitude tracker and pitch tracker for realtime audio

(
// use input amplitude to control Pulse amplitude - use headphones to prevent feedback.
{
	Pulse.ar(90, 0.3, Amplitude.kr(SoundIn.ar(0)))
}.play
)

You can threshold the input to avoid picking up background noise

(
{
var input,inputAmp,threshhold,gate;
var basefreq;

input = SoundIn.ar(0,0.1);
inputAmp = Amplitude.kr(input);
threshhold = 0.02;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);  // Lag smooths opening of gate
(input * gate)
}.play;
)


The Pitch follower has many input arguments, though you usually take the defaults without worrying. It returns two outputs- the tracked frequency and a signal indicating whether it has locked onto any periodicity or not.

Server.internal.boot; //if on a Mac you'll need to swap back to internal server for using .scope- you can have both the internal and localhost server on at once, but you might need to press the -> default button

//showing the outputs - K2A makes sure control rate signals are converted to audio rate, because the final output of a Synth has to be audio rate
(
{
var freq, hasFreq;
# freq, hasFreq = Pitch.kr(SoundIn.ar(0,0.1));
[K2A.ar(freq*0.001), K2A.ar(hasFreq)]
}.scope
)

(
{
	var in, amp, freq, hasFreq, out;
	in = Mix.ar(SoundIn.ar([0,1]));
	amp = Amplitude.kr(in, mul: 0.4);
	# freq, hasFreq = Pitch.kr(in);
	out = Mix.ar( LFTri.ar(freq * [0.5, 1, 2]) ) * amp;
	6.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
	});
	out
}.play
)

(
{
	var in, amp, freq, hasFreq, out;
	in = SoundIn.ar(0);
	amp = Amplitude.kr(in, mul: 0.4);
	# freq, hasFreq = Pitch.kr(in);
	out=if(hasFreq,Pulse.ar(freq,0.5,0.1),SinOsc.ar(freq,0,0.1));

	6.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
	});
	out
}.play
)

There are various machine listening capabilities.

Here are some onset detectors which might be helpful:

[Onsets]
[PV_HainsworthFoote]
[PV_JensenAndersen]

example triggering TGrains UGen:

s.sendMsg(\b_allocRead, 10, "sounds/a11wlk01.wav");

(
var fftbuf;

fftbuf=Buffer.alloc(s,2048,1);

{
var b = 10, source1, detect;

	source1= SoundIn.ar(0);

	detect= PV_HainsworthFoote.ar(FFT(fftbuf.bufnum,source1), 1.0, 0.0, 0.7, 0.01);

	TGrains.ar(2, detect, b, LFNoise0.kr(10,0.2,1.0), MouseX.kr(0,BufDur.kr(b)), MouseY.kr(0.1,0.5), LFNoise0.kr(10,1.0), 0.5, 2);
}.play
)

RecordBuf

If you'd like to capture live sound, the RecordBuf UGen is your friend.
You need to set up a buffer to store the recorded sample data.

(
var b;
b=Buffer.alloc(s,44100,1);	//1 second mono buffer allocated on local server
{
//continuously record in a loop, recording to the buffer we just declared
//each record cycle multiplies the old data
	RecordBuf.ar(SoundIn.ar(0), b.bufnum, 0, 1.0, MouseX.kr(0.0,1.0), 1, 1, 1);
//playback the captured buffer in a loop, backwards
	PlayBuf.ar(1, b.bufnum,MouseY.kr(0.0,-1.0), 1,0,1);
}.play;
)

You might sync captured buffers to tempo for dance music, and add refinements like user interface to choose when to rerecord the buffer...

There are also facilities for control from graphics tablets and joysticks, though these will make more sense after some of the next chapters on GUIs and OSC responders.

[SC2DTabletSlider]
[HIDDeviceService]
["SC://GeneralHID"GeneralHID]

You might also like to try

[MouseButton]
[KeyState]
["SC://SerialPort"SerialPort]

Another standard way is to communicate with other applications of course is Open Sound Control, which you're already familiar with.



