function [Score, N, Bins] = SegScore(HypDir, RefDir, Collar)

% Matlab segmentation scoring, receives a directory of hypothesized 
% segmentations and a directory of reference segmentations.
% Filenames for the hypothesized and reference segmentations must comply
% 
% USAGE: [Score, N, Bins] = SegScore(HypDir, RefDir, Collar)
%
% INPUT:    HypDir - hypothesis files directory
%           RefDir - reference directory 
%           Collar - collar value (float)
%
% OUTPUT:   Score - score value
%           N, Bins - histrogram values

% List files
HypFiles = dir(HypDir);

% Collar and error
Collar = Collar * 100;
DER = zeros(1,size(HypFiles,1)-2);

for i = 3 : size(HypFiles,1)
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
    MatchMat = zeros(max(max(Hyp(:,3))+1,max(Ref(:,3)))+1);
    Perm = 1 : size(MatchMat,1);
    
    % Segmentation to vector
    Ref = SegToVec(Ref, 100);
    Hyp = SegToVec(Hyp, 100);
    
    % Fill Error matrix
    for k = 1 : size(MatchMat,1)
        for j = 1 : size(MatchMat,2)
            I = find(Hyp == Perm(j)-1 & Ref ~= j-1 );
            MatchMat(Perm(j),j) = MatchMat(Perm(j),j) + ...
                length(I);
        end
        Perm = circshift(Perm',1)';
    end
  

    
    % Calculate match
    Matching = Hungarian(MatchMat)';
    % Map Hyp
    Hyp = Matching(Hyp+1)-1;
    
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
    DER(i-2) = sum(Ref ~= Hyp)/length(Ref)*100;

    if(DER(i-2) > 30)
        fprintf(2,['%d. %s: Start: %3.2f End: %3.2f, DER: %3.2f%% Time: %4.2f' ...
            '\n'], i-2, HypFiles(i).name(1:end-4), ...
            Start, End, DER(i-2),length(Hyp)/100)
    else
        fprintf(['%d. %s: Start: %3.2f End: %3.2f, DER: %3.2f%% Time: %4.2f' ...
            '\n'], i-2, HypFiles(i).name(1:end-4), ...
            Start, End, DER(i-2),length(Hyp)/100)
    end
 
end
[N,Bins] = hist(DER,0:1:100);
bar(Bins, N, 1)
Score = mean(DER);
grid
title(sprintf('DER - %3.2f%%',Score))
xlabel('DER [%]')
ylabel('# Conversations')
axis([min(Bins), max(Bins), 0, max(N)+2])

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