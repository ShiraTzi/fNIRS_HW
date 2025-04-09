%% Here, we will load all the data to send to the function CalcNIRS
% Input- none
% Output- none
%% Clear all parameters
clear; 
%% Open the important data

% Intensity data
dataFile1=open("FN_032_V1_Postdose1_Nback.mat");
dataFile2=open('FN_031_V2_Postdose2_Nback.mat');



%% Test 1- first data

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,2];

% Data file to use
dataFile=dataFile1;

[ dHbR_1 , dHbO_1, fig_1 ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 

%% Test 2- second data

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,2];

% Data file to use
dataFile=dataFile2;

[ dHbR_2 , dHbO_2, fig_2 ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 

%% Here, we will find the FFT of the first subject, and calculate SNR


tau=dataFile1.t(1,2)-dataFile1.t(1,1); %time between measurments
Fs=1/tau; %sampling frequency
% create an OD matrix the size of the intensity
ODChannel1=dataFile1.d(1,1)./dataFile1.d(:,1);%OD of first channel

[SNR, powerSpectrum, frequencies, pulseFreq, pulsePower, pulseBPM]=CalcSNRandPulse(ODChannel1, Fs);
% plot all the important data

figure;
plot(frequencies,powerSpectrum,'black')
hold on
plot(pulseFreq,pulsePower,'g*')
xlabel("Frequency (Hz)")
ylabel("Power")
title(sprintf("FFT of OD with BPM: %.2f and SNR: %.3f \n",pulseBPM, SNR))



%end the running of the program here the rest is my tests
return;








%% Other Test for myself
%% Test 3- missing SDS

% Source detector seperation
SDS=[];

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,3,5];

%% Test 4-  SDS not the right type


% Source detector seperation
SDS='hello';

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,3,5];

%% Test 5- missing Tissue type


% Source detector seperation
SDS=3;

% tissue type
tissueType=[];

% Plot channel index
plotChannelIdx=[1,3,5];

%% Test 6- Tissue type not right

% Source detector seperation
SDS=3;

% tissue type
tissueType=3;

% Plot channel index
plotChannelIdx=[1,3,5];

%% Test 6- Tissue type not in table

% Source detector seperation
SDS=3;

% tissue type
tissueType='hello';

% Plot channel index
plotChannelIdx=[1,3,5];

%% Test 7- No data sent

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,3,5];

%% Test 8- no plotting

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[];

%% Test 9- plotting vector not the right type

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx='hello';