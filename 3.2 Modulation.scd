

Modulation Synthesis


// In modulation synthesis one wave, the carrier, is influenced (modulated) by a second, the modulator. Various techniques depend on how the carrier and modulator are plugged together.  Modulation synthesis provides computationally efficient shortcuts to synthesizing complex dynamic spectra. This tutorial also introduces simple GUIs to provide controls for synthesis parameters.  First boot the server using FreqScope, so that we can see the spectral results:

s = FreqScope.server.boot;

// create a new analyzer
FreqScope.new(400, 200, 0);

// Ring Modulation
(
{
var carrier, modulator, carrfreq, modfreq;

carrfreq= MouseX.kr(440,5000,'exponential');
modfreq= MouseY.kr(1,5000,'exponential');

carrier= SinOsc.ar(carrfreq,0,0.5);
modulator= SinOsc.ar(modfreq,0,0.5);

carrier*modulator;
}.play
)

/*
Ring modulation is a simple multiplication of two signals, carrier * modulator.
For simple sine waves, the spectrum ends up with two frequencies (two sidebands), at C+M and C-M, where C is the carrier frequency and M is the modulator frequency. For more complex waves than sines, we get sideband products for each harmonic in the  spectrum of both the carrier and modulator.  But if C and M are harmonic, the sidebands are also harmonic. This follows from the mathematical relation

cos(C)*cos(M) = 0.5*(cos(C-M) + cos(C+M))
*/

/*
FreqScope
Amplitude Modulation (AM)

Using amplitude envelopes, or having a tremolo, are forms of AM.
AM is like ring modulation but with a subtle difference: the modulator is unipolar, that is, always positive.
*/

{SinOsc.ar(440,0,0.5)}.play // ring mod:  bipolar, -0.5 to 0.5

{SinOsc.ar(440,0,0.5,0.5)}.play // amp mod: unipolar, 0 to 1 (0.5 plus or minus 0.5)

/*  The spectrum of amplitude modulation includes the sum and difference frequencies we saw in ring modulation, at C+M and C-M, but also the original carrier frequency C.

The math is now:

cos(C)*(1+cos(M)) = cos(C)+ 0.5*(cos(C-M) + cos(C+M))
*/
(
{
var carrier, modulator, carrfreq, modfreq;

carrfreq= MouseX.kr(440,5000,'exponential');
modfreq= MouseY.kr(1,5000,'exponential');

carrier= SinOsc.ar(carrfreq,0,0.5);
modulator= SinOsc.ar(modfreq,0,0.25, 0.25);

carrier*modulator;
}.play
)

/*
Frequency Modulation (FM)

FM was applied to sound synthesis by John Chowning in 1967, though he published his results in 1973. Yamaha licensed the patents and in 1983 released the Yamaha DX7 synthesiser, which went on to sell 300,000 units, the most commercially successful synthesiser of all time.

You might know the 'slow version' of FM already: a vibrato.

Rather than plugging the modulator into the amplitude of the carrier, we're going to plug the modulator into the carrier frequency. There will be three parameters, the carrier frequency C, the modulation frequency M, and the modulation depth or frequency deviation D.

Because there are three variables we will use a GUI rather than the 2-dimensional mouse.
*/

(
var w, carfreqslider, modfreqslider, moddepthslider, synth;
// define ControlSpecs that scale values of sliders to appropriate ranges
var carrfreqSpec = ControlSpec(20, 5000, 'exponential', 10, 440);
var modfreqSpec = ControlSpec(1, 5000, 'exponential', 1, 1);
var moddepthSpec = ControlSpec(0.01, 5000, 'exponential', 0.01, 0.01);

synth= {arg carrfreq=440, modfreq=1, moddepth=0.01;
	SinOsc.ar(carrfreq + (moddepth*SinOsc.ar(modfreq)),0,0.25)
}.play;

w = Window("FM example").layout_(
	VLayout(
		HLayout(
			carfreqslider=Slider()
			.action_({arg sl; synth.set(\carrfreq, carrfreqSpec.map(sl.value)) }),
			modfreqslider= Slider()
			.action_({arg sl; synth.set(\modfreq, modfreqSpec.map(sl.value)) }),
			moddepthslider= Slider()
			.action_({arg sl; synth.set(\moddepth, moddepthSpec.map(sl.value)) })
))).front.onClose_({ synth.free })
)

/*
In the spectrum now, there are an infinite number of sidebands, but of varying strength. Based on the values we choose for the parameters C, M and D we can make very thick spectrums, or only a light modulation effect. The sidebands turn up at

C + kM where k is any integer, ie. C. C+M, C-M, C+2M, C-2M, ...

By changing the modulation frequency and depth, you can see how the energy in the sidebands is redistributed; the actual formulas for this predicting this use Bessel functions and are outside the scope of this lecture;  see Curtis Roads' The Computer Music Tutorial for a full explanation.

There is a much more musically effective way to control FM, through the modulation index I, defined as:

I= D/M

The ratio of frequency deviation to modulation frequency. If I is small there is little audible FM effect. The higher I is, the stronger the energy in the sidebands.
*/

