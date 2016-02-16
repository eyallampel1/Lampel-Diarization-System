% Train SVM for each speaker
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
[Conv Side Spk NumConv] = ...
    textread('TrainSVMFiles.txt','%s %1d %4d %1d','delimiter',',');

% Load UBM
load(Args.UBM)

% Load BG
load(Args.BG)

% Load NAP
load(Args.NAP);

% UI
fprintf(2,'SVM Training, Parameters\n')
PrintStruct(Args)
fprintf(2,'\n\nSVM Training\n')

% Verbosity
if(Args.Verbose == 1)
    RArgs.StartTime = tic;
end

%% Primary loop
for SpkI = 1 : size(Spk,1)/2
    
    % Set super vector
    SV = [];
    
    for ConvI = 1 : Args.SVMNumConv
        
        % Conversation index
        CI = (SpkI-1)*2+ConvI;
        
        % UI
        [pathstr, name, ext, versn] = fileparts(Conv{CI});
        fprintf('\n%d - %s ->',CI, [name ext] )
        
        % UI
        fprintf(' Open ->')
        
        % Open conversation
        [RArgs.Conv RArgs.Fs] = OpenAudio( Conv{CI}, 0);
        
        % UI
        fprintf(' Pre ->')
        
        % Pre - Processing
        RArgs.Conv = PreProc( RArgs.Conv, Args.PreProcType, 0 );
        
        % UI
        fprintf(' VAD ->')
        
        % Assign samples using manual segmentation
        RArgs.Vad = ManualVAD( Args.SVMVDir, [name ext], RArgs.Fs, Args.VadCollar);
        switch Side(CI)
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
        
        % NAP
        Mean = Mean(:);
        Mean = Mean - NAP_S.V*(NAP_S.V'*Mean);
        
        % UI
        fprintf(' Collect ->')
        
        % Collect SV
        SV = [SV Mean(:)];
        
    end
    
    % UI
    fprintf(' Train ->')
    
    % Train speaker SVM
    Group = [ones(size(SV,2),1);ones(size(BG_S.SV,2),1).*-1];
    Data = [SV BG_S.SV]';
    SVM = libsvmtrain(Group, Data, '-t 0 ');
    
    % Gen separating hyperplane norm
    SVM_H = zeros(1, size(Data,2));
    for SV = 1 : size(SVM.sv_coef,1)
        SVM_H = SVM_H + SVM.sv_coef(SV).*SVM.SVs(SV,:);
    end
    
    SVM_S = struct('Norm',SVM_H,'Bias',SVM.rho, 'Spk',Spk(CI));
    
    % Save SVM
    switch Args.Mod
        case 'gmmubm'
            SVMName = ['SVM/GMM_SVM_' num2str(Spk(CI)) '.mat'];
            save(SVMName,'SVM_S')
            
        case 'somubm'
            SVMName = ['SVM/SOM_SVM_' num2str(Spk(CI)) '.mat'];
            save(SVMName,'SVM_S')
            
        case 'kmubm'
            SVMName = ['SVM/KM_SVM_' num2str(Spk(CI)) '.mat'];
            save(SVMName,'SVM_S')            
    end
end
