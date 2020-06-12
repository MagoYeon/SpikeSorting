set_parameters
DA = 0;
CA = 0;
SA = 0;

    cluster_opt.channel_weight  =   bitshift(1,6);% bitshift(1,10) = %1024
    cluster_opt.Ncluster    =   8;

    range = 0:15;
    num = 0;

    for i = range
    num = num+1;
       cluster_opt.channel_weight  =   bitshift(1,i);% bitshift(1,10) = %1024
       [cluster_out K_C]=   My_clustering(feature_out, detection_out.channel, detection_out.spike_ch, cluster_opt, opt);

       [DA_t CA_t SA_t]  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
       DA(num) = DA_t;
       CA(num) = CA_t;
       SA(num) = SA_t;
    end

X = bitshift(1,range);

figure();
plot(X,DA);
hold on
plot(X,CA);
plot(X,SA);
hold off
grid on;
set(gca,'XScale','log')
legend({'Detection Accuracy','Clustering Accuracy', 'Sorting Accuracy'});
