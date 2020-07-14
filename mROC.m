fprintf('Start\n\n');
tic;

fprintf('Time %3.0fs. Set Parameters \n', toc);
set_parameters
%set_parameters_clus

%%% TEST PARAMETERS %%%%% 
roc             = 0;
single_run		= 1;
mtest_flag      = 0;
feature_test    = 0;
noise_DB		= 0;
batch_size		= 10; % [%]

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


detect_method		=	detect_opt.detect_method;
Thr_a               =   detect_opt.Thr_a;

fprintf('Time %3.0fs. Load gtRes \n', toc);
fid = fopen([datDir,datName,'.res.1'], 'r'); 
ori_gtRes = int32(fscanf(fid, '%d')); 

fprintf('Time %3.0fs. Load gtClu \n', toc);
fid = fopen([datDir,datName,'.clu.1'], 'r'); 
ori_gtClu = int32(fscanf(fid, '%d')); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
method_NEO	= strcmp(detect_method , 'NEO');
method_SVT	= strcmp(detect_method , 'dvt');
method_ABS  = strcmp(detect_method , 'abs');

fclose(fid);

if(opt.NgtClu == 0)
    opt.NgtClu = max(gtClu)-min(gtClu)+1;
end
if(cluster_opt.Ncluster == 0)
    cluster_opt.Ncluster = opt.NgtClu;
end

writematrix(ori_gtClu,[outDir, datName, '_gtClu'], 'Delimiter', 'tab');
%%

% File read
% (+Filtering)

if ~exist([outDir, datName, filtered_suffix, '.mat'])
	[rawData Nsamples] = read_rawData(dat,Nchan);
	ori_filtered_data = filter_data(rawData, opt);
	clearvars rawData;
else
	fprintf('\tFiltered Data Exists\n');
    tic;
    fprintf('Time %3.0fs. Loading Filtered Data Started \n', toc);
    ori_filtered_data = load([outDir, datName,filtered_suffix, '.mat']).filtered_int16_data;
	fprintf('Time %3.0fs. Loading Filtered Data Finished \n', toc);
    
    Nsamples = size(ori_filtered_data, 2);
end

if batch_size ~= 0	% 1 try
    Nsamples = size(ori_filtered_data, 2);
	Nsamples	= ceil(Nsamples * batch_size * 0.01);
	Nspike		= find(ori_gtRes > Nsamples,1) - 1;
	gtRes		= ori_gtRes(1:Nspike);
	gtClu		= ori_gtClu(1:Nspike+1);
end


if(opt.reverse)
    fprintf('Time %3.0fs. Reversing data...\n', toc);
    filtered_data = -1*ori_filtered_data;
end

%%% get data for simulation
%target_spike = 1
%simul_time = gtRes(target_spike)+100;
%simul_data = zeros(Nchan*simul_time,1);
%data_tmp = filtered_data(:,1:simul_time);
%for i = 1:simul_time
%	i_start = 1+(i-1)*Nchan;
%	i_end	= i_start+Nchan-1;
%	simul_data(i_start:i_end,1) = filtered_data(:,i);
%end
%writematrix(simul_data,[outDir, datName, '_simul_data_',num2str(target_spike)], 'Delimiter', 'tab');

gtResFlatten = zeros(1, Nsamples);
for idx = 1:length(gtRes)
    gtResFlatten(gtRes(idx)) = 1;
end
plot_pause = 0;


if(noise_DB ~= 0)
	noise_data = awgn(filtered_data(:,1:Nsamples),noise_DB,'measured');
	in_data=noise_data;
else
	in_data=filtered_data(:,1:Nsamples);
end


if(method_NEO)
    loadNEO
    NEO_C = detect_opt.NEO_C;
    Nspike = size(gtRes,1);
    Thr = NEO_C * NEO_Thr;
    if(roc)
        mtestNEO
    end
end
if(method_SVT)
    %loadSVT
    loadDEV
    if(roc)
        %mtestSVT
        mtestDEV
    end
end
if(method_ABS)
    if(roc)
        mtestABS
    end
end

