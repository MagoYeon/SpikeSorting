
Ncluster            =   6;
Thr = NEO_C * NEO_Thr;
target_spike = 200;
simul_time = gtRes(target_spike)+100;
%simul_data = zeros(Nchan*simul_time,1);
%data_tmp = filtered_data(:,1:simul_time);
%for i = 1:simul_time
%	i_start = 1+(i-1)*Nchan;
%	i_end	= i_start+Nchan-1;
%	simul_data(i_start:i_end,1) = filtered_data(:,i);
%end
%writematrix(simul_data,[outDir, datName, '_simul_data_',num2str(target_spike)], 'Delimiter', 'tab');

Nsamples = simul_time;


detection_out_TVLSI = det_TVLSI(in_data, NEO_data, Thr, Nsamples, detect_opt, opt, 1);

det_num     = detection_out_TVLSI.spike_num;
det_time    = detection_out_TVLSI.spike_time;
spike_train = zeros(1,Nsamples);
spike_train_gt = zeros(1,Nsamples);
spike_train_gt(gtRes(1:target_spike)) = gtClu(1:target_spike);

clearvars k_idx;
k = 0;
k_idx = [];
for i = 1:Nchan;
    det_out(i).det_num         = det_num(i);
    det_out(i).det_spike       = zeros(det_num(i),48);
    det_out(i).det_spike(:,:)  = detection_out_TVLSI.spike(i,1:det_num(i),:);
    det_out(i).det_time        = det_time(i,1:det_num(i));
    if(det_num(i) > Ncluster)
        k = k+1;
        k_idx(k) = i;
        feature_out(i).feature  = feature_ex_TVLSI_only( det_out(i).det_spike, feature_opt,opt,Nchan);
        [cluster_out K_C] = My_clustering(feature_out(i).feature, [], 1, cluster_opt, opt, 0);
        clu_out(i).cluster_out = cluster_out;
    end
end

plot_ch_num = length(k_idx);

clr = lines((1+plot_ch_num)*(Ncluster)+3);

X = 1:Nsamples;
figure;
set(gcf,'color','w');
%set(gca,'visible','off');
set(gca,'xtick',[]);

%plot_size = k_idx(end)-k_idx(1)+1;

%for i = 1:plot_size % k_idx(1):k_idx(end)
%    subplot(plot_size,1,i);
%    plot(X,zeros(1,Nsamples));
%	%ylabel(['Ch ',num2str(i)]);
%    set(gcf,'color','w');
%    set(gca,'visible','off');
%    set(gca,'xtick',[]);
%    box off;
%end

plot_size = length(k_idx);
z = 0;
p_i = 0;
for i = k_idx
    p_i = p_i+1;
    %subplot(plot_size,1,i-k_idx(1)+1);
    ax(p_i) = subplot(plot_size+1,1,p_i);
    hold on
    spike_clu   = clu_out(i).cluster_out(1:det_num(i));
    spike_time  = det_out(i).det_time;
	ylabel(['Ch ',num2str(i)]);
    for j = 1:Ncluster
        clearvars j_idx;
        j_idx = find(spike_clu == j);
        clearvars tmp;
        tmp = zeros(1,Nsamples);
        tmp(spike_time(j_idx)) = 2;
        X = floor(Nsamples/4):Nsamples-100;
        tmp_plot = tmp(X);
        stem(X, tmp_plot, '.', 'Color',clr((z)*Ncluster + j,:),'LineWidth',2);
        xlim([Nsamples*26/32 Nsamples*29/32]);
        set(gcf,'color','w');
        %set(gca,'visible','off');
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        box off;
    end
    stem(X, zeros(1,length(X)), '.', 'Color',clr(1,:));
    hold off
    z = z + 1;
end
ax(p_i+1) = subplot(plot_size+1,1,p_i+1);
hold on
for j = min(gtClu):max(gtClu)
    clearvars j_idx;
    j_idx = find(spike_train_gt == j);
    clearvars tmp;
    tmp = zeros(1,Nsamples);
    tmp(j_idx) = 2;
    X = floor(Nsamples/4):Nsamples-100;
    tmp_plot = tmp(X);
    stem(X, tmp_plot, '.', 'Color',clr((z)*Ncluster + j,:),'LineWidth',2);
    xlim([Nsamples*26/32 Nsamples*29/32]);
	ylabel('GT');
    set(gcf,'color','w');
    %set(gca,'visible','off');
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    box off;
end
stem(X, zeros(1,length(X)), '.', 'Color',clr(end,:));
hold off
Link = linkprop(ax,{'CameraUpVector', 'CameraPosition', ...
    'CameraTarget', 'XLim', 'YLim'});
xlim([Nsamples*26/32 Nsamples*29/32]);

    
    

k_idx


%figure;
%
%x = 1:48;
%plot(x, det_spike(1,:));

