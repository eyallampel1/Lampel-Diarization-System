function [PM] = GenPM( Feat, VPath )

% USAGE : [PM] = GenPM( Feat, VPath )
% 
% Generate pre-models

for i = 1 : max(VPath)
    PM(i).PM = Feat(find(VPath==i),:);
end