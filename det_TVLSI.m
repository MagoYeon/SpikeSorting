function [detection_out] = det_TVLSI(in_data,NEO_data, Thr, Nsamples, detect_opt, opt,save_flag);

Nchan = size(in_data, 1);
%Nsamples = size(in_data, 2);
%Nsamples = 16623305; % 20%
%Nsamples = ceil(size(in_data,2) * 0.005); 
% Nsample range, ylim

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;
detected_suffix		=	opt.detected_suffix;
plot_ch				=	opt.plot_ch;

%Thr				=   detect_opt.Thr;
%Thr_a           =   8;
Thr_a           =   detect_opt.Thr_a;
average_range	=	detect_opt.avg_range; % 32 16 8
reverse			=   detect_opt.reverse;
spike_length	=   48;%detect_opt.spike_length;
align_idx		=   11;%detect_opt.align_idx;
align_opt		=	detect_opt.align_opt;
detect_method	=	detect_opt.detect_method;
overlap_range   =   detect_opt.overlap_range;	% 1~2
halt_range      =   detect_opt.halt_range;
NEO_C			=	detect_opt.NEO_C;
NEO_N			=	detect_opt.NEO_N;

%plot_ch			=	1;
%plot_ch			=	98;
%plot_ch			=	101;

% strcmp takes time, it slower the detection process when its in if condition
% align_amp	= strcmp(align_opt , 'amp');
% align_det	= strcmp(align_opt , 'det');
% align_slope	= strcmp(align_opt , 'slope');
align_amp	= 1;

%fprintf('NEO C:%d\t', NEO_C);
%fprintf('NEO N:%d\n', NEO_N);
fprintf('Time %3.0fs. Spike Detection(NEO) Started \n', toc);

data = in_data;

halt_range = 56;
if(halt_range == 0)
    halt_range = floor(spike_length/2);
end

k = 0;
i = 2;
j = 1;

spike_time  = zeros(Nchan,Nsamples);
spike_det_num   =   zeros(Nchan,1);
%spike_ch    = zeros(Nsamples,1,'uint16');
spike       = zeros(Nchan,Nsamples,spike_length,'int16');
%channel     = zeros(Nsamples,Nchan,'uint8');

detection_out = struct('spike_time', [], 'spike',[]); 
detected = 0;
detected_tmp = 0;
%peak = 10000*ones(average_range);	%significant initial value to avoid initial detection error
%peak_idx = 0;
%peak_num = 0;

%Thr = Thr_a*10000*ones(Nchan,1);
%Tmp_plot_idx = zeros(1,Nsamples);
%Tmp_plot_k = zeros(1,Nsamples);
%Tmp_plot_num = 0;
%Tmp_plot_ch = plot_ch;

        
detect_flag = 0;
max_amp	=	0;
max_amp_ch = 0;
max_amp_time = 0;
detect_done = 0;

fprintf('Time %3.0fs. Detection Processing Started \n', toc);
fprintf('\tDetection processing [%%]:      ');
while i <= Nsamples-1
    if(mod(i,ceil(Nsamples/100))==0)
        fprintf(repmat('\b',1,6));
        fprintf('%6.2f',(i/Nsamples)*100);
    end
	j = 1;
	while j <= Nchan	% this is for searching max amp spike
		detected = (NEO_data(j,i) > Thr(j));
		if( detected )
			detect_flag  = 1;
            max_amp_ch = j;
            max_amp_time = i;
        end
		j = j+1;
	end

	if( detect_flag ) % spike detected
		detect_flag = 0;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Index %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if(align_amp)
			%detected spike to find max amp. point (max amp. point should be in the overlap range)
            if(max_amp_time+spike_length < Nsamples)
                spike_tmp = data(max_amp_ch,[max_amp_time:max_amp_time+spike_length]);           
                [~,max_idx] = max(spike_tmp);
                spike_start_idx = (max_amp_time+max_idx-align_idx);
            else
                spike_start_idx = 0;
            end
		elseif(align_det)
			spike_start_idx = (max_amp_time-align_idx+1);
		elseif(align_slope)
			% this range need modification
            k_i = 0;
			for det_idx = max_amp_time-floor(spike_length/2):max_amp_time+floor(spike_length/2) 
                k_i = k_i+1;
				det_slope(k) = abs(data(max_amp_ch,det_idx)-data(max_amp_ch,det_idx+1));
			end
			[~,max_idx] = max(det_slope);
			spike_start_idx = (max_amp_time+max_idx-align_idx);
            %clearvars det_slope;
		end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% save spikes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		if((spike_start_idx <= 0) || (spike_start_idx+spike_length-1 > Nsamples))
			%fprintf('Error Max Amp. Point : ch[%d], Idx[%d]\n',j,i);
		else
            spike_det_num(max_amp_ch) = spike_det_num(max_amp_ch) + 1;
            k = spike_det_num(max_amp_ch);
			spike_time(max_amp_ch,k) = max_amp_time;
            if(save_flag)
			    spike(max_amp_ch,k,:) = data(max_amp_ch,[(spike_start_idx):(spike_start_idx+spike_length-1)]);
            end
            i = i+ halt_range-1;
		end
    end
	i = i + 1;
