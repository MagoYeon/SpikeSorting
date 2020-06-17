fprintf('Start\n\n');
tic;

fprintf('Time %3.0fs. Set Parameters \n', toc);
set_parameters3

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



in_data=filtered_data;
if ~exist([outDir, datName, detected_suffix, '_data', '.mat'])
    fprintf('Time %3.0fs. NEO filtering data...\n', toc);
	NEO_data = zeros(Nchan,Nsamples,'int16');
    for i = 2:(Nsamples-1)
    	NEO_data(:,i)	=	in_data(:,i).*in_data(:,i)-in_data(:,i+1).*in_data(:,i-1);
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
    NEO_Thr = mean(NEO_data,2);
    save([outDir, datName, detected_suffix, '_Thr'], 'NEO_Thr', '-v7.3');
else
    fprintf('Time %3.0fs. Load NEO Thr...\n', toc);
    NEO_Thr = load([outDir, datName, detected_suffix, '_Thr','.mat']).NEO_Thr;
end

Nspike = size(gtRes,1);
Thr = NEO_C * NEO_Thr;

roc = 0;
if(roc)
    roc_range = [-1*bitshift(1,5) bitshift(1,0:8) [512:100:1024] [129:10:256]];

    if ~exist([outDir, datName, detected_suffix, '_eval','.mat'])
        k = 0;
        for i = roc_range
            fprintf('\tNEO_C : %d\n', i);
            NEO_C = i;
            k = k + 1;
            Thr = NEO_C * NEO_Thr;

            detection_out = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 0);
            Ndetected(k) = size(detection_out.spike_time,1);
            [TP(k) TN(k) FP(k) FN(k)] = eval_det(detection_out.spike_time, gtRes, gtClu(2:end), Nsamples, opt);
        end
        eval_out.TP         = TP;
        eval_out.TN         = TN;
        eval_out.FP         = FP;
        eval_out.FN         = FN;
        eval_out.Ndetected  = Ndetected;
        save([outDir, datName, detected_suffix, '_eval'], 'eval_out', '-v7.3');
    else
        eval_out = load([outDir, datName, detected_suffix, '_eval','.mat']).eval_out;
        TP          = eval_out.TP;
        TN          = eval_out.TN;
        FP          = eval_out.FP;
        FN          = eval_out.FN;
        Ndetected   = eval_out.Ndetected;
        k = size(FN,2);
    end

    abs_roc_range = [-1*bitshift(1,15) bitshift(1,5:2:15)];
    abs_detected_suffix = '_detected_abs';
    if ~exist([outDir, datName, abs_detected_suffix, '_eval','.mat'])
        k = 0;
        for i = abs_roc_range
            fprintf('\tAbs_Thr : %d\n', i);
            k = k + 1;
            Thr = i*ones(Nchan,1);

            abs_detection_out = ROC_NEO(in_data,in_data, Thr, detect_opt, opt, 0);
            abs_Ndetected(k) = size(abs_detection_out.spike_time,1);
            [abs_TP(k) abs_TN(k) abs_FP(k) abs_FN(k)] = eval_det(abs_detection_out.spike_time, gtRes, gtClu(2:end), Nsamples, opt);
        end
        eval_out.TP         = abs_TP;
        eval_out.TN         = abs_TN;
        eval_out.FP         = abs_FP;
        eval_out.FN         = abs_FN;
        eval_out.Ndetected  = abs_Ndetected;
        save([outDir, datName, abs_detected_suffix, '_eval'], 'eval_out', '-v7.3');
    else
        eval_out = load([outDir, datName, abs_detected_suffix, '_eval','.mat']).eval_out;
        abs_TP          = eval_out.TP;
        abs_TN          = eval_out.TN;
        abs_FP          = eval_out.FP;
        abs_FN          = eval_out.FN;
        abs_Ndetected   = eval_out.Ndetected;
        k = size(abs_FN,2);
    end

    %for i = 1:k
    %    fprintf('NEO_C : %d\n',roc_range(i));
    %    fprintf('\t\t\tTrue\t\tFalse\n');
    %    fprintf('\tPositive\t%d\t\t%d\n',TP(i), FP(i));
    %    fprintf('\tNegative\t%d\t%d\n',TN(i), FN(i));
    %    fprintf('\tTPR : %f', TP(i)/(Nspike));
    %    fprintf('\tTNR : %f\n', TN(i)/(Nsamples-Nspike));
    %    fprintf('\tDetection Accuracy\t- [TP/P]: %5.2f%%\n', 100*TP(i)/Ndetected(i));
    %    fprintf('\n');
    %end

    TPR = TP/Nspike;
    TNR = TN/(Nsamples-Nspike);
    pair = [TPR' TNR'];
    [v i] = max(sum(pair,2));
    fprintf('NEO_C best point : %d [%d %d]\n',roc_range(i),pair(i,1),pair(i,2)); 
	fprintf('DA : %f\n',100*TP(i)/Ndetected(i));

	for i = 1:k
		fprintf('%d:%d\n', roc_range(i), 100*TP(i)/Ndetected(i));
	end

	abs_TPR = abs_TP/Nspike;
    abs_TNR = abs_TN/(Nsamples-Nspike);
    abs_pair = [abs_TPR' abs_TNR'];
    [abs_v abs_i] = max(sum(abs_pair,2));
    fprintf('Abs best point : %d [%d %d]\n',abs_roc_range(abs_i),abs_pair(abs_i,1),abs_pair(abs_i,2));
    fprintf('Abs DA : %f\n',100*abs_TP(abs_i)/abs_Ndetected(abs_i));


    figure;
    hold on
    %for i = 1:size(roc_range,2)
    %    plot(1-(TN(i)/(Nsamples -Nspike)),TP(i)/Nspike,'ro');
    %end
    plot(1-(TN/(Nsamples -Nspike)),TP/Nspike,'r--o');
    plot(1-(abs_TN/(Nsamples -Nspike)),abs_TP/Nspike,'b--o');
    hold off
    xlabel('Probability of False Alarm')
    ylabel('Probability of Detection')
    set(gcf,'color','w');
    legend({'NEO' 'Absolute'});
