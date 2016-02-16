function [Energy] = TimeEnergy(Data, Window, Normalize)

% USAGE [Energy] = TimeEnergy(Data, Window, Normalize)
%
% TimeEnergy calcualtes the energy of the signal for the required windows
% and normalizes it to the range [0 1] if required
%
% INPUT :   ConvData - N*1 Samples
%           Window - Number of samples used to frame the data
%           Normalize - Normalize (1) or do not normalize (0) the energy

% Frame the data
Data = EnFrame(Data, Window);

DataSize = size(Data);

% Energy Storage
Energy = zeros(DataSize(1),1);

for k = 1 : DataSize(1)
    Energy(k) = sum(Data(k,:).^2);
end

% Normalize energy
if(Normalize == 1)
    Energy = (Energy - min(Energy))/...
        (max(Energy)-min(Energy));
end
