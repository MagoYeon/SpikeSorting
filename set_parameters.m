opt.datDir = '/home/sykim/Project/neuro/MEAs_dataset/phy/set1/';
opt.datName = '20141202_all_es';
opt.outDir = './output/';
opt.dat =[opt.datDir, opt.datName, '.dat'];

opt.filtered_suffix     = '_filtered';
opt.detected_suffix     = '_detected_dvt';
opt.threshold_suffix    = '_dvt_Thr';
opt.feature_suffix      = '_feature';
opt.cluster_suffix      = '_cluster';

opt.Fs			    =	25000;
opt.filter_band	    =	[300 6000];
opt.Nchan		    =	129;
opt.plot_ch         =   1;
opt.NgtClu          =   7; % 0 : set automatically
opt.spike_length    =   30;

% detection
detect_opt.Thr              =   700;
detect_opt.Thr_a            =   12;
detect_opt.reverse          =   1;
detect_opt.spike_length     =   opt.spike_length;
detect_opt.align_idx        =   15; 
detect_opt.overlap_range    =   5; % 0 for default : spike_length/2
detect_opt.detect_method    =   'cnvx';  
detect_opt.avg_range        =   32; % 8, 16, 32
% 'thr'     : simple threshold
% 'cnvx'    : Convex threshold
detect_opt.align_opt        =   'det';  
% 'det'     : detected point itself
% 'slope'   : max slope
% 'amp'     : max amp

% feature extraction
feature_opt.sum_idx         = detect_opt.align_idx;
feature_opt.spike_length    = detect_opt.spike_length;

% cluster
cluster_opt.Ncluster        =   8; %opt.NgtClu+1; % 0 : set automatically
cluster_opt.feature_weight  =   1;		
cluster_opt.channel_weight  =   bitshift(1,9);% bitshift(1,10) = %1024

%evaluation
evaluation_opt.Ncluster     =   cluster_opt.Ncluster;




% plot
opt.filter_plot             =   0;
detect_opt.do_plot          =   0;
feature_opt.do_plot         =   0;
cluster_opt.do_plot         =   0;



