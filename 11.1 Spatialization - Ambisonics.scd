
/*
Spatialization -

SuperCollider defaults to having its first 16 audio Bus channels available
to be automatically used as sound outputs, but this depends of course on having hardware that supports multiple channel outputs.  (You can change the number of output audio Buses using ServerOptions.) But it also means that you can use any kind of algorithmic controls to place any sound on any channel simply by routing it via Out.ar(n,signal), where n is an integer from 0-15.
*/
(
/// basic setup
s = Server.local.boot;

s.doWhenBooted({
	SynthDef( \nicepoc, { |out=0,freq=440,amp=0.1,dur=0.3|
		Out.ar( out, SinOsc.ar( freq, mul: amp )*EnvGen.kr( Env.perc(0.05,1), timeScale: dur, doneAction:2 ) )
	}).add;
});

)

// mono, 1 channel:
(
Pdef(\multiMono,Pbind(
	 \instrument, \nicepoc,
	\degree, Pseq([0, [3,4], 5, 6, [7,7.5]],inf),
	\dur, Pdefn(\myDur,0.4),
	\out,Pdefn(\myOut,0)
))
)
Pdef(\multiMono).play
Pdef(\multiMono).stop
Pdefn(\myOut,4.rand.postln)
Pdefn(\myDur,0.1)

// multiple mono:
// the melody gets played on both channels, the second note in the pattern differs,
// so when listening to it, the space "spreads" out
(
Pdef(\multiStereo,
	Pbind(
		\degree, Pseq([0, [3,4], 5, 6, [7,7.5]],inf),
     \dur, Pdefn(\myDur,0.4),
		\out,Pfunc({|ev| if( ev[\degree].size>1,
			{Array.fill(2,{4.rand})},0 )}),
     \instrument, \nicepoc
))
)
Pdef(\multiStereo).play
Pdef(\multiStereo).stop
Pdef(\multiStereo).set(\tempo,1)

(
Pdef(\multiQuad,
	Pbind(
		\degree, Pseq([0, 3, 5, 6, 7],inf),
		\dur, Pdefn(\myDur,0.4),
		\out,Pdef(\myOut,Pseq([0,1,2,3],inf)),
     \instrument, \nicepoc
))
)
Pdef(\multiQuad).play
Pdef(\multiQuad).stop
Pdef(\multiQuad).set(\tempo,2)

// Use Envelopes to control mono signals in multichannel array
(
Ndef(\multiEnvQuad,{|t1=1,t2=1.2,t3=1.5,t4=2|
	var env = Env.circle([0,1,0],[1,1],[2,-2],2,1);
	var envgen = EnvGen.kr(env,timeScale:[t1,t2,t3,t4])*0.1;
	LFPar.ar([110,220,330,440],0,envgen)
})
)
Ndef(\multiEnvQuad).play
Ndef(\multiEnvQuad).set(\t1,0.1);
Ndef(\multiEnvQuad).set(\t2,0.11);
Ndef(\multiEnvQuad).set(\t3,0.12);
Ndef(\multiEnvQuad).set(\t4,0.13);
Ndef(\multiEnvQuad).end


// Panning -- moving sound smoothly between two or more speakers

// the perceived loudness of a sound played on a single speaker is greater than the perceived loudness of the same sound played at half the original amplitude on two speakers simultaneously.

// LinPan2 -- (in, pos: 0, level: 1)
play({ LinPan2.ar(PinkNoise.ar(0.4), FSinOsc.kr(0.1)) });

//  Because a signal's apparent power is proportional to the signal squared, this is called a constant power pan-rule -- the fade-in resembles the first quarter period of a sine function and the fade out resembles the first quarter period of a cosine function

// Pan2 -- equal apparent power (in, pos: 0, level: 1)
play({ Pan2.ar(PinkNoise.ar(0.4), FSinOsc.kr(0.1)) });