end
max_k = max(spike_det_num);
detection_out = struct('spike_time', [], 'spike',[], 'spike_num',[]); 
detection_out.spike_time    = spike_time(:,1:max_k);
detection_out.spike_num = spike_det_num;
clearvars spike_time;
if(save_flag)
    detection_out.spike         = spike(:,1:max_k,:);
    clearvars spike;
end
%detection_out.overlap       = overlap';

fprintf('\nTime %3.0fs. Spike Detection Finished \n', toc);
fprintf('\t# of spikes : %d\n',sum(spike_det_num));
%fprintf('\t# of overlap : %d\n',overlap_num);
%Tmp_plot_num

if(save_flag)
    fprintf('Time %3.0fs. Saving Detected Spikes Started \n', toc);
    save([outDir, datName, detected_suffix,'_TVSLI_out'], 'detection_out', '-v7.3');
    fprintf('Time %3.0fs. Saving Detected Spikes Finished \n', toc);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%detect_opt.do_plot = 1;
if (detect_opt.do_plot)
    fprintf('Time %3.0fs. Plotting Detected Spike Started \n', toc);
    %fig_det1 = figure('Name','Detected Signals - every channel','NumberTitle','off');
	%X = 1:spike_length;
    %p = uipanel('Parent',fig_det1,'BorderType','none'); 
	%fnum = Nchan;
	%fsize = ceil(sqrt(fnum));
	%for i = 1:ceil(k/10) %only 10%
	%	subplot(fsize,fsize,detection_out.spike_ch(i),'Parent',p)
	%	hold on;
    %    plot(X, detection_out.spike(i,:));
    %    plot(align_idx, detection_out.spike(i,align_idx), 'ro');
	%    %plot(X, NEO_data(detection_out.spike_ch(i),X+detection_out.spike_time(i)));
	%    %plot(X, Thr(detection_out.spike_ch(i),X+detection_out.spike_time(i)));
	%	hold off;
	%end
	%for i = 1:Nchan
	%	subplot(fsize,fsize,i,'Parent',p)
    %    title({['Ch:',num2str(i)]})
	%end
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
	    plot(X, NEO_data(i,X));
	    plot(X, Thr(i)*ones(1,x_range));
		hold off;
	end
	for i = 1:Nchan
		subplot(fsize,fsize,i,'Parent',p)
        title({['Ch:',num2str(i)]})
	end
    legend('Filtered data','NEO data', 'NEO Thr.')
	%pause;

    %fig_det2 = figure('Name','Detected Signals with Threshold - overlapped','NumberTitle','off');
	%X = 1:spike_length;
    %p = uipanel('Parent',fig_det2,'BorderType','none'); 

    %fnum = 100;
    %plot_num = 0;

	%%for i = 1:Tmp_plot_num
	%for i = 1:k
    %    if(detection_out.overlap(i) == 1)
    %        plot_num = plot_num + 1;
    %        subplot(10,10,plot_num,'Parent',p)
	%        hold on;
    %        %plot(X, detection_out(Tmp_plot_k(i)).spike);
    %        plot(X, detection_out.spike(i,:));
    %        %plot(align_idx, detection_out(Tmp_plot_k(i)).spike(align_idx), 'ro');
    %        plot(align_idx, detection_out.spike(i,align_idx), 'ro');
	%		plot(X, Thr(detection_out.spike_ch(i))*ones(1,spike_length), 'r');
	%        hold off;
    %        %title({['spike#:',num2str(i)],['T:',num2str(detection_out(Tmp_plot_k(i)).spike_time)]})
    %        title({['spike#:',num2str(i)],['T:',num2str(detection_out.spike_time(i))]})
    %    end
    %    if(plot_num==fnum)
    %        break;
    %    end
	%end
	%pause;

    fig_det3 = figure('Name',['All Signals with Threshold - Ch: ', num2str(Tmp_plot_ch)],'NumberTitle','off');
    p = uipanel('Parent',fig_det3,'BorderType','none'); 
	X = 1:Nsamples;

    subplot(1,1,1,'Parent',p)
    hold on
    plot(X, data(Tmp_plot_ch,X));
	plot(X, NEO_data(Tmp_plot_ch,X));
	plot(X, Thr(Tmp_plot_ch)*ones(1,Nsamples));
    %for i = 1:Tmp_plot_num
    %    plot(Tmp_plot_idx(i), data(Tmp_plot_ch, Tmp_plot_idx(i)), 'ro');
    %end
	%plot_time = 509859; % for ch 98
	plot_time = 167963; % for ch 101
	%plot_time = 1618731; % for ch 1
	%plot_time = 32;
    xlim([plot_time-200 plot_time+200]);
    hold off
    legend('Filtered data','NEO data', 'NEO Thr.')
    
    fprintf('Time %3.0fs. Plotting Detected Spike Finished \n', toc);
	%Tmp_plot_idx(1)

    %fig_det4 = figure('Name','All Detected Signals','NumberTitle','off');
    %p = uipanel('Parent',fig_det4,'BorderType','none'); 
	%X = 1:spike_length;
    %subplot(1,1,1,'Parent',p)
    %hold on
    %for i = 1:size(detection_out.spike,1)
    %    %if(max(detection_out.spike(i,:)) > Thr(1))
    %    plot(X, detection_out.spike(i,:));
    %    %end
    %end
    %hold off
end



