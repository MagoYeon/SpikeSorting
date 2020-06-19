
NEO_C = detect_opt.NEO_C;
Nspike = size(gtRes,1);
Thr = NEO_C * NEO_Thr;

%NEO_roc_range = [-1*bitshift(1,5) bitshift(1,0:8) [512:100:1024] [129:10:256]];

%NEO_roc_range = [32:5:64 128];
%if ~exist([outDir, datName, detected_suffix, '_eval','.mat'])
%    k = 0;
%    for i = NEO_roc_range
%        fprintf('\tNEO_C : %d\n', i);
%        NEO_C = i;
%        k = k + 1;
%        Thr = NEO_C * NEO_Thr;
%
%        detection_out = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 0);
%        NEO_Ndetected(k) = size(detection_out.spike_time,1);
%        [NEO_TP(k) NEO_TN(k) NEO_FP(k) NEO_FN(k)] = eval_det(detection_out.spike_time, gtRes, gtClu(2:end), Nsamples, opt);
%    end
%    eval_out.TP         = NEO_TP;
%    eval_out.TN         = NEO_TN;
%    eval_out.FP         = NEO_FP;
%    eval_out.FN         = NEO_FN;
%    eval_out.Ndetected  = NEO_Ndetected;
%    save([outDir, datName, detected_suffix, '_eval'], 'eval_out', '-v7.3');
%else
%    eval_out = load([outDir, datName, detected_suffix, '_eval','.mat']).eval_out;
%    NEO_TP          = eval_out.TP;
%    NEO_TN          = eval_out.TN;
%    NEO_FP          = eval_out.FP;
%    NEO_FN          = eval_out.FN;
%    NEO_Ndetected   = eval_out.Ndetected;
%    k = size(FN,2);
%end
%
%
%%for i = 1:k
%%    fprintf('NEO_C : %d\n',NEO_roc_range(i));
%%    fprintf('\t\t\tTrue\t\tFalse\n');
%%    fprintf('\tPositive\t%d\t\t%d\n',TP(i), FP(i));
%%    fprintf('\tNegative\t%d\t%d\n',TN(i), FN(i));
%%    fprintf('\tTPR : %f', TP(i)/(Nspike));
%%    fprintf('\tTNR : %f\n', TN(i)/(Nsamples-Nspike));
%%    fprintf('\tDetection Accuracy\t- [TP/P]: %5.2f%%\n', 100*TP(i)/Ndetected(i));
%%    fprintf('\n');
%%end
%
%NEO_TPR = NEO_TP/Nspike;
%NEO_TNR = NEO_TN/(Nsamples-Nspike);
%NEO_pair = [NEO_TPR' NEO_TNR'];
%[v i] = max(sum(NEO_pair,2));
%fprintf('NEO_C best point : %d [%d %d]\n',NEO_roc_range(i),NEO_pair(i,1),NEO_pair(i,2)); 
%fprintf('DA : %f\n',100*NEO_TP(i)/NEO_Ndetected(i));
%
%for i = 1:k
%    fprintf('%d:%d\n', NEO_roc_range(i), 100*NEO_TP(i)/NEO_Ndetected(i));
%end
%
%
%%    figure;
%%    hold on
%%    %for i = 1:size(NEO_roc_range,2)
%%    %    plot(1-(TN(i)/(Nsamples -Nspike)),TP(i)/Nspike,'ro');
%%    %end
%%    plot(1-(NEO_TN/(Nsamples -Nspike)),NEO_TP/Nspike,'r--o');
%%    plot(1-(abs_TN/(Nsamples -Nspike)),abs_TP/Nspike,'b--o');
%%    hold off
%%    xlabel('Probability of False Alarm')
%%    ylabel('Probability of Detection')
%%    set(gcf,'color','w');
%%    legend({'NEO' 'Absolute'});
%
%NEO_C = detect_opt.NEO_C;
%Thr = NEO_Thr * NEO_C;
%
%%detect_opt.align_idx        =   15; %15; 
%%detect_opt.align_opt        =   'det'; %'amp';  
%%detect_opt.spike_length     =   30;  
detection_out_My = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

if(feature_test)
    detect_opt.align_idx        =   11; %15; 
    detect_opt.align_opt        =   'det'; %'amp';  
    detect_opt.spike_length     =   48;  
    detection_out_DD = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

    detect_opt.align_idx        =   11; %15; 
    detect_opt.align_opt        =   'det'; %'amp';  
    detect_opt.spike_length     =   30;  
    detection_out_TVLSI = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

    detect_opt.align_idx        =   12;
    detect_opt.spike_length     =   30;
    detect_opt.align_opt        =   'det';  
    detection_out_ZCF = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

    detect_opt.align_idx        =   12; %15; 
    detect_opt.spike_length     =   30;
    detect_opt.align_opt        =   'amp';  
    detection_out_MD = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);
end
