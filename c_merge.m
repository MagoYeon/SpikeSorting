function [merge_out]    =   c_merge(in_data, K, channel_weight);

merge_out = zeros(1,3);
merge_out(3) = -1;

if(K==0)
    i = size(in_data,1):size(in_data,1);
else
    i = 1:K;
end

for i = i; 
    diff            = abs(in_data-in_data(i,:));
    diffw           = [diff(:,1:2) channel_weight*diff(:,3:end)];
    d_sum           = sum(diffw,2);
    d_sum(i)        = max(d_sum);
    [min_v min_i]   = min(d_sum);

    if((merge_out(3) > min_v) || (merge_out(3) == -1))
        merge_out(1) = i;
        merge_out(2) = min_i;
        merge_out(3) = min_v;
    end
end

%merge_out(1:2) = merge_out(1:2)-1;
