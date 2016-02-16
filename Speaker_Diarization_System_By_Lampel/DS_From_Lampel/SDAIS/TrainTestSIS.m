%% Initilization
clear
clc
close

%%
% Add working directory to path and set master directory.
addpath(genpath(cd));

% Initialize diarization system
% Random seed
rand('twister', sum(100*clock));

% Input arguments structure
Args = ParseArgs('SISArgs.txt');

% Open files list
[Conv Side Spk] = ...
    textread('TrainTestFiles.txt','%s %1d %4d','delimiter',',');

% Load UBM
load(Args.UBM)

% Load NAP
load(Args.NAP);

% UI
fprintf(2,'Test set training, Parameters\n')
PrintStruct(Args)
fprintf(2,'\n\nTest set training\n')

%%Test availability of all sides
% for ConvI = 1 : size(Conv,1)
%
%     % Verbosity
%     if(Args.Verbose == 1)
%         RArgs.StartTime = tic;
%     end
%
%     % File parts
%     [pathstr, name, ext, versn] = fileparts(Conv{ConvI});
%
%     % Open manual segmentation
%     RArgs.Vad = ManualVAD( Args.SVMTVDir, [name ext], 8000);
%
%     % Check availability of both sides
%     if(isempty(find(RArgs.Vad == 1)))
%         fprintf(2,['Conv ' num2str(ConvI) ' : ' [name ext]  ', Side A\n']);
%     end
%     if(isempty(find(RArgs.Vad == 2)))
%         fprintf(2,['Conv ' num2str(ConvI) ' : ' [name ext]  ', Side B\n']);
%     end
% end

%% Manual segmentation train test
% Sets

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
    RArgs.Vad = ManualVAD( Args.SVMTVDir, [name ext], RArgs.Fs, Args.VadCollar);
    
    % Switch Sides
    for ConvSide = 0 : 1
        
        try
            
            RArgs.ConvT = RArgs.Conv(find(RArgs.Vad == (ConvSide+1)));
            
            % UI
            fprintf(' Feat ->')
            
            % Feature extraction
            RArgs.Feat = FeatExtract( RArgs.ConvT, RArgs.Fs, Args.FeatType, ...
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
            CSV = Mean(:);
            CSV = CSV - NAP_S.V*(NAP_S.V'*CSV);
            
            % Save
            % UI
            fprintf(' Save ->')
            switch(Args.Mod)
                case 'gmmubm'
                    save(['Test/GMM_' name '_' num2str(ConvSide)], 'CSV');
                case 'somubm'
                    save(['Test/SOM_' name '_' num2str(ConvSide)], 'CSV');
                case 'kmubm'
                    save(['Test/KM_' name '_' num2str(ConvSide)], 'CSV');                    
            end
            
        catch
            continue;
        end
        
    end
end