// Pan4 *ar (in, xpos: 0, ypos: 0, level: 1)
// a quadraphonic  panner which pans between left-right (xpos argument)  and front-back (ypos argument) -- Use this to place a sound in a rectangular listening space with the same stereo image from the back as in the front -- front-back control sets desired balance of power of front to back

play({ Pan4.ar(PinkNoise.ar(0.4), FSinOsc.kr(0.1), MouseY.kr(1,-1)) });

// Balance2 *ar (left, right, pos: 0, level: 1)
// fade left sig with negative 'pos', fade right sig with positive 'pos'
{Balance2.ar(LFSaw.ar(44),Pulse.ar(33),MouseX.kr(-1,1), 0.1) }.play;

// Rotate2
(
{
    // rotation via lfo or MouseX
    var x, y;
    x = WhiteNoise.ar(0.05);
    y = LFTri.ar(800) * LFPulse.kr(3,0,0.3,0.1);
	#x, y = Rotate2.ar(x, y, LFSaw.kr(MouseX.kr(0.01,10,1)));
    // #x, y = Rotate2.ar(x, y, MouseX.kr(0,2));
    [x,y]
}.play;
)

/*
Azimuth Panning - PanAz enables any panning around the perimeter of any number of speakers and control over the width of the panning envelope --

PanAz.ar (numChans, in, pos: 0, level: 1, width: 2, orientation: 0.5)

width = The width of the panning envelope. Nominally this is 2.0 which pans between pairs of adjacent speakers. Width values greater than two will spread the pan over greater numbers of speakers. Width values less than one will leave silent gaps between speakers.
*/

(  // PanAz  assumes equal angles of the speakers
Ndef(\panAz_test,
	{|dir=1,width=2,orientation=0.5|
    var p = PinkNoise.ar; // source

	PanAz.ar(4,p, LFSaw.kr(MouseX.kr(0.1,10,1)*dir),0.1,width,orientation);
});
)
Ndef(\panAz_test).play
Ndef(\panAz_test).set(\dir,-1)
Ndef(\panAz_test).set(\width,1)
Ndef(\panAz_test).stop   // stop monitoring
Ndef(\panAz_test).isPlaying  // still playing, but not monitored
Ndef(\panAz_test).end    // stop playing and release synth
Ndef(\panAz_test).isPlaying // now it's not playing
Ndef.clear // clear all Ndefs

// Ambisonic B-format

//In first-order Ambisonics, sound information is encoded into four channels: W, X, Y and Z. This is called Ambisonic B-format. The W channel is the non-directional mono component of the signal, corresponding to the output of an omnidirectional microphone. The X, Y and Z channels are the directional components in three dimensions. They correspond to the outputs of three figure-of-eight microphones, facing forward, to the left, and upward respectively.

(  // PanB  assumes equal angles and distances of the speakers
Ndef(\panB2_test,{
    var w, x, y, p, a, b, c, d;
    p = PinkNoise.ar; // source
    // B-format encode
   // #w, x, y = PanB2.ar(p, MouseX.kr(-1,1), 0.1);
	#w, x, y = PanB2.ar(p, LFSaw.kr(MouseX.kr(0.1,10,1),1), 0.1);
    // B-format decode to quad
    #a, b, c, d = DecodeB2.ar(4, w, x, y);

    [a, b, d, c] // reorder to my speaker arrangement: Lf Rf Lr Rr
});
)
Ndef(\panB2_test).play
Ndef(\panB2_test).stop
Ndef(\panB2_test).end
Ndef.clear

/*
PanB2  encodes mono signal to 2D ambisonic B-format
Pan2B (in, azimuth: 0, gain: 1)
azimuth	= Position around the circle from -1 to +1. -1 is behind, -0.5 is left, 0 is forward, +0.5 is right, +1 is behind.

Rotate2 -- rotates an ambisonic B-format sound field around an axis
*ar (x, y, pos: 0) x and y are the 2D of ambisonic signal
pos = angle to rotate around the circle from -1 to +1. -1 is 180 degrees
*/