end

Thr = NEO_Thr * 128;

%detect_opt.align_idx        =   15; %15; 
%detect_opt.align_opt        =   'det'; %'amp';  
%detect_opt.spike_length     =   30;  
detection_out_My = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

detect_opt.align_idx        =   11; %15; 
detect_opt.align_opt        =   'det'; %'amp';  
detect_opt.spike_length     =   48;  
detection_out_DD = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

detect_opt.align_idx        =   11; %15; 
detect_opt.align_opt        =   'det'; %'amp';  
detect_opt.spike_length     =   30;  
detection_out_TVLSI = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

detect_opt.align_idx        =   12;
detect_opt.spike_length     =   30;
detect_opt.align_opt        =   'det';  
detection_out_ZCF = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

detect_opt.align_idx        =   12; %15; 
detect_opt.spike_length     =   30;
detect_opt.align_opt        =   'amp';  
detection_out_MD = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

feature_out_DD      =   feature_ex_DD(      detection_out_DD,   feature_opt,opt,Nchan);
feature_out_ZCF     =   feature_ex_ZCF(     detection_out_ZCF,  12,feature_opt,opt,Nchan);
feature_out_TVLSI   =   feature_ex_TVLSI(   detection_out_TVLSI,feature_opt,opt,Nchan);
feature_out_MD		=   feature_ex_MD(		detection_out_MD,	feature_opt,opt,Nchan);
feature_out_My		=   feature_extraction(		detection_out_My,	feature_opt,opt,Nchan);


cluster_opt.channel_weight = 128;

[cluster_out_DD     K_C_DD]     =   clustering(feature_out_DD, [],      detection_out_DD.spike_ch, cluster_opt, opt);
[cluster_out_ZCF    K_C_ZCF]    =   clustering(feature_out_ZCF, [],     detection_out_ZCF.spike_ch, cluster_opt, opt);
[cluster_out_TVLSI  K_C_TVLSI]  =   clustering(feature_out_TVLSI, [],   detection_out_TVLSI.spike_ch, cluster_opt, opt);
[cluster_out_MD		K_C_MD]		=   clustering(feature_out_MD, [],   detection_out_MD.spike_ch, cluster_opt, opt);
[cluster_out_My		K_C_My]		=   clustering(feature_out_My, [],   detection_out_My.spike_ch, cluster_opt, opt);

