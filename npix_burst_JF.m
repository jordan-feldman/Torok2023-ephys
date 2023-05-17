function npix_burst_JF(saveFig)
%% load bursts from one bird
burst_shape = load('/Volumes/Shelyn_2/Jordan_NPIX/V668_day3_superburst_recs/2022-04-28_22-38-40/data_analysis/bursts/burst_shapes_aligned.mat', ...
    'burst_shape').burst_shape;
%% 
fs = 2500;
ch_RA = 257:321; %v668 day 3 experimental
burst_LFP = cellfun(@(x) mean(x(ch_RA, :))*0.195, burst_shape(:, 4), 'UniformOutput', false);
burst_LFP = cat(1, burst_LFP{:});
non_burst_LFP = cellfun(@(x) mean(x(ch_RA, :))*0.195, burst_shape(:, 5), 'UniformOutput', false);
non_burst_LFP = cat(1, non_burst_LFP{:});

ephys_def = cell(1);
ephys_non_def = cell(1);
pad = 0.1*fs;
t_bfr = fs*0.25;
for i = 1:size(burst_LFP, 1)
    ephys_all = cell(1);
    cur_def = burst_LFP(i, :);
    cur_non_def = non_burst_LFP(i, :);
    cntr_win = floor(length(cur_def)/2-pad):floor(length(cur_def)/2+pad);
    min_loc = find(cur_def == min(cur_def(cntr_win)));
    if length(min_loc)>1
        min_loc = min_loc(min_loc >= length(cur_def)/2-pad & min_loc <= length(cur_def)/2+pad);
    end
    ephys_def{i} = cur_def(min_loc-t_bfr+1:min_loc+t_bfr-1);
    
    min_loc_non = find(cur_non_def == min(cur_non_def(cntr_win)));
    if length(min_loc_non)>1
        min_loc_non = min_loc_non(min_loc_non >= length(cur_non_def)/2-pad & min_loc_non <= length(cur_non_def)/2+pad);
    end
    ephys_non_def{i} = cur_non_def(min_loc_non-t_bfr+1:min_loc_non+t_bfr-1);
end

ephys_def = cat(1, ephys_def{:});
ephys_non_def = cat(1, ephys_non_def{:});
figure
xax = (1:length(ephys_def))*(1000/fs);
plot(xax, mean(ephys_def))
hold on
plot(xax, mean(ephys_non_def))
xlabel('ms')
ylabel('\muV')
legend({'bursts', 'non bursts'})
title('Average min aligned deflection during burst and non burst events')
saveas(gcf, [saveFig 'npix_avg_def'], 'fig')
saveas(gcf,  [saveFig 'npix_avg_def'], 'jpg')
close all

%% get avg cwt of deflections and non deflections
all_ephys = cell(1);
all_ephys{1} = ephys_def;
all_ephys{2} = ephys_non_def;
nttls = {'bursts', 'non bursts'};
tic
for n = 1:length(all_ephys)
    all_cwts = cell(1);
    ephys_def_up = all_ephys{n};
    for i=1:size(ephys_def_up, 1)
        L = size(ephys_def_up,2);
        fq_range = [1 300];
        fb = cwtfilterbank('SignalLength',L,'SamplingFrequency',fs,...
            'FrequencyLimits',fq_range,'Wavelet','Morse','VoicesPerOctave',48,'TimeBandwidth',16);
        [chwin,cwt_F,~] = cwt(ephys_def_up(i, :),'FilterBank',fb);
        all_cwts{i} = abs(chwin(:, 1:100:length(chwin))).^2;
        if mod(i, 10) == 0
            disp(i)
            toc
        end
    end 
    figure
    cwt_mean = mean(cat(3, all_cwts{:}), 3);
    chwin_to_plot = ((cwt_mean-mean(cwt_mean, 2))./mean(cwt_mean, 2))*100;
    xax = (1:100:fs/2)*1000/fs;
    pcolor(xax, cwt_F, chwin_to_plot)
    xlabel('ms')
    ylabel('Hz')
    shading interp
    set(gca,'YScale','log','YDir','normal')
    set(gca, 'YTick', flip(cwt_F(1:50:end)))
    a = colorbar;
    a.Label.String = '% increase';
    title(['Avg CWT during ' nttls{n}], 'Interpreter', 'none')
    saveas(gcf, [saveFig 'npix_CWT_' nttls{n}], 'fig')
    saveas(gcf, [saveFig 'npix_CWT_' nttls{n}], 'jpg')
    close all
end
