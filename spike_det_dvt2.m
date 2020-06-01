function [detection_out] = spike_det_dvt2(in_data, detect_opt, opt);



Nchan = size(in_data, 1);
Nsamples = size(in_data, 2);
%Nsamples = 16623305; % 20%
%Nsamples = ceil(size(in_data,2) * 0.016); 
% Nsample range, ylim

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;
detected_suffix		=	opt.detected_suffix;
plot_ch				=	opt.plot_ch;

Thr				=   detect_opt.Thr;
%Thr_a           =   8;
Thr_a           =   detect_opt.Thr_a;
average_range	=	detect_opt.avg_range; % 32 16 8
reverse			=   detect_opt.reverse;
spike_length	=   detect_opt.spike_length;
align_idx		=   detect_opt.align_idx;
align_opt		=	detect_opt.align_opt;
detect_method	=	detect_opt.detect_method;
overlap_range   =   detect_opt.overlap_range;	% 1~2

plot_ch			=	1;
%plot_ch			=	98;
%plot_ch			=	101;

% strcmp takes time, it slower the detection process when its in if condition
align_amp	= strcmp(align_opt , 'amp');
align_det	= strcmp(align_opt , 'det');
align_slope	= strcmp(align_opt , 'slope');

fprintf('Time %3.0fs. Spike Detection Started \n', toc);
% reverse = 0;
if(reverse)
    fprintf('Time %3.0fs. Reversing data...\n', toc);
    data = -1*in_data;
else
    data = in_data;
end

if(overlap_range == 0)
    overlap_range = floor(spike_length/2);
end

k = 0;
i = 2;
j = 1;

detection_out = struct('spike_time', [], 'spike',[],'spike_ch', [], 'channel',[], 'overlap',[]); 
detected_ch = zeros(1,Nchan,'uint8');
detected_ch = zeros(1,1,'uint8');
detected = 0;
detected_tmp = 0;
overlap_num = 0;
peak = 10000*ones(average_range);	%significant initial value to avoid initial detection error
peak_idx = 0;
peak_num = 0;
Thr = Thr_a*10000*ones(Nchan,1);
Tmp_plot_idx = zeros(1,Nsamples);
Tmp_plot_k = zeros(1,Nsamples);
Tmp_plot_num = 0;
Tmp_plot_ch = plot_ch;

% since it takes short time, no need to load it.
%if ~exist([outDir, datName, threshold_suffix,'.mat'])
    fprintf('Time %3.0fs. Threshold Processing Started \n', toc);
    for peak_j = 1:Nchan
		peak = 10000*ones(average_range);
		peak_num = 0;
		%fprintf('ch %d start\n', peak_j);
		for peak_i = 2:Nsamples-1
            %concave = ( (data_c<data_n) && (data_c<=data_p) );
            convex  = ( (data(peak_j,peak_i)>data(peak_j,peak_i+1)) && (data(peak_j,peak_i)>=data(peak_j,peak_i-1)) );
            if( convex && (data(peak_j,peak_i) > 0) && (data(peak_j,peak_i) < Thr(peak_j)) ) %|| concave )
                peak = [data(peak_j,peak_i) peak(1:average_range-1)];
                Thr(peak_j) = mean(peak); 	
				peak_num = peak_num + 1;
				if(peak_num == average_range)
					%fprintf('ch %d done\n', peak_j);
					break;
				end
            end
        end
    end
    fprintf('Time %3.0fs. Threshold Processing Finished \n', toc);

    fprintf('Time %3.0fs. Saving Threshold Started \n', toc);
    save([outDir, datName, threshold_suffix, '.mat'], 'Thr', '-v7.3');
    fprintf('Time %3.0fs. Saving Threshold Finished \n', toc);

%else
%	fprintf('Threshold Exists\n');
%    fprintf('Time %3.0fs. Loading Threshold Started \n', toc);
%    Thr = load([outDir, datName,threshold_suffix, '.mat']).Thr;
%	fprintf('Time %3.0fs. Loading Threshold Finished \n', toc);
%end
    Thr = Thr_a * Thr;
        
detect_flag = 0;
max_amp	=	0;
max_amp_ch = 0;
max_amp_time = 0;
detect_time = 0;
detect_done = 0;

