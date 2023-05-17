%%  Jordan Feldman Summer 2022 
%   code for analyzing sharp waves in the perturbed animals. Generates
%   figures for the paper

%% initialize all bird paths, should change if new birds are added
base_dir = '/Volumes/GoogleDrive/My Drive/Lois Lab/code_final/';
addpath(base_dir)
[paths, birds] = init_birds_JF();
%base_dir = '/My Drive/Lois Lab/code_final/';
%% figure out which channels are bad in each bird
for b = start_bird:end_bird
    jsonFile= paths{birds{b, 2}};
    saveFile = [base_dir 'figs/'];
    btitle = [birds{b, 1} '_' birds{b, 4}];
    if birds{b, 3} == 1
        ephys_ch = 1:16;
    else
        ephys_ch =17:32;
    end
    plot_min_JF(jsonFile, saveFile, btitle, ephys_ch)
end

%% exclude bad channels from further analysis
btable = cell2table(birds(:, 1));
all_birds = table2cell(unique(btable));
ch_to_exclude(:, 1) = all_birds;
ch_to_exclude(:, 2) = {3, [], [], 13, 3};

%% downsample ephys and accelerometer data to 125 Hz so events can be detected
% this takes about 40 min per bird so run over night
start_bird = 1;
end_bird = length(birds);
for b = start_bird:end_bird
    jsonFile= paths{birds{b, 2}};
    saveFile = [base_dir '/all_rs_birds/' birds{b, 1} '_' birds{b, 4}];
    bird_ind = find(cellfun(@(x) strcmp(x, birds{b, 1}), ch_to_exclude(:, 1)));
    if birds{b, 5} == 1
        ephys_ch =1:16;
        ephys_ch(ch_to_exclude{bird_ind, 2}) = [];
        acc_ch =17:19;
    elseif birds{b, 5} == 2 && birds{b, 3} == 1
        ephys_ch =1:16;
        ephys_ch(ch_to_exclude{bird_ind, 2}) = [];
        acc_ch =33:35;
    elseif birds{b, 5} == 2 && birds{b, 3} == 2
        ephys_ch =17:32;
        ephys_ch(ch_to_exclude{bird_ind, 2}) = [];
        acc_ch =36:38;
    end
    downsample_birds_JF(jsonFile, saveFile, ephys_ch, acc_ch)
end
%% from downsampled data extract timepoints of deflections and periods without movement
start_bird = 1;
end_bird = length(birds);
for b = start_bird:end_bird
    dataFile= [base_dir '/all_rs_birds/'];
    saveFig = [base_dir 'figs/'];
    btitle = [birds{b, 1} '_' birds{b, 4}];
    detect_defs_JF(dataFile, saveFig, btitle)
end

%% extract deflections and an equal number of non-deflections from the original data
% takes about 5 min per bird so run in background
start_bird = 1;
end_bird = length(birds);
for b = start_bird:end_bird
    dataDir = [base_dir '/all_rs_birds/defs/'];
    saveFig = [base_dir 'figs/'];
    btitle = [birds{b, 1} '_' birds{b, 4}];
    jsonFile= paths{birds{b, 2}};
    
    bird_ind = find(cellfun(@(x) strcmp(x, birds{b, 1}), ch_to_exclude(:, 1)));
    if birds{b, 5} == 1
        ephys_ch =1:16;
        ephys_ch(ch_to_exclude{bird_ind, 2}) = [];
    elseif birds{b, 5} == 2 && birds{b, 3} == 1
        ephys_ch =1:16;
        ephys_ch(ch_to_exclude{bird_ind, 2}) = [];
    elseif birds{b, 5} == 2 && birds{b, 3} == 2
        ephys_ch =17:32;
        ephys_ch(ch_to_exclude{bird_ind, 2}) = [];
    end
    
    extract_defs_JF(jsonFile, dataDir, saveFig, btitle, ephys_ch)
end
%% get rid of bad trials: electrical bursts of activity in some of the birds
start_bird = 1;
end_bird = length(birds);
for b = start_bird:end_bird
    dataDir = [base_dir '/all_rs_birds/defs/' birds{b, 1} '_' birds{b, 4}];
    bad_trials_JF(dataDir)
end

%% plot example deflections

%good experimental examples
b = 19; %OR296 05-19
dataDir = [base_dir 'all_rs_birds/'];
btitle = [birds{b, 1} '_' birds{b, 4}];
startInd = 69962; %116212;
defSec = 46; %37;
saveFig = [base_dir 'figs/'];
example_def_JF(dataDir, btitle, startInd, defSec, saveFig)

