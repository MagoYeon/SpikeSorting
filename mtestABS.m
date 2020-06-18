abs_roc_range = [-1*bitshift(1,15) bitshift(1,5:2:15)];
abs_detected_suffix = '_detected_abs';
if ~exist([outDir, datName, abs_detected_suffix, '_eval','.mat'])
    k = 0;
    for i = abs_roc_range
        fprintf('\tAbs_Thr : %d\n', i);
        k = k + 1;
        Thr = i*ones(Nchan,1);

        abs_detection_out = ROC_NEO(in_data,in_data, Thr, detect_opt, opt, 0);
        abs_Ndetected(k) = size(abs_detection_out.spike_time,1);
        [abs_TP(k) abs_TN(k) abs_FP(k) abs_FN(k)] = eval_det(abs_detection_out.spike_time, gtRes, gtClu(2:end), Nsamples, opt);
    end
    eval_out.TP         = abs_TP;
    eval_out.TN         = abs_TN;
    eval_out.FP         = abs_FP;
    eval_out.FN         = abs_FN;
    eval_out.Ndetected  = abs_Ndetected;
    save([outDir, datName, abs_detected_suffix, '_eval'], 'eval_out', '-v7.3');
else
    eval_out = load([outDir, datName, abs_detected_suffix, '_eval','.mat']).eval_out;
    abs_TP          = eval_out.TP;
    abs_TN          = eval_out.TN;
    abs_FP          = eval_out.FP;
    abs_FN          = eval_out.FN;
    abs_Ndetected   = eval_out.Ndetected;
    k = size(abs_FN,2);
end

abs_TPR = abs_TP/Nspike;
abs_TNR = abs_TN/(Nsamples-Nspike);
abs_pair = [abs_TPR' abs_TNR'];
[abs_v abs_i] = max(sum(abs_pair,2));
fprintf('Abs best point : %d [%d %d]\n',abs_roc_range(abs_i),abs_pair(abs_i,1),abs_pair(abs_i,2));
fprintf('Abs DA : %f\n',100*abs_TP(abs_i)/abs_Ndetected(abs_i));

