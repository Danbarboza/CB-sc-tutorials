
/*
Open Sound Control (OSC)

OSC is a communication protocol used for sending information across a computer network. It can function as a successor to MIDI for real-time control of dsp instruments with greatly increased speed and high precision,user-customisable data representations.  It is supported by most sound programming software, and many commercial software synthesis applications.  For example, you can also use it to communicate with other programs like Processing, Max/MSP, or PD (for example to control SC Server synths in sync with Jitter).

It is the lifeblood of SuperCollider since all communication from the language  to the localhost server uses OSC! You may also send messages to any other SuperCollider Servers for which you know an IP address. So SuperCollider is immediately equipped for network music.

For OSC, you create your own OSC Address Space as a tree of methods that are called when their corresponding string is invoked. In practice, this means you can choose the    name-IDs of messages you want to send and receive.

(see http://opensoundcontrol.org/introduction-osc for more)

You might use

"/myparameters/object3/frequency"

Or any other string, where the forward slashes / split up the tree to be traversed.

The OSC messages include as well as the address string a typetag string that says whether the information passed is a float,  integers, etc, followed by actual values for each type in the type string:

address, typetags, values

The message is passed to the appropriate method as soon as it arrives.

A 'bundle' can also be sent, which is a set of OSC commands that are to be called simultaneously - an absolute time tag is also enclosed, to control exactly when the commands are to be carried out.

To send general OSC to a known IP use the NetAddr class:
*/

[NetAddr]

NetAddr.new("pauline.mills.edu",57120);  //  communicate with CCM server !
NetAddr.myIP;  // get your own machine's IP address

//demo to send to the localhost Server
// run this code to get ready
(
s = Server.local.boot;
s.scope(2);
)

(
var n, id;

//loopback (send to yourself) address is 127.0.0.1 - try substituting the IP address of another user's machine
n=NetAddr("127.0.0.1", 57110); //57110 is the port number; this is the standard number used by the Server

id=s.nextNodeID; // get the next available number for a Synth (its superclass is Node)
n.sendMsg("s_new",\default,id,0,0);   //sendMsg works out the correct OSC message for you -- this plays a note on the \default Synth

SystemClock.sched(1.0,{n.sendMsg("n_free",id); });
)

/*
To send standard messages to control a SuperCollider server, the Server class is a better interface. Underneath, it uses NetAddr as above.

[Server]

You can also use Julian Rohrhuber's  BroadcastServer class to send messages to a list of NetAddrs (usually other SuperCollider Servers on other machines).  It's a Quark, so you'll first need to download and install it in your Extensions folder.

To view all OSC messages received by SC3, execute: */

OSCFunc.trace

// To receive and react to OSC messages in SCLang, use the OSCdef class:

[OSCdef]

(
// register to receive a trigger message
OSCdef(\test,  // this is the key -- a symbol-name identifying your responder
	{ arg msg, time, addr, recvPort;  // this is the responder function
		"received trigger!".postln; },
	"/tr"   // this is the osc-address
);

//send a trigger message whenever the impulse fires (once every 2 seconds)
{SendTrig.kr(Impulse.kr(0.5))}.play;
)
// See also the SendReply class, which sends more than one value at a time as an Array

//keep it running, and replace the response function:
(
OSCdef(\test,{ arg msg, time, addr, recvPort;
	"new reaction!".post;
	" ".post; time.postln },"/tr"
);
)

OSCdef(\test).disable;   // stop responding
OSCdef(\test).enable;   // restart responding
OSCdef(\test).clear;    // clear the response function
OSCdef.freeAll    // clear all previously defined OSCdefs

/*
MIDI

To access your MIDI interfaces you must initialize: MIDIIn.connectAll
For obtaining incoming MIDI messages see the MIDIIn help file: [MIDIIn]
For sending MIDI messages out see the MIDIOut help file: [MIDIOut]

*/

// here's a simple program to turn on/off notes, and control faders with MIDI controllers
// first, a synth to trigger and control
(
SynthDef(\mmfmCascade,{ arg carFreq=440, amp=0.2, cmRatio1=1, cmRatio2=1,index1=0.5, index2=0.1,gate=0;
	var mod1Freq, mod2Freq,env;
	mod1Freq = cmRatio1*carFreq;
	mod2Freq = cmRatio2*mod1Freq;
	env = EnvGen.kr(Env.asr(0.001,1,0.2),gate,doneAction: 2);
	Out.ar(0,SinOsc.ar(
		SinOsc.ar(
			SinOsc.ar(mod2Freq,0,mod2Freq*index2,mod1Freq),
			0, mod1Freq*index1,carFreq),0,env*amp
	))
}).add;
)

(
MIDIIn.connectAll;  // you must first connect to your MIDI input-outputs
// see args delivered with each noteOn
MIDIdef.noteOn(\test,{ arg ... args; args.postln });
)

(	// play on any channel
MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synth = Synth(\mmfmCascade,[\carFreq,note.midicps,\carAmp,vel/127, gate: 1])
}).fix(true);   // needed to make this persist after Command-.

MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synth.notNil,{ ~synth.set(\gate,0)})})
.fix(true);   // needed to make this MIDIdef persist after Command-.
)

(
//  play only on channel one
MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synth = Synth(\mmfmCascade,[\carFreq,note.midicps,\amp,vel/127,
		gate:1]) // the gate arg starts (1) and releases (0) the sustaining Env
},nil,0).fix(true);  // arg following the function sets the note number it responds to (if nil, it responds to any note), followed by the midichannel it responds to (as 0-15, subtract 1 from conventional chan number)
MIDIdef.noteOff(\testOff,{ arg vel,note;
	if(~synth.notNil,{ ~synth.set(\gate,0)})},nil,0) // also specify note, chan
.fix(true);

// interpret continuous controllers
MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	switch(num.postln,	// 'switch' matches a value with an appropriate response
		0,{ ~synth.set(\carFreq,\freq.asSpec.map(val/127)) },
		1,{ ~synth.set(\amp,\amp.asSpec.map(val/127)) },
		2,{ ~synth.set(\cmRatio1,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		3,{ ~synth.set(\index1,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		4,{ ~synth.set(\cmRatio2,[0.1,20,\lin,0.1].asSpec.map(val/127)) },
		5,{ ~synth.set(\index2,[0.1,20,\lin,0.1].asSpec.map(val/127)) }
	)}).fix(true);
)

( // let's redefine the noteOn and cc MIDIdefs to use the last cc setting for the mod params of the next note played
// first create ~variables storing their last setting, which must be initialized so we don't send 'nil' to the synth (which will make it crash):

~cmRatio=1; ~index1=1; ~cmRatio2=1; ~index2=1;

MIDIdef.noteOn(\testOn,{ arg vel,note;
	~synth = Synth(\mmfmCascade,[\carFreq,note.midicps,\amp,vel/127,
		\cmRatio1,~cmRatio1, \index1,~index1, \cmRatio2,~cmRatio2, \index2, ~index2,
		gate:1])
},nil,0).fix(true);

MIDIdef.cc(\testCC,{ arg val, num, chan;  // this is the vector for controller events
	switch(num.postln,	// save cmratios and indexes
		0,{ ~synth.set(\carFreq,\freq.asSpec.map(val/127)) },
		1,{ ~synth.set(\amp,\amp.asSpec.map(val/127)) },
		2,{ ~synth.set(\cmRatio1,~cmRatio1=([0.1,20,\lin,0.1].asSpec.map(val/127))) },
		3,{ ~synth.set(\index1,~index1=([0.1,20,\lin,0.1].asSpec.map(val/127))) },
		4,{ ~synth.set(\cmRatio2,~cmRatio2=([0.1,20,\lin,0.1].asSpec.map(val/127))) },
	5,{ ~synth.set(\index2,~index2=([0.1,20,\lin,0.1].asSpec.map(val/127))) }
	)}).fix(true);
)

MIDIdef.freeAll;   // clear all MIDIdefs

// SC3 Plugins and Extensions
(
// Plugins are UGens written by other users, that run audio on the Server.  They are written in C++, so you must download the appropriate compilations for Mac or Windows, or build them from sourcecode in Linux.  On Mac, put the downloaded files in your /User/Library/Application Support/SuperCollider/Extensions folder, then recompile.

// Extensions are class libraries written by other users in the SuperCollider language -- they are therefore cross-platform, so you need only the source code. These are available in a package-management system called Quarks, that is currently not working well for automatic updating on MacOS.  But you can install them manually, by moving the quarks folder into the /User/Library/Application Support/SuperCollider folder. Once there they can be included or excluded from your compilation path by typing Quarks.gui<ENTER>, which brings up a selection panel.  Choosee a library to install then recompile, and a link to the chosen quarks code is created in your /User/Library/Application Support/SuperCollider/Extensions/quarks folder.  Try installing the Conductor Quark now to see how the following code works.

// CV (Control-Value) is a Quark that associates data with a ControlSpec
// it also allows flexible connection to GUI objects

var dly = {|dlyTime=1,dcyTime=5,dlyAmp=0.25|
	CombC.ar(SoundIn.ar(0,dlyAmp),2,dlyTime,dcyTime) }.play;
~dlyTime = CV([0.05,2.0,\exp,0].asSpec,1.0);
~dlyTime.action_({|cv| dly.set(\dlyTime,cv.value)});
~dcyTime = CV([0.1,40,\exp,0].asSpec,5);
~dcyTime.action_({|cv| dly.set(\dcyTime,cv.value)});
~dlyAmp = CV(nil,0.25);
~dlyAmp.action_({|cv| dly.set(\dlyAmp,cv.value)});

w = Window("dlyTest",Rect(25, 392, 690, 150)).front.onClose_({ dly.free });
f = FlowView.new(w, margin: 5@5);
~dlyTime.connect(EZSlider(f,220@20,"dlyTime",[0.05,2.0,\exp].asSpec));
~dcyTime.connect(EZSlider(f,220@20,"dcyTime",[0.01,20,\exp,0].asSpec));
~dlyAmp.connect(EZSlider(f,220@20,"dlyAmp",nil));
)








