function Creat3Wave(WaveFilePath,TextFileName,destination,ClusterAB,DER)
%WaveFilePath='C:\DS_From_Lampel\LDC_Callhome\Conversations\en_0638.wav';
%TextFileName='C:\DS_From_Lampel\LDC_Callhome\Segmentations\en_0638.txt';
%destination='d:\';
try 
    fid=fopen(TextFileName);
    ScannedFile=textscan(fid,'%s %s %s',[3,1]);
    ScannedFile=[ScannedFile{1},ScannedFile{2},ScannedFile{3}];
    [path,filename,ext]=fileparts(TextFileName);
catch 
    errordlg(['Error Opening ', TextFileName]);
end

try
    Time=clock;
    hr=num2str(Time(4));
min=num2str(Time(5));
sec=num2str(round(Time(6)));
LogFile=fullfile(destination,['Log_File_',filename,'.txt']);
file=fopen(LogFile,'w');
fprintf(file,[date,' ,',hr,':',min,':',sec,'\n']);
fprintf(file,['********************************************','\n']);
fprintf(file,['Diarization File : ',filename,'.wav','\n']);
fprintf(file,['DER: ',num2str(DER),'%%','\n']);
if ClusterAB==1
    fprintf(file,['The Speaker of Channel 1 is : Cluster ','A','\n']);
 fprintf(file,['The Speaker of Channel 2 is : Cluster ','B','\n']);
else
     fprintf(file,['The Speaker of Channel 1 is : Cluster ','B','\n']);
      fprintf(file,['The Speaker of Channel 1 is : Cluster ','A','\n']);
end
fclose(file);
catch
    errordlg('Cant create log file ');
end
NoneSpeechIndex=1;
Speaker_a_Index=1;
Speaker_b_Index=1;
OverLapIndex=1;

for i=1:length(ScannedFile)
    switch ScannedFile{i,3}
        case '0'
            NoneSpeechSegment(NoneSpeechIndex,1)=str2double(ScannedFile{i,1});
  NoneSpeechSegment(NoneSpeechIndex,2)=str2double(ScannedFile{i,2});
NoneSpeechIndex=NoneSpeechIndex+1;
        case '1'
            Speaker_a_Segment(Speaker_a_Index,1)=str2double(ScannedFile{i,1});
            Speaker_a_Segment(Speaker_a_Index,2)=str2double(ScannedFile{i,2});
            Speaker_a_Index=Speaker_a_Index+1;
        case '2'
            Speaker_b_Segment(Speaker_b_Index,1)=str2double(ScannedFile{i,1});
            Speaker_b_Segment(Speaker_b_Index,2)=str2double(ScannedFile{i,2});
            Speaker_b_Index=Speaker_b_Index+1;
        case '3'
            OverLap_Segment(OverLapIndex,1)=str2double(ScannedFile{i,1});
            OverLap_Segment(OverLapIndex,2)=str2double(ScannedFile{i,2});
            OverLapIndex=OverLapIndex+1;
    end
end
fclose(fid);
 
if ~ismember({'OverLap_Segment'},who) 
   OverLap_Segment=0;
end

if ~ismember({'Speaker_a_Segment'},who) 
   Speaker_a_Segment=0;
end

if ~ismember({'Speaker_b_Segment'},who) 
   Speaker_b_Segment=0;
end

if Speaker_a_Segment(1)==0
    Speaker_a_Segment(1)=Speaker_a_Segment(1)+0.001;
end
if Speaker_b_Segment(1)==0
    Speaker_b_Segment(1)=Speaker_b_Segment(1)+0.001;
end
if OverLap_Segment(1)==0
    OverLap_Segment(1)=OverLap_Segment(1)+0.001;
end
if NoneSpeechSegment(1)==0
    NoneSpeechSegment(1)=NoneSpeechSegment(1)+0.001;
end

try
    [WaveData,fs]=wavread(WaveFilePath);
catch
    errordlg(['cant open ',WaveFilePath]);
end
for i=1:length(NoneSpeechSegment)-1
    NoneSpeechWave{i}=[WaveData(round(NoneSpeechSegment(i,1)*fs):round(NoneSpeechSegment(i,2)*fs))'];
end
for i=1:length(Speaker_a_Segment)-1
    Speaker_a_Wave{i}=[WaveData(round(Speaker_a_Segment(i,1)*fs):round(Speaker_a_Segment(i,2)*fs))'];
end
for i=1:length(Speaker_b_Segment)-1
    Speaker_b_Wave{i}=[WaveData(round(Speaker_b_Segment(i,1)*fs):round(Speaker_b_Segment(i,2)*fs))'];
end
for i=1:length(OverLap_Segment)-1
    OverLapWave{i}=[WaveData(round(OverLap_Segment(i,1)*fs):round(OverLap_Segment(i,2)*fs))'];
end

try
NoneSpeechWave=cell2mat(NoneSpeechWave);
catch
end

try
Speaker_a_Wave=cell2mat(Speaker_a_Wave);
catch
end

try
Speaker_b_Wave=cell2mat(Speaker_b_Wave);
catch
end

    try
OverLapWave=cell2mat(OverLapWave);
    catch
    end
x=fullfile(destination,[filename,'_0','.wav']);
y=fullfile(destination,[filename,'_1','.wav']);
z=fullfile(destination,[filename,'_2','.wav']);
k=fullfile(destination,[filename,'_3','.wav']);
try
wavwrite(NoneSpeechWave,x);
catch
    end
try
wavwrite(Speaker_a_Wave,y);
catch
    end
try
wavwrite(Speaker_b_Wave,z);
catch
    end
try
wavwrite(OverLapWave,k);
catch
end


end