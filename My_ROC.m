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
    NEO_Thr = mean(NEO_data,2);
    save([outDir, datName, detected_suffix, '_Thr'], 'NEO_Thr', '-v7.3');
else
    fprintf('Time %3.0fs. Load NEO Thr...\n', toc);
    NEO_Thr = load([outDir, datName, detected_suffix, '_Thr','.mat']).NEO_Thr;
end

in_data = filtered_data;
Nspike = size(gtRes,1);

roc_range = [-1*bitshift(1,5) bitshift(1,0:12)];

if ~exist([outDir, datName, detected_suffix, '_eval','.mat'])
	k = 0;
	for i = roc_range
		fprintf('NEO_C : %d\n', i);
		NEO_C = i;
		k = k + 1;
		Thr = NEO_C * NEO_Thr;

		detection_out(k) = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt);
		Ndetected(k) = size(detection_out(k).spike_time,1);
		[TP(k) TN(k) FP(k) FN(k)] = eval_det(detection_out(k).spike_time, gtRes, gtClu(2:end), Nsamples, opt);
	end
	eval_out.TP = TP;
	eval_out.TN = TN;
	eval_out.FP = FP;
	eval_out.FN = FN;
	save([outDir, datName, detected_suffix, '_eval'], 'eval_out', '-v7.3');
else
	eval_out = load([outDir, datName, detected_suffix, '_eval','.mat']).eval_out;
	TP = eval_out.TP;
	TN = eval_out.TN;
	FP = eval_out.FP;
	FN = eval_out.FN;
	k = size(FN,1);
end

for i = 5:k-3
	fprintf('NEO_C : %d\n',roc_range(i));
	fprintf('\t\t\tTrue\t\tFalse\n');
	fprintf('\tPositive\t%d\t\t%d\n',TP(i), FP(i));
	fprintf('\tNegative\t%d\t%d\n',TN(i), FN(i));
	fprintf('\tTPR : %f', TP(i)/(Nspike));
	fprintf('\tTNR : %f\n', TN(i)/(Nsamples-Nspike));
	fprintf('\tDetection Accuracy\t- [TP/P]: %5.2f%%\n', 100*TP(i)/Ndetected(i));
	fprintf('\n');
end


figure;
hold on
%for i = 1:size(roc_range,2)
%    plot(1-(TN(i)/(Nsamples -Nspike)),TP(i)/Nspike,'ro');
%end
plot(1-(TN/(Nsamples -Nspike)),TP/Nspike,'r--o');
hold off
xlabel('Probability of False Alarm')
ylabel('Probability of Detection')
set(gcf,'color','w');
