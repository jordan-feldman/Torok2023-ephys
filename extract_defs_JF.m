function extract_defs_JF(jsonFile, dataDir, saveFig, btitle, ephys_ch)
% using the deflection times extract 500 ms surrounding each deflection,
% also extract random non-deflection events for comparison
% jsonFile is the path to the raw data structure, dataFile is the path to
% directory with save data, saveFig is the directory for the figures,
% saveFile is the directory for the files, btitle is the birds name and
% date, ephys_ch is the indices of the ephys channels in the data

jsondecode(fileread(jsonFile));
index = 1;
A=load_open_ephys_binary(jsonFile,'continuous',index,'mmap');
total_length = size(A.Timestamps, 1);

fs = 30000;
fs_new = 125;
ds = fs/fs_new;
samples = 1:ds:total_length;

def_inds = load([dataDir btitle 'def_times.mat']).def_inds;

t_bfr = fs*0.25;
def_inds_up = samples(def_inds);
def_inds_up(def_inds_up<t_bfr+1) = [];
def_inds_up(def_inds_up>total_length - t_bfr+1) = [];
tic
ephys_def = cell(1);
pad = 0.1*fs;
for i = 1:length(def_inds_up)
    rng=def_inds_up(i)-t_bfr-pad:def_inds_up(i)+t_bfr-1+pad;
    ephys_def{i} = A.Data.Data.mapped(ephys_ch, rng)*0.195; %convert to uV
    cntr_win = length(rng)/2-pad:length(rng)/2+pad;
    min_loc = find(ephys_def{i}(1, :) == min(ephys_def{i}(1, cntr_win)));
    if length(min_loc)>1
        min_loc = min_loc(min_loc >= cntr_win(1) & min_loc <= cntr_win(end));
    end
    ephys_def{i} = ephys_def{i}(:, min_loc-t_bfr+1:min_loc+t_bfr-1);
    if mod(i, 10) == 0
        disp(i)
        toc
    end
end

temp = cellfun(@(x) mean(x, 1), ephys_def, 'UniformOutput', false);
ephys_def_up_mn = cat(1, temp{:});
save([dataDir btitle 'ephys_def_mn'], 'ephys_def_up_mn')
save([dataDir btitle 'ephys_def_ch'], 'ephys_def',  '-v7.3')

figure
for i=1:5
    subplot(5, 1, i)
    xax = (1:length(ephys_def_up_mn(i, :)))*(1000/fs);
    plot(xax, ephys_def_up_mn(i, :), 'b')
    hold on
    plot(xax, highpass(ephys_def_up_mn(i, :), 80, fs), 'r')
    ylabel('voltage (\muV)')
    xlabel('time (ms)')
end
title(['example sharp waves and ripples (80 Hz highpass) in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'example_SWs'], 'fig')
saveas(gcf, [saveFig btitle 'example_SWs'], 'jpg')
close all

no_mvmt_periods = load([dataDir btitle 'def_times.mat'], 'no_mvmt_periods').no_mvmt_periods;
no_def_inds = ones(size(no_mvmt_periods));
no_def_inds(def_inds) = 0;
%1 second periods without a deflection or movement
no_def_inds = movmean(no_def_inds, fs_new)==1; 
no_def_inds_i = find(no_def_inds & no_mvmt_periods);
no_def_inds = no_def_inds_i(randsample(length(no_def_inds_i), length(def_inds)));

no_def_inds_up = samples(no_def_inds);
no_def_inds_up(no_def_inds_up<t_bfr+1) = [];
no_def_inds_up(no_def_inds_up>total_length - t_bfr+1) = [];
tic
ephys_no_def = cell(1);
for i = 1:length(no_def_inds_up)
    rng=no_def_inds_up(i)-t_bfr+1:no_def_inds_up(i)+t_bfr-1;
    ephys_no_def{i} = A.Data.Data.mapped(ephys_ch, rng)*0.195; %convert to uV
    if mod(i, 10) == 0
        disp(i)
        toc
    end
end

temp = cellfun(@(x) mean(x, 1), ephys_no_def, 'UniformOutput', false);
ephys_no_def_up = cat(1, temp{:});
save([dataDir btitle 'ephys_no_def'], 'ephys_no_def_up')
save([dataDir btitle 'ephys_no_def_ch'], 'ephys_no_def', '-v7.3')
end
