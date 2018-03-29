declare author "Elodie RABIBISOA";
declare name "Bip bip";
import("stdfaust.lib");

process = vgroup("Metronome", (bip * envelope) : reverb * volume * onOff);
//fruq = hslider("F", 500, 500, 2000, 0.01);
bip = os.osc(830); // Bip's height in Hz;

envelope = en.asr(a,s,r,gate) with{
  a = 0.01; //in seconds
  s = 90; //percentage of gain
  r = 0.02;//in seconds
  //gate = pulse
};

volume = 0.95;

onOff = checkbox("[1]ON/OFF");

reverb = _<: instrReverb:>_;

instrReverb = _,_ <: *(reverbGain),*(reverbGain),*(1 - reverbGain),*(1 - reverbGain) :
re.zita_rev1_stereo(rdel,f1,f2,t60dc,t60m,fsmax),_,_ <: _,!,_,!,!,_,!,_ : +,+
    with {
       //reverbGain = hslider("v:Reverb/Reverberation Volume[acc:1 1 -10 0 10]",0.1,0.05,1,0.01) : si.smooth(0.999) : min(1) : max(0.05);
       reverbGain = 0.1;
       //roomSize = hslider("v:Reverb/Reverberation Room Size[acc:1 1 -10 0 10]", 0.1,0.05,2,0.01) : min(2) : max(0.05);
       roomSize = 0.1;
       rdel = 20;
       f1 = 200;
       f2 = 6000;
       t60dc = roomSize*3;
       t60m = roomSize*2;
       fsmax = 48000;
     };
 /* --------------------- Pulse -----------------------*/

gate = phasor_bin(1) :-(0.001):pulsar;
ratio_env = (0.15);
fade = (0.5); // min > 0 pour eviter division par 0
proba = 1; // Regular tempo
speed = bpm.a25*(typeBpm == 6)+ bpm.b37*(typeBpm == 5) + bpm.c50*(typeBpm == 4) + bpm.d62*(typeBpm == 3) + bpm.e75*(typeBpm == 2) + bpm.f87*(typeBpm == 1) + bpm.g100*(typeBpm == 0);
//speed in Hz
typeBpm = vslider("[2]Tempo[style:radio{'100 BPM':0;'87.5 BPM':1;'75 BPM':2;'62.5 BPM':3;'50 BPM':4;'37.5 BPM':5;'25 BPM':6}]", 0, 0, 6, 1);
bpm = environment {
a25 = 25/60; // Conversion bpm > Hz
b37 = 37.5/60;
c50 = 50/60;
d62 = 62.5/60;
e75 = 75/60;
f87 = 87.5/60;
g100 = 100/60;
}; // Tempo in bpm

phasor_bin (init) =  (+(float(speed)/float(ma.SR)) : fmod(_,1.0)) ~ *(init);
pulsar = _<:(((_)<(ratio_env)):@(100))*((proba)>((_),(no.noise:abs):ba.latch));