(
Ndef(\rotate,{
    var w, x, y, p, q, a, b, c, d;
    p = WhiteNoise.ar(0.05); // source
    q = LFSaw.ar(200,0,0.03)+LFSaw.ar(200.37,0,0.03)+LFSaw.ar(201,0,0.03);
    // B-format encode 2 signals at opposite sides of the circle
    #w, x, y = PanB2.ar(p, -0.5) + PanB2.ar(q, 0.5);
//    #x, y = Rotate2.ar(x, y, MouseX.kr(-1,1));
	#x, y = Rotate2.ar(x, y, LFSaw.kr(0.2,pi));
    // B-format decode to quad
    #a, b, c, d = DecodeB2.ar(4, w, x, y);
    [a, b, d, c] // reorder to my speaker arrangement: Lf Rf Lr Rr
});
)
Ndef(\rotate).play
Ndef(\rotate).end

/*
The BFEncode1 and BFDecode1 classes used below are Josh_UGens.  They are extensions to SuperCollider that include new SC Classes and new Server ugens in the form of binary files called 'plug-ins', written in C++.  They have informative help-files but are in the old html format, so you need to open them manually in a browser rather than here.  I've uploaded them to the class website under 'code'.  Download, uncompress, and move the folder into your Extensions folder (you may need to create this if you haven't dont that yet) here:
"/Users/yourName/Library/Application Support/Supercollider/Extensions/"

Then recompile SuperCollider and you'll be able to run the code below.  BFEncode1 and BFDecode1 enable 3D ambisonics that includes spatialization of elevation and distance, as well as azimuth.

BFDecode1.ar(w, x, y, z, azimuth, elevation, wComp)
w, x, y, z - the B-format signals. All of these MUST be audio rate signals.
azimuth - the angle from 0pi front and center of the speaker.  Can be an array of angles.
elevation - the angle from 0pi center of the speaker.  Can be an array of angles.
wComp - chooses how the W channels is scaled. If 0, a scaler of 0.707 is used. If 1, W is varied according to the scaling of the X, Y and Z channels. 1 is the default.
*/

( // this one is for stereo or quad, with no elevation
Ndef(\ambiNoise, {|spd=0.2|
	var src, w, x, y, z, a, b, c, d;
	var azArray,elArray,rho; // array gives speaker azimuth and elevation positions in angles, size of Array must equal number of speakers
	var elev=0; //  0 if speakers are on same plane
	// azArray = [0.5pi,-0.5pi]; // azimuth for 2 XY channels
	azArray = [-0.25pi, 0.25pi, 0.75pi, 1.25pi]; // ex. azimuth for 4 channels
	// elArray = [0,0];  // elevation for two channels
	elArray = [0,0,0,0]*0.5pi;  // elev for 4 chans, vals should range from -0.25 to 0.25
	rho = MouseY.kr(0,2);
	src = PinkNoise.ar(0.5) * LFSaw.kr(8, pi, -0.2, 0.2); // source

	// encode sig into ambisonic channels
	// BFEncode1.ar(in, azimuth, elevation, rho, gain, wComp)
	#w,x,y,z = BFEncode1.ar(src,LFSaw.kr(spd,Rand(0,2))*pi,elev,rho);

	//decode ambisonics into speaker channels
	// BFDecode1.ar(w, x, y, z, azimuth, elevation, wComp)
	#a, b, c, d = BFDecode1.ar(w, x, y, z, azArray, elArray);
	[a,b,d,c]  // reorder the rear speakers
});
)
Ndef(\ambiNoise).play
Ndef(\ambiNoise).stop
Ndef(\ambiNoise).end
Ndef.clear


