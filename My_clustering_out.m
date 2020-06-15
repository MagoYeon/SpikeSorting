function [cluster_out K_C] = My_clustering(in_data, channel, spike_ch, cluster_opt, opt);

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;
detected_suffix		=	opt.detected_suffix;
feature_suffix		=	opt.detected_suffix;
cluster_suffix		=	opt.cluster_suffix;
plot_ch				=	opt.plot_ch;
NgtClu              =   opt.NgtClu;
spike_length		=	opt.spike_length;
Nchan				=	opt.Nchan;

Ncluster            =   cluster_opt.Ncluster;
feature_weight      =   cluster_opt.feature_weight;
channel_weight      =   cluster_opt.channel_weight;
do_plot             =   cluster_opt.do_plot;
merge_weight		=   cluster_opt.merge_weight;
mean_weight			=   cluster_opt.mean_weight;
max_dis_thr			=	cluster_opt.max_dis_thr;
min_dis_thr			=	cluster_opt.min_dis_thr;
% for hysteresis (like shmitt trigger?)
% feature_w_1 is bigger

clr = lines(Ncluster);


cluster_input       =   [(in_data*feature_weight), (double(channel)*channel_weight)];
cluster_input       =   double(cluster_input);

fprintf('Cluster Info.\n');
fprintf('\tNgtClu = %d\n\tNcluster = %d\n\tChannel Weight = %d\n',NgtClu, Ncluster, channel_weight);

%[cluster_out K_C] = kmeans(cluster_input, Ncluster, 'Replicates', 100);
cluster_out	= zeros(size(cluster_input,1),1);
K_C_tmp		= zeros(Ncluster+1, size(cluster_input, 2));
K_C_count1	= zeros(Ncluster+1,1);
K_C_count2	= zeros(Ncluster+1,1);
%K_C			= cluster_input(1:Ncluster,:);
K_C_hbit	= logical(zeros(Ncluster,Nchan));
init = 1;
K_C_tmp(1:Ncluster,:)	= cluster_input(init:init+Ncluster-1,:);
%fprintf('Time %3.0fs. Clustering Started \n', toc);
K_C_diff	= zeros(Ncluster,size(cluster_out,1));
K_C_merge_cnt	=	0;
K_C_new_cnt	=	0;
K_C_ex_cnt	=	0;

j = 1; % K_C num
min_v(1)		=	0;
max_v(1)		=	0;
K_C_tmp(1,:)	=	cluster_input(1,:);
k = 1;

K_C_tmp(1:Ncluster,:) = cluster_input(1:Ncluster,:);

for i = Ncluster+1:size(cluster_input, 1)
	K_C_tmp(Ncluster+1,:)	=	cluster_input(i,:);
	%merge_out	=	c_merge(K_C_tmp(1:j+1,:), j+1, mean_weight);
	merge_out	=	c_merge(K_C_tmp, 0, 1);
	%min_idx1	=	merge_out(1);
	%min_idx2	=	merge_out(2);
	min_idx1	=	merge_out(2);
	min_v(i)	=	merge_out(3);
	max_idx1	=	merge_out(4);
	max_idx2	=	merge_out(5);
	max_v(i)	=	merge_out(6);

	%if(min_v(i) < min_dis_thr)	% merge
    %K_C_tmp(min_idx1,:)		=	(K_C_tmp(min_idx1,:)*(merge_weight-1)+K_C_tmp(min_idx2,:))/(merge_weight);
	K_C_tmp(min_idx1,:)		=	(K_C_tmp(min_idx1,:)*(merge_weight-1)+K_C_tmp(Ncluster+1,:))/(merge_weight);
    K_C_merge_cnt			=	K_C_merge_cnt + 1;
    K_C_count1(min_idx1)	=	K_C_count1(min_idx1) + 1;
    %K_C_tmp(max_idx2,:)		=	cluster_input(i,:);

	%else
	%	if(j ~= Ncluster)	% new mean
	%		j = j + 1;
	%		K_C_tmp(j,:)			=	cluster_input(i,:);
	%		K_C_new_cnt				=	K_C_new_cnt + 1;
	%	else
	%		K_C_tmp(max_idx2,:)		=	cluster_input(i,:);
	%		K_C_ex_cnt				=	K_C_ex_cnt + 1;
	%		K_C_ex_v(k)				=	max_v(i);
	%		k						=	k+1;
	%		K_C_count2(max_idx2)	=	K_C_count1(max_idx2) + 1;
	%	end
	%end


%	if(max_dis(i)>=	max_dis_thr);
%		if(max_i2 ~= Ncluster+1)
%			K_C_tmp(max_i1)	= cluster_input(i)
		

	%K_C_diff(idx1,i:end)		=	merge_out(3);

	%K_C_tmp(idx1,1:2)			=	[(K_C_tmp(idx1,1:2)*feature_w_1+K_C_tmp(idx2,(1:2))*feature_w_2)/(feature_w)];
	%K_C_bit_tmp					=	K_C_tmp(idx1,3:end);
	%K_C_bit_diff				=	K_C_tmp(idx1,3:end) ~= K_C_tmp(idx2,3:end); % diff of 2 cluster mean
	%K_C_bit_and					=	K_C_bit_diff & K_C_hbit(idx1,:);				% and(&) diff with hysteresis_bit
	%K_C_hbit(idx1,:)			=	K_C_bit_diff;
	%K_C_bit_idx					=	find(K_C_bit_and==1);						% find idx of value 1
	%K_C_bit_tmp(K_C_bit_idx)	=	1*not(K_C_bit_tmp(K_C_bit_idx));			% flip value with above idx

	%K_C_tmp(idx1,3:end)			=	K_C_bit_tmp;
	
	%if(idx2 ~= Ncluster+1)
	%	K_C_tmp(idx2:end-1,:)	=	K_C_tmp(idx2+1:end,:);
	%else
	%	K_C_tmp(idx2)			=	K_C_tmp(Ncluster+1);
	%end

	%K_C_count1(idx1)		=	K_C_count1(idx1)+1;
	%K_C_count2(idx2)		=	K_C_count2(idx2)+1;
end

K_C	=	K_C_tmp(1:Ncluster,:);
%K_C(1,1:2)
%K_C_count1
%K_C_count2
%max(max_dis)

%K_C_merge_cnt
%K_C_new_cnt
%K_C_ex_cnt

for i = 1:size(cluster_input,1)
	new_data		=	cluster_input(i,:);
	c_out			=	c_merge([K_C;new_data],0,1);
	c_idx			=	c_out(2);
	cluster_out(i)	=	c_idx;
end

save([outDir, datName, '_My',cluster_suffix], 'cluster_out', '-v7.3');
writematrix(cluster_out,[outDir, datName, '_My',cluster_suffix], 'Delimiter', 'tab');

[~,K_idx] = max(K_C(:,3:end),[],2);
[~,KA_idx] = max(max(K_C(:,3:end)));

K_idx = K_idx - 2;	% this index is not precise. It's just for estimation.

%figure();
%X = 1:size(cluster_out,1);
%
%hold on
%for i = 1:Ncluster
%	plot(X,K_C_diff(i,:));
%end
%hold off
%figure;
%X = 1:k-1;
%plot(X,K_C_ex_v);
%%plot_ch = 112;
%plot_ch = KA_idx;
%
%figure;
%plot(1:i,min_v)


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

