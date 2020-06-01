function [feature_out] = feature_extraction(in_data, feature_opt, opt, Nchan);

%Nsamples = 16623305; % 20%
%Nsamples = ceil(size(in_data,2) * 0.016); 
% Nsample range, ylim

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
threshold_suffix    =   opt.threshold_suffix;
detected_suffix		=	opt.detected_suffix;
feature_suffix		=	opt.detected_suffix;
plot_ch				=	opt.plot_ch;

sum_idx				=	feature_opt.sum_idx;
spike_length		=   feature_opt.spike_length;

%spike_time		=	cell2mat({in_data.spike_time});
spike			=	in_data.spike;
spike_ch		=	in_data.spike_ch;
%channel			=	cell2mat({in_data.channel});
%overlap			=	cell2mat({in_data.overlap});

spike_num	= size(spike, 1);

feature_out = zeros(spike_num,2);

fprintf('Time %3.0fs. Feature Extraction Started \n', toc);

for i = 1:spike_num
	feature_out(i,:) = [sum(spike(i,1:sum_idx)), sum(spike(i,sum_idx+1:spike_length))];
end

if (feature_opt.do_plot)
    fprintf('Time %3.0fs. Plotting Features Started \n', toc);
    fig_feat = figure('Name','Features - every spike','NumberTitle','off');
    p = uipanel('Parent',fig_feat,'BorderType','none'); 
    subplot(1,1,1,'Parent',p)
	plot(feature_out(:,1),feature_out(:,2),'o');
	title('Simple Feature Plot');

    fig_feat2= figure('Name','Features - every spike w/ spike channel (3D)','NumberTitle','off');
    p = uipanel('Parent',fig_feat2,'BorderType','none'); 
    subplot(1,1,1,'Parent',p)
	plot3(feature_out(:,1),feature_out(:,2),spike_ch,'o');
	title('3D Feature Plot w/ spike channel');


%    fig_feat3= figure('Name','Features - every spike per spike channel','NumberTitle','off');
%    p = uipanel('Parent',fig_feat3,'BorderType','none'); 
%	fsize = ceil(sqrt(Nchan));
%	fprintf('\tPer channel Plotting [%%]:      ');
%	for i = 1:spike_num
%		if(mod(i,100)==0)
%			fprintf(repmat('\b',1,6));
%			fprintf('%6.2f',(i/spike_num)*100);
%		end
%		subplot(fsize,fsize,spike_ch(i),'Parent',p)
%		hold on;
%		plot(feature_out(i,1),feature_out(i,2),'o');
%		hold off;
%	end
%	for i = 1:Nchan
%		subplot(fsize,fsize,i,'Parent',p)
%		title({['Ch:',num2str(i)]})
%	end
	fprintf('\nTime %3.0fs. Plotting Features Finished \n', toc);
end
	
