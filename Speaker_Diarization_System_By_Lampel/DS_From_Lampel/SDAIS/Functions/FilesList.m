function [AFStruct] = FilesList( InFiles )

% USAGE : [AFStruct] = FilesList( InFiles )
% 
% This function is used to generate the files cell from  a list of files

% Check if no files were sent as input to the function

try
    Files = textread(InFiles,'%s','whitespaces','\n');
catch
    error ( sprintf(['The ' InFiles ' file does not exist in the directory'...
        '\nPlease create the file and specify files and folders or\n' ...
        'send an argument to the program specifying the file to analyze']));
end
if ( isempty ( Files ))
    error ( 'No files were assigned to the system');
end

% Generate outputs
NumFiles = length( Files );
FullPath = cell( NumFiles, 1 );
File = cell( NumFiles, 1 );
FilePath = cell( NumFiles, 1 );
for i = 1 : NumFiles
    [pathstr, name, ext] = fileparts(Files{i});
    File{i}=[name ext];
    FullPath{i} = Files{i};
    FilePath{i} = pathstr;
end

AFStruct = struct('File',File,'FilePath', FilePath, ...
    'FullPath',FullPath);