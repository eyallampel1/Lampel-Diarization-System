function [Feat] = DeltaFeat(Feat, Del, DelDel)

% USAGE : [Delta] = DeltaFeat(Feat, Del, DelDel)
% 
% Calculate delta and delta delta features
% 
% INPUT :   Feat - N x D matrix of features
%           Del - 1 x 1 boolean for delta features
%           DelDel - 1 x 1 boolean for delta delta features

if(Del == 1)
    vf=(4:-1:-4)/60;
    ww=ones(4,1);
    nf = size(Feat,1);
    nc = size(Feat,2);
    cx=[Feat(ww,:); Feat; Feat(nf*ww,:)];
    vx=reshape(filter(vf,1,cx(:)),nf+8,nc);
    vx(1:8,:)=[];
    Delta = vx;
    
    Feat = [Feat Delta];
    
    if(DelDel == 1)
        cx=[Delta(ww,:); Delta; Delta(nf*ww,:)];
        vx=reshape(filter(vf,1,cx(:)),nf+8,nc);
        vx(1:8,:)=[];
        DeltaDelta = vx;
        
        Feat = [Feat DeltaDelta];
    end
end
    
        