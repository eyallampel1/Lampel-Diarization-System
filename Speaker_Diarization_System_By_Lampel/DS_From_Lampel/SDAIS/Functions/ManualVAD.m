function [Vad] = ManualVAD( Dir, FileName, WinLen, Collar )

% Generate Vad from manual segmentation for UBM training
%
% INPUT:    Dir - directory for vad files
%           FileName - file name
%           WinLen - the length of the window
%           Collar - Collar remove in secs

% Open file
Seg = dlmread(fullfile(Dir, [FileName(1:end-3) 'txt']));

% Remove collar
Time = Seg(:,2)-Seg(:,1);
I = find(Time <= Collar);
Seg(I,:) = [];
Time(I) = [];
Seg(:,1) = Seg(:,1)+Collar/2;
Seg(:,2) = Seg(:,2)-Collar/2;

Vad = SegToVec(Seg, WinLen);
