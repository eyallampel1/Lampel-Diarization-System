function [] = PlotGMM(Prior, Mean, Cov, Range, Data)

% USAGE : [] = Plot2DGMM(Prior, Mean, Cov, Range)
%
% Generate a plot for a two dimensional GMM
% INPUT : Prior - 1 x K vector of priors
%         Mean - D x K matrix of means
%         Cov - D x D x K array of covariance matrices
%         Range - 1 x N  vector of points
%         Data - Data points used for training

% Check dimension
if(size(Mean,1) > 2)
    error('Max two dimensional GMM');
end

% Set the number of mixtures
NME = size(Mean,2);

% Set data, points
if(size(Mean,1) == 2)
    [X Y] = meshgrid(Range,Range);
    Points = [X(:)';Y(:)'];
    Pr = zeros(size(Points,2), NME);
else
    Points = Range;
end

if(size(size(Cov),2) == 3)
    for i = 1 : NME
        Pr(:,i) =  Prior(i).*gaussPDF(Points, Mean(:,i), Cov(:,:,i));
    end
else
    for i = 1 : NME
        Pr(:,i) =  Prior(i).*gaussPDF(Points, Mean(:,i), diag(Cov(:,i)));
    end
end

% Draw mixture
if(size(Mean,1) == 2)
    Pr = sum(Pr,2);
    figure()
    subplot(2,2,1);
    mesh(X, Y, reshape(Pr,size(X)));
    hold on
    plot(Mean(1,:),Mean(2,:),'+r')
    
    subplot(2,2,2);
    contour(X, Y, reshape(Pr,size(X)),30);
    hold on
    plot(Mean(1,:),Mean(2,:),'+r')
    grid
    
    subplot(2,2,3);
    plot(Data(1,:),Data(2,:),'.');
    hold on
    mesh(X, Y, reshape(Pr,size(X)));
    hold on
    plot(Mean(1,:),Mean(2,:),'+r')
    
    
    subplot(2,2,4);
    plot(Data(1,:),Data(2,:),'.');
    hold on
    contour(X, Y, reshape(Pr,size(X)),30);
    hold on
    plot(Mean(1,:),Mean(2,:),'+r')
    grid
else
    figure()
    [N V] = hist(Data,1000);
    bar(V,3.*N./sum(N));
    hold on
    for i = 1 : size(Mean,2)
        plot(Points,Pr(:,i),'r');
    end
end



    