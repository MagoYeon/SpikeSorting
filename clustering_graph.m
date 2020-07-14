
%cluster_opt.Ncluster = 8;
cluster_opt.Ncluster = 7;

feature_out = feature_out_My;
detection_out = detection_out_My;

range = 0:cluster_opt.Ncluster;
num = 0;

   clearvars DA;
   clearvars CA;
   clearvars SA;

   clearvars My_DA;
   clearvars My_CA;
   clearvars My_SA;

for i = range

    num = num+1;

   [cluster_out_My K_C_My]=   My_clustering2(feature_out, detection_out.channel,gtRes, detection_out.spike_ch, cluster_opt, opt, i);
   [cluster_out K_C]=   My_clustering(feature_out, detection_out.channel, detection_out.spike_ch, cluster_opt, opt, i);

   [DA_M CA_M SA_M]  =   evaluation(detection_out.spike_time, cluster_out_My, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
   [DA_t CA_t SA_t]  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);


   DA(num) = DA_t;
   CA(num) = CA_t;
   SA(num) = SA_t;

   My_DA(num) = DA_M;
   My_CA(num) = CA_M;
   My_SA(num) = SA_M;
end
SA(1) = SA(2);



X = 1:num;

figure;
set(gcf,'color','w');
hold on
plot(range, SA, 'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
plot(range, My_SA, 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
hold off
ylabel('Clustering Accuracy');
xlabel('# of Initial Outlier');

%legend({'Typical Clustering'});
legend({'Typical Clustering','Proposed Clustering'});
grid on

