function [TP TN FP FN] = eval_det(spike_time, gtRes, gtClu, Nsamples, opt);

NgtClu      		=   opt.NgtClu;
Nspike				=	size(gtRes,1);
Nnegatives			=	Nsamples - Nspike;
spike_length		=	opt.spike_length;
Ndetected			=	size(spike_time,1);
Ndetected_negative	=	Nsamples - Ndetected;

gt_mark			=	zeros(Ndetected,1);
miss_detected	=	0;
detection_TP    =   0;


gt_idx = 1;
my_idx = 1;

%fprintf('\n');

while((gt_idx <= Nspike) && (my_idx <= Ndetected))
	if(gtRes(gt_idx) >= (spike_time(my_idx) - spike_length/2) && ...
	gtRes(gt_idx) < (spike_time(my_idx) + spike_length/2) ) % well detected
		gt_mark(my_idx) = gt_idx;
		gt_idx			= gt_idx + 1;
		my_idx 			= my_idx + 1; % it prevents double allocation(mark) problem
	else
		if(gtRes(gt_idx) > spike_time(my_idx))  % FP
			my_idx			= my_idx + 1;
		else                                    % FN
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
TPR				= detection_TP / Nspike;
TNR				= detection_TN / (Nsample-Nspike);

fprintf('Detection Results :\n')
fprintf('\t\t\tTrue\t\tFalse\n');
fprintf('\tPositive\t%d\t\t%d\n',detection_TP, detection_FP);
fprintf('\tNegative\t%d\t%d\n',detection_TN, detection_FN);
fprintf('\n');
fprintf('\tTrue Positive Rate(TPR) : %f\n', TPR);
fprintf('\tTrue Negative Rate(TNR) : %f\n', TNR);
fprintf('\n');
fprintf('\tDetection Accuracy\t- [TP/P]: %5.2f%% (%d/%d)\n', 100*detection_TP/Ndetected, detection_TP, Ndetected);
fprintf('\n');

FP = detection_FP;
FN = detection_FN;
TP = detection_TP;
TN = detection_TN;
