function [detection_out] = spike_detection(in_data, plot_ch, outDir, datName, detect_opt);



Nchan = size(in_data, 1);
Nsamples = size(in_data, 2);

Thr				=   detect_opt.Thr;
reverse			=   detect_opt.reverse;
spike_length	=   detect_opt.spike_length;
align_idx		=   detect_opt.align_idx;
align_opt		=	detect_opt.align_opt;
detect_method	=	detect_opt.detect_method;
overlap_range   =   detect_opt.overlap_range;

% strcmp takes time, it slower the detection process when its in if condition
method_thr	= strcmp(detect_method,'thr');
method_cnvx = strcmp(detect_method ,'cnvx');

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

fprintf('Time %3.0fs. Detection Processing Started \n', toc);
fprintf('Detection processing [%%]:      ');
while i <= Nsamples
    if(mod(i,Nsamples/100000)==0)
        fprintf(repmat('\b',1,6));
        fprintf('%6.2f',(i/Nsamples)*100);
    end
	j = 1;
	while j <= Nchan
		if(method_thr)
			detected = (data(j,i) > Thr);
		elseif(method_cnvx)
			detected = ( (data(j,i-1)<data(j,i)) && (data(j,i)>=data(j,i+1)) &&(data(j,i) > Thr)); % spike detected 
		end
        if( detected ) % spike detected
            k = k + 1;
			% Record channel and time
			detection_out(k).spike_time = i;
			detection_out(k).spike_ch = j;
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
			if((spike_start_idx < spike_length) || (spike_start_idx+spike_length-1 > Nsamples))
				fprintf('Error Max Amp. Point : ch[%d], Idx[%d]\n',j,i);
			else
				detected_spike = data(j,[(spike_start_idx):(spike_start_idx+spike_length-1)]);
				detection_out(k).spike = detected_spike;

                %overlap check
                overlap_cnt = 0;
                for overlap_idx = 2:spike_length-1
			        overlapped = ( (detected_spike(overlap_idx-1)<detected_spike(overlap_idx)) && ...
			                        (detected_spike(overlap_idx+1)<=detected_spike(overlap_idx)) && ...
			                        (detected_spike(overlap_idx) > Thr ));
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
			end
			% same spike Check
            for tmp_i = i:i+overlap_range
                for tmp_j = 1:Nchan
					if(method_thr)
						detected_tmp = (data(tmp_j,tmp_i) > Thr);
					elseif(method_cnvx)
						detected_tmp = ( (data(tmp_j,tmp_i-1)<data(tmp_j,tmp_i)) && (data(tmp_j,tmp_i)>=data(tmp_j,tmp_i+1)) &&(data(tmp_j,tmp_i) > Thr)); % sptmp_ike detected
					end
                    if (detected_tmp) % sptmp_ike detected
						detected_ch(tmp_j) =   1;   %bit masking detected channel
                    end
                end
            end
            detection_out(k).channel = detected_ch;
			detected_ch = zeros(1,Nchan,'uint8');
            i = i+overlap_range+1;
            j = 1;
		else
			j = j+1;
        end
    end
	i = i +1;
end
fprintf('\nTime %3.0fs. Spike Detection Finished \n', toc);
fprintf('# of spikes : %d\n',k);
fprintf('# of overlap : %d\n',overlap_num);

fprintf('Time %3.0fs. Saving Detected Spikes Started \n', toc);
save([outDir, datName, '_detected'], 'detection_out', '-v7.3');
fprintf('Time %3.0fs. Saving Detected Spikes Finished \n', toc);

if (detect_opt.do_plot)
    fprintf('Time %3.0fs. Plotting Detected Spike Started \n', toc);
    fig_det1 = figure('Name','Detected Signals with Threshold - non overlapped','NumberTitle','off');
	X = 1:spike_length;
    p = uipanel('Parent',fig_det1,'BorderType','none'); 

    subplot(1,1,1,'Parent',p)
	hold on;
	for i = 1:k
        if(detection_out(i).overlap == 0)
            plot(X, detection_out(i).spike);
            plot(align_idx, detection_out(i).spike(align_idx), 'ro');
        end
	end
	plot(X, Thr*ones(1, length(X)),'r');
	hold off;
    title('Detected Spikes')

    fig_det2 = figure('Name','Detected Signals with Threshold - overlapped','NumberTitle','off');
	X = 1:spike_length;
    p = uipanel('Parent',fig_det2,'BorderType','none'); 

    fnum = 100;
    plot_num = 0;

	for i = 1:k
        if(detection_out(i).overlap == 1)
            plot_num = plot_num + 1;
            subplot(10,10,plot_num,'Parent',p)
	        hold on;
            plot(X, detection_out(i).spike);
            plot(align_idx, detection_out(i).spike(align_idx), 'ro');
	        plot(X, Thr*ones(1, length(X)),'r');
	        hold off;
            title({['spike#:',num2str(i)],['T:',num2str(detection_out(i).spike_time)]})
        end
        if(plot_num==fnum)
            break;
        end
	end
    fprintf('Time %3.0fs. Plotting Detected Spike Finished \n', toc);
end

