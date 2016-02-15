%% Generate database and lists
clear
clc
close
addpath(genpath(cd));

% Old database
% Generate input files
addpath(genpath(cd))

% TrainUBMFiles.txt
fid = fopen('ConversationLists/Archived/UBM.trn','r');
[Data] = textscan(fid,'%4d %8s');
fclose(fid);

fid = fopen('TrainUBMFiles.txt','w');
for i = 1 : size(Data{1},1)
    fprintf(fid,['/DBMP/AudioDB/SIS_Data/UBM/Conversations/' ...
        Data{2}{i} ',0,' num2str(Data{1}(i)) '\n']);
end
fclose(fid);

% TrainNAPFiles.txt
fid = fopen('ConversationLists/Archived/NAP.trn','r');
[Data] = textscan(fid,'%4s %4d %1d');
fclose(fid);

fid = fopen('TrainNAPFiles.txt','w');
for i = 1 : size(Data{1},1)
    fprintf(fid,['/DBMP/AudioDB/SIS_Data/NAP/Conversations/' ...
        Data{1}{i} '.sph,' num2str(Data{3}(i)-1) ',' num2str(Data{2}(i)) '\n']);
end
fclose(fid);

% TrainBGFiles.txt
fid = fopen('ConversationLists/Archived/Background.trn','r');
[Data] = textscan(fid,'%4d %8s');
fclose(fid);

fid = fopen('TrainBGFiles.txt','w');
for i = 1 : size(Data{1},1)
    fprintf(fid,['/DBMP/AudioDB/SIS_Data/BG/Conversations/' ...
        Data{2}{i} ',0,' num2str(Data{1}(i)) '\n']);
end
fclose(fid);

% TrainSVMFiles.txt
fid = fopen('ConversationLists/Archived/Train.trn','r');
[Data] = textscan(fid,'%4s:%1c\t%4d\t%c');
fclose(fid);

Temp = zeros(size(Data{2},1),1);
Temp(find(Data{2} == 'B')) = 1;

fid = fopen('TrainSVMFiles.txt','w');
for i = 1 : size(Data{1},1)
    fprintf(fid,['/DBMP/AudioDB/SIS_Data/Train/Conversations/' ...
        Data{1}{i} '.sph,' num2str(Temp(i)) ',' num2str(Data{3}(i)) ...
        '\n']);
end
fclose(fid);

% TrainTestSetFiles.txt
fid = fopen('ConversationLists/Archived/Train.trn','r');
[DataSVM] = textscan(fid,'%4s:%1c\t%4d\t%c');
fclose(fid);
SVMSpk = unique(DataSVM{3});
fid = fopen('ConversationLists/Archived/Test.trn','r');
[Data] = textscan(fid,'%4s:%1c %4d');
fclose(fid);

Temp = zeros(size(Data{2},1),1);
Temp(find(Data{2} == 'B')) = 1;

fid = fopen('TrainTestFiles.txt','w');
for i = 1 : size(Data{1},1)
    if(sum(Data{3}(i) == SVMSpk) >= 1)
        fprintf(fid,['/DBMP/AudioDB/SIS_Data/Test/Conversations/' ...
            Data{1}{i} '.sph,' num2str(Temp(i)) ',' num2str(Data{3}(i)) '\n']);
    end
end
fclose(fid);

% EvalSVMTar EvalSVMImp
fid = fopen('ConversationLists/Archived/Train.trn','r');
[DataSVM] = textscan(fid,'%4s:%1c\t%4d\t%c');
fclose(fid);
SVMSpk = unique(DataSVM{3});

fid = fopen('ConversationLists/Archived/Test.trn','r');
[Data] = textscan(fid,'%4s:%1c %4d');
fclose(fid);

[V I] = sort(Data{3});
Data{1} = Data{1}(I);
Data{2} = Data{2}(I);
Data{3} = Data{3}(I);

fid = fopen('EvalTarFiles.txt','w');
for i = 1 : size(Data{1},1)
    if(sum(Data{3}(i) == SVMSpk) >= 1)
        switch Data{2}(i)
            case 'A'
                fprintf(fid,'%s,0,%d\n',Data{1}{i},Data{3}(i));
            case 'B'
                fprintf(fid,'%s,1,%d\n',Data{1}{i},Data{3}(i));
        end
    end
end
fclose(fid);

