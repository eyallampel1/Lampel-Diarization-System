function [] = PrintStruct(S)

% USAGE : [] = PrintStruct(S)
%
% Print structure fields
%
% INPUT : S - structure

A = fieldnames(S);
warning off
for i = 1 : size(A,1)
    fprintf('%20s \t%3s\n',A{i},num2str(getfield(S,A{i})));
end
