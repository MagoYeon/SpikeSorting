function [detection_out] = spike_det_dvt(in_data, plot_ch, outDir, datName, detect_opt);



Nchan = size(in_data, 1);
%Nsamples = size(in_data, 2);
%Nsamples = 16623305; % 20%
Nsamples = ceil(size(in_data,2) * 0.016); 
% Nsample range, ylim

Thr				=   detect_opt.Thr;
%Thr_a           =   8;
Thr_a           =   detect_opt.Thr_a;
average_range	=	detect_opt.avg_range; % 32 16 8
reverse			=   detect_opt.reverse;
spike_length	=   detect_opt.spike_length;
align_idx		=   detect_opt.align_idx;
align_opt		=	detect_opt.align_opt;
detect_method	=	detect_opt.detect_method;
overlap_range   =   detect_opt.overlap_range;

%plot_ch			=	1;
plot_ch			=	98;

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

% it will be cell array on next step
% ex.
% spike = {detection_out.spike};
detection_out = struct('spike_time', [], 'spike',[],'spike_ch', [], 'channel',[], 'overlap',[]); 
detected_ch = zeros(1,Nchan,'uint8');
detected_ch = zeros(1,1,'uint8');
detected = 0;
detected_tmp = 0;
overlap_num = 0;
peak = 10000*ones(Nchan,average_range);	%significant initial value to avoid initial detection error
peak_idx = 0;
Thr = zeros(Nchan,Nsamples);
Tmp_plot_idx = zeros(1,Nsamples);
Tmp_plot_k = zeros(1,Nsamples);
Tmp_plot_num = 0;
Tmp_plot_ch = plot_ch;

%takes too much time to process Thr (like filtering)
if ~exist([outDir, datName, '_dvt_Thr_c_',num2str(average_range),'.mat'])
    fprintf('Time %3.0fs. Threshold Processing Started \n', toc);
    for peak_j = 1:Nchan
		data_tmp = data(peak_j,1:Nsamples+1);
		for peak_i = 2:Nsamples-1
            %concave = ( (data_c<data_n) && (data_c<=data_p) );
            convex  = ( (data_tmp(peak_i)>data_tmp(peak_i+1)) && (data_tmp(peak_i)>=data_tmp(peak_i-1)) );
            if( convex && (data_tmp(peak_i) > 0) ) %|| concave )
                peak(peak_j,:) = [data_tmp(peak_i) peak(peak_j, 1:average_range-1)];
            else
                %peak(peak_j,:) = [0 peak(peak_j,1:7)]; % not c
            end
                Thr(peak_j,peak_i) = mean(peak(peak_j,:)); 	
        end
    end
    fprintf('\nTime %3.0fs. Threshold Processing Finished \n', toc);

    fprintf('Time %3.0fs. Saving Threshold Started \n', toc);
    save([outDir, datName, '_dvt_Thr_c_',num2str(average_range), '.mat'], 'Thr', '-v7.3');
    fprintf('Time %3.0fs. Saving Threshold Finished \n', toc);

else
	fprintf('Threshold Exists\n');
    fprintf('Time %3.0fs. Loading Threshold Started \n', toc);
    Thr = load([outDir, datName,'_dvt_Thr_c_',num2str(average_range), '.mat']).Thr;
	fprintf('Time %3.0fs. Loading Threshold Finished \n', toc);
end
    Thr = Thr_a * Thr;
        
