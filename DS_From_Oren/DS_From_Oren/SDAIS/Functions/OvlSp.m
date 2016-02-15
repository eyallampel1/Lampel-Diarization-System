function [OS, Feat] = OvlSp( Data, OSType, OSWinLen, OSThresh, Verbose )

% USAGE : [OS, Feat] = OvlSp( Data, OSType, OSWinLen, OSThresh)
%
% Detect overlapped speech segments
%
% INPUT :   Data - audio data
%           OSType - entropy,
%           OSWinLen - length of the non-speech window
%           OSThresh - threshold


if(Verbose == 1)
    fprintf('Overlap speech detection - %s', OSType);
    tic;
end


switch OSType
    case 'none'
        OS = [];
        Feat = [];
        
    case 'entropy'
        % Calculate entropy
        Feat = TimeEntropy(Data, OSWinLen, 2^16, 'nat', 1);
        
        % Calculate GMM
        [Priors, Mu, Sigma] = EM_init_kmeans(Feat', 4);
        
        % Sort values
        [Mu I] = sort(Mu);
        Sigma = Sigma(:,:,I);
        Priors =Priors(I);
        
        % Calculate threshold
        WL = Priors(3:4)./sum(Priors(3:4));
        OSth = [Sigma(:,:,4)-Sigma(:,:,3) ...
            2*Mu(:,4)*Sigma(:,:,3)-...
            2*Mu(:,3)*Sigma(:,:,4) ...
            2*Sigma(:,:,3)*Sigma(:,:,4)*...
            log(sqrt(Sigma(:,:,3)/Sigma(:,:,4)))+...
            Mu(:,3)^2*Sigma(:,:,4)-...
            Mu(:,4)^2*Sigma(:,:,3)-...
            2*Sigma(:,:,3)*Sigma(:,:,4)*...
            log(WL(1)/sqrt(Sigma(:,:,3)))+...
            2*Sigma(:,:,3)*Sigma(:,:,4)*...
            log(WL(2)/sqrt(Sigma(:,:,4)))];
        OSth = roots(OSth);
        OSth = OSth(find(OSth < Mu(4) & OSth > Mu(3)));
        if(isempty(OSth))
            OSth = Mu(4);
        end
        
        OSth = Mu(end) - (OSThresh*(Mu(end)-OSth));
        
        % Return values
        OS = (Feat > OSth);
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end