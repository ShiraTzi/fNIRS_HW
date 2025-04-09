
%% 
% [SNR, powerSpectrum, frequencies, pulseFreq, pulsePower, pulseBPM]=CalcSNRandPulse(HinTime, Fs)
%
% Description - calculate the SNR, BPM, and FFT of a signal, based on the
% given signal and sampling rate
%
% Input:
% HinTime - an nx1 vector of the signal
% Fs -the frequency of sampling (in Hz)
% Output :
% SNR - the sound to noise ratio of the signal, when:
% Sound- the signal strength at heart beat frequency
% Noise - average of the signal in Fourier domain at Frequencies above 2.5Hz
% powerSpectrum- the absolut of the FTT transform squared
% frequencies- the frequencys of the FFT
% pulseFreq- the frequency with the highest strengh (will probably the heartbeat frequency)
% pulsePower- the strengh of the strongest frequency
% pulseBPM - the BPM of the strongest frequency, defined as
% pulseFreq[Hz]*60[seconds per minute]

function [SNR, powerSpectrum, frequencies, pulseFreq, pulsePower, pulseBPM]=CalcSNRandPulse(HinTime, Fs)

% Calculating the fft of the first channel
powerSpectrum = abs(fft(HinTime)).^2;

%take only half the power spectrum (no nead to the two sides of the power spectrum)
frequencies = linspace(0, Fs/2, length(powerSpectrum)/2 + 1);
powerSpectrum(length(frequencies)+1:end)=[];

% take out DC
dcFreq=0.5;
indxDcFreq=frequencies<=dcFreq;
frequencies(indxDcFreq)=[];
powerSpectrum(indxDcFreq)=[];

%find peak and BPM

[ pulsePower , maxIdx ] = max(powerSpectrum);

SecondsPerMinute=60;
pulseFreq=frequencies(maxIdx);
pulseBPM=pulseFreq*SecondsPerMinute;

%Find SNR

Sound=pulsePower;
NioseFreq=2.5;
Noise= mean(powerSpectrum(frequencies>=NioseFreq));
SNR=Sound/Noise;

end