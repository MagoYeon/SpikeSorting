%set_parameters

    cluster_opt.Ncluster    =   7;

    for i = 0:10
        cluster_opt.channel_weight  =   bitshift(1,i);% bitshift(1,10) = %1024
        [cluster_out K_C]=   clustering(feature_out, detection_out.channel, detection_out.spike_ch, cluster_opt, opt);

        [DA_t CA_t SA_t]  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
        DA(i+1) = DA_t;
        CA(i+1) = CA_t;
        SA(i+1) = SA_t;
    end

X = bitshift(1,0:10);

figure();
plot(X,DA);
hold on
plot(X,CA);
plot(X,SA);
hold off
grid on;
legend({'Detection Accuracy','Clustering Accuracy', 'Sorting Accuracy'});
