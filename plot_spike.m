function [] = plot_spike(in_data, plot_ch, plot_x, plot_y, plot_opt, opt, plot_time)


%ex plot_spike(in_data		, plot_ch, plot_x	, plot_y	, plot_opt	, opt   , plot_time)
%ex plot_spike(filtered_data, [1:129], [0 0]	, [0 1000]	, detect_opt, opt   , 1146367)


Nchan = size(in_data, 1);
Nsamples = size(in_data, 2);

Nplot = length(plot_ch);

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;


Thr_a		    =   plot_opt.Thr_a;
reverse			=   plot_opt.reverse;
spike_length	=   plot_opt.spike_length;
align_idx		=   plot_opt.align_idx;
align_opt		=	plot_opt.align_opt;
detect_method	=	plot_opt.detect_method;
overlap_range   =   plot_opt.overlap_range;


if exist([outDir, datName, threshold_suffix,'.mat'])
    fprintf('Threshold Loaded\n');
    Thr = load([outDir, datName,threshold_suffix, '.mat']).Thr;
    Thr = Thr*Thr_a;
else
    fprintf('No Threshold Loaded\n');
    Thr = zeros(Nchan,1);
end


%if(reverse)
%    fprintf('Time %3.0fs. Reversing data...\n', toc);
%    data = -1*in_data;
%else
%    data = in_data;
%end

if(overlap_range == 0)
    overlap_range = floor(spike_length/2);
end

fprintf('Time %3.0fs. Plotting Spike Started \n', toc);

fig = figure('Name',['Detected spike w/ all ch @ t :', num2str(plot_time)],'NumberTitle','off');
X = 1:spike_length;
p = uipanel('Parent',fig,'BorderType','none'); 

fnum = Nplot;
fsize = ceil(sqrt(fnum));

spike_start_idx = (plot_time-align_idx+1);

for i = 1:fnum
    subplot(fsize,fsize,i,'Parent',p)
    hold on;
    plot(X, data(plot_ch(i),[spike_start_idx:spike_start_idx+spike_length-1]));
    plot(align_idx, data(plot_ch(i),plot_time), 'ro');
    plot(X, Thr(plot_ch(i))*ones(1, length(X)),'r');
	if(~isequal(plot_x , [0 0]))
		xlim(plot_x)
	end
	if(~isequal(plot_y , [0 0]))
		ylim(plot_y)
	end 
    hold off;
    title(['ch : ',num2str(plot_ch(i))]);
end
fprintf('Time %3.0fs. Plotting Spike finished \n', toc);