fid = fopen('EvalImpFiles.txt','w');
for i = 1 : size(Data{1},1)
    if(sum(Data{3}(i) == SVMSpk) >= 1)
        IM = randi(size(Data{1},1),1,1);
        while((Data{3}(i) == Data{3}(IM)) | (sum(Data{3}(IM) == SVMSpk) == 0))
            IM = randi(size(Data{1},1),1,1);
        end
        switch Data{2}(i)
            case 'A'
                fprintf(fid,'%s,0,%d\n',Data{1}{i},Data{3}(IM));
            case 'B'
                fprintf(fid,'%s,1,%d\n',Data{1}{i},Data{3}(IM));
        end
    end
end
fclose(fid);

%% Check appropriate conversations NIST 2004
AppFiles04 = {};
Dir = '/media/WDDB/NIST04/train/asr_seg/';
Files = dir(Dir);

k = 1;
for i = 3 : size(Files,1)
    fprintf('%s - %d\n',Files(i).name, Files(i).bytes)
    Seg = dlmread([Dir Files(i).name]);
    if(Seg(1,1) > 1)
        continue;
    end

    if(Files(i).bytes < 2048)
        continue
    end

    AppFiles04{k} = [Files(i).name(1:4) '.sph'];
    k = k +1;
end

Dir = '/media/WDDB/NIST04/test/asr_seg/';
Files = dir(Dir);

for i = 3 : size(Files,1)
    fprintf('%s - %d\n',Files(i).name, Files(i).bytes)
    Seg = dlmread([Dir Files(i).name]);
    if(Seg(1,1) > 1)
        continue;
    end

    if(Files(i).bytes < 2048)
        continue
    end

    AppFiles04{k} = [Files(i).name(1:4) '.sph'];
    k = k +1;
end

%% Generate UBM - NIST04
OutDir='/DBMP/AudioDB/SIS_Data/Conversations/';
InDir='/media/WDDB/NIST04/train/data/';
SInDir='/media/WDDB/NIST04/train/asr_trans/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/Segmentations/';
InDirSeg='/media/WDDB/NIST04/train/asr_seg/';

% Male
[SpkM ConvM1 ConvM2 ConvM3]= ...
    textread('/media/WDDB/NIST04/train/male/3sides.trn', '%s%s%s%s','delimiter',',');
SpkM = cell2mat(SpkM);
SpkM = str2num(SpkM);
ConvM = {ConvM1 ConvM2 ConvM3};

[SpkF ConvF1 ConvF2 ConvF3]= ...
    textread('/media/WDDB/NIST04/train/female/3sides.trn', '%s%s%s%s','delimiter',',');
SpkF = cell2mat(SpkF);
SpkF = str2num(SpkF);
ConvF = {ConvF1 ConvF2 ConvF3};

% Generate files for UBM
UBMFiles = [];
Counter = 0;
i = 1;
while(Counter < 100);
    for k = 1 : 3
        if(sum(strcmp(ConvM{k}{i},AppFiles04)) >= 1)
            UBMFiles = [UBMFiles;ConvM{k}{i}];
            Counter = Counter + 1;
            break;
        end
    end
    i = i+1;
end

Counter = 0;
i = 1;
while(Counter < 100);
    for k = 1 : 3
        if(sum(strcmp(ConvF{k}{i},AppFiles04)) >= 1)
            UBMFiles = [UBMFiles;ConvF{k}{i}];
            Counter = Counter + 1;
            break;
        end
    end
    i = i+1;
end

% Write files lists
fid = fopen('TrainUBMFiles.txt','w');
for i = 1 : size(UBMFiles,1)
    fprintf(fid,[OutDir UBMFiles(i,:) '\n']);
end
fclose(fid);

%% Generate BG - NIST04
OutDir='/DBMP/AudioDB/SIS_Data/Conversations/';
InDir='/media/WDDB/NIST04/train/data/';
SInDir='/media/WDDB/NIST04/train/asr_trans/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/Segmentations/';
InDirSeg='/media/WDDB/NIST04/train/asr_seg/';

BGFiles = [];

Counter = 0;
i = 1;
while(Counter < 100);
    for k = 1 : 3
        if(sum(strcmp(ConvM{k}{i},AppFiles04)) >= 1)
            copyfile([InDir ConvM{k}{i}],[OutDir ConvM{k}{i}]);
            copyfile([InDirSeg ConvM{k}{i}(1:4) '.txt'],[OutDirSeg ConvM{k}{i}(1:4) '.txt']);
            BGFiles = [BGFiles;ConvM{k}{i}];
            Counter = Counter + 1;
            break;
        end
    end
    i = i+1;
