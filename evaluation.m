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

%fprintf('Cluster Info. \n\tNgtClu = %d\n\tNcluster = %d\n',NgtClu, Ncluster);
%fprintf('\n');

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

%fprintf('Detection Results :\n')
%fprintf('\t\t\tTrue\t\tFalse\n');
%fprintf('\tPositive\t%d\t\t%d\n',detection_TP, detection_FP);
%fprintf('\tNegative\t%d\t%d\n',detection_TN, detection_FN);
%fprintf('\n');
%fprintf('\tTrue Positive Rate(TPR) : %f\n', TPR);
%fprintf('\tTrue Negative Rate(TNR) : %f\n', TNR);
%fprintf('\n');
%fprintf('\tDetection Accuracy\t- [TP/P]: %5.2f%% (%d/%d)\n', 100*detection_TP/Ndetected, detection_TP, Ndetected);
%fprintf('\n');

%Reordered cluter output
cluster_out_RO					=	zeros(Nspike,1);
cluster_out_tmp					=	cluster_out(gt_mark ~= 0);
gt_mark_RO						=	gt_mark(gt_mark ~= 0);
cluster_out_RO(gt_mark_RO)		=	cluster_out_tmp;
cluster_out_ROn					=	cluster_out(gt_mark == 0); %false detected

for gt_mean = min(gtClu):max(gtClu)
    for my_clu_mean = 1:Ncluster
        Ccompare(gt_mean,my_clu_mean) = length(find(cluster_out_RO(gtClu == gt_mean) == my_clu_mean));
        Ccompare_p(gt_mean,my_clu_mean) = 100*Ccompare(gt_mean,my_clu_mean)/length(find(gtClu==gt_mean));
        %row(gt_mean) = gtClu mean
        %col(my_clu_mean) = Cluster output mean
    end
end

%for gt_mean = min(gtClu):max(gtClu)
%    fprintf('\tgtClu:%d [%5d] =', gt_mean, length(find(gtClu==gt_mean)));
%    for my_clu_mean = 1:Ncluster
%        fprintf('C%d: %5.2f%%  ',my_clu_mean,Ccompare_p(gt_mean,my_clu_mean));
%    end
%    fprintf('\n');
%end

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

%fprintf('\n');
%for i = 1:NgtClu
%    fprintf('\t[Label %d:gtclu %d]\n',i,Cmap(i)); %[Cluster2:Label%d]\t[CLuster3:Label%d]\n',Cmap(1),Cmap(2),Cmap(3));
%end
%if(FCluster)
%	fprintf('\t[Label %d:False Cluster]\n',FCluster);
%else
%	fprintf('\t[No False Cluster]\n');
%end
%
%fprintf('\n');

CErrorIdx = [];
cluster_FP = [];
for i = 1:Ncluster
% Now I have to consider all cluster output
    %errorC{i} = find(spikes{6}(cluster_label==i)~=Cmap(i)); % Label i's error
	tmp_ci		= find(cluster_out==i);		% Positive indexes among whole cluster output
	tmp_cin		= find(cluster_out~=i);		% Negative indexes among whole cluster output
	tmp_ro_ci	= find(cluster_out_RO==i);	% Positive indexes among RO
	tmp_ro_cin	= find(cluster_out_RO~=i);	% Negative indexes among RO
    if(FCluster == i) %it's FCluster = Error Cluster (* Positive = error)
		errorC{i}	= find(gt_mark(tmp_ci) ~= 0);				% False Positive
		errorCn{i}	= find(cluster_out_ROn ~= i);				% False Negative
    else
        errorC{i}	= tmp_ro_ci(gtClu(tmp_ro_ci)~=Cmap(i));			% False Positive in cluster_out_RO
		errorC{i}	= [find(cluster_out_ROn == i) ; errorC{i}];	% Total False Positive (+ROn)
		errorCn{i}	= tmp_ro_cin(gtClu(tmp_ro_cin)==Cmap(i));			% False Negative
    end
    cluster_P		= length(tmp_ci);
	cluster_FP(i)	= length(errorC{i});
	cluster_TP(i)	= cluster_P - cluster_FP(i);
	cluster_N		= length(tmp_cin);
	cluster_FN(i)	= length(errorCn{i});
	cluster_TN(i)	= cluster_N - cluster_FN(i);
	TPR(i)			= cluster_TP(i) / (cluster_TP(i) + cluster_FN(i));
	TNR(i)			= cluster_TN(i) / (cluster_TN(i) + cluster_FP(i));
    CErrorIdx = [CErrorIdx ; errorC{i}];
	%fprintf('\tCluster %d-[TPR]:%.2f\t[TNR]:%.2f', i, TPR(i), TNR(i));
    %fprintf('\t[TP/P]:%5.2f%% (%d/%d)\n', 100*cluster_TP(i)/cluster_P, cluster_TP(i),cluster_P);    
end

%fprintf('\n');



%numFC = length(find(cluster_out==FCluster));

Cluster_error = length(CErrorIdx); % All False Positive

%fprintf('\tFalse Detected Cluster # = %d\n', numFC);
%fprintf('\tCluster Accuracy\t- : %f\n', (sum(cluster_TP)+sum(cluster_TN))/(sum(cluster_TP)+sum(cluster_TN)+sum(cluster_FN)+sum(cluster_FP)));
%fprintf('\tCluster Precision\t- : %f\n', (sum(cluster_TP))/(sum(cluster_TP)+sum(cluster_FP)));
fprintf('\tCluster Accuracy\t- : %f\n', (sum(cluster_TP)/Ndetected));
fprintf('\tCluster mean ROC\t- [TPR]:%5.2f [TNR]:%5.2f\n', mean(TPR), mean(TNR));

evaluation_out = Ccompare_p;
