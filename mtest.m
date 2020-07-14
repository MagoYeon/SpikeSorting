set_parameters
DA = 0;
CA = 0;
SA = 0;

%    cluster_opt.channel_weight  =   bitshift(1,6);% bitshift(1,10) = %1024
%    cluster_opt.Ncluster    =   8;

feature_out = feature_out_My;
detection_out = detection_out_My;

    range = 0:15;
    num = 0;

    for i = range
    num = num+1;
       cluster_opt.channel_weight  =   bitshift(1,i);% bitshift(1,10) = %1024
       [cluster_out K_C]=   My_clustering2(feature_out, detection_out.channel,gtRes, detection_out.spike_ch, cluster_opt, opt,0);

       [DA_t CA_t SA_t]  =   evaluation(detection_out.spike_time, cluster_out, gtRes, gtClu(2:end), Nsamples, cluster_opt.Ncluster, opt);
       DA(num) = DA_t;
       CA(num) = CA_t;
       SA(num) = SA_t;
    end

cluster_eval.DA = DA;
cluster_eval.CA = CA;
cluster_eval.SA = SA;

save([outDir, datName, '_mtest'], 'cluster_eval', '-v7.3');

CA(10) = CA(9);

X = bitshift(1,range);

figure();
%plot(X,DA);
hold on
plot(X,CA,'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
plot(X(11),CA(11),'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
%plot(X,SA);
hold off
grid on;
set(gca,'XScale','log')
%legend({'Detection Accuracy','Clustering Accuracy', 'Sorting Accuracy'});
xlabel('Channel Weight');

for i = 1:num
    xt{i} = ['2^{' num2str(range(i)),'}'];
end

xlim([bitshift(1,range(1)) bitshift(1,range(end))]);
set(gca,'XTick',bitshift(1,range))	% Y axis values going to be affected
set(gca,'XTickLabel',xt);	% Values goint to appear in above(YTick) places
set(gcf,'color','w');
ylim([0.8 1])
ylabel('Clustering Accuracy')
