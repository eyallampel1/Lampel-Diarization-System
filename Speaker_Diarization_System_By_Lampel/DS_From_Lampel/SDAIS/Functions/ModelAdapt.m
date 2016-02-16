function [Prior Mean Cov] = ModelAdapt(Feat, UBM, Args)

% USAGE : [Prior Mean Cov] = ModelAdapt(Feat, UBM, Args)
%
% Adapt model parameters
%
% INPUT :   Feat - N x D matrix of features
%           UBM - UBM structure
%           Args - SIS input arguments
%
% OUTPUT :  Prior - 1 x K vector of priors
%           Mean - K x D vector of means
%           Cov - D x D x K - array of covariance matrices

switch Args.Mod
    
    case 'gmmubm'
        AdaptCoeff = (ones(1,3)).*Args.UBMR;
        [Prior Mean Cov] = EmGmm(Feat', UBM.Prior, UBM.Mean, ...
            UBM.Cov, 1, AdaptCoeff, 0, 0, 0);
        
    case 'somubm'
        [Mean Prior]= Kohonen(Feat', UBM.Mean, UBM.Grid, ...
            floor(Args.UBMSI*size(Feat,1)), 0.1, 0, ...
            Args.UBMSN, 0 );
        Cov = [];
        
    case 'kmubm'
        [Assign, Mean, Prior, Cov] = ...
            KMeans(Feat', UBM.Mean, Args.UBMKI, 1e-5);  
        
end
