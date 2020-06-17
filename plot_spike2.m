function [] = plot_spike2(in_data, plot_ch, col_num, row_distance, plot_x, plot_y, plot_opt, opt,plot_time)

%ex plot_spike2(in_data			, plot_ch	, col_num	, row_distance	, plot_x	, plot_y, plot_opt	, opt	, plot_time)
%ex plot_spike2(filtered_data	, [1:129]	, 3			, 200			, [0 0]		, [0 0]	, detect_opt, opt	, 1146367)


Nchan = size(in_data, 1);
Nsamples = size(in_data, 2);

Nplot = length(plot_ch);

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;

Thr_a			=   plot_opt.Thr_a;
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
    data = in_data;
%end

if(overlap_range == 0)
    overlap_range = floor(spike_length/2);
end

fprintf('Time %3.0fs. Plotting Spike Started \n', toc);

fig = figure('Name',['Detected spike w/ all ch @ t :', num2str(plot_time)],'NumberTitle','off');
X = 1:spike_length;
p = uipanel('Parent',fig,'BorderType','none'); 

fnum = Nplot;
fsize = ceil(fnum/col_num);

spike_start_idx = (plot_time-align_idx+1);

for i = 1:col_num
	j_start = (i-1)*fsize + plot_ch(1);
	j_index = 0;
	plot_data = zeros(fsize,spike_length);
    subplot(1,col_num,i,'Parent',p)
    hold on;
	% desending order
	%for j = j_start:j_start+(fsize-1)
	% ascending order
	for j = flip(j_start:j_start+(fsize-1))
		if(j > fnum)
			break;
		end
		j_index = j_index + 1;
		plot_data(j_index,:) = data(j,[spike_start_idx:spike_start_idx+spike_length-1]) + (j_index-1)*row_distance;
	end
	plot(X, plot_data, 'r');
	ylabel('Ch');
	set(gca,'YTick',0:row_distance:(fsize-1)*row_distance)	% Y axis values going to be affected
	% descending order
	%set(gca,'YTickLabel',j_start:j_start+(fsize-1));	% Values goint to appear in above(YTick) places
	% ascending order
	set(gca,'YTickLabel',flip(j_start:j_start+(fsize-1)));	% Values goint to appear in above(YTick) places
	ylim([-(row_distance+500) fsize*row_distance+1000])
	if(~isequal(plot_x , [0 0]))
		xlim(plot_x)
	end
	if(~isequal(plot_y , [0 0]))
		ylim(plot_y)
	end 
    hold off;
end
fprintf('Time %3.0fs. Plotting Spike finished \n', toc);
