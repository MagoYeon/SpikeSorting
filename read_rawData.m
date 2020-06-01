function [rawData, Nsamples] = read_rawData(datafile, Nch)

d = dir(datafile);
Nsamples = floor(d.bytes/Nch/2); % int16

%rawData = zeros(Nch, Nsamples); %dont use it due to 'array size limit'

fprintf('Time %3.0fs. Reading Raw Data Started \n', toc);
fid = fopen(datafile, 'r');
rawData = fread(fid, [Nch Nsamples], '*int16');
fclose(fid);
fprintf('Time %3.0fs. Reading Raw Data Finished \n', toc);
