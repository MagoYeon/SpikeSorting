function [feature_out] = spike_detection(in_data, plot_ch, outDir, datName, feature_opt);



spike = {in_data.spike};
spike_ch = {in_data.spike_ch};
channel = {in_data.channel};

Nspikes = size(spike, 1);

feature_out = struct('spike_time', [], 'spike',[],'spike_ch', [], 'channel',[]); 
