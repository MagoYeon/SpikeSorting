function [cluster_out K_C] = My_clustering2(in_data, channel, gtRes, spike_ch, cluster_opt, opt, outlier);

Fs					=	opt.Fs;
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
ch_m_range			=	cluster_opt.ch_m_range;
spike_p_sec			=	cluster_opt.spike_p_sec;
cnt_thr				=	cluster_opt.cnt_thr;
ch_label_term       =   cluster_opt.ch_label_term;


% for hysteresis (like shmitt trigger?)
% feature_w_1 is bigger

channel				=	double(channel);
Ndetected			=	size(channel,1);
clr = lines(Ncluster);

cluster_input       =   [(in_data*feature_weight), (double(channel))];

if outlier ~= 0
    for i =1:outlier
        outlier_input = ones(1,size(cluster_input,2))*10000000*i;
        cluster_input(i*10,:)  = outlier_input;
    end
end


%cluster_input       =   [channel_weight*(double(channel))];
cluster_input       =   double(cluster_input);

fprintf('Cluster Info.\n');
fprintf('\tNgtClu = %d\n\tNcluster = %d\n\tChannel Weight = %d\n',NgtClu, Ncluster, channel_weight);

%[cluster_out K_C] = kmeans(cluster_input, Ncluster, 'Replicates', 100);

%fprintf('Time %3.0fs. Clustering Started \n', toc);

% all channel ditribution
ch_label_tmp= zeros(Ncluster,Nchan);
ch_label	= zeros(Ncluster,Nchan);
ch_cnt      = zeros(Ncluster,1);
%ch_m_range	= ones(Ncluster,1);
%ch_cnt		= 0;
k = 0;



start = 1;


%Ndetected

%% ch_label 1
%label_cnt = 1;
%ii = start:start-1+spike_p_sec*10;
%while label_cnt <= Ncluster % just for test
%	for i = ii % 10 sec = 8 thr
%		ch_diff_tmp		= abs(ch_label_tmp - channel(i,:));
%		ch_diff_tmp		= sum(ch_diff_tmp,2);
%		label_idx_tmp	= find(ch_diff_tmp <= ch_m_range,1);
%
%		ch_diff			= abs(ch_label - channel(i,:));
%		ch_diff 		= sum(ch_diff,2);
%		label_idx		= find(ch_diff <= ch_m_range,1);
%
%%		[Li_ch Loc_label]			= ismember(channel(i,:),ch_label,'rows');
%%		[Li_ch_tmp Loc_label_tmp]	= ismember(channel(i,:),ch_label_tmp,'rows');
%		if(isempty(label_idx))
%			if(label_idx_tmp)
%				ch_cnt(label_idx_tmp)	= ch_cnt(label_idx_tmp) + 1;
%			else
%				k						= k + 1;
%				ch_label_tmp(k,:)		= channel(i,:);
%				ch_cnt(k)				= 1;
%			end
%		end
%	end
%
%	%k
%	%figure;
%	%stem(1:k,ch_cnt);
%
%	% find ch_cnt > thr
%	ch_idx = find(ch_cnt >=cnt_thr);
%	ch_label(label_cnt:label_cnt+length(ch_idx)-1,:) = ch_label_tmp(ch_idx,:);
%	label_cnt = label_cnt + length(ch_idx);
%
%	ch_label_tmp= zeros(1,Nchan);
%	ch_cnt		= 0;
%	k = 0;
%
%	ii = ii + spike_p_sec*10;
%end


% ch_label v.2

start = 0;
if start == 0
    start_idx = 1;
else
    start_idx = find(gtRes > start*Fs,1)-1;
end
end_idx = find(gtRes > (start+ch_label_term)*Fs,1)-1;
cnt_thr = spike_p_sec * ch_label_term;

label_cnt = 1;
ii = start_idx:end_idx;
%ii = 1:Ndetected;

for i = ii % 10 sec = 8 thr
    fin_time        = gtRes(i);
    ch_diff			= abs(ch_label - cluster_input(i,3:end));
    ch_diff 		= sum(ch_diff,2);
    label_idx		= find(ch_diff <= ch_m_range,1);

