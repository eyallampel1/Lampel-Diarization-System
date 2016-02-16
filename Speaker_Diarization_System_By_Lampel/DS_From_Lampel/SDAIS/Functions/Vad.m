function [NS, Feat] = Vad( Data, Fs, NSType, NSWinLen, NSThresh, Verbose )

% USAGE : [NS] = Vad( Data, Fs, NSType, NSWinLen, NSThresh)
% 
% Detect non speech segments
%
% INPUT :   Data - audio data
%           Fs - sampling frequency
%           NSType - energy,
%           NSWinLen - length of the non-speech window
%           NSThresh - threshold

if(Verbose == 1)
    fprintf('Voice activity detection - %s', NSType);
    tic;
end

switch NSType
    case 'energy'
        Feat = TimeEnergy(Data, NSWinLen, 0);
        NS = ( Feat < min(Feat) + NSThresh*( mean(Feat)) );
        while(sum(NS) < size(Feat,1)/100)
            NSThresh = NSThresh + 0.01;
            NS = ( Feat < min(Feat) + NSThresh*( max(Feat)-min(Feat)) );
        end
        
    case 'vadsohn'
        [vs,zo]=vadsohn(Data, Fs, 'a');
        rd = mod(size(vs,1),NSWinLen);
        vs = reshape(vs(1:end-rd), NSWinLen, []);
        Feat = sum(vs)';
        NS = (Feat < floor(NSWinLen/4));
        Feat = Feat./NSWinLen;     
        
    case 'bigauss'
         Feat = TimeEnergy(Data, NSWinLen, 0);
         Feat = Feat./max(Feat)+1e-10;
         Feat = 20*log(Feat);
         
         MeanI = randn(1,3);
         [AssignO MeanO PriorO CovO] = KMeans(Feat', MeanI, 15, 1e-5, 0);
         [PriorO MeanO CovO] = EmGmm(Feat', PriorO, MeanO, CovO, 0, 0, 15, 1e-5, 0);
         [MeanO I]= sort(MeanO);
         CovO = CovO(:,:,I);
         PriorO = PriorO(I);
         
         % Intersection
         OSth = [(CovO(:,:,1)-CovO(:,:,2))/(2*CovO(:,:,1)*CovO(:,:,2)) ...
             MeanO(1)/CovO(:,:,1)-...
             MeanO(2)/CovO(:,:,2) ...
             MeanO(2)^2/(2*CovO(:,:,2)) - ...
             MeanO(1)^2/(2*CovO(:,:,1)) + ...
             log(PriorO(1)) - log(PriorO(2)) + ...
             log(sqrt(CovO(:,:,2))) - log(sqrt(CovO(:,:,1)))];
         OSth = roots(OSth);
         OSth = OSth(find(OSth < MeanO(2) & OSth > MeanO(1)));
         OSth = OSth;
         if(isempty(OSth))
             OSth = MeanO(1);
         end
        
        NS = Feat < (OSth + NSThresh*sqrt(CovO(:,:,1)));
        
        PlotGMM(PriorO, MeanO, CovO, min(Feat):max(Feat), Feat);
        line([(OSth + NSThresh*sqrt(CovO(:,:,1))) (OSth + NSThresh*sqrt(CovO(:,:,1)))],[0 0.015],'Color','g');
         
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end