function [Data] = ImgToData(IMGName, Scale, Bias)

% USAGE: [Data] = ImgToData(Name, Scale, Bias)
% Transforms an image into a set of data points 
% 
% INPUT : IMGName - image file name
%         Scale - 1 x 1 scale value
%         Bias - 2 x 1 bias value

IMG = imread(IMGName);
[Y X] = find(IMG ~= 255);
X = X./size(IMG,1);
Y = Y./size(IMG,2);
Data = ([X(:) Y(:)]' + repmat(Bias,1,size(X,1))) .*Scale;