[cluster_out_DD_c     K_C_DD_c]     =   clustering(feature_out_DD,    detection_out_DD.channel,   detection_out_DD.spike_ch, cluster_opt, opt);
[cluster_out_ZCF_c    K_C_ZCF_c]    =   clustering(feature_out_ZCF,   detection_out_ZCF.channel,  detection_out_ZCF.spike_ch, cluster_opt, opt);
[cluster_out_TVLSI_c  K_C_TVLSI_c]  =   clustering(feature_out_TVLSI, detection_out_TVLSI.channel,detection_out_TVLSI.spike_ch, cluster_opt, opt);
[cluster_out_MD_c		K_C_MD_c]	=   clustering(feature_out_MD, detection_out_MD.channel,   detection_out_MD.spike_ch, cluster_opt, opt);
[cluster_out_My_c		K_C_My_c]	=   clustering(feature_out_My, detection_out_My.channel,   detection_out_My.spike_ch, cluster_opt, opt);

[DA_DD CA_DD SA_DD]             =   evaluation(detection_out_DD.spike_time, cluster_out_DD, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_ZCF CA_ZCF SA_ZCF]          =   evaluation(detection_out_ZCF.spike_time, cluster_out_ZCF, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_TVSLI CA_TVSLI SA_TVSLI]    =   evaluation(detection_out_TVLSI.spike_time, cluster_out_TVLSI, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_MD CA_MD SA_MD]             =   evaluation(detection_out_MD.spike_time, cluster_out_MD, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_My CA_My SA_My]             =   evaluation(detection_out_My.spike_time, cluster_out_My, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);

[DA_DD_c CA_DD_c SA_DD_c]           =   evaluation(detection_out_DD.spike_time, cluster_out_DD_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_ZCF_c CA_ZCF_c SA_ZCF_c]        =   evaluation(detection_out_ZCF.spike_time, cluster_out_ZCF_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_TVSLI_c CA_TVSLI_c SA_TVSLI_c]	=   evaluation(detection_out_TVLSI.spike_time, cluster_out_TVLSI_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_MD_c CA_MD_c SA_MD_c]           =   evaluation(detection_out_MD.spike_time, cluster_out_MD_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
[DA_My_c CA_My_c SA_My_c]           =   evaluation(detection_out_My.spike_time, cluster_out_My_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);

DA =    [DA_DD      DA_ZCF      DA_TVSLI	DA_MD	DA_My];
DA_c =  [DA_DD_c    DA_ZCF_c    DA_TVSLI_c	DA_MD_c	DA_My_c];
CA =    [CA_DD      CA_ZCF      CA_TVSLI	CA_MD	CA_My];
CA_c =  [CA_DD_c    CA_ZCF_c    CA_TVSLI_c	CA_MD_c	CA_My_c];
SA =    [SA_DD      SA_ZCF      SA_TVSLI	SA_MD	SA_My];
SA_c =  [SA_DD_c    SA_ZCF_c    SA_TVSLI_c	SA_MD_c	SA_My_c];

feature_eval.DA = [DA DA_c];
feature_eval.CA = [CA CA_c];
feature_eval.SA = [SA SA_c];

save([outDir, datName, '_feature_eval'], 'feature_eval', '-v7.3');

%CA =    [CA_DD      CA_ZCF      CA_TVSLI	CA_MD	];
%CA_c =  [CA_DD_c    CA_ZCF_c    CA_TVSLI_c	CA_MD_c	CA_My_c];
X = 1:size([CA CA_c],2);


figure;
%plot(X, [CA CA_c], 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k')
plot(X, [CA CA_c], 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k')
title('Clustering Accuracy');
set(gca,'XTick',X)	% Y axis values going to be affected
%set(gca,'XTickLabel',{'DD' 'ZCF' 'Filter' 'MD' 'APS' 'DD+SDC' 'ZCF+SDC' 'Filter+SDC' 'MD+SDC' 'APS+SDC'});	% Values goint to appear in above(YTick) places
set(gca,'XTickLabel',{'DD' 'ZCF' 'Filter' 'MD' 'DD+SDC' 'ZCF+SDC' 'Filter+SDC' 'MD+SDC' 'APS+SDC'});	% Values goint to appear in above(YTick) places
set(gcf,'color','w');
grid on


feature_out = feature_out_My;
detection_out = detection_out_My;

mtest

