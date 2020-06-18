
Thr_a = detect_opt.Thr_a;
Nspike = size(gtRes,1);
Thr = Thr_a * SVT_Thr;

%SVT_roc_range = [-1*bitshift(1,5) bitshift(1,0:8) [512:100:1024] [129:10:256]];
%SVT_roc_range = [-16, 0:2:16];
SVT_roc_range = [1:10];
SVT_roc_range = [8:15];

if ~exist([outDir, datName, detected_suffix, '_dev_eval','.mat'])
    k = 0;
    for i = SVT_roc_range
        fprintf('\tDEV Thr_a : %d\n', i);
        Thr_a = i;
        k = k + 1;
        Thr = Thr_a * SVT_Thr;

        detection_out = ROC_SVT(in_data, Thr, detect_opt, opt, 0);
        SVT_Ndetected(k) = size(detection_out.spike_time,1);
        [SVT_TP(k) SVT_TN(k) SVT_FP(k) SVT_FN(k)] = eval_det(detection_out.spike_time, gtRes, gtClu(2:end), Nsamples, opt);
    end
    eval_out.TP         = SVT_TP;
    eval_out.TN         = SVT_TN;
    eval_out.FP         = SVT_FP;
    eval_out.FN         = SVT_FN;
    eval_out.Ndetected  = SVT_Ndetected;
    save([outDir, datName, detected_suffix, '_dev_eval'], 'eval_out', '-v7.3');
else
    eval_out = load([outDir, datName, detected_suffix, '_dev_eval','.mat']).eval_out;
    SVT_TP          = eval_out.TP;
    SVT_TN          = eval_out.TN;
    SVT_FP          = eval_out.FP;
    SVT_FN          = eval_out.FN;
    SVT_Ndetected   = eval_out.Ndetected;
    k = size(SVT_FN,2);
end

%for i = 1:k
%    fprintf('SVT_C : %d\n',SVT_roc_range(i));
%    fprintf('\t\t\tTrue\t\tFalse\n');
%    fprintf('\tPositive\t%d\t\t%d\n',TP(i), FP(i));
%    fprintf('\tNegative\t%d\t%d\n',TN(i), FN(i));
%    fprintf('\tTPR : %f', TP(i)/(Nspike));
%    fprintf('\tTNR : %f\n', TN(i)/(Nsamples-Nspike));
%    fprintf('\tDetection Accuracy\t- [TP/P]: %5.2f%%\n', 100*TP(i)/Ndetected(i));
%    fprintf('\n');
%end

SVT_TPR = SVT_TP/Nspike;
SVT_TNR = SVT_TN/(Nsamples-Nspike);
SVT_pair = [SVT_TPR' SVT_TNR'];
[v i] = max(sum(SVT_pair,2));
fprintf('Thr_a best point : %d [%d %d]\n',SVT_roc_range(i),SVT_pair(i,1),SVT_pair(i,2)); 
fprintf('DA : %f\n',100*SVT_TP(i)/SVT_Ndetected(i));

for i = 1:k
    fprintf('%d:%f\n', SVT_roc_range(i), 100*SVT_TP(i)/SVT_Ndetected(i));
end


Thr_a = detect_opt.Thr_a;
Thr = SVT_Thr * Thr_a;;

%detect_opt.align_idx        =   15; %15; 
%detect_opt.align_opt        =   'det'; %'amp';  
%detect_opt.spike_length     =   30;  
detection_out_My = ROC_SVT(in_data, Thr, detect_opt, opt, 1);

if(feature_test)
    detect_opt.align_idx        =   11; %15; 
    detect_opt.align_opt        =   'det'; %'amp';  
    detect_opt.spike_length     =   48;  
    detection_out_DD = ROC_SVT(in_data, Thr, detect_opt, opt, 1);

    detect_opt.align_idx        =   11; %15; 
    detect_opt.align_opt        =   'det'; %'amp';  
    detect_opt.spike_length     =   30;  
    detection_out_TVLSI = ROC_SVT(in_data, Thr, detect_opt, opt, 1);

    detect_opt.align_idx        =   12;
    detect_opt.spike_length     =   30;
    detect_opt.align_opt        =   'det';  
    detection_out_ZCF = ROC_SVT(in_data, Thr, detect_opt, opt, 1);

    detect_opt.align_idx        =   12; %15; 
    detect_opt.spike_length     =   30;
    detect_opt.align_opt        =   'amp';  
    detection_out_MD = ROC_SVT(in_data, Thr, detect_opt, opt, 1);
end
