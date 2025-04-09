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
% create an OD vector for channel 1 measurement for two labbdas
ODChannel1Lambda1=dataFile1.d(1,1)./dataFile1.d(:,1);%OD of first channel
ODChannel1Lambda1=log10(ODChannel1Lambda1);

ODChannel1Lambda2=dataFile1.d(1,21)./dataFile1.d(:,21);%OD of first channel
ODChannel1Lambda2=log10(ODChannel1Lambda2);

% calculate FFT, SNR and BPM with the function CalcSNRandPulse
[SNR1, powerSpectrum1, frequencies1, pulseFreq1, pulsePower1, pulseBPM1]=CalcSNRandPulse(ODChannel1Lambda1, Fs);
[SNR2, powerSpectrum2, frequencies2, pulseFreq2, pulsePower2, pulseBPM2]=CalcSNRandPulse(ODChannel1Lambda2, Fs);

% plot all the important data

figure;
subplot(2,1,1)
plot(frequencies1,powerSpectrum1,'black')
hold on
plot(pulseFreq1,pulsePower1,'g*')
xlabel("Frequency (Hz)")
ylabel("Power")
title(sprintf("FFT of OD with BPM: %.2f and SNR: %.3f First Lambda \n",pulseBPM1, SNR1))
subplot(2,1,2)
plot(frequencies2,powerSpectrum2,'black')
hold on
plot(pulseFreq2,pulsePower2,'g*')
xlabel("Frequency (Hz)")
ylabel("Power")
title(sprintf("FFT of OD with BPM: %.2f and SNR: %.3f Second Lambda \n",pulseBPM2, SNR2))









% end function for the assignment
return
%% Other Tests for myself
%% Test 3- missing SDS

% Source detector seperation
SDS=[];

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,3,5];

[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 


%% Test 4-  SDS not the right type or value


% Source detector seperation
SDS='hello';

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,3,5];


[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 

%% Test 5- missing Tissue type


% Source detector seperation
SDS=3;

% tissue type
tissueType=[];

% Plot channel index
plotChannelIdx=[1,3,5];

[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 


%% Test 6- Tissue type not the right type

% Source detector seperation
SDS=3;

% tissue type
tissueType=3;

% Plot channel index
plotChannelIdx=[1,3,5];

[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 


%% Test 6- Tissue type not in table

% Source detector seperation
SDS=3;

% tissue type
tissueType='hello';

% Plot channel index
plotChannelIdx=[1,3,5];

[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 


%% Test 7- No data sent

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[1,3,5];

[ ~ , ~, ~ ] = CalcNIRS([], SDS, tissueType, plotChannelIdx); 


%% Test 8- no plotting

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[];

[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 


%% Test 9- plotting vector not the right type

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx='hello';


[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 

%% Test 10- plotting vector with too big channels

% Source detector seperation
SDS=3;

% tissue type
tissueType='adult_head';

% Plot channel index
plotChannelIdx=[21];


[ ~ , ~, ~ ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx); 
