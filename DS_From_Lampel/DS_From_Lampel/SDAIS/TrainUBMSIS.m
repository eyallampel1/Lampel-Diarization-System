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
Args = ParseArgs('SISArgs.txt');

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
    RArgs.Vad = ManualVAD( Args.UBMVDir, C{Conv}(end-7:end), RArgs.Fs, Args.VadCollar);
    switch Args.UBMType
        case 'speech'
            RArgs.Conv = RArgs.Conv(find(RArgs.Vad ~= 0));
        case 'nonspeech'
            RArgs.Conv = RArgs.Conv(find(RArgs.Vad == 0));
        case 'total'
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
    fprintf(' Collect')
    
    % Collect features
    RArgs.FeatGlob = [RArgs.FeatGlob;RArgs.Feat];
    
end

RArgs.FeatGlob = RArgs.FeatGlob';

%% Modeling

% UI
disp( ' ')
fprintf(2,'\nTraining\n')

switch Args.Mod
    
    % Switch UBM type
    case 'gmmubm'
        
        % Switch full or diagonal covariance
        switch Args.GmmTrain
            case 'full'
                
                % Switch initializatin algorithm for gmm
                switch Args.GmmInit
                    case 'random'
                        PriorI = rand(1, Args.GmmOrder);
                        PriorI = PriorI./sum(PriorI);
                        MeanI = randn(size(RArgs.FeatGlob,1), Args.GmmOrder);
                        CovI = zeros(size(RArgs.FeatGlob,1), ...
                            size(RArgs.FeatGlob,1), Args.GmmOrder);
                        for k = 1 : Args.GmmOrder
                            CovI(:,:,k) = diag(rand(1, ...
                                size(RArgs.FeatGlob,1)));
                        end
                        
                    case 'kmeans'
                        MeanI = randn(size(RArgs.FeatGlob,1), Args.GmmOrder);
                        [AssignI, MeanI, PriorI, CovI] = ...
                            KMeans(RArgs.FeatGlob, MeanI, Args.GmmMaxIter, 1e-5);
                        
                end
                
                [Prior, Mean, Cov] = EmGmm(RArgs.FeatGlob, PriorI, ...
                    MeanI, CovI, 0, 0, Args.GmmMaxIter, 1e-5);
                
            case 'diag'
                
                % Switch initialization algorithm for gmm
                switch Args.GmmInit
                    case 'random'
                        PriorI = rand(1, Args.GmmOrder);
                        PriorI = PriorI./sum(PriorI);
                        MeanI = randn(size(RArgs.FeatGlob,1), Args.GmmOrder);
                        CovI = rand(size(RArgs.FeatGlob,1), ...
                            Args.GmmOrder);
                        
                    case 'kmeans'
                        MeanI = randn(size(RArgs.FeatGlob,1), Args.GmmOrder);
                        [AssignI, MeanI, PriorI, CovI] = ...
                            KMeans(RArgs.FeatGlob, MeanI, Args.GmmMaxIter, 1e-5);
                        CovD = zeros(size(MeanI));
                        for i = 1 : Args.GmmOrder
                            CovD(:,i) = diag(CovI(:,:,i));
                        end
                        CovD(find(CovD < 1e-10)) = 1;
                        
                end
                [Prior, Mean, Cov] = EmGmm(RArgs.FeatGlob, PriorI, ...
                    MeanI, CovD, 1, 0, Args.GmmMaxIter, 1e-5);
                
        end
        
        % Train SOM UBM
    case 'somubm'
        
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
        [SOM WN]= Kohonen(RArgs.FeatGlob, SOM, P, Args.SomMaxIter*IK, ...
            0.1, 0.0, 1.0, 0.1 );
        
    case 'kmubm'
        MeanI = randn(size(RArgs.FeatGlob,1), Args.GmmOrder);
        [Assign, Mean, Prior, Cov] = ...
            KMeans(RArgs.FeatGlob, MeanI, Args.GmmMaxIter, 1e-5);
        
end

% Verbosity
fprintf(2,'Total analysis time %3.2f\n\n',toc(RArgs.StartTime));

%% Save UBM

if(strcmp(Args.Mod,'gmmubm') == 1)
    UBM_S = struct('Prior',Prior,'Mean',Mean,'Cov',Cov);
    switch Args.UBMType
        case 'speech'
            UBMName = 'UBM/GMM_UBM_SP';
            ArgsName = 'UBM/GMM_UBM_SP_Args';
        case 'nonspeech'
            UBMName = 'UBM/GMM_UBM_NS';
            ArgsName = 'UBM/GMM_UBM_NS_Args';
        case 'total'
            UBMName = 'UBM/GMM_UBM_T';
            ArgsName = 'UBM/GMM_UBM_T_Args';
    end
    save(UBMName, 'UBM_S')
    save(ArgsName, 'Args')
    
elseif(strcmp(Args.Mod,'somubm') == 1)
    UBM_S = struct('Mean',SOM, 'Grid', P);
    switch Args.UBMType
        case 'speech'
            UBMName = 'UBM/SOM_UBM_SP';
            ArgsName = 'UBM/SOM_UBM_SP_Args';
        case 'nonspeech'
            UBMName = 'UBM/SOM_UBM_NS';
            ArgsName = 'UBM/SOM_UBM_NS_Args';
        case 'total'
            UBMName = 'UBM/SOM_UBM_T';
            ArgsName = 'UBM/SOM_UBM_T_Args';
    end
    save(UBMName, 'UBM_S')
    save(ArgsName, 'Args')
    
elseif(strcmp(Args.Mod,'kmubm') == 1)
    UBM_S = struct('Mean',Mean);
    switch Args.UBMType
        case 'speech'
            UBMName = 'UBM/KM_UBM_SP';
            ArgsName = 'UBM/KM_UBM_SP_Args';
        case 'nonspeech'
            UBMName = 'UBM/KM_UBM_NS';
            ArgsName = 'UBM/KM_UBM_NS_Args';
        case 'total'
            UBMName = 'UBM/KM_UBM_T';
            ArgsName = 'UBM/KM_UBM_T_Args';
    end
    save(UBMName, 'UBM_S')
    save(ArgsName, 'Args')    
end
