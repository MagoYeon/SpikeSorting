SVT_Thr = zeros(Nchan,1);

if ~exist([outDir, datName, detected_suffix, '_Thr','.mat'])
    fprintf('Time %3.0fs. Compute Deviation ...\n', toc);
    for i = 1:Nchan
        SVT_Thr(i) = median(abs(data(i,:)))/0.6745;
    end
    fprintf('Time %3.0fs. Save Deviation ...\n', toc);
    save([outDir, datName, detected_suffix, '_Thr'], 'SVT_Thr', '-v7.3');
else
    fprintf('Time %3.0fs. Load SVT DEV Thr...\n', toc);
    SVT_Thr = load([outDir, datName, detected_suffix, '_Thr','.mat']).SVT_Thr;
end
