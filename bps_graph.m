


single_ch = 16 * 25000;

Bluetooth_5 = 2 * 1024 * 1024;

Wifi_max = 2.4 * 1024 * 1024 * 1024;


ch_max = 14;
ch_range = 1:ch_max;

ch_num = bitshift(1,ch_range);

num = 1:ch_num(end);

B_idx = find(num*single_ch > Bluetooth_5,1);
W_idx = find(num*single_ch > Wifi_max,1);

figure;
set(gcf,'color','w');

hold on
plot(ch_num,single_ch*ch_num/(1024*1024), 'k-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','k');
plot(ch_num,ones(1,ch_max)*Wifi_max/(1024*1024), 'r-', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
plot(ch_num,ones(1,ch_max)*Bluetooth_5/(1024*1024), 'b-','LineWidth',2,'MarkerSize',10','MarkerFaceColor','b');

plot(num(B_idx),single_ch*num(B_idx)/(1024*1024),'b-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','b');
plot(num(W_idx),single_ch*num(W_idx)/(1024*1024),'r-s', 'LineWidth',2,'MarkerSize',10','MarkerFaceColor','r');
hold off
grid on;
set(gca,'XScale','log')
xlabel('# of Channels');
for i = 1:ch_max
    xt{i} = ['2^{' num2str(ch_range(i)),'}'];
end
set(gca,'XTick',bitshift(1,ch_range))	% Y axis values going to be affected
set(gca,'XTickLabel',xt);	% Values goint to appear in above(YTick) places
ylabel('Data Rate [MB]')
legend({'Neural Signal Data Rate', 'Wifi Max Data Rate [2.4Gbps]', 'Bluetooth Max Data Rate [2Mbps]'});
xlim([ch_num(1) ch_num(end)]);
