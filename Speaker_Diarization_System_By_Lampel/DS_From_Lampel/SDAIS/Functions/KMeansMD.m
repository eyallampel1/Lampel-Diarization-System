function [M, W, C, IDX] = KMeansMD(Data, M, rho, Iter, Thresh)

% Variables and space
EmptyFlag = 0;
[Dim ND] = size(Data);
NM = size(M,2);


Dist = zeros(NM,ND);
C = zeros(Dim,Dim,NM);
for i = 1 : NM
    C(:,:,i) = eye(Dim);
end

for k = 1 : Iter
    rho = rho - rho/Iter;
    % Calculate
    for i = 1 : NM
        [V I] = eig(C(:,:,i));
        Dist(i,:) = (1-rho) * (sum(((I^-0.5)*V'*Data - (I^-0.5)*V'*repmat(M(:,i),1,size(Data,2))).^2)) + ...
            rho* sum((Data - repmat(M(:,i),1,size(Data,2))).^2);
    end
    
    % Find minimum
    [V I] = min(Dist);
    
%     % Check empty assignment
%     for i = 1 : NM
%         if(sum(I == i) == 0)
%             M(:,i) = Data(:,randi(ND,1,1));
%             C(:,:,i) = eye(Dim);
%             EmptyFlag = 1;
%         end
%     end
    
    
    if(EmptyFlag == 1)
        EmptyFlag = 0;
        continue;
    end
    
    % Calculate mean and covariance
    for i = 1 : NM
        M(:,i) = mean(Data(:,find(I==i)),2);
        C(:,:,i) = cov(Data(:,find(I==i))')+eye(Dim).*1e-10;
    end
    C
end

W = ones(1,NM)./NM;
IDX = I;