b = 20; %B138 05-19
dataDir = [base_dir 'all_rs_birds/'];
btitle = [birds{b, 1} '_' birds{b, 4}];
startInd = 60962; %116212;
defSec = 7; %37;
saveFig = [base_dir 'figs/'];
example_def_JF(dataDir, btitle, startInd, defSec, saveFig)

%good control example
b = 12; %PK31 09-30
dataDir = [base_dir 'all_rs_birds/'];
btitle = [birds{b, 1} '_' birds{b, 4}];
startInd = 132000; %133250;
defSec = 11; %1
saveFig = [base_dir 'figs/'];
example_def_JF(dataDir, btitle, startInd, defSec, saveFig)

b = 11; %OR295 09-30
dataDir = [base_dir 'all_rs_birds/'];
btitle = [birds{b, 1} '_' birds{b, 4}];
startInd = 216000;
defSec = 5; 
saveFig = [base_dir 'figs/'];
example_def_JF(dataDir, btitle, startInd, defSec, saveFig)

%% make rasters of multi-unit high frequency activity during bursts
% takes a very long time, run over night
start_bird = 1;
end_bird = length(birds);
for b = start_bird:end_bird
    dataDir = [base_dir '/all_rs_birds/defs/'];
    saveFig = [base_dir 'figs/'];
    btitle = [birds{b, 1} '_' birds{b, 4}];
    multi_unit_raster_JF(btitle, saveFig, dataDir)
end

%% Plot density of different durations and amplitudes of the deflections
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
[all_amps, all_tms] = amp_dur_density_JF(dataDir, saveFig, birds);

%% Look at deflection rate over time
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
rate_over_time_JF(dataDir, saveFig, birds)

%% Plot and save CWTs for all events
start_bird = 1;
end_bird = length(birds);
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
for b = start_bird:end_bird 
    btitle = [birds{b, 1} '_' birds{b, 4}];
    event_CWT_JF(dataDir, saveFig, btitle);
end
%% Get deflection spectra relative to non-deflections
start_bird = 1;
end_bird = length(birds);
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
sv_cwt = cell(1);
sv_cwt_no_def = cell(1);
for b = start_bird:end_bird 
    btitle = [birds{b, 1} '_' birds{b, 4}];
    [sv_cwt{b}, sv_cwt_no_def{b}] = rel_spec_JF(dataDir, saveFig, btitle);
end

%% Get frequency band power over time
%freqoi = [1 15; 6 12; 20 40; 45 85; 90 120];
freqoi = [15 30; 30 70];
load([base_dir 'all_rs_birds/defs/B138_05-02cwts_defs_mn.mat'], 'cwt_F')
saveFig = [base_dir 'figs/'];
tf_power_over_time_JF(freqoi, cwt_F, birds, sv_cwt, sv_cwt_no_def, saveFig)
%% Plot and save CFCs for all events
start_bird = 1;
end_bird = length(birds);
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
for b = start_bird:end_bird 
    btitle = [birds{b, 1} '_' birds{b, 4}];
    event_CFC_JF(dataDir, saveFig, btitle);
end

%% Make polar histograms to show coupling
start_bird = 1;
end_bird = length(birds);
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
phs = cell(1);
for b = start_bird:end_bird 
    btitle = [birds{b, 1} '_' birds{b, 4}];
    phs{b} = polar_hist_coupling_JF(dataDir, saveFig, btitle);
end
coupling_over_time_JF(phs, birds, saveFig)

%% Look at when the peak frequency band peaks in each CWT
start_bird = 1;
end_bird = length(birds);
dataDir = [base_dir '/all_rs_birds/defs/'];
saveFig = [base_dir 'figs/'];
for b = start_bird:end_bird 
    btitle = [birds{b, 1} '_' birds{b, 4}];
    peak_freq_peak_time(dataDir, btitle);
end
freq_time_density_JF(dataDir, saveFig, birds)
%% Align 9 experimental songs from day 5 and plot example song
dataDir = '/Volumes/LAB_DR2/';
saveFig = [base_dir 'figs/'];
btitle = 'B138_05-04';
weird_voc_JF(dataDir, saveFig, btitle)

%% Align 9 control songs from day 5 and plot example song
voc_dir = [base_dir '/PK31_day5_bouts/'];
saveFig = [base_dir 'figs/'];
btitle = 'PK31_09-15';
control_voc_JF(voc_dir, btitle, saveFig)

%% Align 5 super burst events from day 3 npix
dataDir = '/Volumes/Shelyn_2/';
saveFig = [base_dir 'figs/'];
btitle = 'NPIX_DLX';
superburst_JF(dataDir, saveFig, btitle)

%% Do similar analysis for npix superbursts
saveFig = [base_dir 'figs/'];
npix_burst_JF(saveFig)

