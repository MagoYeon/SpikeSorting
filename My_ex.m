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
if(filter_plot)
    fprintf('Time %3.0fs. Plotting Filtered Data Started \n', toc);
    fig = figure('Name','Filtered Signals with label','NumberTitle','off');

	filtered_max = max(filtered_data(plot_ch,:));
	filtered_min = min(filtered_data(plot_ch,:));
    p = uipanel('Parent',fig,'BorderType','none'); 
    T = 1/Fs;
    L = Nsamples;
    t = (0:L-1)*T;
    n = 2^nextpow2(L);

    % to see spectrum of casted filtered signal
    Y = fftshift(fft(filtered_data(plot_ch,:), n));
    f = Fs*(-n/2:n/2-1)/n;
    subplot(2,1,1,'Parent',p)
    plot(f,abs(Y) )
    title('C-Filtered-FFT')
    xlabel('f (Hz)')
    ylabel('|P1(f)|')

    subplot(2,1,2,'Parent',p)
    ylim([filtered_min filtered_max])
    xlim([0 Nsamples])
    plot(Fs*t, filtered_data(plot_ch,:))
    hold on, plot(1:Nsamples, 50*gtResFlatten, 'r'), hold off;    
    title('c-filtered data w/ spike label')
    
    if(plot_pause)
        for idx = 1:length(gtRes)
            xlim([(gtRes(idx)-5000) (gtRes(idx)+5000)])
            ylim([filtered_min filtered_max])
            key = input('next');
            if (key == 0)
                break;
            elseif(isempty(key))
                fprintf('');
            else                
                fprintf('go to idx : %d',key);
                idx = key;
            end
        end
    end
    fprintf('Time %3.0fs. Plotting Filtered Data Finished \n', toc);

end


%% 

% Detection

detection_method	= detection_opt.detection_method;
dvt	                = strcmp(detection_method , 'dvt');
NEO	                = strcmp(detection_method , 'NEO');

if ~exist([outDir, datName, detected_suffix, '.mat'])
    if(dvt)
        detection_out = spike_det_dvt2(filtered_data, detect_opt, opt);
    elseif(NEO
        detection_out = spike_det_NEO(filtered_data, detect_opt, opt);
    end
else
	fprintf('Detected Spikeds Exists\n');
    fprintf('Time %3.0fs. Loading Detected Spikes Started \n', toc);
    detection_out = load([outDir, datName,detected_suffix, '.mat']).detection_out;
	fprintf('Time %3.0fs. Loading Detected Spikes Finished \n', toc);
end


%%

% Feature Extraction
    feature_out =   feature_extraction(detection_out, feature_opt, opt, Nchan);

% Cluster
    [cluster_out K_C]=   My_clustering2(feature_out, detection_out.channel, detection_out.spike_ch, cluster_opt, opt);

% Evaluation
    evaluation_out  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);


