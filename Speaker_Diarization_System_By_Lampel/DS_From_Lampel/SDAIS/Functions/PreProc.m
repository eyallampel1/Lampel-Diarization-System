function [Data] = PreProc( Data, PreProcType, Verbose )

% USAGE : [Data] = PreProc( Data, PreProcType )
% 
% INPUT :   Data - input data
%           PreProcType - type of pre-processing, preemph,

if(Verbose == 1)
    fprintf('Pre-processing');
    tic;
end


switch PreProcType
    case 'preemph'
        Data = filter([1 -0.95], 1, Data);
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end