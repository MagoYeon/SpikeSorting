function [filtered_int16_data] = filter_data(rawData, opt);

Nchan = size(rawData,1);
Nsamples = size(rawData,2);

datDir              =   opt.datDir;
datName             =   opt.datName;
outDir              =   opt.outDir;
dat                 =   opt.dat;
detected_suffix     =   opt.detected_suffix;
filtered_suffix     =   opt.filtered_suffix;
threshold_suffix    =   opt.threshold_suffix;

do_plot             =   opt.filter_plot;
Fs                  =   opt.Fs;
filter_band         =   opt.filter_band;
plot_ch             =   opt.plot_ch;

fprintf('Time %3.0fs. Filtering Raw Data Started \n', toc);
fprintf('Filtering Channel :    ');
% Nchan = 2;
filtered_int16_data = zeros(Nchan,Nsamples,'int16');
filtered_int16_tmp = zeros(1,Nsamples,'single');
for i = 1:Nchan
    fprintf(repmat('\b',1,3));
    fprintf('%3d',i);
    filtered_int16_tmp          = cast(rawData(i,:), 'single'); % double takes so much time?
	filtered_int16_tmp          = bandpass(filtered_int16_tmp, filter_band, Fs);
    filtered_int16_data(i,:) = cast(filtered_int16_tmp, 'int16');
end
fprintf('\nTime %3.0fs. Filtering Raw Data Finished \n', toc);

fprintf('\nTime %3.0fs. Saving Filtered Data Started \n', toc);
save([outDir, datName, filtered_suffix], 'filtered_int16_data', '-v7.3');
fprintf('\nTime %3.0fs. Saving Filtered Data Finished \n', toc);

if(do_plot)
	c = cast(rawData(plot_ch,:), 'single');
	fd = bandpass(c, filter_band, Fs);
	cf = cast(fd, 'int16');

	T = 1/Fs;
	L = Nsamples;
	t = (0:L-1)*T;
	n = 2^nextpow2(L);

	fig = figure('Name','Filtered Signals (Bandpass / Detection)','NumberTitle','off');
	p = uipanel('Parent',fig,'BorderType','none'); 
	p.Title = strcat(datName, ' - Bandpass Filter Results');
	p.TitlePosition = 'centertop'; 
	p.FontSize = 12;
	p.FontWeight = 'bold';

	% to see spectrum of original signal
	Y = fftshift(fft(rawData(plot_ch,:), n));
	f = Fs*(-n/2:n/2-1)/n;
	subplot(7,1,1,'Parent',p)
	plot(f,abs(Y) )
	%xlim([-6000 6000])
	%ylim([0 6000])
	title('Original-FFT')
	xlabel('f (Hz)')
	ylabel('|P1(f)|')
	% to see spectrum of filtered signal
	Y = fftshift(fft(fd, n));
	f = Fs*(-n/2:n/2-1)/n;
	subplot(7,1,2,'Parent',p)
	plot(f,abs(Y) )
	%xlim([-6000 6000])
	%ylim([0 5000])
	title('Filtered-FFT')
	xlabel('f (Hz)')
	ylabel('|P1(f)|')
	% to see spectrum of casted filtered signal
	Y = fftshift(fft(cf, n));
	f = Fs*(-n/2:n/2-1)/n;
	subplot(7,1,3,'Parent',p)
	plot(f,abs(Y) )
	%xlim([-6000 6000])
	%ylim([0 5000])
	title('C-Filtered-FFT')
	xlabel('f (Hz)')
	ylabel('|P1(f)|')

	subplot(7,1,4,'Parent',p)
	plot(Fs*t, rawData(plot_ch,:))
	xlim([0 Nsamples])
	title('Original')

	subplot(7,1,5,'Parent',p)
	plot(Fs*t, c)
	xlim([0 Nsamples])
	title('Casted')

	subplot(7,1,6,'Parent',p)
	plot(Fs*t, fd)
	xlim([0 Nsamples])
	title('Filtered')

	subplot(7,1,7,'Parent',p)
	plot(Fs*t, filtered_int16_data(plot_ch,:))
	xlim([0 Nsamples])
	title('final data')
end
