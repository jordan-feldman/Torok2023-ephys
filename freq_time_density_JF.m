%% make 2D histogram of peak frequencies and time of peak
function freq_time_density_JF(dataDir, saveFig, birds)
fs=30000;
all_tms = cell(1);
all_freqs = cell(1);
for b = 1:size(birds, 1)
    btitle = [birds{b, 1} '_' birds{b, 4}];
    temp = load([dataDir btitle 'peak_fr_peak_time.mat'], 'peak_fr_time').peak_fr_time;
    all_tms{b} = temp*(1000/fs);
    all_freqs{b} = load([dataDir btitle 'peak_fr_peak_time.mat'], 'peak_fr').peak_fr;
end

btable = cell2table(birds(:, 1));
all_birds = table2cell(unique(btable));
all_birds(categorical(btable.Var1)=='OR251') = [];
start_days = [datetime('2022-04-30'), datetime('2022-09-1'), ...
    datetime('2022-04-29'), datetime('2022-09-10')];
dt = cellfun(@(x) ['2022-' x], birds(:, 4), 'UniformOutput', false);
dt = datetime(dt);
for j = 1:length(all_birds)
    figure
    rs = find(categorical(btable.Var1)==all_birds{j});
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    for i = 1:length(dpi)
        subplot(2, ceil(length(dpi)/2), i)
        x_pl = all_tms{rs(idx(i))};
        y_pl = all_freqs{rs(idx(i))};
        xc = 1;
        step = 0.01;
        xs = 200; ys = 1;
        xe = 300; ye=120;
        wp = 0.2; xp = (xe-xs)*wp; yp = (ye-ys)*wp;
        xrng = xs:(xe-xs)*step:xe;
        yrng = ys:(ye-ys)*step:ye;
        cmat = zeros(length(xrng), length(yrng));
        for xind = xrng
            yc = 1;
            for yind = yrng
                rng = x_pl >= xind & x_pl<xind+xp & y_pl >=yind & y_pl <yind+yp;
                cmat(xc, yc) = sum(rng)/length(x_pl);
                yc=yc+1;
            end
            xc=xc+1;
        end
        [X, Y] = meshgrid(xrng, yrng);
        pcolor(X, Y, cmat')
        shading interp; caxis([0 0.4]); colormap('jet')
        title([all_birds{j} ' day ' num2str(dpi(i))])
        xlim([200 300])
        ylim([1 120])
        xlabel('Time (ms)')
        ylabel('Frequency (Hz)')
    end
    saveas(gcf, [saveFig all_birds{j} 'time_vs_freq'], 'fig')
    saveas(gcf, [saveFig all_birds{j} 'time_vs_freq'], 'jpg')
    close all
    
    figure
    rs = find(categorical(btable.Var1)==all_birds{j});
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    for i = 1:length(dpi)
        subplot(1, length(dpi), i)
        to_plot = all_freqs{rs(idx(i))};
        h=histogram(to_plot, 15, 'normalization', 'probability');
        p = histcounts(to_plot, 15,'Normalization','pdf');
        % plot it
        hold on
        binCenters = h.BinEdges + (h.BinWidth/2);
        plot(binCenters(1:end-1), p, 'r-')
        xlabel('peak frequency (Hz)')
        ylim([0 0.3])
        ylabel('fraction of total')
        title([all_birds{j} ' day ' num2str(dpi(i))])
    end
    
    saveas(gcf, [saveFig all_birds{j} 'freq_hist'], 'fig')
    saveas(gcf, [saveFig all_birds{j} 'freq_hist'], 'jpg')
    close all
    
    figure
    rs = find(categorical(btable.Var1)==all_birds{j});
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    for i = 1:length(dpi)
        subplot(1, length(dpi), i)
        to_plot = all_tms{rs(idx(i))};
        h=histogram(to_plot, 15, 'normalization', 'probability');
        p = histcounts(to_plot, 15,'Normalization','pdf');
        % plot it
        hold on
        binCenters = h.BinEdges + (h.BinWidth/2);
        plot(binCenters(1:end-1), p, 'r-')
        xlabel('peak time (ms)')
        ylim([0 0.6])
        ylabel('fraction of total')
        title([all_birds{j} ' day ' num2str(dpi(i))])
    end
    
    saveas(gcf, [saveFig all_birds{j} 'peak_time_hist'], 'fig')
    saveas(gcf, [saveFig all_birds{j} 'peak_time_hist'], 'jpg')
    close all
end

figure;
subset=zeros(length(all_birds), 2);
clrs = {'r', 'g', 'b', 'k'};
for j = 1:length(all_birds)
    rs = find(categorical(btable.Var1)==all_birds{j});
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    mds = cellfun(@mean, all_freqs(rs(idx)));
    subplot(2, 1, 1)
    hold on
    up_bnd = cellfun(@(x) mean(x)+std(x)/sqrt(length(x)), all_freqs(rs(idx)))';
    lw_bnd = cellfun(@(x) mean(x)-std(x)/sqrt(length(x)), all_freqs(rs(idx)))';
    fill([dpi;flipud(dpi)],[lw_bnd;flipud(up_bnd)], [0.9, 0.9, 0.9], ...
        'FaceColor', clrs{j}, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    xlabel('dpi')
    ylabel('Frequency (Hz)')
    subset(j, 1)=plot(dpi, mds, clrs{j});
    
    subplot(2, 1, 2)
    hold on

    mds = cellfun(@mean, all_tms(rs(idx)));
    up_bnd = cellfun(@(x) mean(x)+std(x)/sqrt(length(x)), all_tms(rs(idx)))';
    lw_bnd = cellfun(@(x) mean(x)-std(x)/sqrt(length(x)), all_tms(rs(idx)))';

    fill([dpi;flipud(dpi)],[lw_bnd;flipud(up_bnd)], [0.9, 0.9, 0.9], ...
        'FaceColor', clrs{j}, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    subset(j, 2)=plot(dpi, mds, clrs{j});
    xlabel('dpi')
    ylabel('times (ms)')
end
subplot(2, 1, 1)
legend(subset(:, 1), all_birds)
subplot(2, 1, 2)
legend(subset(:, 2), all_birds)
saveas(gcf, [saveFig 'freq_vs_time_over_time'], 'fig')
saveas(gcf, [saveFig 'freq_vs_time_over_time'], 'jpg')
close all