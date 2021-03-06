opt.datDir = '/home/sykim/Project/neuro/Simulator/';

opt.datName = C_Burst_Easy2_noise015.mat
opt.datName = C_Difficult1_noise005.mat
opt.datName = C_Difficult1_noise01.mat
opt.datName = C_Difficult1_noise015.mat
opt.datName = C_Difficult1_noise02.mat
opt.datName = C_Difficult2_noise005.mat
opt.datName = C_Difficult2_noise01.mat
opt.datName = C_Difficult2_noise015.mat
opt.datName = C_Difficult2_noise02.mat
opt.datName = C_Drift_Easy2_noise015.mat
opt.datName = C_Easy1_noise005.mat
opt.datName = C_Easy1_noise01.mat
opt.datName = C_Easy1_noise015.mat
opt.datName = C_Easy1_noise01_short.mat
opt.datName = C_Easy1_noise02.mat
opt.datName = C_Easy1_noise025.mat
opt.datName = C_Easy1_noise03.mat
opt.datName = C_Easy1_noise035.mat
opt.datName = C_Easy1_noise04.mat
opt.datName = C_Easy2_noise005.mat
opt.datName = C_Easy2_noise01.mat
opt.datName = C_Easy2_noise015.mat
opt.datName = C_Easy2_noise02.mat
opt.datName = C_Test_LFPcorr_Easy2_noise015.mat
opt.datName = times_C_Difficult1_noise015.mat

opt.outDir = './output/';
opt.dat =[opt.datDir, opt.datName, '.dat'];

opt.filtered_suffix     = '_filtered';
opt.threshold_suffix    = '_dvt_Thr';
opt.feature_suffix      = '_feature';
opt.cluster_suffix      = '_cluster';

opt.Fs			    =	25000;
opt.filter_band	    =	[300 6000];
opt.Nchan		    =	129;
opt.plot_ch         =   1;
opt.NgtClu          =   7; % 0 : set automatically
opt.spike_length    =   30;
opt.reverse         =   2;

% detection
detect_opt.Thr              =   700;
detect_opt.Thr_a            =   12; % 13?
detect_opt.reverse          =   1;
detect_opt.spike_length     =   opt.spike_length;
detect_opt.align_idx        =   15; %15; 
detect_opt.halt_range       =   1; 
    % 0 for default : spike_length/2
    % detector halt time to avoid multiple detection of same spike
detect_opt.overlap_range    =   opt.spike_length/2; 
    % 0 for default : spike_length/2 
    % spikes within this range are assumed to be overlapped spike
detect_opt.detect_method    =   'NEO';  
    % 'thr'     : simple threshold
    % 'dvt'    : Convex threshold
    % 'NEO'     : NEO
detect_opt.avg_range        =   32; % 8, 16, 32
detect_opt.align_opt        =   'det';  
    % 'det'     : detected point itself
    % 'slope'   : max slope
    % 'amp'     : max amp
detect_opt.NEO_C            =   256; 
    % many researches set C = 8 (empirically)
    % for this dataset, 256 shows best detection metric value
    % for this dataset, 64 is best for SDC
detect_opt.NEO_N            =   opt.spike_length; 
opt.detected_suffix         =   ['_detected_' detect_opt.detect_method];

% feature extraction
feature_opt.sum_idx         = detect_opt.align_idx;
feature_opt.spike_length    = detect_opt.spike_length;

% cluster
cluster_opt.Ncluster        =   8; %opt.NgtClu+1; % 0 : set automatically
cluster_opt.feature_weight  =   1;		
cluster_opt.channel_weight  =   bitshift(1,10);% bitshift(1,10) = %1024
cluster_opt.merge_weight    =   16; % bigger 16, 32
cluster_opt.mean_weight     =   1;
cluster_opt.max_dis_thr     =   0;
cluster_opt.min_dis_thr     =   1000; %867?
cluster_opt.ch_m_range      =   2;
cluster_opt.spike_p_sec     =   7;
cluster_opt.cnt_thr         =   8;

%evaluation
evaluation_opt.Ncluster     =   cluster_opt.Ncluster;




% plot
opt.filter_plot             =   0;
detect_opt.do_plot          =   0;
feature_opt.do_plot         =   0;
cluster_opt.do_plot         =   0;



