function [Data, Fs] = readnist( fileName )

% USAGE : [Data, Fs] = readnist( fileName )
% Reads uncompressed NIST files

fid = fopen(fileName, 'r');
Data = fread(fid);
Header = cell(1,1);
N=0;
while (~strcmp(Header{end},'end_head'))
    N = N + 1;
    Header = textread(fileName ,'%s',N);
end
for l = 1 : N
    if(strcmp(Header{l},'channel_count'))
        Channels = str2num(Header{l+2});
        break;
    end
    if(strcmp(Header{l},'sample_rate'))
        Fs = str2num(Header{l+2});
        break;
    end
end


if(Channels == 2);
    Data(1:1024) = [];%remove header
    Y1=pcmu2lin(Data(1024:2:end-1));
    Y2=pcmu2lin(Data(1024+1:2:end));
    Data = Y1+Y2;
else
    Data(1:1024) = [];%remove header
    Data = pcmu2lin(Data(1024:end));
end

fclose(fid);