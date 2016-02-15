function [] = SDS( Files )

% USAGE [] = Sds(Files)
% Speaker diarization system

%% Initilization
% Add working directory to path and set master directory.
addpath(genpath(cd));

% Initialize diarization system
% Random seed
rand('twister', sum(100*clock));

% Input arguments structure
Args = ParseArgs('SDSArgs.txt');

% Files structure
if (exist('Files', 'var') )
    [pathstr, name, ext] = fileparts(Files);
    clear Files;
    Files(1).File = [name ext];
    Files(1).FullPath = fullfile(pathstr, Files(1).File);
    Files(1).FilePath = pathstr;
else
    Files = FilesList( 'allLDC.txt' );
end

%% Primary loop
for Conv = 1 : size(Files,1)
    
    % Verbosity
    if(Args.Verbose == 1)
        RArgs.StartTime = tic;
    end
    
    % Open conversation
    [RArgs.Conv RArgs.Fs] = OpenAudio( Files(Conv).FullPath, Args.Verbose);
    
    % Voice activity detection
    [RArgs.Vad RArgs.Energy] = Vad( RArgs.Conv, RArgs.Fs,  Args.NonspType, ...
        Args.NonspWinLen*RArgs.Fs, Args.NonspThresh, Args.Verbose );
    
    % Overlapped speech detection
    [RArgs.OS RArgs.Entropy] = OvlSp( RArgs.Conv, Args.OvspType, ...
        Args.OvspWinLen*RArgs.Fs, Args.OvspThresh, Args.Verbose );
    
    % Pre - Processing
    RArgs.Conv = PreProc( RArgs.Conv, Args.PreProcType, Args.Verbose );
    
    % Feature extraction
    RArgs.Feat = FeatExtract( RArgs.Conv, RArgs.Fs, Args.FeatType, ...
        Args.FeatWinLen, Args.FeatWinInc, Args.FeatAnaOrd, ...
        Args.FeatEnergy, Args.Verbose );
    
    % Feature normalization
    RArgs.Feat = FeatNorm( RArgs.Feat, Args.FeatNormType, Args.Verbose );
    RArgs.Feat = DeltaFeat(RArgs.Feat, Args.FeatDel, Args.FeatDelDel);
    RArgs.FeatSize = size(RArgs.Feat);
    RArgs.ALLFeat = RArgs.Feat; % oren - save all features before deletion
    
    % Initial assignment
    [RArgs.PM RArgs.NSI RArgs.OSI RArgs.SI RArgs.IDX] = InitAssign(...
        RArgs.Feat, RArgs.OS, RArgs.Vad, Args.FeatWinLen, Args.FeatWinInc,...
        Args.NonspWinLen, Args.OvspWinLen, Args.SdNumClust, Args.SdInit, ...
        Args.Verbose);
    
    % Remove non-speech model (if required)
    if(Args.SdTrainNS == 0)
        RArgs.PM(1) = [];
    end
    
    %% Modeling and time-series clustering
    % Initial modeling
    Opts.SomWid = Args.SomWid;
    Opts.SomLen = Args.SomLen;
    Opts.GmmOrd = Args.GmmOrder;
    Opts.GmmTrain = Args.GmmTrain;
    RArgs.Models = Modeling( RArgs.PM, [], Args.Mod, Opts, Args.Verbose );
    
    % Initial segmentation
    RArgs.VPath = zeros(RArgs.FeatSize(1),1);
    RArgs.VPath(RArgs.SI) = RArgs.IDX + 1;
    RArgs.VPath(RArgs.NSI) = 1;
    
    % Remove overlapped and non speech from features and path
    if(Args.SdTrainNS == 0)
        RArgs.Feat([RArgs.NSI;RArgs.OSI], : ) = [];
        RArgs.VPath([RArgs.NSI RArgs.OSI]) = [];
        RArgs.VPath = RArgs.VPath - 1;
    else
        RArgs.Feat([RArgs.OSI], : ) = [];
        RArgs.VPath([RArgs.OSI]) = [];
    end
    
    % Save each iteration
    if(Args.SdSaveEachIter == 1)
        % Set VPath
        if(Args.SdTrainNS == 0)
            RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
            RArgs.TVPath(sort([RArgs.SI])) = RArgs.VPath+1;
            RArgs.TVPath(sort([RArgs.NSI])) = 1;
            RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
        else
            RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
            RArgs.TVPath(sort([RArgs.SI;RArgs.NSI])) = RArgs.VPath;
            RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
        end
        
        % Save parameters
        [AutoSeg] = AutoSegMatFile(RArgs.TVPath, Args.FeatWinInc, ...
            Files(Conv).File(1:end-4), fullfile(Args.SdResDir,num2str(0)) , ...
            [], []);
    end
    
    % Verbosity
    if(Args.Verbose == 1)
        fprintf(2,'Diarization iterations\n');
    end
    
    % Time-series clustering and re-modeling
    for Iter = 1 : Args.SdDiarIter
        
        % Viterbi analysis
        [RArgs.VPath RArgs.VDist] = Viterbi(RArgs.Feat, RArgs.Models,...
            RArgs.VPath, floor(Args.SdVitMinDur/0.01),...
            size(RArgs.Models,2), Iter,...
            Args.SdAdaptTransMat, Args.SdAdaptTransMatIter, Args.Mod, ...
            Args.Verbose);
        
        % Build pre-models
        RArgs.PM = GenPM( RArgs.Feat, RArgs.VPath );
        
        % Train models
        RArgs.Models = Modeling( RArgs.PM, RArgs.Models, Args.Mod, Opts, ...
            Args.Verbose);
        
        if(Args.SdSaveEachIter == 1)
            % Set VPath
            if(Args.SdTrainNS == 0)
                RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
                RArgs.TVPath(sort([RArgs.SI])) = RArgs.VPath+1;
                RArgs.TVPath(sort([RArgs.NSI])) = 1;
                RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
            else
                RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
                RArgs.TVPath(sort([RArgs.SI;RArgs.NSI])) = RArgs.VPath;
                RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
            end
            
            % Save parameters
            [AutoSeg] = AutoSegMatFile(RArgs.TVPath, Args.FeatWinInc, ...
                Files(Conv).File(1:end-4), fullfile(Args.SdResDir,num2str(Iter)) , ...
                [], []);
        end
    end
    
    % Verbosity
    if(Args.Verbose == 1)
        fprintf(2,'Final iterations\n');
    end
    
    % Final iterations
    for Iter = 1 : Args.SdDiarIterFinal
        
        % Viterbi analysis
        [RArgs.VPath RArgs.VDist] = Viterbi(RArgs.Feat, RArgs.Models,...
            RArgs.VPath, floor(Args.SdPostVitMimDur/0.01),...
            size(RArgs.Models,2), Iter,...
            Args.SdAdaptTransMat, Args.SdAdaptTransMatIter, Args.Mod, ...
            Args.Verbose);
        
        if(Iter < Args.SdDiarIterFinal)
            % Build pre-models
            RArgs.PM = GenPM( RArgs.Feat, RArgs.VPath );
            
            % Train models
            RArgs.Models = Modeling( RArgs.PM, RArgs.Models, Args.Mod, Opts, ...
                Args.Verbose);
        end
        
        if(Args.SdSaveEachIter == 1)
            % Set VPath
            if(Args.SdTrainNS == 0)
                RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
                RArgs.TVPath(sort([RArgs.SI])) = RArgs.VPath+1;
                RArgs.TVPath(sort([RArgs.NSI])) = 1;
                RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
            else
                RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
                RArgs.TVPath(sort([RArgs.SI;RArgs.NSI])) = RArgs.VPath;
                RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
            end
            
            % Save parameters
            [AutoSeg] = AutoSegMatFile(RArgs.TVPath, Args.FeatWinInc, ...
                Files(Conv).File(1:end-4), fullfile(Args.SdResDir, ...
                ['f' num2str(Iter)]) , ...
                [], []);
        end
        
    end
    
    if(Args.SdSaveEachIter == 1)
        % Set VPath
        if(Args.SdTrainNS == 0)
            RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
            RArgs.TVPath(sort([RArgs.SI])) = RArgs.VPath+1;
            RArgs.TVPath(sort([RArgs.NSI])) = 1;
            RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
        else
            RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
            RArgs.TVPath(sort([RArgs.SI;RArgs.NSI])) = RArgs.VPath;
            RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
        end
        
        % Save parameters
        [AutoSeg] = AutoSegMatFile(RArgs.TVPath, Args.FeatWinInc, ...
            Files(Conv).File(1:end-4), fullfile(Args.SdResDir, ...
            'final') , ...
            [], []);
    else
        
        % Set VPath
        if(Args.SdTrainNS == 0)
            RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
            RArgs.TVPath(sort([RArgs.SI])) = RArgs.VPath+1;
            RArgs.TVPath(sort([RArgs.NSI])) = 1;
            RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
        else
            % Making sure non speech is 1 and OL speech is 3 (nSpeakers+2)
            RArgs.TVPath = zeros(RArgs.FeatSize(1),1);
            RArgs.TVPath(sort([RArgs.SI;RArgs.NSI])) = RArgs.VPath;
            RArgs.TVPath(RArgs.OSI) = Args.SdNumClust + 2;
        end
        
        % Save segmentation
        [AutoSeg] = AutoSegMatFile(RArgs.TVPath, Args.FeatWinInc, ...
            Files(Conv).File(1:end-4), Args.SdResDir, ...
            [], []);
        
        % Save additional data
%         if Args.SdSaveData
%             % Rearrange model nodes (works only for som for now) 
%             % to be -    (nNodes X nFeatures X nModels)
%             modelNodes = cell2mat(reshape(cellfun(@transpose,{RArgs.Models(:).Model},'UniformOutput',false),1,1,3));
%             % Save data as a mat file similar to the result txt file
%             matFileName = fullfile(Args.SdResDir,Files(Conv).File(1:end-4));
%             save(matFileName,'-struct', 'RArgs','ALLFeat');
%             save(matFileName,'modelNodes','-append');
%         end
        
    end
    
    
    % Verbosity
    if(Args.Verbose == 1)
        fprintf(2,'Total analysis time %3.2f\n\n',toc(RArgs.StartTime));
    end
    
    % Clear arguments
    clear RArgs;
    
end