%		[Li_ch Loc_label]			= ismember(channel(i,:),ch_label,'rows');
%		[Li_ch_tmp Loc_label_tmp]	= ismember(channel(i,:),ch_label_tmp,'rows');
    if(isempty(label_idx)) 
        if(label_cnt<Ncluster)  % allocate new
            ch_label(label_cnt,:)   = cluster_input(i,3:end);
            ch_cnt(label_cnt)	    = ch_cnt(label_cnt) + 1;
            label_cnt               = label_cnt+1;
        else                    % free old and alloc new
            break;
        end
    else    % channel exists
        ch_cnt(label_idx)   = ch_cnt(label_idx) + 1;
    end
end

%ii
%ch_cnt
%label_cnt
%fin_time
fin_sec = floor(fin_time * 1/Fs)

del_idx = find(ch_cnt < fin_sec*spike_p_sec);
ch_label(del_idx,:) = 0;

%fprintf('\tCh Count Thre : %d\n',ch_cnt_thr);
fprintf('\tCh Label : \n');
for i = outlier+1:Ncluster
	fprintf('\t%d : range=%d\t',i,ch_m_range);
	fprintf('%d ',find(ch_label(i,:)==1));
	%fprintf('(%d)', ch_cnt(ch_pick_idx(i)));
	fprintf('\n');
end
	
% train with only labelled channel

% init K_C
i = 0;
k = 0;

K_C_tmp = zeros(Ncluster+1,Nchan+size(in_data,2));

while k < Ncluster % allocate features in means
	i = i+1;
	%[Li_ch Loc_label]	= ismember(channel(i,:),ch_label,'rows');
	ch_diff			= abs(ch_label - cluster_input(i,3:end));
	ch_diff 		= sum(ch_diff,2);
	label_idx		= find(ch_diff <= ch_m_range,1);
	if(label_idx)
		k = k+1;
		K_C_tmp(k,:) = cluster_input(i,:);
		%K_C_tmp(k,:) = [double(channel(i,:))];
	end
    if(i == Ndetected)
        break;
    end
end

fprintf('\tCh Label : \n');
for i = 1:Ncluster
	fprintf('\t%d : range=%d\t',i,ch_m_range);
	fprintf('[%d %d]\t', K_C_tmp(i,1:2));
	fprintf('%d ',find(K_C_tmp(i,3:end)==1));
	fprintf('\n');
    ch_num(i) = length(find(K_C_tmp(i,3:end)==1));
end

%mean_feat   = mean(K_C_tmp(1:end-1,1:2),'all')
sum_feat   = sum(K_C_tmp(1:end-1,1:2),2);
max_feat   = max(sum_feat);
%min_feat   = min(sum_feat)

mean_ch     = floor(log2(mean(ch_num,'all')));
%min_ch      = floor(log2(min(ch_num)))
%max_ch      = floor(log2(max(ch_num)))

%weight_mean     = bitshift(mean_feat,-1*mean_ch)
%weight_minmax   = bitshift(min_feat, -1*max_ch)
%weight_maxmin   = bitshift(max_feat, -1*min_ch)
%weight_maxmax   = bitshift(max_feat, -1*max_ch)
%weight_minmin   = bitshift(min_feat, -1*min_ch)
weight_maxmean  = bitshift(max_feat, -1*mean_ch);

%channel_weight = bitshift(1,floor(log2(weight_maxmean)));
cluster_input       =   [(in_data*feature_weight), channel_weight*(double(channel))];

%pause;
		
for i = 1:Ndetected
	%[Li_ch Loc_label]	= ismember(channel(i,:),ch_label,'rows');
	%if(Li_ch)
%	ch_diff			= abs(ch_label - channel(i,:));
%	ch_diff 		= sum(ch_diff,2);
%	label_idx		= find(ch_diff <= ch_m_range,1);
%	if(label_idx)
		K_C_tmp(Ncluster+1,:) = cluster_input(i,:);
		%K_C_tmp(Ncluster+1,:) = [channel_weight*double(channel(i,:))];

		%merge_out	=	c_merge(K_C_tmp, Ncluster+1, mean_weight);
		merge_out	=	c_merge(K_C_tmp, 0, mean_weight);
		%min_idx1	=	merge_out(1);
		%min_idx2	=	merge_out(2);
		min_idx1	=	merge_out(2);
		min_v(i)	=	merge_out(3);

		K_C_tmp(min_idx1,:)		=	(K_C_tmp(min_idx1,:)*(merge_weight-1)+K_C_tmp(Ncluster+1,:))/(merge_weight);
		%K_C_tmp(min_idx2,:)		=	[in_data(i,:)	channel_weight*double(channel(i,:))];
