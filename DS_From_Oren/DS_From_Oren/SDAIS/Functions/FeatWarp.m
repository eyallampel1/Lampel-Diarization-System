function [WFeat] = FeatWarp( Feat, Dist, N)

% USAGE : [WFeat] = FeatWarp( Feat, Dist, N)
%
% Apply feature warping to a set of features using ditribution Dist
%
% INPUT :   Feat - D x K matrix of features
%           Dist - 'Normal','Uniform'
%           N - 1 x 1 states the number of features in each window
%
% OUTPUT :  WFeat - D x K matrix of warped features

% Set parameters
Dim = size(Feat,1);
NF = size(Feat,2);

% Generate distribution
switch Dist
    case 'Normal'
        K = (N+0.5-[N:-1:1])./N;
        W = icdf('Normal', K, 0, 1);
        
    case 'Uniform'
        K = (N+0.5-[N:-1:1])./N;
        W = icdf('Uniform', K, 0, 1);
end

% Map features
% Zero padding
Feat = [zeros(Dim, floor(N/2)) Feat zeros(Dim, floor(N/2))];
for i = 1 : Dim
    for j = 1 : NF
        [V I] = sort(Feat(i, j:j+N-1),'descend');
        Feat(i,j) = W(I(floor(N/2)));
    end
end

WFeat = Feat(:,1:end-N);