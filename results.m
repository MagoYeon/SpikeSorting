
datName1 = '20141202_all_es';
datName2 = '20150924_1_e';
datName3 = '20150601_all_s';
datName4 = '20150924_1_GT';
datName5 = '20150601_all_GT';
datName6 = '20141202_all_GT';

eval_out1 = load(['./output/', datName1, '_eval_0']).eval_out;
eval_out2 = load(['./output/set2/', datName2, '_eval_2']).eval_out;
eval_out3 = load(['./output/set3/', datName3, '_eval_3']).eval_out;
eval_out4 = load(['./output/set4/', datName4, '_eval_4']).eval_out;
eval_out5 = load(['./output/set5/', datName5, '_eval_5']).eval_out;
eval_out6 = load(['./output/set6/', datName6, '_eval_0']).eval_out;

eval_all = [eval_out1.DA_My_c eval_out1.CA_My_c eval_out1.SA_My_c; ...
             eval_out2.DA_My_c2 eval_out2.CA_My_c2 eval_out2.SA_My_c2; ...
            eval_out3.DA_My_c eval_out3.CA_My_c eval_out3.SA_My_c; ...
            eval_out4.DA_My_c eval_out4.CA_My_c eval_out4.SA_My_c; ...
            eval_out5.DA_My_c eval_out5.CA_My_c eval_out5.SA_My_c; ...
            eval_out6.DA_My_c eval_out6.CA_My_c eval_out6.SA_My_c];

eval_all2 = [eval_out1.DA_My_c2 eval_out1.CA_My_c2 eval_out1.SA_My_c2; ...
            eval_out2.DA_My_c eval_out2.CA_My_c eval_out2.SA_My_c; ...
             eval_out3.DA_My_c2 eval_out3.CA_My_c2 eval_out3.SA_My_c2; ...
             eval_out4.DA_My_c2 eval_out4.CA_My_c2 eval_out4.SA_My_c2; ...
             eval_out5.DA_My_c2 eval_out5.CA_My_c2 eval_out5.SA_My_c2; ...
             eval_out6.DA_My_c2 eval_out6.CA_My_c2 eval_out6.SA_My_c2];

figure;
set(gcf,'color','w');
bar(eval_all)
xlabel('set')
grid on
legend({'Detection Accuracy', 'Clustering Accuracy', 'Sorting Accuracy'});

figure;
set(gcf,'color','w');
bar(eval_all2)
xlabel('set')
grid on
legend({'Detection Accuracy', 'Clustering Accuracy', 'Sorting Accuracy'});
