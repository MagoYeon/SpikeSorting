
datName1 = '20141202_all_es';
datName2 = '20150924_1_e';
datName3 = '20150601_all_s';
datName4 = '20150924_1_GT';
datName5 = '20150601_all_GT';
datName6 = '20141202_all_GT';

eval_out1 = load(['./output/', datName1, '_eval_0']).eval_out;
eval_out2 = load(['./output/set2/', datName2, '_eval_2']).eval_out;
eval_out3 = load(['./output/set3/', datName3, '_eval_3']).eval_out;
%eval_out4 = load(['./output/set4/', datName4, '_eval_4']).eval_out;
%eval_out5 = load(['./output/set5/', datName5, '_eval_5']).eval_out;
%eval_out6 = load(['./output/set6/', datName6, '_eval_0']).eval_out;

%eval_all = [eval_out1.DA_My_c eval_out1.CA_My_c eval_out1.SA_My_c; ...
%             eval_out2.DA_My_c2 eval_out2.CA_My_c2 eval_out2.SA_My_c2; ...
%            eval_out3.DA_My_c eval_out3.CA_My_c eval_out3.SA_My_c; ...
%            eval_out4.DA_My_c eval_out4.CA_My_c eval_out4.SA_My_c; ...
%            eval_out5.DA_My_c eval_out5.CA_My_c eval_out5.SA_My_c; ...
%            eval_out6.DA_My_c eval_out6.CA_My_c eval_out6.SA_My_c];

eval_all2 = [eval_out1.FN_My_c2 eval_out1.TP_My_c2 eval_out1.FP_My_c2; ...
            eval_out2.FN_My_c eval_out2.TP_My_c eval_out2.FP_My_c; ...
             eval_out3.FN_My_c2 eval_out3.TP_My_c2 eval_out3.FP_My_c2; ...
             eval_out4.FN_My_c2 eval_out4.TP_My_c2 eval_out4.FP_My_c2; ...
             eval_out5.FN_My_c2 eval_out5.TP_My_c2 eval_out5.FP_My_c2; ...
             eval_out6.FN_My_c2 eval_out6.TP_My_c2 eval_out6.FP_My_c2];

%evall   = [ 0.98    1       0.5     1       1       0.97;
%            0.47    0.74    0.23    0.42    0.98    0.17;
%            0.79    0.98    0.68    1       0.97    0;
%            0.22    0.59    0.18    0.5     0.7     0;
%            0.79    0.97    0.6     0.99    0.93    0;
%            0.36    0.5     0.14    0.4     0.49    0]
evall = [];

JR = zeros(6,8);
gS = zeros(6,8);
kS = zeros(6,8);
ph = zeros(6,8);
sC = zeros(6,8);

Cnum(1) = 7;
JR(1,1:Cnum(1)) =	[	1.00	1.00	1.00	1.00	1.00	1.00	1.00];
gS(1,1:Cnum(1)) =	[	0.74	0.47	0.39	0.50	0.68	0.90	0.58];
kS(1,1:Cnum(1)) =	[	1.00	1.00	1.00	1.00	0.99	1.00	1.00];
ph(1,1:Cnum(1)) =	[	0.86	0.97	0.98	1.00	0.97	0.97	0.96];
sC(1,1:Cnum(1)) =	[	1.00	0.99	1.00	0.99	0.99	0.96	0.98];

Cnum(2) = 7;
JR(2,1:Cnum(2)) =	[	0.99	0.97	0.97	0.99	0.97	0.98	1.00];
gS(2,1:Cnum(2)) =	[	0.17    0.94    0.96    0.29    0.23    0.21	0.42];
kS(2,1:Cnum(2)) =	[	0.53	0.88	0.90	0.42	0.34	0.45	0.40];
ph(2,1:Cnum(2)) =	[	0.45	0.99	0.98	0.40	0.49	0.50	0.55];
sC(2,1:Cnum(2)) =	[	0.85	0.95	0.95	0.58	0.40	0.64	0.77];