fprintf('Time %3.0fs. Detection Processing Started \n', toc);
fprintf('\tDetection processing [%%]:      ');
while i <= Nsamples-1
    if(mod(i,100000)==0)
        fprintf(repmat('\b',1,6));
        fprintf('%6.2f',(i/Nsamples)*100);
    end
	j = 1;
	while j <= Nchan
		data_c  =   data(j,i);        % current data
		data_p  =   data(j,i-1);      % previous data
		data_n  =   data(j,i+1);      % next data
		%concave = ( (data_c<data_n) && (data_c<=data_p) );
		%convex  = ( (data_c>data_n) && (data_c>=data_p) );
		convex  = ( (data(j,i)>data(j,i+1)) && (data(j,i)>=data(j,i-1)) );
		detected = ((data(j,i) > Thr(j)) && convex);
		if( detected && ~detect_flag)
			detect_flag  = 1;
			max_amp		 = data(j,i);
			max_amp_ch	 = j;
			max_amp_time = i;
			detect_time = i;
			detected_ch = zeros(1,Nchan,'uint8');
			detected_ch(j) = 1;
		elseif (detected && detect_flag)
			detected_ch(j) = 1;
			if (max_amp < data(j,i))
				max_amp		= data(j,i);
				max_amp_ch	= j;
				max_amp_time= i;
			end
		end
		j = j+1;
	end

	if( detect_flag && ( ( i - detect_time) > overlap_range) )
		detect_flag = 0;
		detect_done = 1;
	end

	if( detect_done ) % spike detected
		detect_done = 0;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Index %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if(align_amp)
			%detected spike to find max amp. point (max amp. point should be in the overlap range)
			spike = data(max_amp_ch,[max_amp_time:max_amp_time+spike_length]);           
			[~,max_idx] = max(spike);
			spike_start_idx = (max_amp_time+max_idx-align_idx);
		elseif(align_det)
			spike_start_idx = (max_amp_time-align_idx+1);
		elseif(align_slope)
			% this range need modification
			for det_idx = max_amp_time-overlap_range:max_amp_time+overlap_range 
				det_slope(det_idx) = abs(data(max_amp_ch,det_idx)-data(max_amp_ch,det_idx+1));
			end
			[~,max_idx] = max(det_slope);
			spike_start_idx = (max_idx-align_idx+1);
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save spikes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if((spike_start_idx <= 0) || (spike_start_idx+spike_length-1 > Nsamples))
			%fprintf('Error Max Amp. Point : ch[%d], Idx[%d]\n',j,i);
		else
			k = k + 1;
			% Record channel and time

			if(max_amp_ch == Tmp_plot_ch)
				Tmp_plot_num = Tmp_plot_num + 1;
				Tmp_plot_idx(Tmp_plot_num) = max_amp_time;
				Tmp_plot_k(Tmp_plot_num) = k;
			end
			%detection_out.spike_time(k,1) = max_amp_time;
			%detection_out.spike_ch(k,1) = max_amp_ch;
			%detected_spike = data(max_amp_ch,[(spike_start_idx):(spike_start_idx+spike_length-1)]);
			%detection_out.spike(k,:) = detected_spike;
			%detection_out.channel(k,:) = detected_ch;
			spike_time(k) = max_amp_time;
			spike_ch(k) = max_amp_ch;
			spike(k,:) = data(max_amp_ch,[(spike_start_idx):(spike_start_idx+spike_length-1)]);
			channel(k,:) = detected_ch;

			%overlap check
			overlap_cnt = 0;
			for overlap_idx = 2:spike_length-1
				overlapped = ( (spike(overlap_idx-1)<spike(overlap_idx)) && ...
								(spike(overlap_idx+1)<=spike(overlap_idx)) && ...
								(spike(overlap_idx) > Thr(max_amp_ch)) ); %further fix required
				if(overlapped)
					overlap_cnt = overlap_cnt + 1;
				end
			end
			if(overlap_cnt > 1)
				overlap(k) = 1;
				overlap_num = overlap_num + 1;
			else
				overlap(k) = 0;
			end
			% same spike Check
			peak_tmp = peak;
			%for tmp_i = i:i+overlap_range
			%	if(i+overlap_range > Nsamples)
			%		break;
			%	end
			%	for tmp_j = 1:Nchan
			%		detected_tmp = (data(tmp_j,tmp_i) > Thr(tmp_j,tmp_i));
			%		if (detected_tmp) % sptmp_ike detected
			%			detected_ch(tmp_j) =   1;   %bit masking detected channel
			%		end
			%	end
			%end
		end
    end
	i = i +1;
end
detection_out = struct('spike_time', [], 'spike',[],'spike_ch', [], 'channel',[], 'overlap',[]); 
detection_out.spike_time    = spike_time';
detection_out.spike         = spike;
detection_out.spike_ch      = spike_ch';
detection_out.channel       = channel;
detection_out.overlap       = overlap';

