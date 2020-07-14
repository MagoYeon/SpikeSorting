
figure;
len = 14;
X = bitshift(1,1:len);
len_range=1:len;
Fw= 16 * 2;
Fw_TVLSI = 9 * 4;
Fw_BioCAS = 16 * 64;
Fw_JSSC = 8 * 30;
Nclu = 9;


set(gcf,'color','w');
hold on
plot(X, (Fw+X)*Nclu/(1024*1024), 'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
plot(X, X*Fw_TVLSI*Nclu/(1024*1024), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
plot(X, X*Fw_BioCAS*Nclu/(1024*1024), 'b-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','b');
plot(X, X*Fw_JSSC*Nclu/(1024*1024), 'g-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','g');
hold off

%set(gca,'XTick',X)	% X axis values going to be affected
%set(gca,'XTickLabel',flip(j_start:j_start+(fsize-1)));	% Values goint to appear in above(YTick) places

set(gca,'XScale','log')
legend({'Proposed', '[TVSLI2019]', '[BioCAS2019]','[JSSC2013]'});
xlabel('# of channel');
ylabel('Memory Requirement [Mb]');

for i = len_range
    xt{i} = ['2^{' num2str(len_range(i)),'}'];
end

set(gca,'XTick',bitshift(1,len_range))	% Y axis values going to be affected
set(gca,'XTickLabel',xt);	% Values goint to appear in above(YTick) places
xlim([X(1) X(end)]);
grid on