Cnum(3) = 8;
JR(3,1:Cnum(3)) =	[	0.8648    0.8748    0.9880    0.9794    0.8950    0.9608    0.9962	0.9464];
gS(3,1:Cnum(3)) =	[	0.8345    0.7000    0.5180    0.9765    0.4821    0.7255    0.6297	0.4228];
kS(3,1:Cnum(3)) =	[	0.9935    0.9937    0.9988    0.9956    0.9911    0.9991    1.0000	0.9959];
ph(3,1:Cnum(3)) =	[	0.5658    0.7900    0.9231    0.9706    0.6989    0.8195    0.6331	0.7822];
sC(3,1:Cnum(3)) =	[	0.9572    0.9610    0.9940    0.9904    0.9512    0.9889	0.9923	0.5296];

Cnum(4) = 7;
JR(4,1:Cnum(4)) =	[	0.9540   -0.9935   -0.9897    0.8085   -0.9166    0.7210    0.8300];
gS(4,1:Cnum(4)) =	[	0.2427   -0.9097   -0.9613    0.4725    0.1724    0.1686    0.3226];
kS(4,1:Cnum(4)) =	[	0.6372   -0.9966   -0.2446    0.4929    0.7988    0.6383    0.3931];
ph(4,1:Cnum(4)) =	[	0.2604   -0.9737   -0.9732    0.6691    0.2415    0.5112    0.3618];
sC(4,1:Cnum(4)) =	[	0.9910   -0.9964   -0.9892    0.6470    0.3108    0.5733    0.9543];

Cnum(5) = 8;
JR(5,1:Cnum(5)) =	[	0.8913    0.8681    0.9760    0.9780    0.8834    0.9529    0.5173    0.9460];
gS(5,1:Cnum(5)) =	[	0.8843    0.6539    0.4313    0.9654    0.4175    0.6770    0.5665    0.1963];
kS(5,1:Cnum(5)) =	[	0.9917    0.9899    0.9880    0.9599    0.9768    0.9979    0.9975    0.5927];
ph(5,1:Cnum(5)) =	[	0.8089    0.7897    0.9081    0.9398    0.6850    0.7657    0.6241    0.4528];
sC(5,1:Cnum(5)) =	[	0.9656    0.9791    0.9784    0.9557    0.9562    0.9885    0.9648    0.5868];

Cnum(6) = 7;
JR(6,1:Cnum(6)) =	[	0.6490    0.5050    0.8538   -0.9931    0.7981    0.4497    0.5138];
gS(6,1:Cnum(6)) =	[	0.1200    0.2511    0.4051   -0.2744    0.1921    0.1605    0.0961];
kS(6,1:Cnum(6)) =	[	0.6051    0.4996    0.6917   -0.9603    0.2790    0.2325    0.2082];
ph(6,1:Cnum(6)) =	[	0.3933    0.3597    0.8126   -1.0000    0.3560    0.4238    0.2734];
sC(6,1:Cnum(6)) =	[	0.7036    0.4054    0.3554    0.5196    0.7386    0.2574    0.5416];

for i = 1:length(Cnum)
	set_score{i} = [ph(i,1:Cnum(i))' sC(i,1:Cnum(i))' gS(i,1:Cnum(i))' kS(i,1:Cnum(i))' JR(i,1:Cnum(i))'];
end

for i = 1:length(Cnum)
	figure;
	set(gcf,'color','w');
	bar(set_score{i})
	xlabel('set')
	grid on
	legend({'phy', 'spkykingCircus', 'globalSuper', 'kiloSort', 'JRClust', 'Proposed Workd'})
	ylim([0 1])
end


figure;
set(gcf,'color','w');
bar(eval_all2)
xlabel('set')
grid on
legend({'Detection Accuracy', 'Clustering Accuracy', 'Sorting Accuracy'});