/* next version uses BFEncode2.ar and BFDecode1.ar1, which allow azimuth  placements of sound at any X-Y position within the speaker matrix, ausing X-Y distances in meters from the center, or 'rho' array in the calculation

BFEncode2.ar(in, point_x, point_y, elevation, gain)

point_x - a point in the x axis
point_y - a point in the y axis
elevation -  in radians, -0.5pi to +0.5pi
gain - a control rate level input.
wComp - scaling of w channel: If 0, 0.707 is used; if 1, W is varied according to the scaling of the X, Y and Z channels. 1 is default.

x, y positions-
	0 -1 behind
	0 1 in front
	-1 0 right
	1 0 left

BFDecode1.ar1(w, x, y, z, azimuth, elevation, maxDist, distance)
azimuth and elevation -- as before
maxDist - the distance (in meters) to the furthest speaker from center - (this allocates the delay size)
distance - the distance (in meters) to each speaker.

*/
(
Ndef(\ambiNoise2, {
    var src, w, x, y, z;
	var azArray,elArray; // array gives speaker azimuth and elevation positions in angles, size of Array must equal number of speakers
	var elev=0;  // no point changing unless you have elevated speakers!
	// azArray = [0.5pi,-0.5pi]; // azimuth for 2 XY channels
	 azArray = [-0.25pi, 0.25pi, 0.75pi, 1.25pi]; // azimuth for 4 channels arranged in a square
	// elArray = [0,0];  // elevation for two channels
	 elArray = [0,0,0,0];  // elevation for 4 channels
    src = PinkNoise.ar(1) * LFSaw.kr(8, pi, -0.2, 0.2); // source
	// encode sig into ambisonic channels
	#w, x, y, z = BFEncode2.ar(src,
		MouseX.kr(-1,1),MouseY.kr(1,-1),elev*0.5pi);
	//decode ambisonics into speaker channels
    BFDecode1.ar1(w, x, y, z, azArray, elArray)
});
)
Ndef(\ambiNoise2).play
Ndef(\ambiNoise2).end

// ambisonic encode data for litttlefield sound system (3 not used)
azArray = [-0.454,0.454,0,0,-1.047,1.047,-2.39,2.39] // angles
elArray = [0.088,0.088,0,1.22,0.35,0.35,0.524,0.524] // elev
maxDist = 25;
rhoArray = [1,1,0,0,0.56,0.5,0.8,0.8] // rho (distance)
(
Ndef(\littlefield,{|spd=0.2,maxDist=25|
    var src, w, x, y, z;
	var azArray,elArray,rhoArray; // array gives speaker azimuth and elevation positions in angles, size of Array must equal number of speakers
	var elev=MouseY.kr(-0.25,0.25);
	var rho=MouseX.kr(0,1);
	azArray = [-0.454,0.454,0,0,-1.047,1.047,-2.39,2.39];
	elArray = [0.088,0.088,0,1.22,0.35,0.35,0.524,0.524];
	rhoArray = [1,1,0,0,0.56,0.5,0.8,0.8];
    src = PinkNoise.ar(1) * LFSaw.kr(8, pi, -0.2, 0.2); // source
	// encode sig into ambisonic channels
	#w, x, y, z = BFEncode1.ar(src,
		LFSaw.kr(spd,Rand(0,2))*pi,elev*pi);
	//decode ambisonics into speaker channels
    BFDecode1.ar1(w, x, y, z,
		azArray, elArray,maxDist,rhoArray*maxDist)
});
)
Ndef(\littlefield).play;
Ndef(\littlefield).end;

({
	var w, x, y, z, p;
	p = PinkNoise.ar(1) * LFSaw.kr(2, pi, -0.2, 0.2); // source
	// B-format encode
	#w, x, y, z = BFEncode1.ar(p, MouseX.kr(-0.5pi, 0.5pi), 0, 1);
	// B-format decode to stereo with speakers at different distances
	BFDecode1.ar1(w, x, y, z, [-0.25pi, 0.25pi], 0, 10, [MouseY.kr(5, 10), 10]);
}.play;

// ambisonic encode data for 5.1
azArray = [-0.166,0,0.166,-0.611,0.611]
elArray = 0;
rhoArray = 1;



)
// PHASE DECORRELATION, GRANULATION, DIFFUSION

