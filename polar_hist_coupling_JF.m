function burst_ph = polar_hist_coupling_JF(dataDir, saveFig, btitle)
fs=30000;
ephys_def_up = load([dataDir btitle 'ephys_def_mn.mat'], 'ephys_def_up_mn').ephys_def_up_mn;
high_freqs = [30 40];
low_freqs = [10 20];

LFPs_high= bandpass(ephys_def_up', high_freqs, fs)';
LFPs_low = bandpass(ephys_def_up', low_freqs, fs)';

LFPs_hpwr = abs(hilbert(LFPs_high'))';
[~, l_hi] = max(LFPs_hpwr, [], 2); %#ok<UDIM>

%look at if peak in high power occur at specific phase of low power
LFPs_langle = angle(hilbert(LFPs_low'))';

burst_ph = diag(LFPs_langle(:, l_hi));
figure
polarhistogram(burst_ph, 50, 'FaceColor', 'b', ...
    'Normalization', 'probability')
%hold on
%requires circ stats toolbox
%polarplot([circ_mean(burst_ph) circ_mean(burst_ph)], [0 circ_r(burst_ph)], 'r')
[p, ~] = circ_rtest(burst_ph);
title([strrep(btitle, '_', ' ') ': phase of low frequency when high frequency peaks. rtest p: '...
    num2str(p)])
saveas(gcf, [saveFig btitle 'peak_phase_30-40Hz_mn'], 'fig')
saveas(gcf, [saveFig btitle 'peak_phase_30-40Hz_mn'], 'jpg')
close all