function [cluster_out] = clustering(in_data, channel, cluster_opt, opt);

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;
detected_suffix		=	opt.detected_suffix;
feature_suffix		=	opt.detected_suffix;
plot_ch				=	opt.plot_ch;

Ncluster            =   cluster_opt.Ncluster;
feature_weight      =   cluster_opt.feature_weight;
channel_weight      =   cluster_opt.channel_weight;
do_plot             =   cluster_opt.do_plot;

clr = lines(Ncluster);

cluster_input       =   [in_data*feature_weight channel*channel_weight];
cluster_input       =   double(cluster_input);

fprintf('Time %3.0fs. Feature Extraction Started \n', toc);
[cluster_out K_C] = kmeans(cluster_input, Ncluster, 'Replicates', 100);

if(do_plot)
    fprintf('Time %3.0fs. Plotting Cluster Started \n', toc);
    figure();
    hold on
    scatter3(cluster_input(:,1),cluster_input(:,2),cluster_input(:,112), 50, clr(cluster_out,:), 'Marker','.')
    scatter3(K_C(:,1),K_C(:,2),K_C(:,112), 55, 'k', 'Marker','x', 'LineWidth',10)
    hold off
    view(3), axis vis3d, box on, rotate3d on
    xlabel('feature 1'), ylabel('feature 2'), zlabel('feature 3')
    %legend([{'Cluster 1'},{'Cluster 2'},{'Cluster 3'},{'Cluster 4'}])
    title('K-means (1,2,3)')
	fprintf('\nTime %3.0fs. Plotting Cluster Finished \n', toc);
end