fprintf('Time %3.0fs. Detection Processing Started \n', toc);
fprintf('Detection processing [%%]:      ');
while i <= Nsamples-1
    if(mod(i,100)==0)
        fprintf(repmat('\b',1,6));
        fprintf('%6.2f',(i/Nsamples)*100);
    end
	j = 1;
	while j <= Nchan
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		if( ( (data(j,i)<data(j,i+1)) && (data(j,i)<=data(j,i-1)) ) || ... %concave
%		    ( (data(j,i)>data(j,i+1)) && (data(j,i)>=data(j,i-1)) ) ... %convex
%		); % concave or convex
%			peak(j,:) = [data(j,i) peak(j,1:7)];
%		else
%			peak(j,:) = [0 peak(j,1:7)];
%		end
%			Thr(j,i) = Thr_a * mean(peak(j,:)); 	
            data_c  =   data(j,i);        % current data
            data_p  =   data(j,i-1);      % previous data
            data_n  =   data(j,i+1);      % next data
            %concave = ( (data_c<data_n) && (data_c<=data_p) );
            convex  = ( (data_c>data_n) && (data_c>=data_p) );

			detected = ((data(j,i) > Thr(j,i)) && convex);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if( detected ) % spike detected
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start Index %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			if(align_amp)
				%detected spike to find max amp. point (max amp. point should be in the overlap range)
				detected_spike = data(j,[i:i+overlap_range]);           
				[~,max_idx] = max(detected_spike);
				spike_start_idx = (i+max_idx-align_idx);
			elseif(align_det)
				spike_start_idx = (i-align_idx+1);
			elseif(align_slope)
				% this range need modification
				for det_idx = i-overlap_range:i+overlap_range 
					det_slope(det_idx) = abs(data(j,det_idx)-data(j,det_idx+1));
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

				if(j == Tmp_plot_ch)
					Tmp_plot_num = Tmp_plot_num + 1;
					Tmp_plot_idx(Tmp_plot_num) = i;
					Tmp_plot_k(Tmp_plot_num) = k;
				end
				detection_out(k).spike_time = i;
				detection_out(k).spike_ch = j;
				detected_spike = data(j,[(spike_start_idx):(spike_start_idx+spike_length-1)]);
				detection_out(k).spike = detected_spike;

                %overlap check
                overlap_cnt = 0;
                for overlap_idx = 2:spike_length-1
			        overlapped = ( (detected_spike(overlap_idx-1)<detected_spike(overlap_idx)) && ...
			                        (detected_spike(overlap_idx+1)<=detected_spike(overlap_idx)) && ...
			                        (detected_spike(overlap_idx) > Thr(j,overlap_idx) )); %further fix required
                    if(overlapped)
                        overlap_cnt = overlap_cnt + 1;
                    end
                end
                if(overlap_cnt > 1)
                    detection_out(k).overlap = 1;
                    overlap_num = overlap_num + 1;
                else
                    detection_out(k).overlap = 0;
                end
				% same spike Check
				peak_tmp = peak;
				for tmp_i = i:i+overlap_range
					if(i+overlap_range > Nsamples)
						break;
					end
					for tmp_j = 1:Nchan
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%					if( ( (data(tmp_j,tmp_i)<data(tmp_j,tmp_i+1)) && (data(tmp_j,tmp_i)<=data(tmp_j,tmp_i-1)) ) || ... %concave
	%						( (data(tmp_j,tmp_i)>data(tmp_j,tmp_i+1)) && (data(tmp_j,tmp_i)>=data(tmp_j,tmp_i-1)) ) ... %convex
	%					); % concave or convex
	%						peak_tmp(tmp_j,:) = [data(tmp_j,tmp_i) peak_tmp(tmp_j,1:7)];
	%					else
	%						peak_tmp(tmp_j,:) = [0 peak_tmp(tmp_j,1:7)];
	%					end
	%						Thr_tmp = Thr_a * mean(peak_tmp(tmp_j,:)); 	

							detected_tmp = (data(tmp_j,tmp_i) > Thr(tmp_j,tmp_i));
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
						if (detected_tmp) % sptmp_ike detected
							detected_ch(tmp_j) =   1;   %bit masking detected channel
						end
					end
				end
				detection_out(k).channel = detected_ch;
				detected_ch = zeros(1,Nchan,'uint8');
			end
			i = i+overlap_range;
			j = Nchan+1;              %mod
		else
			j = j+1;
        end
    end
	i = i +1;
end
fprintf('\nTime %3.0fs. Spike Detection Finished \n', toc);
fprintf('# of spikes : %d\n',k);
fprintf('# of overlap : %d\n',overlap_num);
Tmp_plot_num

fprintf('Time %3.0fs. Saving Detected Spikes Started \n', toc);
%save([outDir, datName, '_detected_dvt'], 'detection_out', '-v7.3');
fprintf('Time %3.0fs. Saving Detected Spikes Finished \n', toc);

if (detect_opt.do_plot)
    fprintf('Time %3.0fs. Plotting Detected Spike Started \n', toc);
    fig_det1 = figure('Name','Detected Signals - every channel','NumberTitle','off');
	X = 1:spike_length;
    p = uipanel('Parent',fig_det1,'BorderType','none'); 

	fnum = Nchan;
	fsize = ceil(sqrt(fnum));

	for i = 1:k
		subplot(fsize,fsize,detection_out(i).spike_ch,'Parent',p)
		hold on;
        plot(X, detection_out(i).spike);
        plot(align_idx, detection_out(i).spike(align_idx), 'ro');
		hold off;
	end
	for i = 1:Nchan
		subplot(fsize,fsize,i,'Parent',p)
        title({['Ch:',num2str(i)]})
	end

    fig_det2 = figure('Name','Detected Signals with Threshold - overlapped','NumberTitle','off');
	X = 1:spike_length;
    p = uipanel('Parent',fig_det2,'BorderType','none'); 

    fnum = 100;
    plot_num = 0;

	%for i = 1:Tmp_plot_num
	for i = 1:k
        if(detection_out(i).overlap == 1)
            plot_num = plot_num + 1;
            subplot(10,10,plot_num,'Parent',p)
	        hold on;
            %plot(X, detection_out(Tmp_plot_k(i)).spike);
            plot(X, detection_out(i).spike);
            %plot(align_idx, detection_out(Tmp_plot_k(i)).spike(align_idx), 'ro');
            plot(align_idx, detection_out(i).spike(align_idx), 'ro');
	        hold off;
            %title({['spike#:',num2str(i)],['T:',num2str(detection_out(Tmp_plot_k(i)).spike_time)]})
            title({['spike#:',num2str(i)],['T:',num2str(detection_out(i).spike_time)]})
        end
        if(plot_num==fnum)
            break;
        end
	end

    fig_det3 = figure('Name','All Signals with Threshold','NumberTitle','off');
	X = 1:Nsamples;
    p = uipanel('Parent',fig_det3,'BorderType','none'); 

    subplot(1,1,1,'Parent',p)
    hold on
    plot(X, data(Tmp_plot_ch,1:Nsamples));
	plot(X, Thr(Tmp_plot_ch,X));
    for i = 1:Tmp_plot_num
        plot(Tmp_plot_idx(i), data(Tmp_plot_ch, Tmp_plot_idx(i)), 'ro');
    end
	plot_time = 509859; % for ch 98
	%plot_time = 32;
    xlim([plot_time-200 plot_time+200]);
    hold off
    
    fprintf('Time %3.0fs. Plotting Detected Spike Finished \n', toc);
end