fprintf('\nTime %3.0fs. Spike Detection Finished \n', toc);
fprintf('\t# of spikes : %d\n',k);
fprintf('\t# of overlap : %d\n',overlap_num);
Tmp_plot_num

fprintf('Time %3.0fs. Saving Detected Spikes Started \n', toc);
save([outDir, datName, detected_suffix], 'detection_out', '-v7.3');
fprintf('Time %3.0fs. Saving Detected Spikes Finished \n', toc);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (detect_opt.do_plot)
    fprintf('Time %3.0fs. Plotting Detected Spike Started \n', toc);
    fig_det1 = figure('Name','Detected Signals - every channel','NumberTitle','off');
	X = 1:spike_length;
    p = uipanel('Parent',fig_det1,'BorderType','none'); 
	fnum = Nchan;
	fsize = ceil(sqrt(fnum));
	for i = 1:ceil(k/10) %only 10%
		subplot(fsize,fsize,detection_out.spike_ch(i),'Parent',p)
		hold on;
        plot(X, detection_out.spike(i,:));
        plot(align_idx, detection_out.spike(i,align_idx), 'ro');
		plot(X, Thr(detection_out.spike_ch(i))*ones(1,spike_length), 'r');
		hold off;
	end
	for i = 1:Nchan
		subplot(fsize,fsize,i,'Parent',p)
        title({['Ch:',num2str(i)]})
	end
	%%%pause;

    fig_det1_1 = figure('Name','Whole Signals - every channel','NumberTitle','off');
	x_range = ceil(Nsamples * 0.02);
	X = 1:x_range;
    p = uipanel('Parent',fig_det1_1,'BorderType','none'); 
	fnum = Nchan;
	fsize = ceil(sqrt(fnum));
	for i = 1:Nchan
		subplot(fsize,fsize,i,'Parent',p)
		hold on;
        plot(X, data(i, 1:x_range));
		plot(X, Thr(detection_out.spike_ch(i))*ones(1,x_range), 'r');
		hold off;
	end
	for i = 1:Nchan
		subplot(fsize,fsize,i,'Parent',p)
        title({['Ch:',num2str(i)]})
	end
	%pause;

    fig_det2 = figure('Name','Detected Signals with Threshold - overlapped','NumberTitle','off');
	X = 1:spike_length;
    p = uipanel('Parent',fig_det2,'BorderType','none'); 

    fnum = 100;
    plot_num = 0;

	%for i = 1:Tmp_plot_num
	for i = 1:k
        if(detection_out.overlap(i) == 1)
            plot_num = plot_num + 1;
            subplot(10,10,plot_num,'Parent',p)
	        hold on;
            %plot(X, detection_out(Tmp_plot_k(i)).spike);
            plot(X, detection_out.spike(i,:));
            %plot(align_idx, detection_out(Tmp_plot_k(i)).spike(align_idx), 'ro');
            plot(align_idx, detection_out.spike(i,align_idx), 'ro');
			plot(X, Thr(detection_out.spike_ch(i))*ones(1,spike_length), 'r');
	        hold off;
            %title({['spike#:',num2str(i)],['T:',num2str(detection_out(Tmp_plot_k(i)).spike_time)]})
            title({['spike#:',num2str(i)],['T:',num2str(detection_out.spike_time(i))]})
        end
        if(plot_num==fnum)
            break;
        end
	end
	%pause;

    fig_det3 = figure('Name',['All Signals with Threshold - Ch: ', num2str(Tmp_plot_ch)],'NumberTitle','off');
	X = 1:Nsamples;
    p = uipanel('Parent',fig_det3,'BorderType','none'); 

    subplot(1,1,1,'Parent',p)
    hold on
    plot(X, data(Tmp_plot_ch,1:Nsamples));
	plot(X, Thr(Tmp_plot_ch)*ones(1,Nsamples));
    for i = 1:Tmp_plot_num
        plot(Tmp_plot_idx(i), data(Tmp_plot_ch, Tmp_plot_idx(i)), 'ro');
    end
	%plot_time = 509859; % for ch 98
	%plot_time = 167963; % for ch 101
	%plot_time = 1618731; % for ch 1
	plot_time = 32;
    %xlim([plot_time-200 plot_time+200]);
    hold off
    
    fprintf('Time %3.0fs. Plotting Detected Spike Finished \n', toc);
	Tmp_plot_idx(1)
end

