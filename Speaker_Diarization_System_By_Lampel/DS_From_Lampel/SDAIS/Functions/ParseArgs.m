function [Args] = ParseArgs(File)

% USAGE [Args] = ParseArgs(File)
%
% ParseAtgs reads the InputArgs.txt file and imports its
% paramenters to the Args struct

% Initialize input arguments cell
Args = struct();

try
    ArgsFile = textread(File,'%s','whitespaces','\n');
    
    % Read input arguments
    for i = 1 : size(ArgsFile,1)
        Temp = strread(ArgsFile{i},'%s','delimiter',',');
        if(Temp{1}(1) ~= '#')
            switch Temp{2}
                case 'N'
                    Args = setfield(Args, Temp{1}, str2num(Temp{3}));
                case 'S'
                    Args = setfield(Args, Temp{1}, Temp{3});
            end
        end
        if(strcmp(Temp,'# End args #'))
            break;
        end
    end
catch
    error('InputParameters.txt file missing, or corrupt restore the file ! ');
end