function [evaluation_out] = evaluation(in_data, gtClu, evaluation_opt, opt);

Ncluster    =   evaluation_opt.Ncluster;
NgtClu      =   opt.NgtClu;

for gt_mean = 1:NgtClu
    for my_clu_mean = 1:Ncluster
        Ccompare(gt_mean,my_clu_mean) = length(find(in_data(gtClu == gt_mean) == my_clu_mean));
        %row(gt_mean) = gtClu mean
        %col(my_clu_mean) = Cluster output mean
    end
end

for gt_mean = 1:NgtClu
    fprintf('gtClu:%d\t=\t', gt_mean);
    for my_clu_mean = 1:Ncluster
        fprintf('C%d:%d\t',my_clu_mean,Ccompare(gt_mean,my_clu_mean));
    end
    fprintf('\n');
end

evaluation_out = Ccompare;
