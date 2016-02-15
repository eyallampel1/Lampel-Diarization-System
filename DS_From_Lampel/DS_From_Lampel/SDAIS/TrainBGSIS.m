% Train background model
clear
clc
close 

%% Initilization
% Add working directory to path and set master directory.
addpath(genpath(cd));

% Initialize diarization system
% Random seed
rand('twister', sum(100*clock));

% Input arguments structure
Args = ParseArgs('SISArgs.txt');

%Files structure
[C Side Spk NumConv] = ...
    textread('TrainBGFiles.txt','%s %1d %4d %1d','delimiter',',');

% UI
fprintf(2,'BG Training, Parameters\n')
PrintStruct(Args)
fprintf(2,'\n\nBG Training\n')

% Initialize global super vector storage
RArgs.SVGlobe = [];

% Load UBM
load(Args.UBM)

% Load NAP
load(Args.NAP);

% Initialize timer
RArgs.StartTime = tic;


%% Primary loop
for Conv = 1 : size(C,1)
    
    % UI
    fprintf('\n%d - %s ->',Conv, C{Conv}(end-7:end) )
    
    % UI
    fprintf(' Open ->')
    
    % Open conversation
    [RArgs.Conv RArgs.Fs] = OpenAudio( C{Conv}, 0);
    
    % UI
    fprintf(' Pre ->')
    
    % Pre - Processing
    RArgs.Conv = PreProc( RArgs.Conv, Args.PreProcType, 0 );
    
    % UI
    fprintf(' VAD ->')
    
    % Assign samples using manual segmentation
    RArgs.Vad = ManualVAD( Args.BGVDir, C{Conv}(end-7:end), RArgs.Fs, Args.VadCollar);
    RArgs.Conv = RArgs.Conv(find(RArgs.Vad ~= 0), :);

    
    % UI
    fprintf(' Feat ->')
    
    % Feature extraction
    RArgs.Feat = FeatExtract( RArgs.Conv, RArgs.Fs, Args.FeatType, ...
        Args.FeatWinLen, Args.FeatWinInc, Args.FeatAnaOrd, ...
        Args.FeatEnergy, 0 );
    
     % Delta features
    RArgs.Feat = DeltaFeat(RArgs.Feat, Args.FeatDel, Args.FeatDelDel);
    
    % UI
    fprintf(' Norm ->')
    
    % Feature normalization
    RArgs.Feat = FeatNorm( RArgs.Feat, Args.FeatNormType, 0 );
    
    % UI
    fprintf(' Adapt ->')
    
    % Adapt model
    [Prior Mean Cov] = ModelAdapt(RArgs.Feat, UBM_S, Args);
    
    % NAP
    Mean = Mean(:);
    Mean = Mean - NAP_S.V*(NAP_S.V'*Mean);
    
    % UI
    fprintf(' Collect')
    
    % Collect Super vectors
    RArgs.SVGlobe = [RArgs.SVGlobe Mean(:)];
    
end

%% Save BG

% UI
fprintf('\n\nSave background\n')
fprintf(2,'Total analysis time %3.2f\n\n',toc(RArgs.StartTime));

BG_S = struct('SV',RArgs.SVGlobe);

if(strcmp(Args.Mod,'gmmubm') == 1)
        BGName = ['BG/GMM_BG'];
        ArgsName = ['BG/GMM_BG_Args'];
        save(BGName, 'BG_S')
        save(ArgsName, 'Args')
    
elseif(strcmp(Args.Mod,'somubm') == 1)
        BGName = ['BG/SOM_BG'];
        ArgsName = ['BG/SOM_BG_Args'];
        save(BGName, 'BG_S')
        save(ArgsName, 'Args')
        
elseif(strcmp(Args.Mod,'kmubm') == 1)
        BGName = ['BG/KM_BG'];
        ArgsName = ['BG/KM_BG_Args'];
        save(BGName, 'BG_S')
        save(ArgsName, 'Args')        
end

