

if ~exist([outDir, datName, detected_suffix, '_data', '.mat'])
    fprintf('Time %3.0fs. NEO filtering data...\n', toc);
	NEO_data = zeros(Nchan,Nsamples,'int32');
    for i = 2:(Nsamples-1)
    	NEO_data(:,i)	=	cast(in_data(:,i),'int32').*cast(in_data(:,i),'int32')-cast(in_data(:,i+1),'int32').*cast(in_data(:,i-1),'int32');
    end
    NEO_data(:,1)			=	NEO_data(:,2);
    NEO_data(:,Nsamples)	=	NEO_data(:,end-1);
    save([outDir, datName, detected_suffix, '_data'], 'NEO_data', '-v7.3');
else
    fprintf('Time %3.0fs. Load NEO data...\n', toc);
    NEO_data = load([outDir, datName,detected_suffix, '_data','.mat']).NEO_data;
end

if ~exist([outDir, datName, detected_suffix, '_Thr','.mat'])
    fprintf('Time %3.0fs. Compute Threshold for Plot...\n', toc);
    NEO_Thr = mean(NEO_data(:,1:(6*Fs)),2); % 4 sec
    save([outDir, datName, detected_suffix, '_Thr'], 'NEO_Thr', '-v7.3');
else
    fprintf('Time %3.0fs. Load NEO Thr...\n', toc);
    NEO_Thr = load([outDir, datName, detected_suffix, '_Thr','.mat']).NEO_Thr;
end
