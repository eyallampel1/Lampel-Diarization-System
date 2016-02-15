function [ScoreTar, ScoreImp] = EvalSVMScore(ModelsDir, Model, ...
    TestDir, ImpFile, TarFile, Mode)

% Impostors
[Conv,Side,Spk] = textread(ImpFile,'%4s,%d,%d');
ScoreImp = zeros(size(Side));

switch Mode
    case 'KS'
        for i = 1 : size(Conv,1)
            load(fullfile(ModelsDir,[Model '_SVM_' num2str(Spk(i))]));
            load(fullfile(TestDir,[Model '_' Conv{i} '_' num2str(Side(i))]));
            ScoreImp(i) = SVM_S.Norm*CSV-SVM_S.Bias;
        end
        
    case 'US'
        for i = 1 : size(Conv,1)
            Score = ones(1,2).*-inf;
            for k = 1 : 2
                try
                    load(fullfile(ModelsDir,[Model '_SVM_' num2str(Spk(i))]));
                    load(fullfile(TestDir,[Model '_' Conv{i} '_' num2str(k-1)]));
                    Score(k) = SVM_S.Norm*CSV-SVM_S.Bias;
                catch
                    continue;
                end
            end
            ScoreImp(i) = max(Score);
        end
        
    case '2W'
        for i = 1 : size(Conv,1)
            load(fullfile(ModelsDir,[Model '_SVM_' num2str(Spk(i))]));
            load(fullfile(TestDir,[Model '_' Conv{i}]));
            ScoreImp(i) = SVM_S.Norm*CSV-SVM_S.Bias;
        end
end

% Targets
[Conv,Side,Spk] = textread(TarFile,'%4s,%d,%d');
ScoreTar = zeros(size(Side));

switch Mode
    case 'KS'
        for i = 1 : size(Conv,1)
            load(fullfile(ModelsDir,[Model '_SVM_' num2str(Spk(i))]));
            load(fullfile(TestDir,[Model '_' Conv{i} '_' num2str(Side(i))]));
            ScoreTar(i) = SVM_S.Norm*CSV-SVM_S.Bias;
        end
        
    case 'US'
           for i = 1 : size(Conv,1)
            Score = ones(1,2).*-inf;
            for k = 1 : 2
                try
                    load(fullfile(ModelsDir,[Model '_SVM_' num2str(Spk(i))]));
                    load(fullfile(TestDir,[Model '_' Conv{i} '_' num2str(k-1)]));
                    Score(k) = SVM_S.Norm*CSV-SVM_S.Bias;
                catch
                    continue;
                end
            end
            ScoreTar(i) = max(Score);
        end
        
    case '2W'
        for i = 1 : size(Conv,1)
            load(fullfile(ModelsDir,[Model '_SVM_' num2str(Spk(i))]));
            load(fullfile(TestDir,[Model '_' Conv{i}]));
            ScoreTar(i) = SVM_S.Norm*CSV-SVM_S.Bias;
        end
end
