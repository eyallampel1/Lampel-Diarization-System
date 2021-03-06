function [RDER] = SegScore2SNIST(HypDir, RefDir, Collar, Detailed, ...
    Save, MaxConv)

% Matlab segmentation scoring, receives a directory of hypothesized
% segmentations and a directory of reference segmentations.
% Filenames for the hypothesized and reference segmentations must comply
%
% USAGE: [DER] = SegScore2S(HypDir, RefDir, Collar, Save, Detailed, ...
%   MaxConv)
%
% INPUT:    HypDir - hypothesis files directory
%           RefDir - reference directory
%           Collar - collar value (float)
%           Save - save alligned segmentation
%           Detailed - presents detailed errors
%           MaxConv - set the number of maximum conversations to examine
%
% OUTPUT:   DER - Diarization error rate

% List files
HypFiles = dir([HypDir '*.txt']);
DetailedI = 0;
SaveI = 0;

if(nargin >= 4)
    DetailedI = Detailed;
end
if(nargin >= 5)
    SaveI = Save;
end
if(nargin >= 6)
    HypFiles = HypFiles(1:MaxConv+2);
end


% Collar and error initialization
Collar = Collar * 100;
DER = zeros(1,size(HypFiles,1)-2);
NSAS = zeros(1,size(HypFiles,1)-2); % Non speech as speech
SANS = zeros(1,size(HypFiles,1)-2); % Speech as non-speech
SMIX = zeros(1,size(HypFiles,1)-2); % Mixed speakers
SOVS = zeros(1,size(HypFiles,1)-2); % Overlapped speech

for i = 1 : size(HypFiles,1)
    % Load Hyp and Ref files
    Hyp = textread(fullfile(HypDir,HypFiles(i).name));
    Ref = textread(fullfile(RefDir,HypFiles(i).name));
    
    % Align segmentations
    Start = max(Hyp(1,1), Ref(1,1));
    End = min(Hyp(end,2), Ref(end,2));
    
    if(Hyp(1,1) ~= Start)
        I = find(Hyp(:,1) >= Start,1,'first');
        Hyp = Hyp(I-1:size(Hyp,1),:);
        Hyp(1,1) = Start;
    end
    if(Ref(1,1) ~= Start)
        I = find(Ref(:,1) >= Start,1,'first');
        Ref = Ref(I-1:size(Hyp,1),:);
        Ref(1,1) = Start;
    end
    if(Hyp(end,2) ~= End)
        I = find(Hyp(:,2) <= End, 1,'last');
        Hyp = Hyp(1:I+1,:);
        Hyp(end,2) = End;
    end
    if(Ref(end,2) ~= End)
        I = find(Ref(:,2) <= End, 1,'last');
        Ref = Ref(1:I+1,:);
        Ref(end,2) = End;
    end
    Ref(:,1:2) = Ref(:,1:2)-Start;
    Hyp(:,1:2) = Hyp(:,1:2)-Start;
    
    % Gen match matrix
    MatchMat = zeros(max(max(Hyp(:,3))+1,max(Ref(:,3))+1));
    Perm = 1 : size(MatchMat,1);
    
    % Segmentation to vector
    Ref = SegToVec(Ref, 100);
    Hyp = SegToVec(Hyp, 100);
    
    % Calculate matching
    Err = zeros(1,2);
    Rep = [0 2 1 3];
    Err(1) = sum(Ref ~= Hyp);
    HypT = zeros(size(Hyp));
    HypT(find(Hyp==1)) = 2;
    HypT(find(Hyp==2)) = 1;
    HypT(find(Hyp==3)) = 3;
    Err(2) = sum(Ref ~= HypT);
    [II VV] = min(Err);
    if(VV == 2)
        Hyp = HypT;
    end
    
    % Save aligned segmentation
    if(SaveI == 1)
        if(VV == 2)
            fprintf(2,'Replaced segmentation\n');
            HypMat = textread(fullfile(HypDir,HypFiles(i).name));
            HypMat(find(HypMat(:,3) == 1),3) = 4;
            HypMat(find(HypMat(:,3) == 2),3) = 1;
            HypMat(find(HypMat(:,3) == 4),3) = 2;
            dlmwrite(fullfile(HypDir,HypFiles(i).name), HypMat, 'delimiter','\t','precision',10);
        end
    end
    
%     Remove Ref non-speech and overlapped speech
%     I = find(Ref == 0);
%     Ref(I) = [];
%     Hyp(I) = [];
%     I = find(Ref == 3);
%     Ref(I) = [];
%     Hyp(I) = [];
    
