function plot_spike_per_cluster(detection_spike, cluster_out, cluster_opt, opt);
% plot_spike_per_cluster(detection_out.spike, cluster_out, cluster_opt, opt);

spike_length		=	opt.spike_length;
NgtClu              =   opt.NgtClu;

Ncluster            =   cluster_opt.Ncluster;

Ndetected			=	size(detection_spike,1);

X = 1:spike_length;

    fprintf('Time %3.0fs. Plotting Started \n', toc);
fig_clu = figure('Name','Clusters - every spike per cluster','NumberTitle','off');
p = uipanel('Parent',fig_clu,'BorderType','none'); 
fsize = ceil(sqrt(Ncluster));
for i = 1:Ndetected
    subplot(fsize,fsize,cluster_out(i),'Parent',p);
    hold on
    plot(X,detection_spike(i,:));
    hold off 
end
for i = 1:Ncluster
    subplot(fsize,fsize,i,'Parent',p)
    title({['Clu:',num2str(i)]})
end
    fprintf('Time %3.0fs. Plotting Finished \n', toc);
