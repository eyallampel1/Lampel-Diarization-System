% Generates a list file

[FileName,PathName] = uigetfile({'*.wav';'*.sph'},'Select Conv Files',...
'..\','MultiSelect','on');

list = cellfun(@(t)fullfile(PathName,t),FileName,'UniformOutput',false);

[saveFileName,savePathName] = uiputfile('..\allDc.txt','List File Save');
fid = fopen(fullfile(savePathName,saveFileName),'w');
cellfun(@(t)fprintf(fid,'%s\n',t),list);
fclose(fid);
