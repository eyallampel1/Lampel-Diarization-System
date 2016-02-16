function [AutoSeg] = AutoSegMatFile(VPath, FWInc, File, ResDir, ...
    TimeStamp, Iteration)

% USAGE: [AutoSeg] = AutoSegMatFile(VPath, FWInc, File, ...
%     ResDir, TimeStamp)
%
% GenAutoSeg generates the automatic segmentation of the conversation given
% the Viterbi path and the increment in time associated with each of the
% samples
%
% INPUT:    VPath - Viterbi analyzed path of the system.
%           FWInc - Window increment in seconds
%           File - Filename
%           ResDir - Directory to output the automatic segmentation
%           TimeStamp - Add a timestamp to the file if required
%           Iteration - Add iteration stamp for the file if required
%
% OUTPUT:   AutoSeg - Matrix contains the automatic segmentation


% Generate auto segmentation matrix
% Initialize parameters
AutoSeg = zeros(length(find(diff(VPath)~=0))+1,3); % Oren - preallocation (22/11/10)
AutoSegR = 1;
Counter = 0;
for k = 1 : size(VPath,1)-1
    if(VPath(k) == VPath(k+1))
        Counter = Counter + 1;
    else
        Counter = Counter + 1;
        AutoSeg(AutoSegR,1) = VPath(k); % column 1 - Identifier
        AutoSeg(AutoSegR,3) = AutoSeg(AutoSegR,2) + Counter*FWInc; % column 3 - end time
        AutoSegR = AutoSegR + 1;
        AutoSeg(AutoSegR,2) = AutoSeg(AutoSegR-1,3);% column 2 - start time
        Counter = 0;
    end
end
k = k+1;   
Counter = Counter + 1;
AutoSeg(AutoSegR,1) = VPath(k);
AutoSeg(AutoSegR,3) = AutoSeg(AutoSegR,2) + Counter*FWInc;

% Save auto segmentation file
if(Iteration <= 9 )
    Iteration = ['0' num2str(Iteration)];
else
    Iteration = num2str(Iteration);
end

AutoSegT = [AutoSeg(:,2) AutoSeg(:,3) AutoSeg(:,1)-1];
AutoSeg = AutoSegT;

AutoSegFile = fullfile(ResDir,[File  TimeStamp  ...
    Iteration '.txt']);

% Check if results dir exists
if(exist(ResDir,'dir'))
    dlmwrite(AutoSegFile, AutoSeg, 'delimiter','\t','precision',10);
else
    mkdir(ResDir);
    dlmwrite(AutoSegFile, AutoSeg, 'delimiter','\t','precision',10);
end
