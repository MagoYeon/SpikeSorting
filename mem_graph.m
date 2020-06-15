
figure;
len = 8;
X = bitshift(1,0:len);
Fw = 16 * 4;
Nclu = 8;


hold on
plot(X, X*Fw*Nclu);
plot(X, Fw*Nclu*ones(1,len+1));
hold off

set(gca,'XTick',X)	% X axis values going to be affected
set(gca,'XTickLabel',flip(j_start:j_start+(fsize-1)));	% Values goint to appear in above(YTick) places

legend({'Typical','Proposed'});
xlabel('# of channel');
ylabel('Memory Requirement [bit]');
set(gcf,'color','w');