end

Counter = 0;
i = 1;
while(Counter < 100);
    for k = 1 : 3
        if(sum(strcmp(ConvF{k}{i},AppFiles04)) >= 1)
            copyfile([InDir ConvF{k}{i}],[OutDir ConvF{k}{i}]);
            copyfile([InDirSeg ConvF{k}{i}(1:4) '.txt'],[OutDirSeg ConvF{k}{i}(1:4) '.txt']);
            BGFiles = [BGFiles;ConvF{k}{i}];
            Counter = Counter + 1;
            break;
        end
    end
    i = i+1;
end
% Write files lists
fid = fopen('TrainBGFiles.txt','w');
for i = 1 : size(BGFiles,1)
    fprintf(fid,[OutDir BGFiles(i,:) '\n']);
end
fclose(fid);

%% Generate NAP - NIST04
OutDir='/DBMP/AudioDB/SIS_Data/Conversations/';
InDir='/media/WDDB/NIST05/train/data/';
SInDir='/media/WDDB/NIST05/train/asr_trans/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/Segmentations/';
InDirSeg='/media/WDDB/NIST05/train/asr_seg/';

% Male
[SpkM ConvM1 ConvM2 ConvM3 ConvM4 ConvM5 ConvM6 ConvM7 ConvM8]= ...
    textread('/media/WDDB/NIST05/train/male/8conv4w.trn', '%s%s%s%s%s%s%s%s%s','delimiter',',');
SpkM = cell2mat(SpkM);
SpkM = str2num(SpkM(:,2:end));
ConvM = {ConvM1,ConvM2,ConvM3,ConvM4,ConvM5,ConvM6,ConvM7,ConvM8};

[SpkF ConvF1 ConvF2 ConvF3 ConvF4 ConvF5 ConvF6 ConvF7 ConvF8]= ...
    textread('/media/WDDB/NIST05/train/female/8conv4w.trn', '%s%s%s%s%s%s%s%s%s','delimiter',',');
SpkF = cell2mat(SpkF);
SpkF = str2num(SpkF(:,2:end));
ConvF = {ConvF1,ConvF2,ConvF3,ConvF4,ConvF5,ConvF6,ConvF7,ConvF8};

