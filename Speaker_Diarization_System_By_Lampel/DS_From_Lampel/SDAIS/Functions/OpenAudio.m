function [Data, Fs, Bits] = OpenAudio( fileName, Verbose )

% USAGE : [Data, Fs, Bits] = openAudio( fileName)
%
% openAudio - opens wav and sphere audio files
%
% INPUT :   fileName - full file path

[Path, Name, Ext] = fileparts( fileName );

if(Verbose == 1)
    fprintf('Open audio file %s',[Name Ext]);
    tic;
end



switch(Ext)
    case '.wav'
        [Data, Fs] = audioread( fileName );
        %[Data, Fs, WMode, Fidx] = readwav( fileName );
        
    case '.sph'
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
            end
            if(strcmp(Header{l},'sample_rate'))
                Fs = str2num(Header{l+2});
            end
        end
        
        if(Channels == 2);
            Y1=pcmu2lin(Data(1025:2:end-1));
            Y2=pcmu2lin(Data(1026:2:end));
%             Y1 = Y1./max(abs(Y1));
%             Y2 = Y2./max(abs(Y2));
            Data = Y1+Y2;
%             Data = Data./max(abs(Data));
        else
            Data = pcmu2lin(Data(1025:end));
%             Data = Data./max(abs(Data));
        end
        
        fclose(fid);
end


if(Verbose == 1)
    Time = toc;
    fprintf(' - %3.2f Sec\n',Time);
end

