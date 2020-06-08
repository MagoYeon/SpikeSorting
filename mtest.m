%set_parameters

    cluster_opt.Ncluster    =   8;

    for i = 0:10
        cluster_opt.channel_weight  =   bitshift(1,i);% bitshift(1,10) = %1024
        [cluster_out K_C]=   My_clustering(feature_out, detection_out.channel, detection_out.spike_ch, cluster_opt, opt);

        evaluation_out  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
    end
