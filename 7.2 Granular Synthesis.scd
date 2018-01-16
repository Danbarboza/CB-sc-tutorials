// Granular Synthesis

// In Granular Synthesis sounds are modelled out of microscopic particles of sound, short grains in the region of 10-100 milliseconds long.  There are lots of choices for these grains, they might be enveloped sine tones, or tiny extracts of sampled sound:

(
s = Server.local.boot;
s.scope(2);
)

p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
b = Buffer.read(s,p);

//three different possible grains
(
{
var singrain1, singrain2, sfgrain;
singrain1=SinOsc.ar(440,0,XLine.kr(1.0, 0.0001, 0.05));
singrain2=FSinOsc.ar(800, 0.0, Line.kr(1.0,0,0.05).squared);
sfgrain=(PlayBuf.ar(1,b.bufnum, BufRateScale.kr(b.bufnum)))*EnvGen.kr(Env([0,1,1,0],[0.01,0.01,0.01], -4));

[singrain1,singrain2,sfgrain]
}.plot(0.1,s)
)

// When lots of these microsounds are combined into big swarms, we can make macroscopic soundscapes.  How would we control a swarm? Via the scheduling we introduced previously ...

//simple sine grain synthdef - note the all important doneAction
(
SynthDef(\sinegrain, {arg pan, freq, amp;
	var grain= SinOsc.ar(freq, 0, amp)*(XLine.kr(1.001,0.001,0.1, doneAction:2)-0.001);
	Out.ar(0,Pan2.ar(grain, pan))
}).add;
)

//listen to a single grain;
Synth(\sinegrain,[\freq,rrand(100,10000),\amp, exprand(0.05,0.1), \pan, 1.0.rand2]);

//schedule 100 random grains over 1 second
(
{
100.do{arg i;
	Synth(\sinegrain,[\freq,rrand(100,10000),\amp, exprand(0.05,0.1), \pan, 1.0.rand2]);
	0.01.wait
};
}.fork
)

// Over time, we can change the characteristics of the swarm, for example, playing with its density, and control individual parameters of grains within tendency masks or following certain paths

//schedule 200 random grains over time, decreasing the range of allowed random frequencies and lowering the density over time
(
{
	200.do{arg i;
		var timeprop = (i/199.0)**3;
		Synth(\sinegrain,[\freq,exprand(100,5000-(20*i)),
			\amp, exprand(0.05,0.1), \pan, 1.0.rand2]
		);

		rrand((timeprop*0.1).max(0.01),timeprop*0.3).wait
	};
}.fork
)

//simple playbuf grain synthdef - note the all important doneAction
(
SynthDef(\sfgrain, {arg bufnum=0, pan=0.0, startPos=0.0, amp=0.1, dur=0.04;
	var grain= PlayBuf.ar(1,bufnum, BufRateScale.kr(bufnum),1,
		BufFrames.ir(bufnum)*startPos,0)
	*(EnvGen.kr(Env.perc(0.01,dur),doneAction:2)-0.001);
	Out.ar(0,Pan2.ar(grain, pan))}).add;
)

//individual grain
Synth(\sfgrain,[\bufnum, b.bufnum, \startPos,rrand(0.0,1.0),\amp, exprand(0.005,0.1), \pan, 1.0.rand2]);

//schedule 200 random soundfile playback grains over time, with random offset positions into the soundfile and lowering the density over time
(
{
	200.do{arg i;
		var timeprop = (i/199.0)**3;
		Synth(\sfgrain,[\bufnum, b.bufnum, \startPos,rrand(0.0,timeprop),\amp, exprand(0.005,0.1), \pan, 1.0.rand2]);
		rrand((timeprop*0.1).max(0.01),timeprop*0.4).wait
	};
}.fork
)

// Each grain might have many different parameters attached to it; some salient ones might be the pitch, the duration of the envelope, the pan position in the stereo field or the amplitude. The overall cloud can also have some sort of distribution for these parameters, which might lead to a tendency mask determining the range of frequencies of the particles allowed at differnet points in time, or control of the evolving density of the cloud.  The composer's work is to both specify the grains, and also control how they are used over time to make an interesting compositional structure.  These techniques were first conceptualised and explored in instrumental and electronic music by Iannis Xenakis (late 50s), and further investigated in computer implementation, notably by Curtis Roads and Barry Truax, from the early 1970s on. Real-time systems became plausible in the 1980s.  Because you can take tiny slices of sound, granular processing allows one to perform quite dramatic transformations on sound sources. The sound can be made to disappear into a stream of tiny quanta and reappear, coalescing out of distinct particles:

