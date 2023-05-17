function multi_unit_raster_JF(btitle, saveFig, dataDir)
% plots multi-unit spike times during each deflection
warning('off', 'signal:findpeaks:largeMinPeakHeight')
fs=30000;
baseline_time = 1:fs*(50/1000)+1;
event_time = fs*(225/1000):fs*(275/1000);
ephys_def = load([dataDir btitle 'ephys_def_ch.mat'], 'ephys_def').ephys_def;
ephys_CAR = cellfun(@(x) double(x)-mean(x, 1), ephys_def, 'UniformOutput', false);
spikes = cell(1);
sp_arr = cell(1);
tic
for ch = 1:size(ephys_CAR{1}, 1)
    trace = cellfun(@(x) x(ch, :), ephys_CAR, 'UniformOutput', false);
    trace = cat(1, trace{:});
    trace = bandpass(trace', [600, 6000], fs, 'ImpulseResponse','fir')';
    trace = resample(trace', 50000, fs)';
    energy = trace(:, 2:end-1).^2-trace(:, 1:end-2).*trace(:, 3:end);
    energy(energy <0) = 0;
    energy = sqrt(energy);
    sd_smooth = 0.4;
    energy = smoothdata(energy, 2, 'gaussian', sd_smooth*5);
    thresh = 3*mean(mean(energy));
    sp_arr{ch} = zeros(size(energy, 1), size(ephys_def{1}, 2));
    for tr=1:size(energy, 1)
        [~, MU_inds] = findpeaks(energy(tr, :), 'MinPeakHeight', thresh);
        spikes{tr, ch} = floor(MU_inds*(fs/50000));
        sp_arr{ch}(tr, spikes{tr, ch}) = 1;
    end
    disp(['channel: ' num2str(ch) ' time: ' num2str(toc)])
    figure
    subplot(5, 1, 1:4)
    hold on
    [trials,timebins] = find(logical(sp_arr{ch}));
    trials = trials';
    timebins = timebins';
    timebins=timebins*(1000/fs);
    halfSpikeHeight = 1/2;
    
    xPoints = [ timebins; timebins; NaN(size(timebins)) ];
    yPoints = [ trials - halfSpikeHeight; 
        trials + halfSpikeHeight; NaN(size(trials)) ];
    xPoints = xPoints(:);
    yPoints = yPoints(:);
    plot(xPoints,yPoints,'k', 'LineWidth', 3);
    
    xax = (1:size(ephys_def{1}, 2))*(1000/fs);
%     for triali = 1:size(spikes, 1)
%         spikes_to_plot = spikes{triali, ch};
%         height = ones(1, length(spikes_to_plot))*triali;
%         plot([xax(spikes_to_plot); xax(spikes_to_plot)], [height; height+1], 'k')
%     end
    ylabel('trial #')
    all_mns = cellfun(@mean, ephys_def, 'UniformOutput', false);
    avg_def = mean(cat(1, all_mns{:}));
    plot(xax, normalize(avg_def, 'range')*size(spikes, 1), 'r', 'LineWidth', 1)
    hold off
    disp(['channel: ' num2str(ch) ' time: ' num2str(toc)])
    ylim([0 size(spikes, 1)])
    title([strrep(btitle, '_', ' ') 'Detected multi unit spiking in channel ' num2str(ch)])
    sp_arr_ch = sp_arr{ch};
    save([dataDir btitle 'multi_unit_ch' num2str(ch)], 'sp_arr_ch')
    subplot(6, 1, 6)
    plot(xax, mean(movmean(sp_arr{ch}, fs*(10/1000), 2)*fs))
    ylabel('rate (Hz)')
    xlabel('time (ms)') 
    [~, p] = ttest(mean(sp_arr_ch(:, baseline_time), 2), mean(sp_arr_ch(:, event_time), 2));
    title(['ttest p: ' num2str(p)])
    saveas(gcf, [saveFig btitle 'multi_unit_ch' num2str(ch)], 'jpg')
    close all
end