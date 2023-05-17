function downsample_birds_JF(jsonFile, saveFile, ephys_ch, acc_ch)
% downsample the raw data so that events can be extracted
% jsonFile is the path to the structure.oebin file
% saveFile is the directory for the saved downsampled data
% ephys_ch and acc_ch are the channels for ephys and accelerometer data

jsondecode(fileread(jsonFile));
index = 1;
A=load_open_ephys_binary(jsonFile,'continuous',index,'mmap');
total_length = size(A.Timestamps, 1);
fs = 30000;
fs_new = 125;
ds = fs/fs_new;

count=1;
ephys_all = cell(1);
acc_all = cell(1);
tic
for i=1:240000:total_length
    rng=i:min(i+239999, total_length);
    ephys_all{count} = resample(double(A.Data.Data.mapped(ephys_ch, rng))', 1, ds)'*0.195;
    acc_raw = double(A.Data.Data.mapped(acc_ch, rng));
    acc_mn = mean(acc_raw, 2);
    acc_all{count} = resample((acc_raw-acc_mn)', 1, ds)'+acc_mn;
    count = count+1;
    if mod(count, 10) == 0
        disp(count)
        disp(i/total_length)
        toc
    end
end
save(saveFile, 'ephys_all', 'acc_all')
