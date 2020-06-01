useGPU = 1; % do you have a GPU? Kilosorting 1000sec of 32chan simulated data takes 55 seconds on gtx 1080 + M2 SSD.

% default options are in parenthesis after the comment
npath    = '/home/sykim/Project/neuro/';    %neuro projec path
kpath    = [npath, 'KiloSort/'];        %kiloSort path
fpath    = [kpath,'My_sort/My_test4/']; % where on disk do you want the simulation? ideally and SSD...
dpath    = [npath, 'MEAs_dataset/phy/set4/']; % where on disk do you want the simulation? ideally and SSD...

if ~exist(fpath, 'dir'); mkdir(fpath); cd(fpath); end

addpath(genpath(kpath)) % path to kilosort folder
addpath(genpath([npath,'npy-matlab-master/npy-matlab'])) % path to npy-matlab scripts
pathToYourConfigFile = fpath; % for this example it's ok to leave this path inside the repo, but for your own config file you *must* put it somewhere else!  

run(fullfile(pathToYourConfigFile, 'StandardConfig_MOVEME.m'))

tic; % start timer
%
if ops.GPU     
    gpuDevice(1); % initialize GPU (will erase any existing GPU arrays)
end

if strcmp(ops.datatype , 'openEphys')
   ops = convertOpenEphysToRawBInary(ops);  % convert data, only for OpenEphys
end
%
[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

% AutoMerge. rez2Phy will use for clusters the new 5th column of st3 if you run this)
%     rez = merge_posthoc2(rez);

% save matlab results file
save(fullfile(ops.root,  'rez.mat'), 'rez', '-v7.3');

% save python results file for Phy
rezToPhy(rez, ops.root);

% remove temporary file
delete(ops.fproc);
%%
