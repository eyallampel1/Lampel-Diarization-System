% Evaluation
close
clear
clc

%% Evaluate known side
% Add working directory to path and set master directory.
addpath(genpath(cd));

% Initialize diarization system
% Random seed
rand('twister', sum(100*clock));

% Input arguments structure
Args = ParseArgs('SISArgs.txt');

%% Eval Man-Man
disp('Man-Man');
[MMScoreTarKS MMScoreImpKS] = EvalSVMScore('SVM/SVM_ManSeg/','GMM', 'Test/Test_ManSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'KS');
[MMScoreTarUS MMScoreImpUS] = EvalSVMScore('SVM/SVM_ManSeg/','GMM', 'Test/Test_ManSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'US');
[MMScoreTar2W MMScoreImp2W] = EvalSVMScore('SVM/SVM_ManSeg/','GMM', 'Test/Test2W_ManSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', '2W');

%% Eval Man-Auto
disp('Man-Auto');
[MAScoreTarKS MAScoreImpKS] = EvalSVMScore('SVM/SVM_ManSeg/','GMM', 'Test/Test_AutoSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'KS');
[MAScoreTarUS MAScoreImpUS] = EvalSVMScore('SVM/SVM_ManSeg/','GMM', 'Test/Test_AutoSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'US');
[MAScoreTar2W MAScoreImp2W] = EvalSVMScore('SVM/SVM_ManSeg/','GMM', 'Test/Test2W_AutoSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', '2W');

%% Eval Auto-Man
disp('Auto-Man');
[AMScoreTarKS AMScoreImpKS] = EvalSVMScore('SVM/SVM_AutoSeg/','GMM', 'Test/Test_ManSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'KS');
[AMScoreTarUS AMScoreImpUS] = EvalSVMScore('SVM/SVM_AutoSeg/','GMM', 'Test/Test_ManSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'US');
[AMScoreTar2W AMScoreImp2W] = EvalSVMScore('SVM/SVM_AutoSeg/','GMM', 'Test/Test2W_ManSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', '2W');

%% Eval Auto-Auto
disp('Auto-Auto');
[AAScoreTarKS AAScoreImpKS] = EvalSVMScore('SVM/SVM_AutoSeg/','GMM', 'Test/Test_AutoSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'KS');
[AAScoreTarUS AAScoreImpUS] = EvalSVMScore('SVM/SVM_AutoSeg/','GMM', 'Test/Test_AutoSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', 'US');
[AAScoreTar2W AAScoreImp2W] = EvalSVMScore('SVM/SVM_AutoSeg/','GMM', 'Test/Test2W_AutoSeg/',...
    'EvalImpFiles.txt', 'EvalTarFiles.txt', '2W');

%% Plot results
% Known speaker
figure(1);
hold on
[Pmiss, Pfa] = Compute_DET(MMScoreTarKS, MMScoreImpKS);
h = Plot_DET (Pmiss, Pfa,'k');
[Pmiss, Pfa] = Compute_DET(MAScoreTarKS, MAScoreImpKS);
h = Plot_DET (Pmiss, Pfa,'r');
[Pmiss, Pfa] = Compute_DET(AMScoreTarKS, AMScoreImpKS);
h = Plot_DET (Pmiss, Pfa,'g');
[Pmiss, Pfa] = Compute_DET(AAScoreTarKS, AAScoreImpKS);
h = Plot_DET (Pmiss, Pfa,'c');
title('Known side DET curve');
legend('Man-Man','Man-Auto','Auto-Man','Auto-Auto')

% Unknown speaker
figure(2);
hold on
[Pmiss, Pfa] = Compute_DET(MMScoreTarUS, MMScoreImpUS);
h = Plot_DET (Pmiss, Pfa,'k');
[Pmiss, Pfa] = Compute_DET(MAScoreTarUS, MAScoreImpUS);
h = Plot_DET (Pmiss, Pfa,'r');
[Pmiss, Pfa] = Compute_DET(AMScoreTarUS, AMScoreImpUS);
h = Plot_DET (Pmiss, Pfa,'g');
[Pmiss, Pfa] = Compute_DET(AAScoreTarUS, AAScoreImpUS);
h = Plot_DET (Pmiss, Pfa,'c');
title('Unknown side DET curve');
legend('Man-Man','Man-Auto','Auto-Man','Auto-Auto')

% 2W
figure(3);
hold on
[Pmiss, Pfa] = Compute_DET(MMScoreTar2W, MMScoreImp2W);
h = Plot_DET (Pmiss, Pfa,'k');
[Pmiss, Pfa] = Compute_DET(MAScoreTar2W, MAScoreImp2W);
h = Plot_DET (Pmiss, Pfa,'r');
[Pmiss, Pfa] = Compute_DET(AMScoreTar2W, AMScoreImp2W);
h = Plot_DET (Pmiss, Pfa,'g');
[Pmiss, Pfa] = Compute_DET(AAScoreTar2W, AAScoreImp2W);
h = Plot_DET (Pmiss, Pfa,'c');
title('Two wire (2W) DET curve');
legend('Man-Man','Man-Auto','Auto-Man','Auto-Auto')

% Mafaat required
figure(4);
hold on
[Pmiss, Pfa] = Compute_DET(MMScoreTarUS, MMScoreImpUS);
h = Plot_DET (Pmiss, Pfa,'k');
[Pmiss, Pfa] = Compute_DET(AAScoreTarUS, AAScoreImpUS);
h = Plot_DET (Pmiss, Pfa,'c');
[Pmiss, Pfa] = Compute_DET(AAScoreTar2W, AAScoreImp2W);
h = Plot_DET (Pmiss, Pfa,'r');
title('Required tests');
legend('Man-Man','Auto-Auto','Auto-2W')

% Mafaat table
[Pmiss, Pfa] = Compute_DET(MMScoreTarUS, MMScoreImpUS);
[V I]=min(abs(0.01-Pfa))
disp(['MD@1%FA: ' num2str(Pmiss(I)*100) ,'%']);
[Pmiss, Pfa] = Compute_DET(MAScoreTarUS, MAScoreImpUS);
[V I]=min(abs(0.01-Pfa))
disp(['MD@1%FA: ' num2str(Pmiss(I)*100) ,'%']);
[Pmiss, Pfa] = Compute_DET(AMScoreTarUS, AMScoreImpUS);
[V I]=min(abs(0.01-Pfa))
disp(['MD@1%FA: ' num2str(Pmiss(I)*100) ,'%']);
[Pmiss, Pfa] = Compute_DET(AAScoreTarUS, AAScoreImpUS);
[V I]=min(abs(0.01-Pfa))
disp(['MD@1%FA: ' num2str(Pmiss(I)*100) ,'%']);
[Pmiss, Pfa] = Compute_DET(MMScoreTar2W, MMScoreImp2W);
[V I]=min(abs(0.01-Pfa))
disp(['MD@1%FA: ' num2str(Pmiss(I)*100) ,'%']);
[Pmiss, Pfa] = Compute_DET(AAScoreTar2W, AAScoreImp2W);
[V I]=min(abs(0.01-Pfa))
disp(['MD@1%FA: ' num2str(Pmiss(I)*100) ,'%']);