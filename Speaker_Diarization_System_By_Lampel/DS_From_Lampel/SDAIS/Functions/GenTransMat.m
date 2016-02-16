function [TransMat] = GenTransMat(ViterbiPath, MinDur, Iteration,...
    MelModelsSize, AdaptiveViterbi, AdaptiveViterbiIter)

% Initialize transition matrix
MinDurCounter = 0;
if(Iteration == 1 && AdaptiveViterbi == 1)
    TransMat = zeros(MelModelsSize);
    for VI = 2 : size(ViterbiPath,1)
        if(ViterbiPath(VI-1) == ViterbiPath(VI))
            MinDurCounter = MinDurCounter+1;
            if(MinDurCounter > MinDur)
                TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) = ...
                    TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) + 1;
            end
        else
            MinDurCounter = 0;
            TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) = ...
                TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) + 1;
        end
    end
    TransMat = TransMat./repmat(sum(TransMat,2),1,...
        size(TransMat,2));
elseif(AdaptiveViterbiIter == 1)
    TransMat = zeros(MelModelsSize);
    for VI = 2 : size(ViterbiPath,1)
        if(ViterbiPath(VI-1) == ViterbiPath(VI))
            MinDurCounter = MinDurCounter+1;
            if(MinDurCounter > MinDur)
                TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) = ...
                    TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) + 1;
            end
        else
            MinDurCounter = 0;
            TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) = ...
                TransMat(ViterbiPath(VI-1),ViterbiPath(VI)) + 1;
        end
    end
    TransMat = TransMat./repmat(sum(TransMat,2),1,...
        size(TransMat,2));
else
    TransMat = ones(MelModelsSize)...
        .*(1/(MelModelsSize+1))+...
        eye(MelModelsSize)*(1/(MelModelsSize+1));
end