(
var w, slid, lastval;
lastval=0.0;

w= Window("My Window", Rect(100,500,200,200));
//A 200 by 200 window appears at screen co-ordinates (100, 500)
slid= Slider(w,Rect(10,10,150,40)); //a basic slider object
slid.action_({lastval= slid.value;}); //this function is called whenever you move the slider

{
	inf.do{arg i;
		var prop, timestart, timeend;
		prop= (i%300)/300;  // outputs 0 - 1, over 300 iterations of the loop
		timestart= prop*0.8;
		timeend= prop*(0.8+(0.1*lastval));

		Synth(\sfgrain,[\bufnum, b.bufnum, \startPos,rrand(timestart,timeend),
			\amp, exprand(0.005,0.1), \pan, lastval.rand2, \dur, 0.1+(lastval*0.5)]);
		//max in this to avoid ever going near 0.0 wait time, which would crash the computer!
		(((lastval*0.2)+0.01).max(0.01)).wait
	};
}.fork;

w.front;
)



// more SynthDefs that produce single grains
(
SynthDef("granSin",{ arg freq=400, dur=0.01,pan=0,amp=0.1;
	var env, dir, saw, start;
	env = Env.sine(dur);
	Out.ar(0,
		EnvGen.ar(env,doneAction: 2,timeScale: dur.max(0.00025))*
		Pan2.ar(SinOsc.ar(freq,0,amp),pan))
}).store;

SynthDef("granNse",{ arg freq=400, dur=0.01,pan=0,amp=0.1;
	var env, dir, saw, start;
	env = Env.sine(dur);
	Out.ar(0,
		EnvGen.ar(env,doneAction: 2,timeScale: dur.max(0.00025))*
		Pan2.ar(Ringz.ar(
				WhiteNoise.ar(amp*0.1),
				freq,0.01),
			pan))
}).store;

SynthDef("granKlnk",{ arg freq=400, dur=0.01,pan=0,amp=0.1;
	var env, dir, saw, start;
	env = Env.sine(dur);
	Out.ar(0,
		EnvGen.ar(env,doneAction: 2,timeScale: dur.max(0.00025))*
		Pan2.ar(Mix(
			Ringz.ar(
				Decay.ar(Impulse.ar(dur.reciprocal),0.03,
						ClipNoise.ar(amp*0.1)),
				[freq,freq*1.5,freq*2.7,freq*5.9],dur)),
			pan))
}).store;
)

