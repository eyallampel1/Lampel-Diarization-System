function [Feat] = FeatNorm( Feat, Type, Verbose )

% USAGE: [Feat] = FeatNorm( Feat, Type )
% 
% Normalize features
%
% INPUT:    Feat - set of features
%           Type - type, mean, meanvar

if(Verbose == 1)
    fprintf('Feature normalization - %s', Type);
    tic;
end

switch Type
 %   case 'none'
 
    case 'cms'
        Mean = mean(Feat);
        Feat = Feat - repmat(Mean,size(Feat,1),1);
    
    case 'cmsvar'
        Mean = mean(Feat);
        Std = sqrt(var(Feat));
        Feat = Feat - repmat(Mean,size(Feat,1),1);
        Feat = Feat ./ repmat(Std,size(Feat,1),1);
        
    case 'warp'
        [Feat] = FeatWarp( Feat', 'Normal', 300)';
        
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end