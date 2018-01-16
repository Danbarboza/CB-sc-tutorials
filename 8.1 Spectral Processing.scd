

/*
FFT Processing

The Fast Fourier Transform (FFT) is a central technnology in computer music, allowing an efficient transformation between the time domain (amplitude-time waveforms) and the frequency domain (spectrum, representing the phase and energy of component pure frequencies). Fourier re-synthesis back into the time domain is accomplished by an IFFT (Inverse FFT) or a third party additive synthesis UGens, which enable a variety of useful spectral processing techniques.

PV (Phase Vocoder) UGens are used to operate directly on the FFT spectral data:

input -> FFT -> PV_UGen1 ... PV_UGenN... -> IFFT -> output
*/

// summary of FFT principles is in Bb Readings folder, "Spectral Processing Theory"
// then see helpfile:  [FFT Overview]

(
s = Server.local.waitForBoot({
	s.scope(2);
	b = Buffer.alloc(s,1024,1)}); //a buffer must be allocated which gives the size of the FFT; 1024 sample window size in this case. The hop size is half the window by default.
)
{ Pan2.ar(WhiteNoise.ar,MouseX.kr)}.play
( //	do nothing transformation
{ var in, chain;
	in = WhiteNoise.ar(0.8);
	chain = FFT(b, in);	//go from time domain to frequency domain; note that the UGen does not appear to run at a conventional rate (no .ar or .kr); in actual fact, FFT and PV_UGens are at control rate, but only calculate when there is data to act on; IFFT is at audio rate to produce output samples

	[in,IFFT(chain)];			//convert the data back to the time domain when input chain is a valid buffer number; output is in stereo with the IFFT output on the left and the original input on the right channel for comparison
}.play(s);
)

// example 2 PV UGen example; spectral filtering
// b = Buffer.alloc(s,1024,1);
(
{ var in, chain;
	in = WhiteNoise.ar(0.8);
	chain = FFT(b, in);
//PV_BrickWall acts as a spectral filter, low pass when second argument (wipe) is -1 to 0 and high pass for 0 to 1
	//chain= PV_BrickWall(chain, Line.kr(-1,1,10));
	chain= PV_BrickWall(chain, SinOsc.kr(10.1));
	Pan2.ar(IFFT(chain),0.0)
}.play(s);
)

// example 3 Multiple PV UGens across two chains!

(
// b = Buffer.alloc(s,1024,1);
c = Buffer.alloc(s,1024,1);
d = Buffer.alloc(s,1024,1); //buffer for a copy of spectral data
)

(
{ var in1, in2, chain1, chain2, copychain;
	in1 = Saw.ar(440,0.8);
	in2 = SoundIn.ar(0);
	chain1 = FFT(b, in1);
	chain2 = FFT(c, in2);
	copychain= PV_Copy(chain2, d); //copy of FFT analysis of SoundIn

	chain1 = PV_MagMul(chain1,chain2);	// PV_MagMul multiplies magnitudes of two inputs and keeps the phases of the first
	copychain=PV_MagFreeze(copychain,LFNoise0.kr(10));
	// PV_MagFreeze freezes spectrum, when 'freeze' arg goes above 0
	[0.25*IFFT(chain1),IFFT(copychain)]
}.play(s);
)

//FFT is also used as a first stage in various machine listening UGens:

[PV_HainsworthFoote]  // onset detector
[PV_JensenAndersen]

//example triggering TGrains UGen -- first load a soundfile to be triggered:

*/
(
b = Buffer.alloc(s,1024,1);
Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav", bufnum: 10);
~fftbuf=Buffer.alloc(s,2048,1);  // FFT requires a buffer
)

(
{
	var b = 10, source1, detect;
	source1= SoundIn.ar(0);
	detect= PV_HainsworthFoote.ar(
		FFT(~fftbuf.bufnum,source1),
		1.0, 0.0, 0.7, 0.01);
	TGrains.ar(2, detect, b,
		LFNoise0.kr(10,0.2,1.0),
		MouseX.kr(0,BufDur.kr(b)), MouseY.kr(0.1,0.5),
		LFNoise0.kr(10,1.0), 0.5, 2);
}.play
)

/*
Some third party sources:

Non-realtime analysis using LORIS, SPEAR and ATS

Josh Parmenter's JoshUGens library (a 'quark' extension) has many additional PV_UGens
*/

// you can also operate on spectral data using other UGens
// see PV_ChainUGen, and its method 'pvcollect'
//  The function argument processes each bin of an FFT chain separately: func(mag, phase, index)

(
b = Buffer.alloc(s,1024,1);
c = Buffer.read(s,Platform.resourceDir +/+ "sounds/a11wlk01.wav");
)

(
SynthDef(\notworking,
	{ var in, chain;
		in = PlayBuf.ar(1,c,BufRateScale.kr(c),loop:1);
		chain = FFT(b, in);
		// .pvcollect (numframes, func, frombin: 0, tobin, zeroothers: 0)
		chain= chain.pvcollect(b.numFrames,
			{|mag, phase, index|
				//this function gets called once for every bin
				var noise;
				noise= LFNoise1.kr(rrand(0.5,1.1));
				[noise*mag,noise.range(-pi,pi)]
			},
			frombin:0, tobin:250,zeroothers:1);
		Out.ar(0,Pan2.ar(IFFT(chain),0.0))
}).add;
)
Synth(\notworking)



