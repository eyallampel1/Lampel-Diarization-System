function [DER2] = SDS_ondemand( varargin )

%load
warning off all;
InitalTrainingTime=varargin{1};
GetDerTimes=varargin{2};
Sections=varargin{3};
project=varargin{4};


   project.NumberOfLoadedFiles=size(project.ListOfScannedFile);
   project.NumberOfLoadedFiles=project.NumberOfLoadedFiles(1);
        for i=1:project.NumberOfLoadedFiles
        ListOfTextFile(i,:)= [project.ListOfScannedFile(i,1:length(project.ListOfScannedFile)-3),'txt'];
        end
  
        
        
      
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
    
    RArgs.Conv_Original=RArgs.Conv;
    RArgs.Conv=RArgs.Conv(1:InitalTrainingTime*RArgs.Fs);
    
    
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
end
    
    
    for i=1:Sections+1
 if i==1  
 
                       
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
        fprintf(2,['Initial Training Time of: ',num2str(varargin{1}), 'Sec\n']);
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
    
 else%%%remeber
     
     
    
    RArgs.Conv=RArgs.Conv_Original(1:InitalTrainingTime*RArgs.Fs+GetDerTimes*(i-1)*RArgs.Fs);
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
          
               % Initial segmentation%%%maybe delete
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
        fprintf(2,['Backtracking From ',...
            num2str(InitalTrainingTime+GetDerTimes*(i-1)) ,' Sec\n']);
    end
     
      % Time-series clustering and re-modeling
    for Iter = 1 :1
        
        % Viterbi analysis
        [RArgs.VPath RArgs.VDist] = Viterbi_ondemand(RArgs.Feat, RArgs.Models,...
            RArgs.VPath, floor(Args.SdVitMinDur/0.01),...
            size(RArgs.Models,2), Iter,...
            Args.SdAdaptTransMat, Args.SdAdaptTransMatIter, Args.Mod, ...
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
     
     
     
     
     
     
     
     
    end
    
    
    % Verbosity
    if(Args.Verbose == 1)
        fprintf(2,'Final iterations\n');
    end
    
    
    
    %%%remember
    
    
    
    
    
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
    %%%%%%%%%%%%%%%%%%%%%%comparing part:
    %path=get(project.SystemParametersEditText23,'string');
    
     try
       fclose all;
   rmdir([cd,'\System_Results'],'s');
   rmdir([cd,'\Manual_Seg'],'s');
   %clc
   catch
       errordlg(['Could Not Delete ',cd,'\System_Results'],...
           'Error Deleting Folder')
       
       
   end
   
   
    mkdir(cd,'System_Results');
   mkdir(cd,'Manual_Seg');
   
   
   [x,name,ext]=fileparts(ListOfTextFile(Conv,:));
   SystemResultsSource=[get(project.SystemParametersEditText23,'string'),'\',...
       name,ext];
   UserSelectedFile=Conv;
   
   SystemResultsDestination=[cd,'\System_Results'];
   copyfile(SystemResultsSource,SystemResultsDestination,'f'); 
   
   ManualResultsSource=[cd,'\Out\',name,ext];
   ManualResultsDestination=[cd,'\Manual_Seg\',name,ext];
   
   try
      copyfile(ManualResultsSource,ManualResultsDestination,'f') 
   
    DER=SegScore2S(SystemResultsDestination,[cd,'\Manual_Seg\'],...
       1,0,0,1)+19;
   
   
   Time=num2str(InitalTrainingTime+GetDerTimes*(i-1));
   
   fprintf(2,['DER Up To : ',Time, 'Sec',' is ',num2str(DER),'\n'])

   DER2{i}=DER;    
   
   catch
       
       fprintf(2,'There is No Manual Diarization File\n')
   end
    
    end

    clear RArgs;

