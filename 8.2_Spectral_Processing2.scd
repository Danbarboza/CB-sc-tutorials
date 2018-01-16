

// MORE FFT and PV Ugen examples.  These use a SynthDef wrapper class called 'Instr', a Quark found in 'cruciallib', which has a convenient autoGUI functionality.  Sliders are created for each argument, and the array that follows the synth function contains ControlSpec parameters that apply to each argument, listed in the same order as they appear as args

(	// allocate Buffers for performing FFTs
(
s = Server.local.waitForBoot({
	s.scope(2);
	b = Buffer.alloc(s,2048,1);
	c = Buffer.alloc(s,2048,1);
})
)

( // pass only bins above magnitude threshold
Instr("magAbove", { arg cfreq=80, threshold=48, amp=0.2;
	var in, chain;
	in = WhiteNoise.ar(amp);
//	in = Pulse.ar(cfreq,0.1,amp);
	chain = FFT(b.bufnum, in);
	chain = PV_MagAbove(chain, threshold); 	IFFT(chain);
},#[ \freq, [0,100] ]).test;
)

(
 // pass bins below mag threshold
Instr("magBelow",{ arg cfreq=200,threshold=100, amp=0.2;
	var in, chain;
	in = WhiteNoise.ar(amp);
//	in = Pulse.ar(cfreq,0.1,amp);
	chain = FFT(b.bufnum, in);
	chain = PV_MagBelow(chain, threshold); 	IFFT(chain);
},#[ \freq, [0,100] ]).test;
)

(	//	PV_MagClip .. limit magnitudes to a threshold,
Instr("magClip",{ arg threshold=10, amp=0.5;
	var in;
//	in = SoundIn.ar(0,amp);
	in = SinOsc.ar(400,0,amp);
	IFFT(
		PV_MagClip(
			FFT(b.bufnum, in),
			threshold
		);
	)
},#[ [0,100],[0,4]]).test;
)

(	// PV_MagMul -- multiply magnitudes of two signals
Instr("ringFFT",{ arg freq=440, modDepth=0.1, amp=0.5;
	var input1, input2, mousex, fft1, fft2,  ring;
	input1 = WhiteNoise.ar(0.1);
	input2 = SinOsc.ar(freq,0,modDepth);
	fft1 = FFT(b.bufnum, input1);
	fft2 = FFT(c.bufnum, input2);
	ring = PV_MagMul(fft1, fft2);
	IFFT(ring)*amp;
}).test;
)

( // with spectral processing, you can have a "brickwall filter"
Instr("brickWall", { arg cfreq=200, wipe=0.1;
	var in, chain;
	in = WhiteNoise.ar(0.2);
//	in = Pulse.ar(cfreq,0.1,0.5);
	chain = FFT(b.bufnum, in);
	// wipe = 0, allpass; wipe > 0 = hi pass; wipe < 0 = lo pass
	chain = PV_BrickWall(chain, wipe); 	0.5 * IFFT(chain);
},#[ \freq,[-1,1]  ]).test;
)

(	// brickWall filters an FM voice
Instr("osc-BrickWall", { arg cfreq=800, mfreq=100, 	threshold=0.1;		// threshold in bins
	var in, chain;
	in = SinOsc.ar(
		SinOsc.kr(
			// mod oscillator is itself modulated by LFO
			SinOsc.kr(0.08,0,6,6.2).squared,
			0, mfreq,	// modulation range
			cfreq)		// center freq
	);
	chain = FFT(b.bufnum, in);
	// pass freq above threshold
	chain = PV_BrickWall(chain, threshold); 	0.5 * IFFT(chain);
},#[ \freq, \freq  ]).test;
)

( // chooses bins to suppress at random -- wipe 0->1 controls how many are chosen, from none to all, at each trigger
Instr("help-randcomb", { arg tfreq, wipe, nseAmp, plsAmp;
	var in, chain;
	in = Mix([{WhiteNoise.ar(nseAmp)}.dup,
		in = {Pulse.ar(40,0.01,plsAmp)}.dup]);
	chain = FFT(b.bufnum, in);
//	PV_RandComb args =  buffer, wipe, trig;
	chain = PV_RandComb(chain, wipe, Impulse.kr(tfreq));
	0.5*IFFT(chain);
},#[[0.1,20,\exponential]],nil,\amp,\amp).test;
)

( // suppress 'numTeeth' blocks of bins, blocksize= width
Instr("help-rectcomb", { arg numTeeth=8, phsRate=0.2, width=0.5;
	var in, chain;
	in = {WhiteNoise.ar(0.2)}.dup;
//	in = {Pulse.ar(40,0.01,0.5)}.dup;
	chain = FFT(b.bufnum, in);
// PV_RectComb args = buffer, numTeeth, phase, width
 	chain = PV_RectComb(chain, numTeeth, 			LFTri.kr(phsRate,0,0.4,0.5),
 			width
	);
	0.5*IFFT(chain);
},#[[1,32,\linear,1],[0.1,20,\exponential]]).test;
)

( // freeze magnitudes when freeze > 0
Instr("help-magFreeze", { arg freeze=0, freq=400, nspeed=4.6;
	var in, chain;
	in = SinOsc.ar(LFNoise1.kr(nspeed,freq/1.6,freq));
	chain = FFT(b.bufnum, in);
	// moves in and out of freeze
	chain = PV_MagFreeze(chain, freeze );
	0.5 * IFFT(chain);
},#[ [0,1,\linear,1], \freq, \lofreq ]).test;
)

( //	bin smearing: averages n adjacent bins for each side of bin. cpu-expensive for large values of n.

Instr("help-magSmear", { arg freq=100, nbins=0, sinAmp=0.5, plsAmp=0,audioInAmp=0;
	var in, chain;
	in = Mix([SinOsc.ar(freq,0,sinAmp),
		Pulse.ar(freq,0.01,plsAmp),
		SoundIn.ar(0,audioInAmp)]);
	chain = FFT(b.bufnum, in);
// PV_MagSmear(in, n)
	chain = PV_MagSmear(chain, nbins);
	IFFT(chain);
},#[ \freq, [0,64,\linear,1]]).test;
)

//	PV_Diffuser .. adds random values to phases. trig selects new random values.
//	PV_Diffuser(in, trig)
(
Instr("pvDiffuser",{ arg freq,trigSpd;
	IFFT(
		PV_Diffuser(
			FFT(b.bufnum,
				Pulse.ar(freq,0.01)),
			SinOsc.kr(trigSpd)
		);
	);
},#[ \freq, \lofreq ]).test
)

/* 	BinShifting
PV_BinShift args: buffer, stretch = 1.0, shift;
newbin = (shift + oldbin), and stretch original magnitudes proportionally across bins
*/
(
Instr("binShift", { arg freq=100, stretch=1, shift=0.0,
	sinAmp=0.5, plsAmp=0,audioInAmp=0;
	var in, chain;
	in = Mix([SinOsc.ar(freq,0,sinAmp),
		Pulse.ar(freq,0.01,plsAmp),
		SoundIn.ar(0,audioInAmp)]);
	chain = FFT(b.bufnum, in);
	chain = PV_BinShift(chain, stretch, shift);
	0.5 * IFFT(chain);
},#[ \freq, [0.25,4,\linear,0.1], [0,32,\linear,1]]).test;
)

//	file processing/morphing -- first put your own correct sample filepath as an argument to the class 'Sample' in each example

/*	PV_BinWipe .. spectral crossfade between two sounds
(PV_BinWipe(inA, inB, wipe)
as wipe goes from 0 to 1, begin copying in high bins from inB.
as wipe goes from 0 to -1, begin copying in low bins from inB.
*/
( // binShift a sample
Instr("sampBinShift", { arg sample, stretch=1, shift=0.0, rate=1,startPos=0,endPos=1,dir=1,amp=0.5;
	var in, chain, dur;
	dur = ((endPos-startPos).abs*sample.bufDurKr);
	in = PlayBuf.ar(1,sample.bufnumIr,
			sample.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur).min(100)),
			startPos*sample.bufFramesKr,
			endPos*sample.bufFramesKr,1);
	chain = FFT(b.bufnum, in);
	chain = PV_BinShift(chain, stretch, shift);
	amp * IFFT(chain);
},#[ [\sample],[0.1,10,\linear,0.05], [0,64,\linear,1],[0.01,2],nil,nil,[-1,1,\linear,1]]);
p = Patch(\sampBinShift,[Sample("/Sounds/disco/bustaloop")];);
p.gui;
)

(
Instr("sampBinWipe", { arg sample1, sample2, wipe = 0.0, rate=1, startPos=0,endPos=1,dir=1, amp=0.5;
	var in1, in2, chain, chain1, chain2, dur1, dur2, trig;
	dur1 = ((endPos-startPos).abs*sample1.bufDurKr);
	dur2 = ((endPos-startPos).abs*sample2.bufDurKr);
	in1 = PlayBuf.ar(1,sample1.bufnumIr,
			sample1.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur1).min(100)),
			startPos*sample1.bufFramesKr,
			endPos*sample1.bufFramesKr,1);
	chain1 = FFT(b.bufnum, in1);
	in2 = PlayBuf.ar(1,sample2.bufnumIr,
			sample2.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur2).min(100)),
			startPos*sample2.bufFramesKr,
			endPos*sample2.bufFramesKr,1);
	chain2 = FFT(c.bufnum, in2);
	chain = PV_BinWipe(chain1, chain2, wipe);
	amp * IFFT(chain);
},#[ [\sample],[\sample], [-1,1],[0.125,8,\exp],nil,nil,[-1,1,\linear,1]]);
// A Patch specifies an Instr and the inputs that will be passed to the Instr function.
p = Patch(\sampBinWipe,[Sample("/Sounds/manystreams/bali_insects"),
			Sample("/Sounds/bells/belltree1")];);
p.gui;
)

(	// PV_Max .. pass bins with the max magnitude of A and B.
Instr("pvMax", { arg sample1, sample2, rate=1,
	startPos=0,endPos=1,dir=1, amp=0.5;
	var in1, in2, chain, chain1, chain2, dur1, dur2, trig;
	dur1 = ((endPos-startPos).abs*sample1.bufDurKr);
	dur2 = ((endPos-startPos).abs*sample2.bufDurKr);
	in1 = PlayBuf.ar(1,sample1.bufnumIr,
			sample1.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur1).min(100)),
			startPos*sample1.bufFramesKr,
			endPos*sample1.bufFramesKr,1);
	chain1 = FFT(b.bufnum, in1);
	in2 = PlayBuf.ar(1,sample2.bufnumIr,
			sample2.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur2).min(100)),
			startPos*sample2.bufFramesKr,
			endPos*sample2.bufFramesKr,1);
	chain2 = FFT(c.bufnum, in2);
	chain = PV_Max(chain1, chain2);
	amp * IFFT(chain);
},#[ [\sample],[\sample], [0.5,2],nil,nil,[-1,1,\linear,1]]);
p = Patch(\pvMax,[Sample("/Sounds/manystreams/bali_insects"),
			Sample("/Sounds/bells/belltree1")]);
p.gui;
)

(	// PV_Min .. pass bins with the min magnitude of A and B.
Instr("pvMin", { arg sample1, sample2, rate=1,
	startPos=0,endPos=1,dir=1, amp=0.5;
	var in1, in2, chain, chain1, chain2, dur1, dur2, trig;
	dur1 = ((endPos-startPos).abs*sample1.bufDurKr);
	dur2 = ((endPos-startPos).abs*sample2.bufDurKr);
	in1 = PlayBuf.ar(1,sample1.bufnumIr,
			sample1.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur1).min(100)),
			startPos*sample1.bufFramesKr,
			endPos*sample1.bufFramesKr,1);
	chain1 = FFT(b.bufnum, in1);
	in2 = PlayBuf.ar(1,sample2.bufnumIr,
			sample2.bufRateScaleKr*rate*dir,
			Impulse.kr((1/dur2).min(100)),
			startPos*sample2.bufFramesKr,
			endPos*sample2.bufFramesKr,1);
	chain2 = FFT(c.bufnum, in2);
	chain = PV_Min(chain1, chain2);
	amp * IFFT(chain);
},#[ [\sample],[\sample], [0.5,2],nil,nil,[-1,1,\linear,1]]);
p = Patch(\pvMin,[Sample("/Sounds/manystreams/bali_insects"),
			Sample("/Sounds/bells/belltree1")]);
p.gui;
)