%if(roc)
%    figure;
%    hold on
%    if(method_NEO)
%        plot(1-(NEO_TN/(Nsamples -Nspike)),NEO_TP/Nspike,'r--o');
%        legend({'NEO'});
%    end
%    if(method_SVT)
%        plot(1-(SVT_TN/(Nsamples -Nspike)),SVT_TP/Nspike,'b--o');
%        legend({'SVT'});
%    end
%    if(method_ABS)
%        plot(1-(abs_TN/(Nsamples -Nspike)),abs_TP/Nspike,'k--o');
%        legend({'ABS'});
%    end
%    hold off
%    xlabel('Probability of False Alarm')
%    ylabel('Probability of Detection')
%    set(gcf,'color','w');
%end
Thr = detect_opt.NEO_C * NEO_Thr;
detection_out_My = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);
detection_out_My2 = ROC_NEO2(in_data,NEO_data, Thr, detect_opt, opt, 1);
feature_out_My		            =   feature_extraction(		detection_out_My,	feature_opt,opt,Nchan);
feature_out_My2		            =   feature_extraction(		detection_out_My2,	feature_opt,opt,Nchan);

if(single_run)
    [cluster_out_My_c	K_C_My_c]	=   My_clustering3(feature_out_My, detection_out_My.channel, gtRes,  detection_out_My.spike_ch, cluster_opt, opt, 0);
    [cluster_out_My_c2	K_C_My_c2]	=   My_clustering3(feature_out_My2, detection_out_My2.channel, gtRes,  detection_out_My.spike_ch, cluster_opt, opt, 0);
    [DA_My_c CA_My_c SA_My_c FN_My_c TP_My_c FP_My_c]       =   evaluation(detection_out_My.spike_time, cluster_out_My_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
    [DA_My_c2 CA_My_c2 SA_My_c2 FN_My_c2 TP_My_c2 FP_My_c2]       =   evaluation(detection_out_My2.spike_time, cluster_out_My_c2, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);

	eval_out.DA_My_c	=	DA_My_c;
	eval_out.CA_My_c	=	CA_My_c;
	eval_out.SA_My_c	=	SA_My_c;
	eval_out.FN_My_c	=	FN_My_c;
	eval_out.TP_My_c	=	TP_My_c;
	eval_out.FP_My_c	=	FP_My_c;
	eval_out.DA_My_c2	=	DA_My_c2;
	eval_out.CA_My_c2	=	CA_My_c2;
	eval_out.SA_My_c2	=	SA_My_c2;
	eval_out.FN_My_c2	=	FN_My_c2;
	eval_out.TP_My_c2	=	TP_My_c2;
	eval_out.FP_My_c2	=	FP_My_c2;

    fprintf('save\n');
	save([outDir, datName, '_eval_' ,num2str(param_ID)], 'eval_out');
end
    %for i = 1:9
    %    fprintf('%d\t: %f\t%f |\t',i,int16(K_C_My_c2(i,1)),int16(K_C_My_c2(2)));
    %    fprintf('%d ',find(K_C_My_c2(i,3:end)~=0));
    %    fprintf('\n');
    %end

    %writematrix(int16(Thr),[outDir, datName, '_Thr_tmp'], 'Delimiter', 'tab');
if(mtest_flag)
    mtest
end

if(feature_test)
    feature_out_My		            =   feature_extraction(		detection_out_My,	feature_opt,opt,Nchan);
    feature_out_DD      =   feature_ex_DD(      detection_out_DD,   feature_opt,opt,Nchan);
    feature_out_ZCF     =   feature_ex_ZCF(     detection_out_ZCF,  12,feature_opt,opt,Nchan);
    feature_out_TVLSI   =   feature_ex_TVLSI(   detection_out_TVLSI,feature_opt,opt,Nchan);
    feature_out_MD		=   feature_ex_MD(		detection_out_MD,	feature_opt,opt,Nchan);

    [cluster_out_DD     K_C_DD]     =   clustering(feature_out_DD, [],      detection_out_DD.spike_ch, cluster_opt, opt);
    [cluster_out_ZCF    K_C_ZCF]    =   clustering(feature_out_ZCF, [],     detection_out_ZCF.spike_ch, cluster_opt, opt);
    [cluster_out_TVLSI  K_C_TVLSI]  =   clustering(feature_out_TVLSI, [],   detection_out_TVLSI.spike_ch, cluster_opt, opt);
    [cluster_out_MD		K_C_MD]		=   clustering(feature_out_MD, [],   detection_out_MD.spike_ch, cluster_opt, opt);
    [cluster_out_My		K_C_My]		=   clustering(feature_out_My, [],   detection_out_My.spike_ch, cluster_opt, opt);
    [cluster_out_My_c	K_C_My_c]	=   clustering(feature_out_My, detection_out_My.channel,   detection_out_My.spike_ch, cluster_opt, opt);

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
    feature_eval = load([outDir, datName, '_feature_eval','.mat']).feature_eval;

    %CA =    [CA_DD      CA_ZCF      CA_TVSLI	CA_MD	];
    %CA_c =  [CA_DD_c    CA_ZCF_c    CA_TVSLI_c	CA_MD_c	CA_My_c];

    DD_w = 7*3*16*Nchan;
    ZCF_w = 2*16*Nchan;
    TVLSI_w = 4*16*Nchan;
    MD_w = 2*16*Nchan;
    ASP_w = 2*16+Nchan;

    CA = [feature_eval.CA(4) feature_eval.CA(2) feature_eval.CA(3) feature_eval.CA(1) ...
            feature_eval.CA(9) feature_eval.CA(7) feature_eval.CA(8) feature_eval.CA(4) feature_eval.CA(10)];

    X = 1:size(CA,2);

    feature_w = [DD_w		MD_w		ZCF_w		TVLSI_w ...
                DD_w+Nchan	MD_w+Nchan	ZCF_w+Nchan TVLSI_w+Nchan ASP_w];



    figure;
    %plot(X, [CA CA_c], 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k')
    set(gcf,'color','w');
    yyaxis left
    plot(X, CA, 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k')
    set(gca,'YColor','k');
    ylabel('Clustering Accuracy');
    %ax1 = gca;
    %ax1_pos = ax1.Position;
    %ax2 = axes('Position',ax1_pos, ...
    %			'XAxisLocation','top', ...
    %			'YAxisLocation', 'right', ...
    %			'Color','none');

    yyaxis right
    plot(X, feature_w, 'b-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','b')
    ylabel('Memory Requirement')
    set(gca,'XTick',X)	% Y axis values going to be affected
    %set(gca,'XTickLabel',{'DD' 'ZCF' 'Filter' 'MD' 'APS' 'DD+SDC' 'ZCF+SDC' 'Filter+SDC' 'MD+SDC' 'APS+SDC'});	% Values goint to appear in above(YTick) places
    set(gca,'XTickLabel',{'DD' 'ZCF' 'Filter' 'MD' 'DD+SDC' 'ZCF+SDC' 'Filter+SDC' 'MD+SDC' 'APS+SDC'});	% Values goint to appear in above(YTick) places
    set(gca,'YColor','b');
    grid on

    DD_w = 7*3*16;
    ZCF_w = 2*16;
    TVLSI_w = 4*16;
    MD_w = 2*16;
    ASP_w = 2*16;

    W = [TVLSI_w DD_w ZCF_w];
    My_W = ASP_w;
    range = 12;
    num = 3;

    P_W = zeros(range,num);
    P_My = zeros(range,1);
    for i = 1:range
        k = bitshift(1,i);
        P_W(i,:) = [W*k];
        P_My(i) = My_W+i;
        xt{i} = ['2^{' num2str(bitshift(1,i)),'}'];
    end

    X = 1:range;
    figure;
    hold on
    for i = 1:num
        plot(X,  P_W(:,i), 'LineWidth', 2)
    end
    plot(X,  P_My, 'LineWidth', 2);

    hold off
    set(gcf,'color','w');
    legend({'[TVLSI 2019]', '[JSSC 2011]', '[EMBC 2013]', '[This Paper]'});

    set(gca,'XScale','log')
    set(gca,'XTick',bitshift(1,1:range))	% Y axis values going to be affected
    set(gca,'XTickLabel',xt);	% Values goint to appear in above(YTick) places

    feature_out = feature_out_My;
    detection_out = detection_out_My;
end
