function [SegVec] = SegToVec(Seg, Fs)

% USAGE : [SegVec] = SegToVec(Seg, Fs)
%   
%   Segmetnation to vector
% 
% INPUT :   Seg - Segmentation matrix
%           Fs - Sampling frequency
%
% OUTPUT :  SegVec - Segmentation vector

SegVec = ones(1,floor(Seg(end,2)*Fs)).*-1;
for l = 1 : size(Seg,1)
    SegVec(round(Seg(l,1)*Fs+1):...
        round(Seg(l,2)*Fs)) = Seg(l,3);
end
