function [cluster_out] = clustering(in_data, channel, spike_ch, cluster_opt, opt);

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;
detected_suffix		=	opt.detected_suffix;
feature_suffix		=	opt.detected_suffix;
cluster_suffix		=	opt.cluster_suffix;
plot_ch				=	opt.plot_ch;
NgtClu              =   opt.NgtClu;

Ncluster            =   cluster_opt.Ncluster;
feature_weight      =   cluster_opt.feature_weight;
channel_weight      =   cluster_opt.channel_weight;
do_plot             =   cluster_opt.do_plot;

clr = lines(Ncluster);

cluster_input       =   [(in_data*feature_weight), (double(channel)*channel_weight)];
cluster_input       =   double(cluster_input);

fprintf('NgtClu = %d\nNcluster = %d\n',NgtClu, Ncluster);

fprintf('Time %3.0fs. Clustering Started \n', toc);
[cluster_out K_C] = kmeans(cluster_input, Ncluster, 'Replicates', 100);

save([outDir, datName, cluster_suffix], 'cluster_out', '-v7.3');
writematrix(cluster_out,[outDir, datName, cluster_suffix], 'Delimiter', 'tab');

[~,K_idx] = max(K_C(:,3:end),[],2);
[~,KA_idx] = max(max(K_C(:,3:end)));

K_idx = K_idx - 2;	% this index is not precise. It's just for estimation.

%plot_ch = 112;
plot_ch = KA_idx;

if(do_plot)
    fprintf('Time %3.0fs. Plotting Cluster Started \n', toc);
    figure();
    hold on
    scatter3(K_C(:,1),K_C(:,2),K_C(:,plot_ch), 55, 'k', 'Marker','x', 'LineWidth',10)
    scatter3(cluster_input(:,1),cluster_input(:,2),cluster_input(:,plot_ch+2), 50, clr(cluster_out,:), 'Marker','.')
    hold off
    view(3), axis vis3d, box on, rotate3d on
    xlabel('feature 1'), ylabel('feature 2'), zlabel(['Channel ' num2str(plot_ch)])
    %legend([{'Cluster 1'},{'Cluster 2'},{'Cluster 3'},{'Cluster 4'}])
    title(['K-means (1,2,ch:' num2str(plot_ch) ')'])

    fig_clu = figure('Name','Clusters - every features w/ spike channel (3D)','NumberTitle','off');
    p = uipanel('Parent',fig_clu,'BorderType','none'); 
    ax1 = subplot(1,1,1,'Parent',p);
	hold on
	%scatter3(K_C(:,1),K_C(:,2),K_idx, 80, 'k', 'Marker','x', 'LineWidth',10);
	scatter3(cluster_input(:,1),cluster_input(:,2),spike_ch, 30, clr(cluster_out,:), 'Marker','.');
	hold off
    view(3), axis vis3d, box on, rotate3d on
    xlabel('feature 1'), ylabel('feature 2'), zlabel('channel')
	title('3D Feature Plot : Cluster mean only');
    %ax2 = subplot(1,2,2,'Parent',p);
	%hold on
	%scatter3(K_C(:,1),K_C(:,2),K_idx, 80, 'k', 'Marker','x', 'LineWidth',10);
	%hold off
    %view(3), axis vis3d, box on, rotate3d on
    %xlabel('feature 1'), ylabel('feature 2'), zlabel('channel')
	%title('3D Feature Plot w/ spike channel (Black: Cluster mean)');
	%Link = linkprop([ax1 ax2],{'CameraUpVector', 'CameraPosition', ...
	%	'CameraTarget', 'XLim', 'YLim', 'ZLim'});
	%setappdata(gcf, 'StoreTheLink', Link);
	fprintf('Time %3.0fs. Plotting Cluster Finished \n', toc);
end

