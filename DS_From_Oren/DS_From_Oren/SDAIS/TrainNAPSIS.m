% Train NAP model
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

% Open files list
[Conv Side Spk] = ...
    textread('TrainNAPFiles.txt','%s %1d %4d','delimiter',',');

% Sort speakers
[V I] = sort(Spk);
Conv = Conv(I,:);
Side = Side(I);
Spk = Spk(I);

% Load UBM
load(Args.UBM)

% UI
fprintf(2,'NAP Training, Parameters\n')
PrintStruct(Args)
fprintf(2,'\n\nNAP Training\n')

% Generate feature matrix
A = [];


%% Iterate over conversations
for ConvI = 1 : size(Conv,1)
    
    % Verbosity
    if(Args.Verbose == 1)
        RArgs.StartTime = tic;
    end
    
    % File parts
    [pathstr, name, ext, versn] = fileparts(Conv{ConvI});
    fprintf('\n%d - %s ->',ConvI, [name ext] )
    
    % UI
    fprintf(' Open ->')
    
    % Open conversation
    [RArgs.Conv RArgs.Fs] = OpenAudio( Conv{ConvI}, 0);
    
    % UI
    fprintf(' Pre ->')
    
    % Pre - Processing
    RArgs.Conv = PreProc( RArgs.Conv, Args.PreProcType, 0 );
    
    % UI
    fprintf(' VAD ->')
    
    % Assign samples using manual segmentation
    RArgs.Vad = ManualVAD( Args.NAPVDir, [name ext], RArgs.Fs, Args.VadCollar);
    switch Side(ConvI)
        case 0
            RArgs.Conv = RArgs.Conv(find(RArgs.Vad == 1));
        case 1
            RArgs.Conv = RArgs.Conv(find(RArgs.Vad == 2));
    end
    
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
    
    % UI
    fprintf(' collect ->')
    
    % Collect features
    A = [A Mean(:)];
    
end

%% Train NAP
Ord = 200;

% Remove mean from appropriate components of A
SpkU = unique(Spk);
for i = 1 : size(SpkU,1)
    I = find(Spk == SpkU(i));
    A(:,I) = A(:,I) - repmat(mean(A(:,I),2),1,size(I,1));
end

% Calculate projection matrix
S = A'*A;

% Eigenvalues
[V,D] = eigs(S,Ord);

% Normalize eigenvectors
V = A * V;
V = V./repmat(sqrt(sum(V.^2)),size(V,1),1);

%% Save

NAP_S = struct('V',V);

if(strcmp(Args.Mod,'gmmubm') == 1)
        NAPName = ['NAP/GMM_NAP_' num2str(Ord)];
        ArgsName = ['NAP/GMM_NAP_Args_' num2str(Ord)];
        save(NAPName, 'NAP_S')
        save(ArgsName, 'Args')
    
elseif(strcmp(Args.Mod,'somubm') == 1)
        NAPName = ['NAP/SOM_NAP_' num2str(Ord)];
        ArgsName = ['NAP/SOM_NAP_Args_' num2str(Ord)];
        save(NAPName, 'NAP_S')
        save(ArgsName, 'Args')
        
elseif(strcmp(Args.Mod,'kmubm') == 1)
        NAPName = ['NAP/KM_NAP_' num2str(Ord)];
        ArgsName = ['NAP/KM_NAP_Args_' num2str(Ord)];
        save(NAPName, 'NAP_S')
        save(ArgsName, 'Args')        
end