%	end
end

K_C	= zeros(size(K_C_tmp) - [1 0]);
K_C	= K_C_tmp(1:Ncluster,:);
	
%figure;
%hold on
%scatter(in_data(:,1), in_data(:,2),'k');
%for i = 1:Ncluster
%	scatter(K_C(i,1), K_C(i,2), 55,'Marker','o', 'LineWidth',10);
%end
%hold off

cluster_out = zeros(2,1);

for i = 1:size(cluster_input,1)
	new_data		=	cluster_input(i,:);
	c_out			=	c_merge([K_C;new_data],0,1);
	c_idx			=	c_out(2);
	cluster_out(i)	=	c_idx;
end
	

save([outDir, datName, '_My',cluster_suffix], 'cluster_out', '-v7.3');
writematrix(cluster_out,[outDir, datName, '_My',cluster_suffix], 'Delimiter', 'tab');

%
%
%% pick ch_label with highest cnt
%ch_merge_range		= ones(Ncluster,1);
%ch_cnt_tmp			= ch_cnt;
%
%[max_v max_i]		= max(ch_cnt);
%K_C_ch(1,:)			= ch_label(max_i,:);
%ch_pick_idx(1)		= max_i;
%ch_merge_idx		= [];
%merge_cnt			= 1;
%ch_cnt_tmp(max_i)	= 0;
%
%i = 1;
%while (i ~= Ncluster)
%	[max_v max_i]		= max(ch_cnt_tmp);
%	ch_cnt_tmp(max_i)	= 0;
%	ch_diff				= abs(K_C_ch(1:i,:) - ch_label(max_i,:));
%	ch_diff				= sum(ch_diff,2);
%	merge_idx			= find(ch_diff <= ch_merge_range(1:i),1);
%	%[min_v min_i]		= min(ch_diff);
%	if(merge_idx)
%		ch_merge_range(merge_idx)	= ch_merge_range(merge_idx) + 1;
%		ch_merge_idx(merge_cnt,:)	= [merge_idx max_i];
%		merge_cnt					= merge_cnt + 1;
%	else
%		i = i+1;
%		K_C_ch(i,:)		= ch_label(max_i,:);
%		ch_pick_idx(i)	= max_i;
%	end
%end
%k = i;
%
%% self merge?
%for i = 1:k %Ncluster
%	ch_diff			= abs(K_C_ch - K_C_ch(i,:));
%	ch_diff			= sum(ch_diff,2);
%	merge_idx		= find(ch_diff <= ch_merge_range(i),2);
%	if(size(merge_idx,2) == 2)
%		K_C_ch(merge_idx(2),:) = 0;
%		ch_merge_range(i) = ch_merge_range(i) + 1;
%		ch_merge_idx(merge_cnt,:)	= [i merge_idx(2)];
%		merge_cnt					= merge_cnt + 1;
%	end
%end
%
%% delete ch under threshold
%ch_cnt_thr = 500;
%del_ch_idx = find(ch_cnt(ch_pick_idx) < ch_cnt_thr);
%K_C_ch(del_ch_idx, :) = 0;
%ch_merge_range(del_ch_idx) = 1;
%% ch_cnt(ch_pick_idx(del_ch_idx)) = 0;
%
%
%fprintf('Report\n');
%fprintf('\tmerge flow\n');
%for i = 1:(merge_cnt-1)
%	fprintf('\t%d\t: %d <- %d\n',i,ch_merge_idx(i,1),ch_merge_idx(i,2));
%end
%
%fprintf('\tCh Count Thre : %d\n',ch_cnt_thr);
%fprintf('\tCh Label : \n');
%for i = 1:Ncluster
%	fprintf('\t%d : range=%d\t',i,ch_merge_range(i));
%	fprintf('%d ',find(K_C_ch(i,:)==1));
%	fprintf('(%d)', ch_cnt(ch_pick_idx(i)));
%	fprintf('\n');
%end
%
%
%K_C_feature;
%%allocate free K_C
%i = 1;
%k = 0;
%while i ~= (Ncluster+1)
%	k = k + 1;
%	[Li_ch Loc_label] = ismember(channel(k,:),K_C_ch,'rows');
%
%	if(find(i == del_ch_idx)) % deleted mean
%		if(~Li_ch)
%			K_C_feature(i,:)	= in_data(k,:);
%			K_C_ch(i,:)			= channel(k,:);
%			i					= i+1;
%		end
%	else						% not deleted mean
%		if(Li_ch && (Loc_label == i)) % K_C_ch exits 
%			K_C_feature(i,:)	= in_data(k,:);
%			i					= i+1;
%		end
%	end
%end
%		
%	
%figure;
%fprintf('\tCh Feature and Label : \n');
%hold on
%for i = 1:Ncluster
%	fprintf('\t%d : feature = %d, %d\t',i,K_C_feature(i,1), K_C_feature(i,2));
%	fprintf('ch = range:%d\tlist:',ch_merge_range(i));
%	fprintf('%d ',find(K_C_ch(i,:)==1));
%	fprintf('\n');
%	
%	scatter(K_C_feature(i,1), K_C_feature(i,2), 'o');
%end
%hold off
%
%
%
%ch_label = zeros(Ncluster, Nchan);
%
%
%[max_v max_i] = max(ch_cnt);
%
%diff_ch = 
%ch_cnt(max_i) = 0;
%
%for i = 1:size(cluster_input,1)
%	new_data		=	cluster_input(i,:);
%	c_out			=	c_merge([K_C;new_data],0,channel_weight,1);
%	c_idx			=	c_out(2);
%	cluster_out(i)	=	c_idx;
%end
%
%
%
%save([outDir, datName, '_My',cluster_suffix], 'cluster_out', '-v7.3');
%writematrix(cluster_out,[outDir, datName, '_My',cluster_suffix], 'Delimiter', 'tab');
%
[~,K_idx] = max(K_C(:,3:end),[],2);
[~,KA_idx] = max(max(K_C(:,3:end)));

