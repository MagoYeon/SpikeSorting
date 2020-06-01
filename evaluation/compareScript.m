

% Script to compare clusterings to groundTruth


%% set1

datFilename = 'V:\nick\GroundTruth\set1\20141202_all_emptyStatic.dat';
datFilename = [];
gtClu = LoadClu('V:\nick\GroundTruth\set1\20141202_all_emptyStatic.clu.1');
fid = fopen('V:\nick\GroundTruth\set1\20141202_all_emptyStatic.res.1', 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

entryDir = 'V:\nick\GroundTruth\set1\entries\phy\';
testKwikFile = [entryDir 'testOutput.kwik'];
testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));

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

% entryDir = 'V:\nick\GroundTruth\set1\entries\kiloSort\';
% load([entryDir 'testClu.mat']);
% load([entryDir 'testRes.mat']);

tic
[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
toc
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');



%% set2

datFilename = 'V:\www\phy.cortexlab.net\data\sortingComparison\set2\20150924_1_e.dat';
datFilename = [];
gtClu = LoadClu('V:\nick\GroundTruth\set2\20150924_1_e.clu.1');
fid = fopen('V:\nick\GroundTruth\set2\20150924_1_e.res.1', 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

entryDir = 'V:\nick\GroundTruth\set2\entries\phy\';
testKwikFile = [entryDir 'testOutput.kwik'];
testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));


% entryDir = 'V:\nick\GroundTruth\set2\entries\globalSuper\';
% fname = 'set2127066_thresh0.8_filt2';
% testClu = LoadClu([entryDir fname '.clu.1']);
% fid = fopen([entryDir fname '.res.1'], 'r'); 
% testRes = int32(fscanf(fid, '%d')); 
% fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set2\entries\kiloSort\';
% load([entryDir 'testClu.mat']);
% load([entryDir 'testRes.mat']);

[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');


%% set3

datFilename = 'V:\www\phy.cortexlab.net\data\sortingComparison\set3\20150601_all_s.dat';
gtClu = LoadClu('V:\nick\GroundTruth\set3\20150601_all_s.clu.1');
fid = fopen('V:\nick\GroundTruth\set3\20150601_all_s.res.1', 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

entryDir = 'V:\nick\GroundTruth\set3\entries\phy\';
testKwikFile = [entryDir 'testOutput.kwik'];
% testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));
fid = fopen('V:\nick\GroundTruth\set3\entries\phy\spike_clusters.txt', 'r'); 
testClu = int32(fscanf(fid, '%d')); 
fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set3\entries\globalSuper\';
% fname = 'set32516515_thresh0.8_filt2';
% testClu = LoadClu([entryDir fname '.clu.1']);
% fid = fopen([entryDir fname '.res.1'], 'r'); 
% testRes = int32(fscanf(fid, '%d')); 
% fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set3\entries\kiloSort\';
% load([entryDir 'testClu.mat']);
% load([entryDir 'testRes.mat']);

[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');


%% set4

datFilename = 'V:\www\phy.cortexlab.net\data\sortingComparison\set4\20150924_1_GT.dat';
datFilename = [];
gtClu = LoadClu('V:\nick\GroundTruth\set4\20150924_1_GT.clu.1');
fid = fopen('V:\nick\GroundTruth\set4\20150924_1_GT.res.1', 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set4\entries\phy\';
% testKwikFile = [entryDir 'testOutput.kwik'];
% % testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
% testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));
% fid = fopen('V:\nick\GroundTruth\set4\entries\phy\spike_clusters.txt', 'r'); 
% testClu = int32(fscanf(fid, '%d')); 
% fclose(fid);

entryDir = 'V:\nick\GroundTruth\set4\entries\spykingCircus\';
testKwikFile = [entryDir '20150924_1_GT.kwik'];
testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'))+5;

% entryDir = 'V:\nick\GroundTruth\set4\entries\globalSuper\';
% fname = 'set46001809_thresh0.8_filt2.clump';
% testClu = LoadClu([entryDir fname '.clu.1']);
% fid = fopen([entryDir fname '.res.1'], 'r'); 
% testRes = int32(fscanf(fid, '%d')); 
% fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set4\entries\kiloSort\';
% load([entryDir 'testClu.mat']);
% load([entryDir 'testRes.mat']);

[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');

%% set5

datFilename = 'V:\www\phy.cortexlab.net\data\sortingComparison\set5\20150601_all_GT.dat';
% datFilename = [];
gtClu = LoadClu('V:\nick\GroundTruth\set5\20150601_all_GT.clu.1');
fid = fopen('V:\nick\GroundTruth\set5\20150601_all_GT.res.1', 'r'); 
% datFilename = '/Volumes/data/www/phy.cortexlab.net/data/sortingComparison/set5/20150601_all_GT.dat';
% gtClu = LoadClu('/Volumes/data/nick/GroundTruth/set5/20150601_all_GT.clu.1');
% fid = fopen('/Volumes/data/nick/GroundTruth/set5/20150601_all_GT.res.1', 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set5\entries\phy\';
% testKwikFile = [entryDir 'testOutput.kwik'];
% % testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
% testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));
% fid = fopen([entryDir 'spike_clusters.txt'], 'r'); 
% testClu = fscanf(fid, '%d'); 
% fclose(fid);