%     Remove Hyp non-speech and overlapped speech
%     I = find(Hyp == 0);
%     Ref(I) = [];
%     Hyp(I) = [];
%     I = find(Hyp == 3);
%     Ref(I) = [];
%     Hyp(I) = [];
    
    % Remove collar
    if(Collar > 0)
        
        q = 1;
        while (q < size(Ref,2)-Collar)
            if((Ref(q) ~= Ref(q+1)) & (q > Collar))
                for k =  q-floor(Collar/2) : q+floor(Collar/2)
                    Ref(k) = -1;
                    Hyp(k) = -1;
                end
                q = k;
            end
            q = q+1;
        end
    end
    
    Hyp(find(Ref == -1)) = [];
    Ref(find(Ref == -1)) = [];
    
    
    % Calculate error
    Err = find(Ref~=Hyp);
    DER(i) = length(Err)/length(Ref)*100;
    NSAS(i) = sum(((Ref(Err) == 0) & (Hyp(Err) == 1)) | ...
        ((Ref(Err) == 0) & (Hyp(Err) == 2)))/length(Ref)*100;
    SANS(i) = sum(((Ref(Err) == 1) & (Hyp(Err) == 0)) | ...
        ((Ref(Err) == 2) & (Hyp(Err) == 0)))/length(Ref)*100;
    SMIX(i) = sum(((Ref(Err) == 1) & (Hyp(Err) == 2)) | ...
        ((Ref(Err) == 2) & (Hyp(Err) == 1)) )/length(Ref)*100;
    SOVS(i) = sum((Ref(Err) == 3) & (Hyp(Err) ~= 3))/length(Ref)*100;
    
    if(DetailedI == 1)
        if(DER(i) > 30)
            fprintf(2,['%d. %s: Start: %3.2f End: %3.2f, DER: %3.2f%% Time: %4.2f\n'],...
                i, HypFiles(i).name(1:end-4), ...
                Start, End, DER(i),length(Hyp)/100)
        else
            fprintf(['%d. %s: Start: %3.2f End: %3.2f, DER: %3.2f%% Time: %4.2f\n'],...
                i, HypFiles(i).name(1:end-4), ...
                Start, End, DER(i),length(Hyp)/100)
        end
    end
    
end

if(DetailedI == 1)
    figure()
    [NDER,BinsDER] = hist(DER,0:1:100);
    [NNSAS,BinsNSAS] = hist(NSAS,0:1:100);
    [NSANS,BinsSANS] = hist(SANS,0:1:100);
    [NSMIX,BinsSMIX] = hist(SMIX,0:1:100);
    [NSOVS,BinsSOVS] = hist(SOVS,0:1:100);
    
    bar(BinsDER, NDER, 1)
    hold on
    grid
    title(sprintf('Diarization error rate - %3.2f%%',mean(DER)));
    xlabel('Error [%]')
    ylabel('# Conversations')
    
    
    figure()
    subplot(2,2,1)
    bar(BinsNSAS, NNSAS, 1)
    hold on
    grid
    title(sprintf('Non speech as speech - %3.2f%%',mean(NSAS)));
    xlabel('Error [%]')
    ylabel('# Conversations')
    
    subplot(2,2,2)
    bar(BinsSANS, NSANS, 1)
    hold on
    grid
    title(sprintf('Speech as non speech - %3.2f%%',mean(SANS)));
    xlabel('Error [%]')
    ylabel('# Conversations')
    
    subplot(2,2,3)
    bar(BinsSMIX, NSMIX, 1)
    hold on
    grid
    title(sprintf('Mixed speech - %3.2f%%',mean(SMIX)));
    xlabel('Error [%]')
    ylabel('# Conversations')
    
    subplot(2,2,4)
    bar(BinsSOVS, NSOVS, 1)
    hold on
    grid
    title(sprintf('Overlapped speech - %3.2f%%',mean(SOVS)));
    xlabel('Error [%]')
    ylabel('# Conversations')
end

% Return values
RDER = mean(DER);



% Seg to vec function
function [SegVec] = SegToVec(Seg, Fs)

% USAGE : [SegVec] = SegToVec(Seg, Fs)
%
%   Segmetnation to vector
%
% INPUT :   Seg - Segmentation matrix
%           Fs - Sampling frequency
%
% OUTPUT :  SegVec - Segmentation vector

SegVec = zeros(1,floor(Seg(end,2)*Fs));
for l = 1 : size(Seg,1)
    SegVec(round(Seg(l,1)*Fs+1):...
        round(Seg(l,2)*Fs)) = Seg(l,3);
end


% Generate auto segmentation matrix
function [SegMat] = VecToSeg(VPath, FWInc)

% Initialize parameters
AutoSeg = zeros(1,3);
AutoSegR = 1;
Counter = 0;

for k = 1 : size(VPath,2)-1
    if(VPath(k) == VPath(k+1))
        Counter = Counter + 1;
    else
        Counter = Counter + 1;
        AutoSeg(AutoSegR,3) = VPath(k);
        AutoSeg(AutoSegR,2) = AutoSeg(AutoSegR,1) + Counter*FWInc;
        AutoSegR = AutoSegR + 1;
        AutoSeg = [AutoSeg; zeros(1,3)];
        AutoSeg(AutoSegR,1) = AutoSeg(AutoSegR-1,2);
        Counter = 0;
    end
end
k = k+1;
Counter = Counter + 1;
AutoSeg(AutoSegR,3) = VPath(k);
AutoSeg(AutoSegR,2) = AutoSeg(AutoSegR,1) + Counter*FWInc;

SegMat = AutoSeg;
