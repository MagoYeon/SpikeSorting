average_range	=	detect_opt.avg_range; % 32 16 8

peak = 10000*ones(average_range);	%significant initial value to avoid initial detection error
peak_num = 0;
SVT_Thr = Thr_a*10000*ones(Nchan,1);

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
        if( convex && (data(peak_j,peak_i) > 0) && (data(peak_j,peak_i) < SVT_Thr(peak_j)) ) %|| concave )
            peak = [data(peak_j,peak_i) peak(1:average_range-1)];
            SVT_Thr(peak_j) = mean(peak); 	
            peak_num = peak_num + 1;
            if(peak_num == average_range)
                %fprintf('ch %d done\n', peak_j);
                break;
            end
        end
    end
end
fprintf('Time %3.0fs. Threshold Processing Finished \n', toc);

