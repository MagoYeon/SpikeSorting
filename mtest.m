set_parameters

    cluster_out =   clustering(feature_out, detection_out.channel, detection_out.spike_ch, cluster_opt, opt);

    evaluation_out  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