(
b = Buffer.alloc(s,2048,1);
c = Buffer.read(s,"sounds/a11wlk01.wav");
d = Buffer.alloc(s,2048,1);
)

(
//make stereo from mono
// MouseX triggers decorrelation
x = SynthDef("PV_DecorrelateStereo", { arg out=0, bufnum=0, bufnum2, soundBufnum=2;
 var in, chain, chain2;
 in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 1);
 chain = FFT(bufnum, in);
 chain2 = PV_Copy(chain, bufnum2);
// Adds a different constant random phase shift to each bin. When triggered, it selects a new set of random phases.
 chain = PV_Diffuser([chain, chain2], MouseX.kr > 0.5);
// auto triggered changes
//chain = PV_Diffuser([chain,chain2],Impulse.kr(MouseX.kr(0.1,20,1)));
 Out.ar(out, 0.5 * IFFT(chain));
}).play(s,[\out, 0, \bufnum, b, \bufnum2, d, \soundBufnum, c]);
)

x.free; [b, c, d].do(_.free);

// granulation

(
b = Buffer.read(s, "sounds/a11wlk01.wav");
SynthDef("grain",{ arg i_out=0, i_sampbufnum, dur = 0.05,
 pointer, offset = 0.005, amp = 1.0, loop = 1;
 var thisStart, thisDur, grain;
 thisStart = pointer + IRand(0, offset); // adds random time offset
 grain = EnvGen.ar(Env.sine, 1.0, amp, 0.0, dur, 2)
  * PlayBuf.ar(1,i_sampbufnum, BufRateScale.ir(i_sampbufnum),
   1, thisStart,loop);
 OffsetOut.ar(i_out,grain); // use OffsetOut for precise sub-block timing
}).send(s);
)

(
x = {
var numGrains = 32; // approximate number of simultaneous grains
var numChannels = 4; // adjust for your setup
var dur = 0.05, durRand = 0.05, thisDur;
var start, now;
var numGrainsRecip;
numGrainsRecip = numGrains.reciprocal; // save some divides by converting to reciprocal

start = Main.elapsedTime;
loop({
 now = Main.elapsedTime - start;
 thisDur = dur + durRand.rand;
 s.bind({Synth("grain", [i_out: numChannels.rand, i_sampbufnum: b, dur: thisDur,
  pointer: now * b.sampleRate, amp: numGrainsRecip]);
 }); // send as a bundle for precise sub-block timing
 (thisDur * numGrainsRecip).wait;
})
}.fork;
)

x.stop; b.free;

// spectral diffusion
(
n = 512; // number of bins
b = Buffer.alloc(s, n, 1);
c = Buffer.alloc(s, n, 1);

// create arrays of magnitude scalars and load them to buffers
d = Array.fill(n, {1.0.linrand});
e = 1.0 - d;
d = Buffer.loadCollection(s, d);
e = Buffer.loadCollection(s, e);

f = Buffer.read(s,"sounds/a11wlk01.wav");
)

(
x = SynthDef("spectral diffusion", { arg out=0, analBuf, analBufCopy, scalBuf1, scalBuf2, soundBuf;
 var chain1, chain2;
 chain1 = FFT(analBuf,
	PlayBuf.ar(1, soundBuf, BufRateScale.kr(soundBuf), loop: 1));
 chain2 = PV_Copy(chain1, analBufCopy); // copy the initial analysis
 chain1 = PV_MagMul(chain1, scalBuf1);
 chain2 = PV_MagMul(chain2, scalBuf2);
 Out.ar(out,  0.5 * IFFT([chain1, chain2]));
}).play(s,[out: 0, analBuf: b, analBufCopy: c, scalBuf1: d, scalBuf2: e, soundBuf: f]);
)

// execute this multiple times to change the distribution
(
g = Array.fill(n, {1.0.linrand});
h = 1 - g;
d.loadCollection(g);
e.loadCollection(h);
)

x.free; [b, c, d, e, f].do(_.free);
