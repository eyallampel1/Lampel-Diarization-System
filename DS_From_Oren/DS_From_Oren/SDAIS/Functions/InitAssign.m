function [PM, NSI, OSI, SP, IDX] = InitAssign(Feat, OS, Vad, FeatWinLen, ...
    FeatWinInc, NonspWinLen, OvspWinLen, NumClust, SdInit, Verbose, UBM)

% USAGE: [Clusters, NSI, OSI, SI] = InitAssign(Feat, OS, Vad, FeatWinLen, ...
%     FeatWinInc, NonspWinLen, OvspWinLen, SdInit)
% 
% INPUT :   Feat - set of features
%           OS - overlapped speech indices
%           Vad - voice activity detection indices
%           FeatWinLen - length of the feature extraction window
%           FeatWinInc - increment of the feature extraction
%           NonspWinLen - non speech detection window length
%           OvspWinLen - overelapped speech window length
%           SdInit - initialization method, wskma
%           UBM - UBM filename
%
% OUTPUT :  PM - preModels
%           NSI - nonspeech indices
%           OSI - overlapped speech indices
%           SP - speech indices
%           IDX - speech indices

if(Verbose == 1)
    fprintf('Initial assignment - %s', SdInit);
    tic;
end

switch SdInit
    case 'random'
        % Expand speech and overlapped speech indices
        ExpandFactorNS = NonspWinLen/FeatWinInc;
        ExpandFactorOS = OvspWinLen/FeatWinInc;
        OST = reshape(repmat(OS,1,ExpandFactorOS)',[],1);
        if(size(OST,1) > size(Feat,1))
            OS = OST(1:size(Feat,1));
        else
            OS = [OST;zeros(size(Feat,1)-size(OST,1),1)];
        end
        VadT = reshape(repmat(Vad,1,ExpandFactorNS)',[],1);
        if(size(VadT,1) > size(Feat,1))
            Vad = VadT(1:size(Feat,1));
        else
            Vad = [VadT;ones(size(Feat,1)-size(VadT,1),1)];
        end
        
        % Get speech indices
        SP = find(~(OS | Vad));
        
        % Random assignment
        IDX = randint(1,size(SP,1));
        while(sum(IDX) == 0)
            IDX = randint(1,size(SP,1));
        end
        IDX = IDX+1;
        
        % Assign indices
        NSI = find(Vad);
        OS(find(Vad)) = 0;
        OSI = find(OS);
        
        % Assign clusters
        PM(1).PM = Feat(NSI,:);
        for i = 1 : max(IDX)
            PM(i+1).PM = Feat(SP(find(IDX==i)),:);
        end
        
    case 'srandom'
        % Expand speech and overlapped speech indices
        ExpandFactorNS = NonspWinLen/FeatWinInc;
        ExpandFactorOS = OvspWinLen/FeatWinInc;
        OST = reshape(repmat(OS,1,ExpandFactorOS)',[],1);
        if(size(OST,1) > size(Feat,1))
            OS = OST(1:size(Feat,1));
        else
            OS = [OST;zeros(size(Feat,1)-size(OST,1),1)];
        end
        VadT = reshape(repmat(Vad,1,ExpandFactorNS)',[],1);
        if(size(VadT,1) > size(Feat,1))
            Vad = VadT(1:size(Feat,1));
        else
            Vad = [VadT;ones(size(Feat,1)-size(VadT,1),1)];
        end
        
        % Get speech indices
        SP = find(~(OS | Vad));
        
        % Cluster indices
        CII = SP(2:end) - SP(1:end-1);
        CI = find(CII ~= 1);
        Clusters{1} = SP(1:CI(1));
        for i = 2 : size(CI,1)
            Clusters{i} = SP(CI(i-1)+1:CI(i));
        end
        Clusters{i+1} = SP(CI(i)+1:end);
        
        % Random assignment
        RandIDX = randint(1,size(Clusters,2));
        while(sum(RandIDX) == 0)
            RandIDX = randint(1,size(Clusters,2));
        end
        RandIDX = RandIDX+1;
        IDX = [];
        
        for i = 1:size(RandIDX,2)
            IDX = [IDX repmat(RandIDX(i),1,size(Clusters{i},1))];
        end
        
        % Assign indices
        NSI = find(Vad);
        OS(find(Vad)) = 0;
        OSI = find(OS);
        
        % Assign clusters
        PM(1).PM = Feat(NSI,:);
        for i = 1 : max(IDX)
            PM(i+1).PM = Feat(SP(find(IDX==i)),:);
        end
    
    case 'kmeans'
        % Expand speech and overlapped speech indices
        ExpandFactorNS = NonspWinLen/FeatWinInc;
        ExpandFactorOS = OvspWinLen/FeatWinInc;
        OST = reshape(repmat(OS,1,ExpandFactorOS)',[],1);
        if(size(OST,1) > size(Feat,1))
            OS = OST(1:size(Feat,1));
        else
            OS = [OST;zeros(size(Feat,1)-size(OST,1),1)];
        end
        VadT = reshape(repmat(Vad,1,ExpandFactorNS)',[],1);
        if(size(VadT,1) > size(Feat,1))
            Vad = VadT(1:size(Feat,1));
        else
            Vad = [VadT;ones(size(Feat,1)-size(VadT,1),1)];
        end
        
        % Get speech indices
        SP = find(~(OS | Vad));
        
        % Generate speech matrix
        SpeechMat = Feat(SP,:)';
        
        % K-Means/SOM
        MeanI = randperm(size(SpeechMat,2));
        MeanI = SpeechMat(:,MeanI(1:NumClust));
        
        [IDX] = kmeans(SpeechMat', NumClust, 'emptyaction', 'singleton')';          
        %[IDX MeanO PriorO CovO] = KMeans(SpeechMat, MeanI, 100, 1e-5, 0);  
        %IDX = IDX + 1;
        
        % Assign indices
        NSI = find(Vad);
        OS(find(Vad)) = 0;
        OSI = find(OS);
        
        % Assign clusters
        PM(1).PM = Feat(NSI,:);
        for i = 1 : max(IDX)
            PM(i+1).PM = Feat(SP(find(IDX==i)),:);
        end
        
    case 'skmeans'
        
        % Expand speech and overlapped speech indices
        ExpandFactorNS = NonspWinLen/FeatWinInc;
        ExpandFactorOS = OvspWinLen/FeatWinInc;
        OST = reshape(repmat(OS,1,ExpandFactorOS)',[],1);
        if(size(OST,1) > size(Feat,1))
            OS = OST(1:size(Feat,1));
        else
            OS = [OST;zeros(size(Feat,1)-size(OST,1),1)];
        end
        VadT = reshape(repmat(Vad,1,ExpandFactorNS)',[],1);
        if(size(VadT,1) > size(Feat,1))
            Vad = VadT(1:size(Feat,1));
        else
            Vad = [VadT;ones(size(Feat,1)-size(VadT,1),1)];
        end
        
        % Get speech indices
        SP = find(~(OS | Vad));
        
        % Cluster indices
        CII = SP(2:end) - SP(1:end-1);
        CI = find(CII ~= 1);
        Clusters{1} = SP(1:CI(1));
        for i = 2 : size(CI,1)
            Clusters{i} = SP(CI(i-1)+1:CI(i));
        end
        Clusters{i+1} = SP(CI(i)+1:end);
        
        % Calculate the segmentation matrix
        ClustMat = [];
        MeanMat = [];
        for i = 1 : size(Clusters,2)
            MeanMat = [MeanMat mean(Feat(Clusters{i},:),1)'];
        end
        
        % K-Means/SOM
        MeanI = randperm(size(MeanMat,2));
        MeanI = MeanMat(:,MeanI(1:NumClust));
        
        [IDXKM] = kmeans(MeanMat', NumClust, 'emptyaction', 'singleton')';
        %[IDXKM MeanO PriorO CovO] = KMeans(MeanMat, MeanI, 100, 1e-5, 0);
        %IDXKM = IDXKM + 1;
        
        IDX = [];
        
        for i = 1:size(IDXKM,2)
            IDX = [IDX repmat(IDXKM(i),1,size(Clusters{i},1))];
        end
        
        % Assign indices
        NSI = find(Vad);
        OS(find(Vad)) = 0;
        OSI = find(OS);
        
        % Assign clusters
        PM(1).PM = Feat(NSI,:);
        for i = 1 : max(IDX)
            PM(i+1).PM = Feat(SP(find(IDX==i)),:);
        end
         
    case 'wskmeans'
        
        % Expand speech and overlapped speech indices
        ExpandFactorNS = NonspWinLen/FeatWinInc;
        ExpandFactorOS = OvspWinLen/FeatWinInc;
        OST = reshape(repmat(OS,1,ExpandFactorOS)',[],1);
        if(size(OST,1) > size(Feat,1))
            OS = OST(1:size(Feat,1));
        else
            OS = [OST;zeros(size(Feat,1)-size(OST,1),1)];
        end
        VadT = reshape(repmat(Vad,1,ExpandFactorNS)',[],1);
        if(size(VadT,1) > size(Feat,1))
            Vad = VadT(1:size(Feat,1));
        else
            Vad = [VadT;ones(size(Feat,1)-size(VadT,1),1)];
        end
        
        % Get speech indices
        SP = find(~(OS | Vad));
        
        % Cluster indices
        CII = SP(2:end) - SP(1:end-1);
        CI = find(CII ~= 1);
        Clusters{1} = SP(1:CI(1));
        for i = 2 : size(CI,1)
            Clusters{i} = SP(CI(i-1)+1:CI(i));
        end
        Clusters{i+1} = SP(CI(i)+1:end);
        
        % Calculate the segmentation matrix
        ClustMat = [];
        MeanMat = [];
        for i = 1 : size(Clusters,2)
            MeanMat = [MeanMat mean(Feat(Clusters{i},:),1)'];
            ClustMat = [ClustMat repmat(MeanMat(:,end), ...
                1,size(Clusters{i},1))]; 
        end
        
        % K-Means/SOM
         MeanI = randperm(size(MeanMat,2));
         MeanI = MeanMat(:,MeanI(1:NumClust));

        [IDX] = kmeans(ClustMat', NumClust, 'emptyaction', 'singleton')';
        %[IDX MeanO PriorO CovO] = KMeans(ClustMat, MeanI, 100, 1e-5, 0);
        %IDX = IDX + 1;
        
        % Assign indices
        NSI = find(Vad);
        OS(find(Vad)) = 0;
        OSI = find(OS);
        
        % Assign clusters
        PM(1).PM = Feat(NSI,:);
        for i = 1 : max(IDX)
            PM(i+1).PM = Feat(SP(find(IDX==i)),:);
        end
        
    case 'somubm'
        
        % Load SOM UBM
        load(['UBM/' UBM]);
        
        % Expand speech and overlapped speech indices
        ExpandFactorNS = NonspWinLen/FeatWinInc;
        ExpandFactorOS = OvspWinLen/FeatWinInc;
        OST = reshape(repmat(OS,1,ExpandFactorOS)',[],1);
        if(size(OST,1) > size(Feat,1))
            OS = OST(1:size(Feat,1));
        else
            OS = [OST;zeros(size(Feat,1)-size(OST,1),1)];
        end
        VadT = reshape(repmat(Vad,1,ExpandFactorNS)',[],1);
        if(size(VadT,1) > size(Feat,1))
            Vad = VadT(1:size(Feat,1));
        else
            Vad = [VadT;ones(size(Feat,1)-size(VadT,1),1)];
        end
        
        % Get speech indices
        SP = find(~(OS | Vad));
        
        % Cluster indices
        CII = SP(2:end) - SP(1:end-1);
        CI = find(CII ~= 1);
        Clusters{1} = SP(1:CI(1));
        for i = 2 : size(CI,1)
            Clusters{i} = SP(CI(i-1)+1:CI(i));
        end
        Clusters{i+1} = SP(CI(i)+1:end);
        
        % Map adaptation for each of the clusters
        ClustersMap = cell(size(Clusters));
        
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end