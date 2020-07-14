
FR_datDir  {1}= '/home/sykim/Project/neuro/MEAs_dataset/phy/set1/';
FR_datName {1}= '20141202_all_es';
FR_datDir  {2}= '/home/sykim/Project/neuro/MEAs_dataset/phy/set2/';
FR_datName {2}= '20150924_1_e';
FR_datDir  {3}= '/home/sykim/Project/neuro/MEAs_dataset/phy/set3/';
FR_datName {3}= '20150601_all_s';
FR_datDir  {4}= '/home/sykim/Project/neuro/MEAs_dataset/phy/set4/';
FR_datName {4}= '20150924_1_GT';
FR_datDir  {5}= '/home/sykim/Project/neuro/MEAs_dataset/phy/set5/';
FR_datName {5}= '20150601_all_GT';
FR_datDir  {6}= '/home/sykim/Project/neuro/MEAs_dataset/phy/set6/';
FR_datName {6}= '20141202_all_GT';


    clearvars FR;
for i = 1:6
    fid = fopen([FR_datDir{i},FR_datName{i},'.res.1'], 'r'); 
    FR_gtRes = int32(fscanf(fid, '%d')); 
    fid = fopen([FR_datDir{i},FR_datName{i},'.clu.1'], 'r'); 
    FR_gtClu = int32(fscanf(fid, '%d')); 
    double(FR_gtRes);
    double(FR_gtClu);
    clearvars sec;
    idx_s = find(FR_gtRes > Fs*10,1);
    idx_e = find(FR_gtRes > Fs*20,1);
    sec = 10;%double(FR_gtRes(idx))/double(Fs);

    z = 0;
    for k=min(FR_gtClu):max(FR_gtClu)
        z = z+1;
        FR(i,z) = double(length(find(FR_gtClu(idx_s:idx_e)==k)))/sec;
    end
end

for i = 1:6
    fprintf('%d : ',i);
    fprintf('%f ', FR(i,:));
    fprintf('%f ', mean(FR(i,:)));
    fprintf('\n');
end