// here's an interface for creating granular streams using the above synths
(
var gobutt,gotext,synthbutt,synthtext,
durtext,durslide,freqtext,freqslide,panslide,pantext,
ampslide,amptext,densslide,denstext,cfreq=400,frqRng=100,dur, cdur=0.1,durRng=0.025,cpan=0,panRng=1,camp=0.1,ampRng=0.1,
density=1,densRng=4,densSpec,shortest=0.005,synth=\granSin;

r = Routine({
	var dur;
	loop({
		dur = (cdur+rrand(durRng.neg,durRng)).max(shortest);
		Synth(synth,
			[\freq,cfreq+rrand(frqRng.neg,frqRng),
				\dur,dur,
				\pan,cpan+rrand(panRng.neg,panRng).max(-1.0),
				\amp,camp+rrand(ampRng.neg,ampRng)]);
		(dur/(density+rrand((densRng*0.125).neg,densRng)))
						.max(shortest*0.1).wait
	})
});

w = Window("cloudGen", Rect(100, 500, 300, 425)).onClose_({ r.stop });
w.front;
//	GUI to set start and stop the granulator
gotext = StaticText(w, Rect(210,5, 70,20));
	gotext.font = Font("Helvetica", 10);
	gotext.stringColor = Color.blue;
	gotext.align = \center;
	gotext.string = "granulator";
	gobutt = Button(w, Rect(210,30, 60, 20));
	gobutt.states = [
		["GO!", Color.black, Color.new(0.0, 0.5, 0.9)],
		["stop!", Color.white, Color.new(0.8, 0.5, 0.9)],
		];
	gobutt.action = { arg view;
		if (gobutt.value == 1, { r.reset; r.play(SystemClock) },{ r.stop })
	};

synthtext = StaticText(w, Rect(20,5, 70,20));
	synthtext.font = Font("Helvetica", 10);
	synthtext.stringColor = Color.blue;
	synthtext.align = \center;
	synthtext.string = "synth";
	synthbutt = Button(w, Rect(20,30, 60, 20));
	synthbutt.states = [
		["sine", Color.black, Color.red],
		["noise", Color.black, Color.red],
		["klank", Color.black, Color.red]
		];
	synthbutt.action = { arg view;
		switch(synthbutt.value,
		0,{synth=\granSin},1,{synth=\granNse},2,{synth=\granKlnk})
	};

durtext = StaticText(w, Rect(10,120, 90,20));
	durtext.font = Font("Helvetica", 10);
	durtext.stringColor = Color.blue;
	durtext.align = \left;
	durtext.string = "grain duration";

durslide = RangeSlider(w, Rect(10,145, 280,20));
	durslide.lo = 0.025;
	durslide.hi = 0.125;
	durslide.action = { arg slider;
		cdur =  (((durslide.hi - durslide.lo)*0.5)+durslide.lo).max(shortest);
		durRng = cdur-durslide.lo;
		durRng.postln;
	};
freqtext = StaticText(w, Rect(10,180, 90,20));
	freqtext.font = Font("Helvetica", 10);
	freqtext.stringColor = Color.blue;
	freqtext.align = \left;
	freqtext.string = "freq variance";
freqslide = RangeSlider(w, Rect(10,205, 280,20));
	freqslide.lo = 0.4;
	freqslide.hi = 0.6;
	freqslide.action = { arg slider;
		cfreq =  \freq.asSpec
			.map(((freqslide.hi - freqslide.lo)*0.5)+freqslide.lo);
		frqRng = cfreq-\freq.asSpec.map(freqslide.lo);
	};
pantext = StaticText(w, Rect(10,240, 90,20));
	pantext.font = Font("Helvetica", 10);
	pantext.stringColor = Color.blue;
	pantext.align = \left;
	pantext.string = "stereo variance";

panslide = RangeSlider(w, Rect(10,265, 280,20));
	panslide.lo = -1.0;
	panslide.hi = 1.0;
	panslide.action = { arg slider;
		cpan = \pan.asSpec
			.map(((panslide.hi - panslide.lo)*0.5)+panslide.lo);
		panRng = cpan-\pan.asSpec.map(panslide.lo);
	};

amptext = StaticText(w, Rect(10,300, 90,20));
	amptext.font = Font("Helvetica", 10);
	amptext.stringColor = Color.blue;
	amptext.align = \left;
	amptext.string = "amp variance";

ampslide = RangeSlider(w, Rect(10,325, 280,20));
	ampslide.lo = 0.1;
	ampslide.hi = 0.3;
	ampslide.action = { arg slider;
		camp = \amp.asSpec.map(((ampslide.hi - ampslide.lo)*0.5)+ampslide.lo);
		ampRng = camp-(\amp.asSpec.map(ampslide.lo));
	};

densSpec = [0.1,10,'lin',0,1].asSpec;
denstext = StaticText(w, Rect(10,360, 90,20));
	denstext.font = Font("Helvetica", 10);
	denstext.stringColor = Color.blue;
	denstext.align = \left;
	denstext.string = "dens variance";

densslide = RangeSlider(w, Rect(10,385, 280,20));
	densslide.lo = 0.1;
	densslide.hi = 0.3;
	densslide.action = { arg slider;
		density = densSpec.map(((densslide.hi - densslide.lo)*0.5)+densslide.lo);
		densRng = density-densSpec.map(densslide.lo);
	};
)

 /* the following sample granulator is by Brad Garton, who teaches at Columbia Univ.
The idea is the same as for the last granulator, but ALL of the granulation parameters are chosen stochastically from limits set from the RangeSlider GUI
*/
(
var s, w, b, c, nchans, nframes, buf, buftext, bufenter, soundbutt, soundtext, gotext, gobutt,
										// GUI items to control
	rateslide, ratetext, ratelo, ratehi,	//  rate of grain generation
	durslide, durtext, durlo, durhi,		// duration of grain
	pchslide, pchtext, pchlo, pchhi,	// pitch of grain
	posslide, postext, poslo, poshi,		// current position in file
	locslide, loctext, loclo, lochi, locspread,	// spatial position
	speedslide, speedtext, speed;		// scan speed

s = Server.local;
if (s.serverRunning == false, { s.boot; });

// two SynthDefs, one each for mono and stereo soundfiles

SynthDef("plbuf1", { arg trig = 1, start = 0, gdur = 0.05,
		prate = 1.0, pos = 0.5, bno = 0;
	var out, e, amp, c1, c2;
	e = Env.triangle(dur: gdur, level: 1.0);
	amp = EnvGen.ar(e, doneAction: 2);
	out = PlayBuf.ar(1, bno, prate, trig, startPos: start, loop: 0);
	c1 = out*amp*pos;
	c2 = out*amp*(1.0-pos);
	Out.ar(0, [c1, c2]);
	}).load(s);

SynthDef("plbuf2", { arg trig = 1, start = 0, gdur = 0.05,
		prate = 1.0, pos = 0.5, bno = 0;
	var out, e, amp, c1, c2;
	e = Env.triangle(dur: gdur, level: 1.0);
	amp = EnvGen.ar(e, doneAction: 2);
	out = PlayBuf.ar(2, bno, prate, trig, startPos: start, loop: 0);
	c1 = out.at(0)*amp*pos;
	c2 = out.at(1)*amp*(1.0-pos);
	Out.ar(0, [c1, c2]);
	}).load(s);

//	preset the hi and lo limits on random generation of parameters
ratelo = 0.2;
ratehi = 0.21;
durlo = 0.04;
durhi = 0.06;
pchlo = 1.0;
pchhi = 1.0;
poslo = 0.5;
poshi = 0.5;
loclo = 0.1;
lochi = 0.2;
locspread = 0.1;
speed = 0.005;
buf = 0;

w = Window("Cotton Candy!", Rect(100, 500, 300, 425));

// GUI to load your soundFile
soundtext = StaticText(w, Rect(30,5, 60,20));
	soundtext.font = Font("Helvetica", 10);
	soundtext.stringColor = Color.blue;
	soundtext.align = \center;
	soundtext.string = "soundfile";

soundbutt = Button(w, Rect(30,30, 60, 20));
	soundbutt.states = [
		["load", Color.black, Color.new(0.0, 0.5, 0.9)],
		];
	soundbutt.action = { arg view;
		buf = bufenter.value; // get the value of the current buffer
		File.openDialog("hey hey hey", { arg path; var sf;
			sf = SoundFile.new;
			sf.openRead(path);
			nchans = sf.numChannels;
			nframes = sf.numFrames;
			sf.close;
			s.sendMsg("/b_allocRead", buf, path, 0, nframes);
			gobutt.enabled = true;
			});
		};
buftext = StaticText(w, Rect(120,5, 60,20));
	buftext.font = Font("Helvetica", 10);
	buftext.stringColor = Color.blue;
	buftext.align = \center;
	buftext.string = "buffer #";

bufenter = NumberBox(w, Rect(140,30, 20,20));
	bufenter.align = \center;
	bufenter.setProperty(\boxColor, Color.new(0.8, 0.5, 0.9));
	bufenter.value = 0;

//	GUI to set start and stop the granulator
gotext = StaticText(w, Rect(210,5, 70,20));
	gotext.font = Font("Helvetica", 10);
	gotext.stringColor = Color.blue;
	gotext.align = \center;
	gotext.string = "granulatarize...";

	gobutt = Button(w, Rect(210,30, 60, 20));
	gobutt.states = [
		["GO!", Color.black, Color.new(0.0, 0.5, 0.9)],
		["nomore!", Color.white, Color.new(0.8, 0.5, 0.9)],
		];

// the button action triggers the two play Routines
	gobutt.action = { arg view;
		if (gobutt.value == 1, {
//  Routine 'b' generates  Synths
			b = Routine({
			loop ({
				if (nchans == 1, {
					Synth("plbuf1", ["start", rrand(loclo, lochi)*(nframes-												(durhi*(44100*pchhi))),
						"gdur", rrand(durlo, durhi),
						"prate", rrand(pchlo, pchhi),
						"pos", rrand(poslo, poshi),
						"bno", buf]);
				},{
					Synth("plbuf2", ["start", rrand(loclo, lochi)*(nframes-												(durhi*(44100*pchhi))),
					"gdur", rrand(durlo, durhi),
					"prate", rrand(pchlo, pchhi),
					"pos", rrand(poslo, poshi),
					"bno", buf]);
				});
				rrand(ratelo, ratehi).wait;
				})
			}).play;

// Routine 'c' automatically changes the location of playback in the file
// by moving the lochi and loclo variables
			c = Routine({
			loop ({
				0.01.wait;
				loclo = loclo + speed;
				lochi = lochi + speed;
				if (lochi > 1.0, {
					loclo = 0.0;
					lochi = loclo+locspread;
					});
				if (loclo < 0.0, {
					lochi = 1.0;
					loclo = lochi-locspread;
					});
				locslide.setProperty(\lo, loclo);
				locslide.setProperty(\hi, lochi);
				});
			});
			AppClock.play(c);
	/* this Routine is played by the AppClock which must be used when controlling 	things with Cocoa primitives (such as MacOS graphics) .  ' .play' defaults to SystemClock.play, 	which is more accurate, but cannot call Cocoa */
		},{
			b.stop;
			c.stop;
		});
	};
	gobutt.enabled = false;

// the rest is just GUI, which set the parameters for scanning and grain generation

ratetext = StaticText(w, Rect(10,60, 90,20));
	ratetext.font = Font("Helvetica", 10);
	ratetext.stringColor = Color.blue;
	ratetext.align = \left;
	ratetext.string = "grain rate";
// note the RangeSlider, a very useful control for setting ranges for rrand
rateslide = RangeSlider(w, Rect(10,85, 280,20));
	rateslide.lo = ratelo+0.01;
	rateslide.hi = ratehi+0.01;
	rateslide.action = { arg slider;
		ratelo = rateslide.lo+0.0025;
		ratehi = rateslide.hi+0.0025;
		//the "ratelo" multiplier protects a bit against CPU overload
		durlo = (durslide.lo+0.0025)*(ratelo*10.0);
		durhi = (durslide.hi+0.0025)*(ratelo*10.0);
		};
durtext = StaticText(w, Rect(10,120, 90,20));
	durtext.font = Font("Helvetica", 10);
	durtext.stringColor = Color.blue;
	durtext.align = \left;
	durtext.string = "grain duration";

durslide = RangeSlider(w, Rect(10,145, 280,20));
	durslide.lo = durlo+0.01;
	durslide.hi = durhi+0.01;
	durslide.action = { arg slider;
		//the "ratelo" multiplier protects a bit against CPU overload
		durlo = (durslide.lo+0.0025)*(ratelo*10.0);
		durhi = (durslide.hi+0.0025)*(ratelo*10.0);
		};
pchtext = StaticText(w, Rect(10,180, 90,20));
	pchtext.font = Font("Helvetica", 10);
	pchtext.stringColor = Color.blue;
	pchtext.align = \left;
	pchtext.string = "pitch variance";
pchslide = RangeSlider(w, Rect(10,205, 280,20));
	pchslide.lo = pchlo/2.0;
	pchslide.hi = pchhi/2.0;
	pchslide.action = { arg slider;
		pchlo = (pchslide.lo*2.0);
		pchhi = (pchslide.hi*2.0);
		};
postext = StaticText(w, Rect(10,240, 90,20));
	postext.font = Font("Helvetica", 10);
	postext.stringColor = Color.blue;
	postext.align = \left;
	postext.string = "stereo variance";

posslide = RangeSlider(w, Rect(10,265, 280,20));
	posslide.lo = poslo;
	posslide.hi = poshi;
	posslide.action = { arg slider;
		poslo = posslide.lo;
		poshi = posslide.hi;
		};
loctext = StaticText(w, Rect(10,300, 90,20));
	loctext.font = Font("Helvetica", 10);
	loctext.stringColor = Color.blue;
	loctext.align = \left;
	loctext.string = "playback location";

locslide = RangeSlider(w, Rect(10,325, 280,20));
	locslide.lo = loclo;
	locslide.hi = lochi;
	locslide.action = { arg slider;
		loclo = locslide.lo;
		lochi = locslide.hi;
		locspread = lochi-loclo;
		};
speedtext = StaticText(w, Rect(10,360, 90,20));
	speedtext.font = Font("Helvetica", 10);
	speedtext.stringColor = Color.blue;
	speedtext.align = \left;
	speedtext.string = "playback speed";

speedslide = Slider(w, Rect(10,385, 280,20));
	speedslide.value = (speed/0.05)+0.5;
	speedslide.action = { arg slider;
		speed = (speedslide.value-0.5)*0.05;
		};
w.front;
)