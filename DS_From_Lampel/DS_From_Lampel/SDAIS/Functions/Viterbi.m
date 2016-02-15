function [VPath VDist] = Viterbi( Feat, Models, VPath, MinDur, ModNum, Iter,...
    AdaptTransMat, AdaptTransMatIter, Type, Verbose)

% USAGE: [VPath VDist] = Viterbi( Feat, Models, VPath, MinDur, ModNum, Iter,...
%     AdaptTransMat, AdaptTransMatIter, Type)
% Calculate the Viterbi path

if(Verbose == 1)
    fprintf('\tClustering - %s', Type);
    tic;
end


% Build transition matrix
[TransMat] = GenTransMat(VPath, MinDur, Iter, ModNum, AdaptTransMat,...
   AdaptTransMatIter);
TransMat(2,3) = 1e-3;
TransMat(3,2) = 1e-3;
TransMat(2,1) = 1e-3;
TransMat(3,1) = 1e-3;
TransMat = TransMat./repmat(sum(TransMat,2),1,3);

switch Type
    case 'som'
        % Convert models
        VModel = zeros([size(Models(1).Model) size(Models,2)]);
        for MI = 1 : size(Models,2)
            VModel(:,:,MI) = Models(MI).Model;
        end
    
        % Calculate path
        [VPath VDist VB] =  ViterbiMDSOM( TransMat, ...
        Feat', VModel, MinDur, ones(size(Models,2),1)./size(Models,2));
        VPath = VPath';
        
    case 'gmm'
           % Convert models
        VModel = zeros([size(Models(1).Model) size(Models,2)]);
        for MI = 1 : size(Models,2)
            VModel(:,:,MI) = Models(MI).Model;
        end
    
        % Calculate path
        [VPath VDist VB] =  ViterbiMDSOM( TransMat, ...
        Feat', VModel, MinDur, ones(size(Models,2),1)./size(Models,2));
        VPath = VPath';
        
end

if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end
