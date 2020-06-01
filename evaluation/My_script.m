%% set1

datDir = '/home/sykim/Project/neuro/MEAs_dataset/phy/set1/';
datName = '20141202_all_es.dat'

datFilename = [datDir,datName,'.dat'];
gtClu = LoadClu([datDir,datName,'.clu.1']);
fid = fopen([datDir,datName,'.res.1'], 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set1\entries\phy\';
% testKwikFile = [entryDir 'testOutput.kwik'];
% testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
% testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));

% entryDir = 'V:\nick\GroundTruth\set1\entries\globalSuper\';
% fname = 'testOutput86466_thresh0.8_filt2';
% testClu = LoadClu([entryDir fname '.clu.1']);
% fid = fopen([entryDir fname '.res.1'], 'r'); 
% testRes = int32(fscanf(fid, '%d')); 
% fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set1\entries\spykingCircus\';
% testKwikFile = [entryDir '20141202_all_es.kwik'];
% testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
% testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));

entryDir = '/home/sykim/Project/neuro/KiloSort/My_sort/My_test4/';
addpath(genpath([entryDir, 'evaluation/generalUtils']))

%load([entryDir 'testClu.mat']);
%load([entryDir 'testRes.mat']);

load([entryDir 'rez.mat']);
testClu = int32(rez.st3(:,2));
testRes = int32(rez.st3(:,1));


tic
[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
toc
save([entryDir 'evaluation' '/scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');

%% ?



sets = {'set1'};
nGT = [7];
%nGT = [7 7 8 7 8 7];
algorithms = {'kiloSort'};
algColors = hsv(4);

finalScore = nan(length(sets), length(algorithms));
fpRate = nan(length(sets), length(algorithms));
missRate = nan(length(sets), length(algorithms));
numMerges = nan(length(sets), length(algorithms));
initialScore = nan(length(sets), length(algorithms));

for s = 1:length(sets)
    for a = 1:length(algorithms)
        entryFile = fullfile(entryDir, 'evaluation', 'scores.mat');
        if exist(entryFile)
            load(entryFile)
            isc = zeros(1,length(allScores));
            fsc = zeros(1,length(allScores));
            nm = zeros(1,length(allScores));
            fpr = zeros(1,length(allScores));
            mr = zeros(1,length(allScores));
            for cGT = 1:length(allScores)
                isc(cGT) = allScores{cGT}(1);
                 fsc(cGT) = allScores{cGT}(end);
                 nm(cGT) = length(allScores{cGT})-1;
                 fpr(cGT) = allFPs{cGT}(end);
                 mr(cGT) = allMisses{cGT}(end);
            end
            finalScore(s,a) = median(fsc);
            fpRate(s,a) = median(fpr);
            missRate(s,a) = median(mr);
            numMerges(s,a) = median(nm);
            initialScore(s,a) = median(isc);
        end
    end
end

%% figure

plot_x = 1:nGT;

% f = figure; set(f, 'Position', [-1119         -40         635         841]);
% imagesc(finalScore)
% set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
% set(gca, 'YTick', 1:length(sets), 'YTickLabel', sets);
% colormap gray
% colorbar
% caxis([0 1]);
% title('median post-merge score');

figure; 
subplot(2, 3, 1);
% plot(finalScore, '.-')
bar(fsc)
% legend(algorithms)
set(gca, 'XTick', plot_x, 'XTickLabel', plot_x);
ylim([0 1]);
ylabel('median post-merge score')
makepretty;
            
% f = figure; set(f, 'Position', [-1119         -40         635         841]);
% imagesc(fpRate)
% set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
% set(gca, 'YTick', 1:length(sets), 'YTickLabel', sets);
% colormap gray
% colorbar
% caxis([0 .2]);
% title('median false positive rate');

subplot(2, 3, 2);
% plot(fpRate, '.-')
bar(fpr)
legend(algorithms)
set(gca, 'XTick', plot_x, 'XTickLabel', plot_x);
ylim([0 0.3]);
ylabel('median false positive')
makepretty;

% f = figure; set(f, 'Position', [-1119         -40         635         841]);
% imagesc(missRate)
% set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
% set(gca, 'YTick', 1:length(sets), 'YTickLabel', sets);
% colormap gray
% colorbar
% caxis([0 .2]);
% title('median miss rate');

subplot(2, 3, 3);
% plot(missRate, '.-')
bar(mr)
% legend(algorithms)
set(gca, 'XTick', plot_x, 'XTickLabel', plot_x);
ylim([0 0.3]);
ylabel('median miss rate')
makepretty;

% f = figure; set(f, 'Position', [-1119         -40         635         841]);
% imagesc(numMerges)
% set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
% set(gca, 'YTick', 1:length(sets), 'YTickLabel', sets);
% colormap gray
% colorbar
% title('median number of merges');

subplot(2, 3, 4);
% plot(numMerges, '.-')
bar(nm)
% legend(algorithms)
set(gca, 'XTick', plot_x, 'XTickLabel', plot_x);
% ylim([0 1]);
ylabel('median number of merges')
makepretty;

% f = figure; set(f, 'Position', [-1119         -40         635         841]);
% imagesc(initialScore)
% set(gca, 'XTick', 1:length(algorithms), 'XTickLabel', algorithms);
% set(gca, 'YTick', 1:length(sets), 'YTickLabel', sets);
% colormap gray
% title('median initial score');
% caxis([0 1]);
% colorbar

subplot(2, 3, 5);
% plot(initialScore, '.-')
bar(isc)
% legend(algorithms)
set(gca, 'XTick', plot_x, 'XTickLabel', plot_x);
ylim([0 1]);
ylabel('median initial score')
makepretty;



