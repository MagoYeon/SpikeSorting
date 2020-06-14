fprintf('Start\n\n');
tic;

fprintf('Time %3.0fs. Set Parameters \n', toc);
set_parameters

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
dat                 =   opt.dat;
detected_suffix     =   opt.detected_suffix;
filtered_suffix     =   opt.filtered_suffix;
threshold_suffix    =   opt.threshold_suffix;

filter_plot         =   opt.filter_plot;
Fs                  =   opt.Fs;
Nchan               =   opt.Nchan;
filter_band         =   opt.filter_band;
plot_ch             =   opt.plot_ch;


fprintf('Time %3.0fs. Load gtRes \n', toc);
fid = fopen([datDir,datName,'.res.1'], 'r'); 
gtRes = int32(fscanf(fid, '%d')); 

fprintf('Time %3.0fs. Load gtClu \n', toc);
fid = fopen([datDir,datName,'.clu.1'], 'r'); 
gtClu = int32(fscanf(fid, '%d')); 

fclose(fid);

if(opt.NgtClu == 0)
    opt.NgtClu = max(gtClu)-min(gtClu)+1;
end
if(cluster_opt.Ncluster == 0)
    cluster_opt.Ncluster = opt.NgtClu;
end

writematrix(gtClu,[outDir, datName, '_gtClu'], 'Delimiter', 'tab');
%%

% File read
% (+Filtering)

if ~exist([outDir, datName, filtered_suffix, '.mat'])
	[rawData Nsamples] = read_rawData(dat,Nchan);
	filtered_data = filter_data(rawData, opt);
else
	fprintf('\tFiltered Data Exists\n');
    tic;
    fprintf('Time %3.0fs. Loading Filtered Data Started \n', toc);
    filtered_data = load([outDir, datName,filtered_suffix, '.mat']).filtered_int16_data;
	fprintf('Time %3.0fs. Loading Filtered Data Finished \n', toc);
    
    Nsamples = size(filtered_data, 2);
end

if(opt.reverse)
    fprintf('Time %3.0fs. Reversing data...\n', toc);
    filtered_data = -1*filtered_data;
end


gtResFlatten = zeros(1, Nsamples);
for idx = 1:length(gtRes)
    gtResFlatten(gtRes(idx)) = 1;
end
plot_pause = 0;



if ~exist([outDir, datName, detected_suffix, '_data', '.mat'])
    fprintf('Time %3.0fs. NEO filtering data...\n', toc);
    for i = 2:(Nsamples-1)
    	NEO_data(:,i)	=	in_data(:,i).*in_data(:,i)-in_data(:,i+1).*in_data(:,i-1);
    end
    NEO_data(:,1)			=	NEO_data(:,2);
    NEO_data(:,Nsamples)	=	NEO_data(:,end);
    save([outDir, datName, detected_suffix, '_data'], 'NEO_data', '-v7.3');
else
    fprintf('Time %3.0fs. Load NEO data...\n', toc);
    NEO_data = load([outDir, datName,detected_suffix, '_data','.mat']).NEO_data;
end

if ~exist([outDir, datName, detected_suffix, '_Thr','.mat'])
    fprintf('Time %3.0fs. Compute Threshold for Plot...\n', toc);
    Thr = mean(NEO_data,2);
    save([outDir, datName, detected_suffix, '_Thr'], 'Thr', '-v7.3');
else
    fprintf('Time %3.0fs. Load NEO Thr...\n', toc);
    Thr = load([outDir, datName, detected_suffix, '_Thr','.mat']).Thr;
end


Thr = NEO_C * Thr;

detection_out = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt);
[TP TN FP FN] = eval_det(detection_out.spike_time, gtRes, gtClu(2:end), Nsamples, opt);