(
var w, carfreqslider, modfreqslider, modindexslider, synth;
// define ControlSpecs that scale values of sliders to appropriate ranges
var carrfreqSpec = ControlSpec(20, 5000, 'exponential', 10, 440);
var modfreqSpec = ControlSpec(1, 5000, 'exponential', 1, 1);
var modindexSpec = ControlSpec(0.0, 10, 'linear', 0.01, 0.0);

synth= {arg carrfreq=440, modfreq=1, modindex=0;
	SinOsc.ar(carrfreq + (modindex*modfreq*SinOsc.ar(modfreq)),0,0.25)
}.play;

w = Window("FM using modIndex").layout_(
	VLayout(
		HLayout(
			carfreqslider=Slider()
			.action_({arg sl; synth.set(\carrfreq, carrfreqSpec.map(sl.value)) }),
			modfreqslider= Slider()
			.action_({arg sl; synth.set(\modfreq, modfreqSpec.map(sl.value)) }),
			modindexslider= Slider()
			.action_({arg sl; synth.set(\modindex, modindexSpec.map(sl.value)) })
))).front.onClose_({ synth.free })
)


// this is an efficient version via mouse control -- the 'add' arg of the modulator sets the carrier freq!
(
{
var modf, ind;

modf= MouseX.kr(1,440, 'exponential');
ind=MouseY.kr(0.0,10.0);

SinOsc.ar(SinOsc.ar(modf,0,modf*ind, 440),0,0.25)
}.play
)

/*
Phase Modulation

The phase input can also be used do FM -- recall that the  SinOsc arguments are (freq, phase, mul, add).  These examples show a more specific style of placing GUI widgets, which allow us to make use of one called EZSlider, which includes labeling of thje controls and numerical readouts of the slider values.  The 'Rect' class defines the position and shape of the window, and the FlowLayout allows automated placement of the GUIs within the window.  See their help-files to explore this now if you want to
*/
(

var w, carrfreqslider, modfreqslider, moddepthslider, synth;

w=Window("frequency modulation", Rect(100, 400, 400, 300));
w.view.decorator = FlowLayout(w.view.bounds);

synth= {arg carrfreq=440, modfreq=1, moddepth=0.01;
	SinOsc.ar(carrfreq, moddepth*SinOsc.ar(modfreq),0.25)
}.play;

carrfreqslider= EZSlider(w, 300@50, "carrfreq", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|  synth.set(\carrfreq, ez.value)});
w.view.decorator.nextLine;

modfreqslider= EZSlider(w, 300@50, "modfreq", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth.set(\modfreq, ez.value)});
w.view.decorator.nextLine;
moddepthslider= EZSlider(w, 300@50, "moddepth", ControlSpec(0.01, 5000, 'exponential', 0.01, 0.01), {|ez|  synth.set(\moddepth, ez.value)});

w.front;
)

(
var w, carrfreqslider, modfreqslider, modindexslider, synth;

w=Window("FM via mod index", Rect(100, 400, 400, 300));
w.view.decorator = FlowLayout(w.view.bounds);

synth= {arg carrfreq=440, modfreq=1, modindex=0;

SinOsc.ar(carrfreq, modindex*modfreq*SinOsc.ar(modfreq),0.25)
}.play;

carrfreqslider= EZSlider(w, 300@50, "carrfreq", ControlSpec(20, 5000, 'exponential', 10, 440), {|ez|  synth.set(\carrfreq, ez.value)});
w.view.decorator.nextLine;

modfreqslider= EZSlider(w, 300@50, "modfreq", ControlSpec(1, 5000, 'exponential', 1, 1), {|ez|  synth.set(\modfreq, ez.value)});
w.view.decorator.nextLine;
modindexslider= EZSlider(w, 300@50, "modindex", ControlSpec(0.0, 10, 'linear', 0.01, 0.0), {|ez|  synth.set(\modindex, ez.value)});

w.front;
)


//or via mouse control

(
{
var modf, ind;

modf= MouseX.kr(1,440, 'exponential');
ind=MouseY.kr(0.0,10.0);

SinOsc.ar(440, SinOsc.ar(modf,0,modf*ind),0.25)
}.play
)

/*
The rate of change of phase is frequency. So phase modulation is related to frequency modulation.

[PMOsc]	//A dedicated phase modulation oscillator

In fact, anything you could control can be modulated, that is, changed over time by some oscillator or other signal.


