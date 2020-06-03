function [evaluation_out] = evaluation(spike_time, cluster_out, gtRes, gtClu, Nsamples, Ncluster, opt);

NgtClu      		=   opt.NgtClu;
Nspike				=	size(gtRes,1);
Nnegatives			=	Nsamples - Nspike;
spike_length		=	opt.spike_length;
Ndetected			=	size(cluster_out,1);
Ndetected_negative	=	Nsamples - Ndetected;

gt_mark			=	zeros(Ndetected,1);
miss_detected	=	0;


gt_idx = 1;
my_idx = 1;

fprintf('Cluster Info. \n\tNgtClu = %d\n\tNcluster = %d\n',NgtClu, Ncluster);
fprintf('\n');

while((gt_idx <= Nspike) && my_idx <= Ndetected)
	if(gtRes(gt_idx) >= (spike_time(my_idx) - spike_length/2) && ...
	gtRes(gt_idx) < (spike_time(my_idx) + spike_length/2) )
		gt_mark(my_idx) = gt_idx;
		gt_idx			= gt_idx + 1;
		my_idx 			= my_idx + 1; % it prevents double allocation(mark) problem
	else
		if(gtRes(gt_idx) > spike_time(my_idx))
			my_idx			= my_idx + 1;
		else
			miss_detected	= miss_detected + 1;
			gt_idx			= gt_idx + 1;
		end
	end
end
if(gt_idx <= Nspike) % untested gtClu remains
	miss_detected =  miss_detected + Nspike - gt_idx + 1;
end
			
detection_FP	= length(find(gt_mark == 0));
detection_TP 	= Ndetected - detection_FP;
detection_FN 	= miss_detected;
detection_TN	= Ndetected_negative - detection_FN;
TPR				= detection_TP / (detection_TP + detection_FN);
TNR				= detection_TN / (detection_TN + detection_FP);

fprintf('Detection Results :\n')
fprintf('\t\t\tTrue\t\tFalse\n');
fprintf('\tPositive\t%d\t\t%d\n',detection_TP, detection_FP);
fprintf('\tNegative\t%d\t%d\n',detection_TN, detection_FN);
fprintf('\n');
fprintf('\tTrue Positive Rate(TPR) : %f\n', TPR);
fprintf('\tTrue Negative Rate(TNR) : %f\n', TNR);
fprintf('\n');

%Reordered cluter output
cluster_out_RO				=	zeros(Nspike,1);
cluster_out_tmp				=	cluster_out(gt_mark ~= 0);
gt_mark_RO					=	gt_mark(gt_mark ~= 0);
cluster_out_RO(gt_mark_RO)	=	cluster_out_tmp;

for gt_mean = min(gtClu):max(gtClu)
    for my_clu_mean = 1:Ncluster
        Ccompare(gt_mean,my_clu_mean) = length(find(cluster_out_RO(gtClu == gt_mean) == my_clu_mean));
        Ccompare_p(gt_mean,my_clu_mean) = 100*Ccompare(gt_mean,my_clu_mean)/length(find(gtClu==gt_mean));
        %row(gt_mean) = gtClu mean
        %col(my_clu_mean) = Cluster output mean
    end
end

for gt_mean = min(gtClu):max(gtClu)
    fprintf('\tgtClu:%d = ', gt_mean);
    for my_clu_mean = 1:Ncluster
        fprintf('C%d: %5.2f%%  ',my_clu_mean,Ccompare_p(gt_mean,my_clu_mean));
    end
    fprintf('\n');
end

Cmap = zeros(1,Ncluster);
TCcompare = Ccompare;
for i = 1:NgtClu
    [r, c] = find(TCcompare==max(max(TCcompare)));
    Cmap(c) = r; %mapping cluster 
    %index c = cluster result
    %value r = gtClu index
    TCcompare(r,:) = 0;
    TCcompare(:,c) = 0;
end
%Camp(4)

FCluster = find(Cmap==0);

fprintf('\n');
for i = 1:NgtClu
    fprintf('\t[Label %d:gtclu %d]\n',i,Cmap(i)); %[Cluster2:Label%d]\t[CLuster3:Label%d]\n',Cmap(1),Cmap(2),Cmap(3));
end
if(FCluster)
	fprintf('\t[Label %d:False Cluster]\n',FCluster);
else
	fprintf('\t[No False Cluster]\n');
end

fprintf('\n');

evaluation_out = Ccompare_p;
