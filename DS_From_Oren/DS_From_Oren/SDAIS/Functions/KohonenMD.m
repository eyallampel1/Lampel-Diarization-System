function [SOM C]= KohonenMD(Data, SOMI, LDU, Iters, SigmaS , SigmaF )

% // SOM training using the Kohonen algorithm
% // At each iteration, a random data point is chosen, the closest unit
% // is selected, and all of the units are moved toward the datapoint in
% // proportion to their distance from the winner (in the low-dimensional
% // space).  The 'proportion' is eta*exp(-d/2sigma^2).
% //
% // INPUTS:
% //     Data - D x N matrix of N input vectors
% //     SOMI - D x M matrix of neural units' preferred inputs
% //     LDU - m x M matrix of neural units' low-dimensional coordinates
% //     Iters - the number of iterations
% //     EtaS & EtaF - the start & final values of eta
% //     SigmaS & SigmaF - the start & final values of sigma
% //
% // OUTPUTS:
% //     SOM - D x M A matrix of aligned neurons
% //	   WN - 1 x M The number of times a neuron has won

% Set constants
[Dim NData] = size(Data);
NNeurons = size(SOMI,2);

% Set learning factors delta
DSigma = (SigmaS - SigmaF)/Iters;
Sigma = SigmaS;

% Set covariances
C = zeros(Dim,Dim,NNeurons);
for i = 1 : NNeurons
    C(:,:,i) = eye(Dim);
end

% Set the SOM
SOM = SOMI;

% Set the distance and low dim distance matrix
Dist = zeros(NNeurons, NData);
LDDist = zeros(NNeurons, NData);

for iter = 1 : Iters
    % Calculate the distance
    for i = 1 : NNeurons
        [V I] = eig(C(:,:,i));
        Dist(i,:) = sum((((I^-0.5)*V'*Data-repmat((I^-0.5)*V'*SOM(:,i),1,NData))).^2);
    end
    
    % Find the winner neuoron for each observation
    [V I] = min(Dist);
    
    % Calculate low dimensional distance
    for i = 1 : NData
        LDDist(:,i) = exp(-sum((repmat(LDU(:,I(i)),1,NNeurons)-LDU).^2)./(2*Sigma^2))';
    end
    
    for i = 1 : NNeurons
        [V I] = eig(C(:,:,i));
        SOM(:,i) = sum(repmat(LDDist(i,:),Dim,1).*(Data),2)./sum(LDDist(i,:));
        C(:,:,i) = cov((repmat(LDDist(i,:),Dim,1).*Data)') + eye(Dim).*1e-3;
    end
    
    Sigma = Sigma - DSigma;
end

