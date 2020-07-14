
k = 0;
init_C = detect_opt.NEO_C;
Thr = mean(NEO_data(:,1:(6*Fs)),2) * init_C;

clearvars SNR_DET_TP;
clearvars SNR_DET_TN;
clearvars SNR_DET_FP;
clearvars SNR_DET_FN;
clearvars SNR_K_C_tmp;
clearvars SNR_CLU_DA;
clearvars SNR_CLU_CA;
clearvars SNR_CLU_SA;

clearvars SNR_DET_TP2;
clearvars SNR_DET_TN2;
clearvars SNR_DET_FP2;
clearvars SNR_DET_FN2;
clearvars SNR_K_C_tmp2;
clearvars SNR_CLU_DA2;
clearvars SNR_CLU_CA2;
clearvars SNR_CLU_SA2;

i_range = [0:-5:-15];

for i = i_range
    k = k+1;
    fprintf('Time %3.0fs. Add Noise : %d \n', toc, i);
    in_data = awgn(filtered_data(:,1:Nsamples),i,'measured');
    fprintf('Time %3.0fs. NEO filtering data...\n', toc);
	NEO_data = zeros(Nchan,Nsamples,'int32');
    for i = 2:(Nsamples-1)
    	NEO_data(:,i)	=	cast(in_data(:,i),'int32').*cast(in_data(:,i),'int32')-cast(in_data(:,i+1),'int32').*cast(in_data(:,i-1),'int32');
    end
    NEO_data(:,1)			=	NEO_data(:,2);
    NEO_data(:,Nsamples)	=	NEO_data(:,end-1);


    CC = init_C * 1/(power(2,k-1));
    fprintf('Time %3.0fs. Compute Threshold C : %d ...\n', toc, CC);
    Thr = mean(NEO_data(:,1:(6*Fs)),2) * CC;

    detection_out_My = ROC_NEO(in_data,NEO_data, Thr, detect_opt, opt, 1);

    detection_out_My2 = ROC_NEO2(in_data,NEO_data, Thr, detect_opt, opt, 1);

	if(size(detection_out_My.spike,1) ~= 0)
		[SNR_DET_TP(k) SNR_DET_TN(k) SNR_DET_FP(k) SNR_DET_FN(k)] = eval_det(detection_out_My.spike_time, gtRes, gtClu(2:end), Nsamples, opt);

		feature_out_My		            =   feature_extraction(		detection_out_My,	feature_opt,opt,Nchan);

		[cluster_out_My_c	K_C_My_c]	=   My_clustering3(feature_out_My, detection_out_My.channel, gtRes,  detection_out_My.spike_ch, cluster_opt, opt,0);
		SNR_K_C_tmp{k} = K_C_My_c;

		[SNR_CLU_DA(k) SNR_CLU_CA(k) SNR_CLU_SA(k)]       =   evaluation(detection_out_My.spike_time, cluster_out_My_c, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
	else
		fprintf('Nothing Detected on #%d:%d[dB]\n',k,i);
		SNR_DET_TP(k)		= -1; 
		SNR_DET_TN(k)		= -1;
		SNR_DET_FP(k)		= -1;
		SNR_DET_FN(k)		= -1;
		SNR_K_C_My_tmp{k}	= -1;
		SNR_CLU_DA(k)		= -1;
		SNR_CLU_CA(k)		= -1;
		SNR_CLU_SA(k)		= -1;
	end

	if(size(detection_out_My2.spike,1) ~= 0)
		[SNR_DET_TP2(k) SNR_DET_TN2(k) SNR_DET_FP2(k) SNR_DET_FN2(k)] = eval_det(detection_out_My2.spike_time, gtRes, gtClu(2:end), Nsamples, opt);

		feature_out_My2		            =   feature_extraction(		detection_out_My2,	feature_opt,opt,Nchan);

		[cluster_out_My_c2	K_C_My_c2]	=   My_clustering3(feature_out_My2, detection_out_My2.channel, gtRes,  detection_out_My2.spike_ch, cluster_opt, opt,0);
		SNR_K_C_tmp2{k} = K_C_My_c2;

		[SNR_CLU_DA2(k) SNR_CLU_CA2(k) SNR_CLU_SA2(k)]       =   evaluation(detection_out_My2.spike_time, cluster_out_My_c2, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
	else
		fprintf('Nothing Detected on #%d:%d[dB]\n',k,i);
		SNR_DET_TP2(k)		= -1; 
		SNR_DET_TN2(k)		= -1;
		SNR_DET_FP2(k)		= -1;
		SNR_DET_FN2(k)		= -1;
		SNR_K_C_My_tmp2{k}	= -1;
		SNR_CLU_DA2(k)		= -1;
		SNR_CLU_CA2(k)		= -1;
		SNR_CLU_SA2(k)		= -1;
	end
end



figure
hold on
set(gcf,'color','w');
%yyaxis left
%plot((i_range),(SNR_DET_FP), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
%set(gca,'YColor','k');
%ylabel('False Positive')
%yyaxis right
plot((i_range),(SNR_CLU_SA), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
%set(gca,'YColor','r');
ylabel('Sorting Accuracy');
hold off
xlabel('SNR')
grid on

figure
hold on
set(gcf,'color','w');
%yyaxis left
%plot((i_range),(SNR_DET_FP2), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
%set(gca,'YColor','k');
%ylabel('False Positive')
%yyaxis right
plot((i_range),(SNR_CLU_SA2), 'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
%set(gca,'YColor','r');
ylabel('Sorting Accuracy');
hold off
xlabel('SNR')
grid on

figure
hold on
set(gcf,'color','w');
plot((i_range),(SNR_CLU_SA2), 'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
plot((i_range),(SNR_CLU_SA), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
ylabel('Sorting Accuracy');
hold off
xlabel('SNR')
grid on
legend({'With Abs. Thr.','Without Abs. Thr.'})

figure
hold on
set(gcf,'color','w');
plot((i_range),(SNR_DET_FP2), 'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
plot((i_range),(SNR_DET_FP), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
ylabel('False Positive');
hold off
xlabel('SNR')
grid on
legend({'With Abs. Thr.','Without Abs. Thr.'})

%tmp_SNR_DET_FP = SNR_DET_FP;
%tmp_SNR_CLU_SA = SNR_CLU_SA;