% Generate files for NAP
NAPFiles = []; NAPSpk = [];
NAPCount = 0;
i = 1;
while(NAPCount < 30)
    Counter = 0;
    for k = 1 : 8
        if(sum(strcmp(ConvM{k}{i}(1:end-2),AppFiles05)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 8)
        for k = 1 : 8
            NAPFiles = [NAPFiles;ConvM{k}{i}];
            NAPSpk = [NAPSpk; SpkM(i)];
        end
        NAPCount = NAPCount + 1;
    end
    i = i + 1;
end

NAPCount = 0;
i = 1;
while(NAPCount < 30)
    Counter = 0;
    for k = 1 : 8
        if(sum(strcmp(ConvF{k}{i}(1:end-2),AppFiles05)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 8)
        for k = 1 : 8
            NAPFiles = [NAPFiles;ConvF{k}{i}];
            NAPSpk = [NAPSpk; SpkF(i)];
        end
        NAPCount = NAPCount + 1;
    end
    i = i + 1;
end

% Write files lists
fid = fopen('TrainNAPFiles.txt','w');
for i = 1 : size(NAPFiles,1)
    if(NAPFiles(i,end) == 'A')
        fprintf(fid,[OutDir NAPFiles(i,1:end-2) ',0,' num2str(NAPSpk(i)) '\n']);
    elseif(NAPFiles(i,end) == 'B')
        fprintf(fid,[OutDir NAPFiles(i,1:end-2) ',1,' num2str(NAPSpk(i)) '\n']);
    end
end
fclose(fid);

%% Check appropriate conversations NIST 2005
clc
clear
close

AppFiles05 = {};


Dir = '/media/WDDB/NIST05/train/asr_seg/';
ADir = '/media/WDDB/NIST05/train/data/';
Files = dir(Dir);

k = 1;
for i = 3 : size(Files,1)
    
    try
        
        % Check segmentation contains both sides
        fprintf('%s - %d\n',Files(i).name, Files(i).bytes)
        Seg = dlmread([Dir Files(i).name]);
        if(Seg(1,1) > 1)
            continue;
        end
        
        if(isempty(find(Seg(:,3) == 1)) || isempty(find(Seg(:,3) == 2)))
            continue;
        end
        
        % Check segmentation fits file
        Header = cell(1,1);
        N=0;
        while (~strcmp(Header{end},'end_head'))
            N = N + 1;
            Header = textread([ADir Files(i).name(1:4) '.sph'] ,'%s',N);
        end
        for l = 1 : N
            if(strcmp(Header{l},'channel_count'))
                Channels = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_rate'))
                Fs = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_count'))
                Samples = str2num(Header{l+2});
            end
        end
        
        if(Samples/Fs < Seg(end,2))
            continue;
        end
    catch
        continue;
    end
    
    % Add file to appropriate list
    AppFiles05{k} = [Files(i).name(1:4) '.sph'];
    k = k +1;
end

Dir = '/media/WDDB/NIST05/test/asr_seg/';
ADir = '/media/WDDB/NIST05/test/data/';
Files = dir(Dir);

for i = 3 : size(Files,1)
    
    try
        
        % Check segmentation contains both sides
        fprintf('%s - %d\n',Files(i).name, Files(i).bytes)
        Seg = dlmread([Dir Files(i).name]);
        if(Seg(1,1) > 1)
            continue;
        end
        
        if(isempty(find(Seg(:,3) == 1)) || isempty(find(Seg(:,3) == 2)))
            continue;
        end
        
        % Check segmentation fits file
        Header = cell(1,1);
        N=0;
        while (~strcmp(Header{end},'end_head'))
            N = N + 1;
            Header = textread([ADir Files(i).name(1:4) '.sph'] ,'%s',N);
        end
        for l = 1 : N
            if(strcmp(Header{l},'channel_count'))
                Channels = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_rate'))
                Fs = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_count'))
                Samples = str2num(Header{l+2});
            end
        end
        
        if(Samples/Fs < Seg(end,2))
            continue;
        end
    catch
        continue;
    end
    
    % Add file to appropriate list
    AppFiles05{k} = [Files(i).name(1:4) '.sph'];
    k = k +1;
end


%% Generate Train and test - NIST05
OutDir='/DBMP/AudioDB/SIS_Data/Train/Conversations/';
InDir='/media/WDDB/NIST05/train/data/';
SInDir='/media/WDDB/NIST05/train/asr_tran/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/Train/Segmentations/';
InDirSeg='/media/WDDB/NIST05/train/asr_seg/';

% NIST Index
[TSpk TConv TLang TO TSide TSpkID TFile TMic TGen THand TOLang THandT ...
    TNLang TTest TMic TMM TMT T T T T] = ...
    textread('ConversationKeys/sre05_key/sre05-key-v7b.txt' ...
    ,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s');

% Generate the speakers in NIST05
TTSpk = zeros(size(TSpk,1),1);
TTSpkID = zeros(size(TSpk,1),1);
TTConv = cell(size(TSpk,1),1);
for i = 1 : size(TSpk,1)
    TTSpk(i) = str2num(TSpk{i}(2:end));
    if(isempty(str2num(TSpkID{i})))
        TTSpkID(i) = 0;
    else
        TTSpkID(i) = str2num(TSpkID{i});
    end
    TTConv(i) = TConv(i);
end

% Male
[SpkM ConvM1 ConvM2 ConvM3 ConvM4 ConvM5 ConvM6 ConvM7 ConvM8]= ...
    textread('/media/WDDB/NIST05/train/male/8conv4w.trn', '%s%s%s%s%s%s%s%s%s','delimiter',',');
SpkM = cell2mat(SpkM);
SpkM = str2num(SpkM(:,2:end));
ConvM = {ConvM1 ConvM2 ConvM3 ConvM4 ConvM5 ConvM6 ConvM7 ConvM8};
clear ConvM1 ConvM2 ConvM3 ConvM4 ConvM5 ConvM6 ConvM7 ConvM8

[SpkF ConvF1 ConvF2 ConvF3 ConvF4 ConvF5 ConvF6 ConvF7 ConvF8]= ...
    textread('/media/WDDB/NIST05/train/female/8conv4w.trn', '%s%s%s%s%s%s%s%s%s','delimiter',',');
SpkF = cell2mat(SpkF);
SpkF = str2num(SpkF(:,2:end));
ConvF = {ConvF1 ConvF2 ConvF3 ConvF4 ConvF5 ConvF6 ConvF7 ConvF8};
clear ConvF1 ConvF2 ConvF3 ConvF4 ConvF5 ConvF6 ConvF7 ConvF8

% Identify by speaker ID
for i = 1 : size(SpkM,1)
    I = find(TTSpk == SpkM(i));
    SpkM(i) = mean(TTSpkID(I));
end

for i = 1 : size(SpkF,1)
    I = find(TTSpk == SpkF(i));
    SpkF(i) = mean(TTSpkID(I));
end

% Generate files for SVM
SVMFiles = []; SVMSpk = [];

SVMCount = 0;
i = 1;
while(SVMCount < 100)
    Counter = 0;
    if(SpkM(i) == 0)
        i = i + 1;
        continue;
    end
    for k = 1 : 8
        if(sum(strcmp(ConvM{k}{i}(1:end-2),AppFiles05)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 8)
        for k = 1 : 8
            SVMFiles = [SVMFiles;ConvM{k}{i}];
            SVMSpk = [SVMSpk; SpkM(i)];
        end
        SVMCount = SVMCount + 1;
    end
    i = i + 1;
end

SVMCount = 0;
i = 1;
while(SVMCount < 100)
    Counter = 0;
    if(isnan(SpkF(i)))
        i = i + 1;
        continue;
    end
    
    for k = 1 : 8
        if(sum(strcmp(ConvF{k}{i}(1:end-2),AppFiles05)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 8)
        for k = 1 : 8
            SVMFiles = [SVMFiles;ConvF{k}{i}];
            SVMSpk = [SVMSpk; SpkF(i)];
        end
        SVMCount = SVMCount + 1;
    end
    i = i + 1;
end

% Write files lists
fid = fopen('TrainSVMFiles.txt','w');
for i = 1 : size(SVMFiles,1)
    switch SVMFiles(i,10)
        case 'A'
            fprintf(fid,[OutDir SVMFiles(i,1:8) ',0,' num2str(SVMSpk(i)) '\n']);
        case 'B'
            fprintf(fid,[OutDir SVMFiles(i,1:8) ',1,' num2str(SVMSpk(i)) '\n']);
    end
end
fclose(fid);

%% Generate test conversations
OutDir='/DBMP/AudioDB/SIS_Data/Test/Conversations/';
InDir='/media/WDDB/NIST05/test/data/';
SInDir='/media/WDDB/NIST05/test/asr_tran/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/Test/Segmentations/';
InDirSeg='/media/WDDB/NIST05/test/asr_seg/';

% Generate unique SVM speakers
TSVMSpk = unique(SVMSpk);

% Generate target conversations
TestConv = [];

for i = 1 : size(TSVMSpk,1)
    Counter = 0;
    I = find(TTSpkID == TSVMSpk(i));
    for k = 2 : size(I,1)
        if( (sum(strcmp([TTConv{I(k)} '.sph'],AppFiles05)) >= 1) & ...
                (strcmp([TTConv{I(k)} '.sph'],[TTConv{I(k-1)} '.sph']) ~= 1))
            TestConv = [TestConv;I(k)];
        end
    end
end

% Write conversations
fid = fopen('TrainTestFiles.txt','w');
for i = 1 : size(TestConv,1)
    switch TSide{TestConv(i)}
        case 'a'
            fprintf(fid,[OutDir TTConv{TestConv(i)} '.sph,0,' num2str(TTSpkID(TestConv(i))) '\n']);
        case 'b'
            fprintf(fid,[OutDir TTConv{TestConv(i)} '.sph,1,' num2str(TTSpkID(TestConv(i))) '\n']);
        case 'x1'
            fprintf(fid,[OutDir TTConv{TestConv(i)} '.sph,0,' num2str(TTSpkID(TestConv(i))) '\n']);
        case 'x2'
            fprintf(fid,[OutDir TTConv{TestConv(i)} '.sph,1,' num2str(TTSpkID(TestConv(i))) '\n']);
            
    end
end
fclose(fid);

% Write targets
fid = fopen('EvalTarFiles.txt','w');
for i = 1 : size(TestConv,1)
    switch TSide{TestConv(i)}
        case 'a'
            fprintf(fid,[TTConv{TestConv(i)} ',0,' num2str(TTSpkID(TestConv(i))) '\n']);
        case 'b'
            fprintf(fid,[TTConv{TestConv(i)} ',1,' num2str(TTSpkID(TestConv(i))) '\n']);
        case 'x1'
            fprintf(fid,[TTConv{TestConv(i)} ',0,' num2str(TTSpkID(TestConv(i))) '\n']);
        case 'x2'
            fprintf(fid,[TTConv{TestConv(i)} ',1,' num2str(TTSpkID(TestConv(i))) '\n']);
    end
end
fclose(fid);

% Write impostors
fid = fopen('EvalImpFiles.txt','w');
for i = 1 : size(TestConv,1)
    while 1
        Obj = TTSpkID(TestConv(randi(size(TestConv,1))));
        if(strcmp(Obj,TTSpkID(TestConv(i))) == 0)
            break;
        end
    end
    fprintf(fid,[TTConv{TestConv(i)} ',' num2str(randi(2)-1) ',' ...
        num2str(Obj) '\n']);
end
fclose(fid)

%% Check NIST06 appropriate files
clc
clear
close

AppFiles06 = {};


Dir = '/media/WDDB/NIST06/train/asr_seg/';
ADir = '/media/WDDB/NIST06/train/data/';
Files = dir(Dir);

k = 1;
for i = 3 : size(Files,1)
    
    % Approximate large enough file
    if(Files(i).bytes < 2048)
        continue
    end
    
    % Check segmentation contains both sides
    fprintf('%s - %d\n',Files(i).name, Files(i).bytes)
    Seg = dlmread([Dir Files(i).name]);
    if(Seg(1,1) > 1)
        continue;
    end
    
    if(isempty(find(Seg(:,3) == 1)) || isempty(find(Seg(:,3) == 2)))
        continue;
    end
    
    % Check segmentation fits file
    try
        Header = cell(1,1);
        N=0;
        while (~strcmp(Header{end},'end_head'))
            N = N + 1;
            Header = textread([ADir Files(i).name(1:4) '.sph'] ,'%s',N);
        end
        for l = 1 : N
            if(strcmp(Header{l},'channel_count'))
                Channels = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_rate'))
                Fs = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_count'))
                Samples = str2num(Header{l+2});
            end
        end
        
        if(Samples/Fs < Seg(end,2))
            continue;
        end
    catch
        continue;
    end
    
    % Add file to appropriate list
    AppFiles06{k} = [Files(i).name(1:4) '.sph'];
    k = k +1;
end

Dir = '/media/WDDB/NIST05/test/asr_seg/';
ADir = '/media/WDDB/NIST05/test/data/';
Files = dir(Dir);

for i = 3 : size(Files,1)
    
    % Approximate large enough file
    if(Files(i).bytes < 2048)
        continue
    end
    
    % Check segmentation contains both sides
    fprintf('%s - %d\n',Files(i).name, Files(i).bytes)
    Seg = dlmread([Dir Files(i).name]);
    if(Seg(1,1) > 1)
        continue;
    end
    
    if(isempty(find(Seg(:,3) == 1)) || isempty(find(Seg(:,3) == 2)))
        continue;
    end
    
    % Check segmentation fits file
    try
        Header = cell(1,1);
        N=0;
        while (~strcmp(Header{end},'end_head'))
            N = N + 1;
            Header = textread([ADir Files(i).name(1:4) '.sph'] ,'%s',N);
        end
        for l = 1 : N
            if(strcmp(Header{l},'channel_count'))
                Channels = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_rate'))
                Fs = str2num(Header{l+2});
            end
            if(strcmp(Header{l},'sample_count'))
                Samples = str2num(Header{l+2});
            end
        end
        
        if(Samples/Fs < Seg(end,2))
            continue;
        end
    catch
        continue;
    end
    
    % Add file to appropriate list
    AppFiles06{k} = [Files(i).name(1:4) '.sph'];
    k = k +1;
end

%% Generate UBM NIST06
OutDir='/DBMP/AudioDB/SIS_Data/UBM/Conversations/';
InDir='/media/WDDB/NIST06/train/data/';
SInDir='/media/WDDB/NIST06/train/asr_tran/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/UBM/Segmentations/';
InDirSeg='/media/WDDB/NIST06/train/asr_seg/';

% Male
[SpkM ConvM1]= ...
    textread('/media/WDDB/NIST06/train/male/1conv4w.trn', '%s%s','delimiter',' ');
SpkM = cell2mat(SpkM);
SpkM = str2num(SpkM(:,2:end));
ConvM = {ConvM1};
clear ConvM1

[SpkF ConvF1]= ...
    textread('/media/WDDB/NIST06/train/female/1conv4w.trn', '%s%s','delimiter',' ');
SpkF = cell2mat(SpkF);
SpkF = str2num(SpkF(:,2:end));
ConvF = {ConvF1};
clear ConvF1

% Generate files for UBM
UBMFiles = []; UBMSpk = [];

UBMCount = 0;
i = 1;
while(UBMCount < 100)
    Counter = 0;
    if(SpkM(i) == 0)
        i = i + 1;
        continue;
    end
    for k = 1 : 1
        if(sum(strcmp(ConvM{k}{i}(1:end-2),AppFiles06)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 1)
        for k = 1 : 1
            UBMFiles = [UBMFiles;ConvM{k}{i}];
            UBMSpk = [UBMSpk; SpkM(i)];
        end
        UBMCount = UBMCount + 1;
    end
    i = i + 1;
end

UBMCount = 0;
i = 1;
while(UBMCount < 100)
    Counter = 0;
    if(SpkF(i) == 0)
        i = i + 1;
        continue;
    end
    for k = 1 : 1
        if(sum(strcmp(ConvF{k}{i}(1:end-2),AppFiles06)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 1)
        for k = 1 : 1
            UBMFiles = [UBMFiles;ConvF{k}{i}];
            UBMSpk = [UBMSpk; SpkF(i)];
        end
        UBMCount = UBMCount + 1;
    end
    i = i + 1;
end

% Write files lists
fid = fopen('TrainUBMFiles.txt','w');
for i = 1 : size(UBMFiles,1)
    switch UBMFiles(i,10)
        case 'A'
            fprintf(fid,[OutDir UBMFiles(i,1:8) ',0,' num2str(UBMSpk(i)) '\n']);
        case 'B'
            fprintf(fid,[OutDir UBMFiles(i,1:8) ',1,' num2str(UBMSpk(i)) '\n']);
    end
end
fclose(fid);

%% Generate BG NIST06
OutDir='/DBMP/AudioDB/SIS_Data/BG/Conversations/';
InDir='/media/WDDB/NIST06/train/data/';
SInDir='/media/WDDB/NIST06/train/asr_tran/';
OutDirSeg='/DBMP/AudioDB/SIS_Data/BG/Segmentations/';
InDirSeg='/media/WDDB/NIST06/train/asr_seg/';

% Male
[SpkM ConvM1]= ...
    textread('/media/WDDB/NIST06/train/male/1conv4w.trn', '%s%s','delimiter',' ');
SpkM = cell2mat(SpkM);
SpkM = str2num(SpkM(:,2:end));
ConvM = {ConvM1};
clear ConvM1

[SpkF ConvF1]= ...
    textread('/media/WDDB/NIST06/train/female/1conv4w.trn', '%s%s','delimiter',' ');
SpkF = cell2mat(SpkF);
SpkF = str2num(SpkF(:,2:end));
ConvF = {ConvF1};
clear ConvF1

% Generate files for BG
BGFiles = []; BGSpk = [];

BGCount = 0;
i = 110;
while(BGCount < 200)
    Counter = 0;
    if(SpkM(i) == 0)
        i = i + 1;
        continue;
    end
    for k = 1 : 1
        if(sum(strcmp(ConvM{k}{i}(1:end-2),AppFiles06)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 1)
        for k = 1 : 1
            BGFiles = [BGFiles;ConvM{k}{i}];
            BGSpk = [BGSpk; SpkM(i)];
        end
        BGCount = BGCount + 1;
    end
    i = i + 1;
end

UBMCount = 0;
i = 1;
while(UBMCount < 100)
    Counter = 0;
    if(SpkF(i) == 0)
        i = i + 1;
        continue;
    end
    for k = 1 : 1
        if(sum(strcmp(ConvF{k}{i}(1:end-2),AppFiles06)) >= 1)
            Counter = Counter+1;
        end
    end
    if(Counter == 1)
        for k = 1 : 1
            BGFiles = [BGFiles;ConvF{k}{i}];
            BGSpk = [BGSpk; SpkF(i)];
        end
        UBMCount = UBMCount + 1;
    end
    i = i + 1;
end

% Write files lists
fid = fopen('TrainBGFiles.txt','w');
for i = 1 : size(BGFiles,1)
    switch BGFiles(i,10)
        case 'A'
            fprintf(fid,[OutDir BGFiles(i,1:8) ',0,' num2str(BGSpk(i)) '\n']);
        case 'B'
            fprintf(fid,[OutDir BGFiles(i,1:8) ',1,' num2str(BGSpk(i)) '\n']);
    end
end
fclose(fid);

%% Copy files
% UBM
[Conv Side Spk] = textread('TrainUBMFiles.txt','%s %1d %4d','delimiter',',');
for i = 1 : size(Conv,1)
    [pathstr, name, ext, versn] = fileparts(Conv{i});
    try
        copyfile(['/media/WDDB/NIST04/train/data/' name ext], ['/DBMP/AudioDB/SIS_Data/UBM/Conversations/' name ext])
        copyfile(['/media/WDDB/NIST04/train/asr_seg/' name '.txt'], ['/DBMP/AudioDB/SIS_Data/UBM/Segmentations/' name '.txt'])
    catch
        disp(name);
    end
end

%NAP
[Conv Side Spk] = textread('TrainNAPFiles.txt','%s %1d %4d','delimiter',',');
for i = 1 : size(Conv,1)
    [pathstr, name, ext, versn] = fileparts(Conv{i});
    switch name(1)
        case 't'
            try
                copyfile(['/media/WDDB/NIST04/train/data/' name ext], ['/DBMP/AudioDB/SIS_Data/NAP/Conversations/' name ext])
                copyfile(['/media/WDDB/NIST04/train/asr_seg/' name '.txt'], ['/DBMP/AudioDB/SIS_Data/NAP/Segmentations/' name '.txt'])
            catch
                disp(name);
            end
        case 'x'
            try
                copyfile(['/media/WDDB/NIST04/test/data/' name ext], ['/DBMP/AudioDB/SIS_Data/NAP/Conversations/' name ext])
                copyfile(['/media/WDDB/NIST04/test/asr_seg/' name '.txt'], ['/DBMP/AudioDB/SIS_Data/NAP/Segmentations/' name '.txt'])
            catch
                disp(name);
            end
    end
end

% Background
[Conv Side Spk] = textread('TrainBGFiles.txt','%s %1d %4d','delimiter',',');
for i = 1 : size(Conv,1)
    [pathstr, name, ext, versn] = fileparts(Conv{i});
    try
        copyfile(['/media/WDDB/NIST04/train/data/' name ext], ['/DBMP/AudioDB/SIS_Data/BG/Conversations/' name ext])
        copyfile(['/media/WDDB/NIST04/train/asr_seg/' name '.txt'], ['/DBMP/AudioDB/SIS_Data/BG/Segmentations/' name '.txt'])
    catch
        disp(name);
    end
end

% Train
[Conv Side Spk] = textread('TrainSVMFiles.txt','%s %1d %4d','delimiter',',');
for i = 1 : size(Conv,1)
    [pathstr, name, ext, versn] = fileparts(Conv{i});
    try
        copyfile(['/media/WDDB/NIST05/train/data/' name ext], ['/DBMP/AudioDB/SIS_Data/Train/Conversations/' name ext])
        copyfile(['/media/WDDB/NIST05/train/asr_seg/' name '.txt'], ['/DBMP/AudioDB/SIS_Data/Train/Segmentations/' name '.txt'])
    catch
        disp(name);
    end
end

% Test
[Conv Side Spk] = textread('TrainTestFiles.txt','%s %1d %4d','delimiter',',');
for i = 1 : size(Conv,1)
    [pathstr, name, ext, versn] = fileparts(Conv{i});
    try
        copyfile(['/media/WDDB/NIST05/test/data/' name ext], ['/DBMP/AudioDB/SIS_Data/Test/Conversations/' name ext])
        copyfile(['/media/WDDB/NIST05/test/asr_seg/' name '.txt'], ['/DBMP/AudioDB/SIS_Data/Test/Segmentations/' name '.txt'])
    catch
        disp(name);
    end
end




