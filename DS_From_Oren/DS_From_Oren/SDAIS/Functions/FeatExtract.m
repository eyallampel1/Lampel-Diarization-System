function Feat = FeatExtract( Data, Fs, Type, WinLen, WinInc, AnaOrd, ...
    Energy, Verbose )

% USAGE : Feat = FeatExtract( Data, Fs, Type,WinLen, WinInc, AnaOrd, ...
%     Energy, Verbose )
% 
% Calculates one of several features
% 
% INPUT :   Data - audio data
%           Fs - sampling frequency
%           Type - features type, mfcc
%           WinLen - length of features window
%           WinInc - features window increment
%           AnaOrd - analysis order
%           Energy - include energy, residual coefficinet


if(Verbose == 1)
    fprintf('Feature extraction - %s',Type);
    tic;
end

switch Type
    case 'mfcc'
        Opt = 'M';
        if(Energy == 1)
            Opt = [Opt '0'];
        end
                
        Feat = melcepst(Data, Fs, Opt, AnaOrd, floor(3*log(Fs)), ...
            ceil(WinLen*Fs), floor(WinInc*Fs), 0, 0.5);
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end