% entryDir = '/Volumes/data/nick/GroundTruth/set5/entries/globalSuper/';
% entryDir = 'V:\nick\GroundTruth\set5\entries\globalSuper\';
% fname = 'test52516344_thresh0.8_filt2.clump';
% testClu = LoadClu([entryDir fname '.clu.1']);
% fid = fopen([entryDir fname '.res.1'], 'r'); 
% testRes = int32(fscanf(fid, '%d')); 
% fclose(fid);

entryDir = 'V:\nick\GroundTruth\set5\entries\spykingCircus\';
testKwikFile = [entryDir '20150601_all_GT.kwik'];
testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));

% entryDir = 'V:\nick\GroundTruth\set5\entries\kiloSort\';
% load([entryDir 'testClu.mat']);
% load([entryDir 'testRes.mat']);

[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');


%% set6

datFilename = 'V:\www\phy.cortexlab.net\data\sortingComparison\set6\20141202_all_GT.dat';
datFilename = [];
gtClu = LoadClu('V:\nick\GroundTruth\set6\20141202_all_GT.clu.1');
fid = fopen('V:\nick\GroundTruth\set6\20141202_all_GT.res.1', 'r'); 
gtRes = int32(fscanf(fid, '%d')); 
fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set6\entries\phy\';
% testKwikFile = [entryDir 'testOutput.kwik'];
% testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
% testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'));


entryDir = 'V:\nick\GroundTruth\set6\entries\spykingCircus\';
testKwikFile = [entryDir '20141202_all_GT.kwik'];
testClu = h5read(testKwikFile, '/channel_groups/1/spikes/clusters/main');
testRes = int32(h5read(testKwikFile, '/channel_groups/1/spikes/time_samples'))+10;

% entryDir = 'V:\nick\GroundTruth\set6\entries\globalSuper\';
% fname = 'set62670613_thresh0.8_filt2.clump';
% testClu = LoadClu([entryDir fname '.clu.1']);
% fid = fopen([entryDir fname '.res.1'], 'r'); 
% testRes = int32(fscanf(fid, '%d')); 
% fclose(fid);

% entryDir = 'V:\nick\GroundTruth\set6\entries\kiloSort\';
% load([entryDir 'testClu.mat']);
% load([entryDir 'testRes.mat']);

[allScores, allFPs, allMisses, allMerges] = compareClustering(gtClu, gtRes, testClu, testRes, datFilename, entryDir);
save([entryDir 'scores.mat'], 'allScores', 'allFPs', 'allMisses', 'allMerges');

%% compile results

% plots: totalScore, FPrate, MissRate, numMerges, initialScore
% - as 2D color plot with set (or individual cluster) and algorithm as axes, color as score
% 

sets = {'set1', 'set2', 'set3', 'set4', 'set5', 'set6'};
nGT = [7 7 8 7 8 7];
algorithms = {'phy', 'spykingCircus', 'globalSuper', 'kiloSort'};
algColors = hsv(4);

rootDir = 'V:\nick\GroundTruth\';

finalScore = nan(length(sets), length(algorithms));
fpRate = nan(length(sets), length(algorithms));
missRate = nan(length(sets), length(algorithms));
numMerges = nan(length(sets), length(algorithms));
initialScore = nan(length(sets), length(algorithms));

for s = 1:length(sets)
    for a = 1:length(algorithms)
        entryFile = fullfile(rootDir, sets{s}, 'entries', algorithms{a}, 'scores.mat');
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
bar(finalScore)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
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
bar(fpRate)
legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
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
bar(missRate)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
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
bar(numMerges)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
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
bar(initialScore)
% legend(algorithms)
set(gca, 'XTick', 1:length(sets), 'XTickLabel', sets);
ylim([0 1]);
ylabel('median initial score')
makepretty;


%% new mode
answersRootDir = 'V:\www\phy.cortexlab.net\data\sortingComparison\datasets\';
submissionRootDir = 'V:\www\phy.cortexlab.net\data\sortingComparison\results\';
algorithmName = 'JRClust';
setName = 'set6';

% eval(['spikeTimes = ' setName '.testRes; clusterIDs = ' setName '.testClu;'])
% fid = fopen([setName '/' algorithmName '_' setName '_spikeClusters.txt'], 'w');
% fprintf(fid,'%d\n', clusterIDs(:));
% fclose(fid)
% fid = fopen([setName '/' algorithmName '_' setName '_spikeTimes.txt'], 'w');
% fprintf(fid,'%d\n', spikeTimes(:));
% fclose(fid)

runComparisonAndUpdateResults(setName, algorithmName, submissionRootDir, answersRootDir)

