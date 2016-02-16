clc
clear all
load('Results')
%On Demand Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function []=OnDemand(varargin)

%Read user input in init seg,Online diarization Block
% InitialTrainingTime=get(project.SystemParametersEditText18,'string');  % %%%uncomm
InitialTrainingTime=120;%delete this

%Read user input in update seg,Online diarization Block
 %GetDerTimes=get(project.SystemParametersEditText19,'string') ;  %%%uncomm
GetDerTimes=100;%delete this

%Preallocating for better speed
Data=cell(1,size(project.ListOfScannedFile,1));
Fs=cell(1,size(project.ListOfScannedFile,1));
ConversationDuration=cell(1,size(project.ListOfScannedFile,1));
DataUntilInitialTrainingTime=cell(1,size(project.ListOfScannedFile,1));
Time=cell(1,size(project.ListOfScannedFile,1));


%Load Wave Files and Fs, From Results figure in loaded files block
for i=1:size(project.ListOfScannedFile,1)
[Data{i},Fs{i}]=wavread(  project.ListOfScannedFile(i,:)  );
Time{i}=( 1:length(Data{i}))/Fs{i};
ConversationDuration{i}=length(Time{i})/Fs{i};
                                %Stop on error
                                if InitialTrainingTime>ConversationDuration{i} || ...
                                                              GetDerTimes>ConversationDuration{i}
                                error('Input Parameters is bigger then Conversation Duration')
                                end                          
                                
%Cut the wave file until Initial Training Time
DataUntilInitialTrainingTime{i}=Data{i}(1:InitialTrainingTime*Fs{i});
end


Sections=floor((ConversationDuration{1}-InitialTrainingTime)/...
    GetDerTimes);

%save a new wave file the same name 
%length of user input init seg time + DERtimes

for i=1:size(project.ListOfScannedFile,1)
        for j=0:Sections+1
                 if j~=Sections+1
                      wavwrite(Data{i}(1:InitialTrainingTime*Fs{i}+GetDerTimes*j*Fs{i}),...
                          Fs{i},project.ListOfScannedFile(i,:) );
                       fclose('all');
%                        SDS
%                        DER
                 else
                      wavwrite(Data{i},...
                       Fs{i},project.ListOfScannedFile(i,:) );
                      fclose('all');
%                        SDS
%                        DER
                 end
        end
end



