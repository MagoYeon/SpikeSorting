function [merge_out]    =   c_merge(in_data, K, channel_weight, mean_weight);

merge_out(3) = -1;
data_length =   size(in_data,1);

max_dis_v   =   0;
max_dix_i1  =   0;
max_dix_i2  =   0;


if(K==0)
    K = data_length;
else
    i = 1:K;
end

mean_w      =   mean_weight*ones(K,1);
mean_w(K)   =   1;

for i = 1:K; 
    diff            = abs(in_data-in_data(i,:));
    %diffw           = [diff(:,1:2) channel_weight*diff(:,3:end)];
    diffw           = diff;
    d_sum           = sum(diffw,2); %.*mean_w;
    [max_v max_i]   = max(d_sum);

    if(max_dis_v < max_v)
        max_dis_v   = max_v;
        max_dis_i1  = i;
        max_dis_i2  = max_i;
    end

    d_sum(i)        = max_v;
    [min_v min_i]   = min(d_sum);

    if((merge_out(3) > min_v) || (merge_out(3) == -1))
        merge_out(1) = i;
        merge_out(2) = min_i;
        merge_out(3) = min_v;
    end
end

merge_out(4) = max_dis_i1;
merge_out(5) = max_dis_i2;
merge_out(6) = max_dis_v;

%merge_out(1:2) = merge_out(1:2)-1;
