%% CalcNIRS - calculate and plot HbR HbO
% Input:
% dataFile - .mat file with intensity data.
% SD.Lambda : two wavelengths (in nm)
% t : time vector
% d : intensity data of 20 channels
% 20 first rows-> first wavelength, 20 last rows->second wavelength
% SDS - Sourse-Detector Separation distance in cm
% tissueType - one of the rows in DPFperTissueFile (for example 'adult_forearm' \ 'baby_head' \ 'adult_head' \'adult_leg' )
% plotChannelIdx - vector with numbers in the range of [1-20] indicating channels to plot. If empty - none is plotted. (default = [])
%
% extinctionCoefficientsFile - .csv file with the following columns : wavelength, Water, HbO2, HHb, FatSoybean
% default = '.\ExtinctionCoefficientsData.csv' (if not passed or empty)
% DPFperTissueFile - .txt file with two columns: Tissue and DPF (Tissue is tissue type, corresponding with tissueType input variable)
% measured at 807nm
% default = '.\DPFperTissue.txt' (if not passed or empty)
% relDPFfile - relative DPF according to wavelength
% default = '.\RelativeDPFCoefficients.csv' (if not passed or empty)
%
% Output :
% dHbR - HbR concentration change for all channels (nx20) where n is time vector length
% dHbO - HbO concentration change for all channels (nx20) where n is time vector length
% fig - handle to figure. Empty if plotChannelIdx==[].

function [ dHbR , dHbO, fig ] = CalcNIRS(dataFile, SDS, tissueType, plotChannelIdx, ...
    extinctionCoefficientsFile , DPFperTissueFile , relDPFfile) 


%% Validation of variables
% we will validate that each variable ansers the requirement. if not, an
% error will be returned

% flag for plotting
plot_flag=true;

% validate dataFile
if ~exist('dataFile','var')||~isa(dataFile,'struct')
    error("dataFile is empty or not the right type");
else
    % validate all variables in the dataFile exist
    if ~isfield(dataFile,'SD')||~isfield(dataFile.SD,'Lambda')||~isa(dataFile.SD.Lambda,'double')|| all(size(dataFile.SD.Lambda)~=[1 2])
        error("dataFile.SD.Lambda is empty or not the right type");
    end
    if ~isfield(dataFile,'t')||isempty(dataFile.t)||~isnumeric(dataFile.t)
        error("dataFile.t is empty or not the right type");
    end
    if ~isfield(dataFile,'d')||isempty(dataFile.d)||~isnumeric(dataFile.d)%||size(dataFile.d,2)~=2*channels
        error("dataFile.d is empty or not the right type or size");
    end

    % now that we know all the values exist, we need to validate the sizes are
    % compatible
    if size(dataFile.t,2)~=size(dataFile.d,1)
        error("dataFile.d and dataFile.t are not compatible in size");
    end

end

% Validate SDS
if ~exist('SDS','var')||isempty(SDS)||~isnumeric(SDS)||SDS<=0
    error("SDS is empty, below 0, or not the right type");
end

% validate tissueType
if ~exist('tissueType','var')||isempty(tissueType)|| (~ischar(tissueType)&&~isstring(tissueType))
    error("tissueType is empty or not the right type");
end

% Validate plotChannelIdx
if ~exist('plotChannelIdx','var')||isempty(plotChannelIdx)
    plotChannelIdx=[];
    plot_flag=false;
end

if any(round(plotChannelIdx)~=plotChannelIdx) || any(~isnumeric(plotChannelIdx))
    error("plotChannelIdx must be an integer vector (doesn't have to be from the integer class)");
end


% Validate DPFperTissueFile
if ~exist('DPFperTissueFile','var')||isempty(DPFperTissueFile)
    DPFperTissueFile='.\DPFperTissue.txt';
end

if ~isfile(DPFperTissueFile)
    error("DPFperTissueFile is not a recognisable file"); 
end


% Validate extinctionCoefficientsFile
if ~exist('extinctionCoefficientsFile','var')||isempty(extinctionCoefficientsFile)
    extinctionCoefficientsFile='.\ExtinctionCoefficientsData.csv';
end

if ~isfile(extinctionCoefficientsFile)
    error("extinctionCoefficientsFile is not a recognisable file"); 
end

% Validate relDPFfile
if ~exist('relDPFfile','var')||isempty(relDPFfile)
    relDPFfile='.\RelativeDPFCoefficients.csv';
end

if ~isfile(relDPFfile)
    error("relDPFfile is not a recognisable file"); 
end

%% Extract the needed parameters and further validate
% number of channels (assume is half the numbers of columns in intensity mmeasurements)
channels=size(dataFile.d,2)/2;
if mod(size(dataFile.d,2),2)==1
    error("Missing channels")
end
if max(plotChannelIdx)>channels
    error("Can't plot the channels in plotChannelIdx since some channels don't exist")
end
% DPF per Tissue
DPFperTissueTable=readtable(DPFperTissueFile);
% Find the DPF of a single type of tissue
indx= strcmp( DPFperTissueTable.Tissue, tissueType);
if all(indx==0)
    error("Tisssue type doesn't exist in the given DPFperTissueTable")
end
DPFForExperiment=DPFperTissueTable(indx,:);
DPF=DPFForExperiment.DPF(1,1);
% Find Leff
Leff=DPF*SDS;
% extract Molar Extinction Coefficient for the two wavelenghts
MECTable=readtable(extinctionCoefficientsFile);
% from the table, we will extract the HbR and HbO of two wavelength in a
% 2x2 matrix
MEC=zeros(2,2);
MEC(1,1)=MECTable.HbO2(MECTable.wavelength==dataFile.SD.Lambda(1));
MEC(1,2)=MECTable.HbO2(MECTable.wavelength==dataFile.SD.Lambda(2));
MEC(2,1)=MECTable.HHb(MECTable.wavelength==dataFile.SD.Lambda(1));
MEC(2,2)=MECTable.HHb(MECTable.wavelength==dataFile.SD.Lambda(2));

%% OD Calculation
% now, we will calculate the intensity like explained in the excercise

% create an OD matrix the size of the intensity
OD=dataFile.d(1,:)./dataFile.d;
OD=log10(OD);

%% Find deltaHbR and deltaHbO

% create a matrix to save deltaHbR and deltaHbO for each minute
dHbR=zeros(size(dataFile.t,2),channels);
dHbO=zeros(size(dataFile.t,2),channels);
%for each time, we calculate deltaHbR and deltaHbO
for c=1:channels
    SmallOD=[OD(:,c), OD(:,c+channels)];
    HinTime=SmallOD/(MEC*Leff);
    dHbO(:,c)=HinTime(:,1);
    dHbR(:,c)=HinTime(:,2);
end



%% Plot results

if plot_flag
    % create matrixes for deltaHbR and deltaHbO to plots
    dHbR_plot=dHbR(:,plotChannelIdx);
    dHbO_plot=dHbO(:,plotChannelIdx);
    % create Titles so we can see which channel is which
    legendTxt=["\Delta HbO" ,"\Delta HbR"];
    fig=figure;
    numPlots=size(plotChannelIdx,2);
    for pl=1:numPlots
        titleTxt=strcat("Channel ", num2str(plotChannelIdx(pl)));
        subplot(numPlots,1,pl)
        plot(dataFile.t,dHbO_plot(:,pl),'red')
        hold on
        plot(dataFile.t,dHbR_plot(:,pl),'blue')
        xlabel("Time (s)")
        ylabel("\Delta H")
        title(titleTxt);
        legend(legendTxt);
    end




else
    fig=[];
end


end