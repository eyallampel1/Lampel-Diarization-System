function [Entropy] = TimeEntropy(Data, EntropyWindowS, ...
    EntropyQ, Measure, Normalize)

% USAGE [Entropy] = TimeEntropy(ConvData, EntropyWindowS, ...
%     EntropyQ, Measure, Normalize)
%
% TimeEntropycalculates the entropy using the histogram approximation
% algorithm, first a histogram is calculated, number fof appearances is 
% normalized and then the entropy is calculated
%
% INPUT :   Data - N*1 Samples
%           EntropyWindowS - Number of samples used to frame the data
%           EntropyQ - Number of histogram bins
%           Measure - 'bit' for log_2, 'nat' for log_e, 'dit' for log_10
%           Normalize - (0) do not normalize the entropy (1) - normalize

Data = Data./max(abs(Data));
% Normalize data
Data = floor(Data.*2^15);

% Calculate Probabilities Vector
[n, xout] = hist(Data,-EntropyQ/2:EntropyQ/2);
DataSize = size(Data);

% Normalize Observation Appearance
P = n./DataSize(1);

% Frame the data
Data = EnFrame(Data, EntropyWindowS);
DataSize = size(Data);

% Entropy Storage

Entropy = zeros(DataSize(1),1);

for k = 1 : DataSize(1)
    
    Vec = Data(k,:)+2^15+1;
    % Calculate Entropy
    switch Measure
        case 'bit'
            Entropy(k) = -sum(log2(P(Vec)));
        case 'nat'
            Entropy(k) = -sum(log(P(Vec)));
        case 'dit'
            Entropy(k) = -sum(log10(P(Vec)));
    end
    
    Entropy(k) = Entropy(k)./size(Vec,1);
end

% Normalize energy
if(Normalize == 1)
    Entropy = (Entropy - min(Entropy))/...
        (max(Entropy)-min(Entropy));
end
