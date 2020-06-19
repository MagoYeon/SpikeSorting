fig_det1_1 = figure('Name','Whole Signals - every channel','NumberTitle','off');
x_range = ceil(Nsamples * 0.05);
X = 1:x_range;
p = uipanel('Parent',fig_det1_1,'BorderType','none'); 
fnum = Nchan;
fsize = ceil(sqrt(fnum));
for i = 1:Nchan
	subplot(fsize,fsize,i,'Parent',p)
	hold on;
	plot(X, in_data(i, 1:x_range));
%	plot(X, Thr(i)*ones(1,x_range), 'r');
	title({['Ch:',num2str(i)]})
	hold off;
end
