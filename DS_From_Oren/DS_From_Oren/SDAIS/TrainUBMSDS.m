% Train a unified background modeling
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
Args = ParseArgs('SDSArgs.txt');

% Files structure
% Open files list
[C Side Spk] = ...
    textread('TrainUBMFiles.txt','%s %1d %4d','delimiter',',');

% UI
fprintf(2,'UBM Training, Parameters\n')
PrintStruct(Args)
fprintf(2,'\n\nUBM Training\n')

% Initialize feature set
RArgs.FeatGlob = [];

% Initialize timer
RArgs.StartTime = tic;

%% Primary loop
for Conv = 1 : 20 % size(C,1)
    
    % UI
    fprintf('\n%d - %s ->',Conv, C{Conv}(end-7:end) )
    
    % UI
    fprintf(' Open ->')
    
    % Open conversation
    [RArgs.Conv RArgs.Fs] = OpenAudio(C{Conv}, 0);
    
    % UI
    fprintf(' Pre ->')
    
    % Pre - Processing
    RArgs.Conv = PreProc( RArgs.Conv, Args.PreProcType, 0 );
    
    % UI
    fprintf(' VAD ->')
    
    % Assign samples using manual segmentation
    RArgs.Vad = ManualVAD( '/DBMP/AudioDB/SIS_Data/UBM/Segmentations', C{Conv}(end-7:end), RArgs.Fs, ...
        Args.VadCollar);
    
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
    fprintf(' Collect')
    
    % Collect features
    RArgs.FeatGlob = [RArgs.FeatGlob;RArgs.Feat];
    
end

RArgs.FeatGlob = RArgs.FeatGlob';

MeanI = randn(size(RArgs.FeatGlob,1), 60);
[AssignI, MeanI, PriorI, CovI] = ...
    KMeans(RArgs.FeatGlob, MeanI, 20, 1e-5);
CovD = zeros(size(MeanI));
for i = 1 : Args.GmmOrder
    CovD(:,i) = diag(CovI(:,:,i));
end
CovD(find(CovD < 1e-10)) = 1;
[Prior, Mean, Cov] = EmGmm(RArgs.FeatGlob, PriorI, ...
    MeanI, CovD, 1, 0, Args.GmmMaxIter, 1e-5);
                        
% Dimensions
IK = size(RArgs.FeatGlob,2);
Dim = size(RArgs.FeatGlob,1);
M = Args.SomLen*Args.SomWid;

% Make a matrix of neurons coordinates
[X,Y]=meshgrid(1:Args.SomLen,1:Args.SomWid); P=[X(:)';Y(:)'];

% Initial centers
W=randn(Dim,M);

% Train models
[SOM WN]= Kohonen(RArgs.FeatGlob, W, P, IK, 0.8 ,0.1 , 10 , 1 );
[SOM WN]= Kohonen(RArgs.FeatGlob, SOM, P, 5*IK, ...
    0.1, 0.0, 1.0, 0.1 );
UBM_S = struct('Mean',SOM, 'Grid', P);
UBMName = 'SDSUBM/SOM_UBM';
ArgsName = 'SDSUBM/SOM_UBM_Args';
save(UBMName, 'UBM_S')
save(ArgsName, 'Args')

%% Initialize feature set
RArgs.FeatGlob = [];

% Initialize timer
RArgs.StartTime = tic;

%% Primary loop
for Conv = 1 : size(C,1)
    
    % UI
    fprintf('\n%d - %s ->',Conv, C{Conv}(end-7:end) )
    
    % UI
    fprintf(' Open ->')
    
    % Open conversation
    [RArgs.Conv RArgs.Fs] = OpenAudio(C{Conv}, 0);
    
    % UI
    fprintf(' Pre ->')
    
    % Pre - Processing
    RArgs.Conv = PreProc( RArgs.Conv, Args.PreProcType, 0 );
    
    % UI
    fprintf(' VAD ->')
    
    % Assign samples using manual segmentation
    RArgs.Vad = ManualVAD( '/DBMP/AudioDB/SIS_NIST04_NIST05/Segmentations', C{Conv}(end-7:end), RArgs.Fs);
    RArgs.Conv = RArgs.Conv(find(RArgs.Vad == 0));
    
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
    fprintf(' Collect')
    
    % Collect features
    RArgs.FeatGlob = [RArgs.FeatGlob;RArgs.Feat];
    
end

RArgs.FeatGlob = RArgs.FeatGlob';


% Dimensions
IK = size(RArgs.FeatGlob,2);
Dim = size(RArgs.FeatGlob,1);
M = Args.SomLen*Args.SomWid;

% Make a matrix of neurons coordinates
[X,Y]=meshgrid(1:Args.SomLen,1:Args.SomWid); P=[X(:)';Y(:)'];

% Initial centers
W=randn(Dim,M);

% Train models
[SOM WN]= Kohonen(RArgs.FeatGlob, W, P, IK, 0.8 ,0.1 , 10 , 1 );
[SOM WN]= Kohonen(RArgs.FeatGlob, SOM, P, 5*IK, ...
    0.1, 0.0, 1.0, 0.1 );
UBM_S = struct('Mean',SOM, 'Grid', P);
UBMName = 'SDSUBM/SOM_UBM_NS';
ArgsName = 'SDSUBM/SOM_UBM_NS_Args';
save(UBMName, 'UBM_S')
save(ArgsName, 'Args')