K_idx = K_idx - 2;	% this index is not precise. It's just for estimation.
%
%%figure();
%%X = 1:size(cluster_out,1);
%%
%%hold on
%%for i = 1:Ncluster
%%	plot(X,K_C_diff(i,:));
%%end
%%hold off
%%figure;
%%X = 1:k-1;
%%plot(X,K_C_ex_v);
%%%plot_ch = 112;
%%plot_ch = KA_idx;
%%
%%figure;
%%plot(1:i,min_v)
%

%do_plot = 1;
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
    ax1 = subplot(1,2,1,'Parent',p);
	hold on
	scatter3(K_C(:,1),K_C(:,2),K_idx, 80, 'k', 'Marker','x', 'LineWidth',10);
	scatter3(cluster_input(:,1),cluster_input(:,2),spike_ch, 30, clr(cluster_out,:), 'Marker','.');
	hold off
    view(3), box on, rotate3d on
    xlabel('feature 1'), ylabel('feature 2'), zlabel('channel')
	title('3D Feature Plot : Cluster mean only');
    ax2 = subplot(1,2,2,'Parent',p);
	hold on
	scatter3(K_C(:,1),K_C(:,2),K_idx, 80, 'k', 'Marker','x', 'LineWidth',10);
	hold off
    view(3), box on, rotate3d on
    xlabel('feature 1'), ylabel('feature 2'), zlabel('channel')
	title('3D Feature Plot w/ spike channel (Black: Cluster mean)');
	Link = linkprop([ax1 ax2],{'CameraUpVector', 'CameraPosition', ...
		'CameraTarget', 'XLim', 'YLim', 'ZLim'});
	setappdata(gcf, 'StoreTheLink', Link);
	fprintf('Time %3.0fs. Plotting Cluster Finished \n', toc);
end

