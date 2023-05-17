%% make 2D histogram of widths and amplitudes of bursts
function [all_amps, all_tms] = amp_dur_density_JF(dataDir, saveFig, birds)
fs=30000;
all_amps = cell(1);
all_tms = cell(1);
for b = 1:size(birds, 1)
    btitle = [birds{b, 1} '_' birds{b, 4}];
    ephys_def_up = load([dataDir btitle 'ephys_def_mn.mat'], 'ephys_def_up_mn').ephys_def_up_mn;
    cntr = floor(length(ephys_def_up)/2 - fs*(50/1000)):...
        floor(length(ephys_def_up)/2 + fs*(50/1000));
    amps = min(ephys_def_up(:, cntr), [], 2);
    widths = zeros(size(amps));
    for a = 1:length(amps)
        if amps(a) < 0; sc = -0.99; else; sc = -1.01; end
        [pks, ~, w, ~] = findpeaks(-1*ephys_def_up(a, :), 'MinPeakHeight', sc*amps(a));
        amps(a) = pks(w==max(w))*-1;
        widths(a) = max(w);
    end
    tms = widths*(1000/fs); %in ms
    all_amps{b} = amps;
    all_tms{b} = tms;
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
        x_pl = all_amps{rs(idx(i))};
        y_pl = all_tms{rs(idx(i))};
        xc = 1;
        step = 0.01;
        xs = -2000; ys = 0;
        xe = 0; ye=150;
        wp = 0.075; xp = (xe-xs)*wp; yp = (ye-ys)*wp;
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
        xlim([-2000 0])
        ylim([0 150])
        xlabel('amplitude \muV')
        ylabel('duration (ms)')
    end
    saveas(gcf, [saveFig all_birds{j} 'amp_vs_dur'], 'fig')
    saveas(gcf, [saveFig all_birds{j} 'amp_vs_dur'], 'jpg')
    close all
end

figure;
subset=zeros(length(all_birds), 2);
clrs = {'r', 'g', 'b', 'k'};
for j = 1:length(all_birds)
    rs = find(categorical(btable.Var1)==all_birds{j});
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    %mds = cellfun(@median, all_amps(rs(idx)));
    mds = cellfun(@mean, all_amps(rs(idx)));
    subplot(2, 1, 1)
    hold on
%     up_bnd = cellfun(@(x) prctile(x, 75), all_amps(rs(idx)))';
%     lw_bnd = cellfun(@(x) prctile(x, 25), all_amps(rs(idx)))';
    up_bnd = cellfun(@(x) mean(x)+2*std(x)/sqrt(length(x)), all_amps(rs(idx)))';
    lw_bnd = cellfun(@(x) mean(x)-2*std(x)/sqrt(length(x)), all_amps(rs(idx)))';
    fill([dpi;flipud(dpi)],[lw_bnd;flipud(up_bnd)], [0.9, 0.9, 0.9], ...
        'FaceColor', clrs{j}, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    xlabel('dpi')
    ylabel('amplitudes (\muV)')
    subset(j, 1)=plot(dpi, mds, clrs{j});
    
%     pvals = zeros(length(idx)-1, 1);
%     for t=1:length(idx)-1
%         [~, pvals(t)] = ttest2(all_amps{rs(idx(t))}, ...
%             all_amps{rs(idx(t+1))}, 'vartype', 'unequal');
%         
%         if pvals(t) < 0.05/105
%             plot(dpi(t), mds(t), ['*' clrs{j}])
%             plot(dpi(t+1), mds(t+1), ['*' clrs{j}])
%         end
%     end
    
    subplot(2, 1, 2)
    hold on
%     mds = cellfun(@median, all_tms(rs(idx)));
%     up_bnd = cellfun(@(x) prctile(x, 75), all_tms(rs(idx)))';
%     lw_bnd = cellfun(@(x) prctile(x, 25), all_tms(rs(idx)))';

    mds = cellfun(@mean, all_tms(rs(idx)));
    up_bnd = cellfun(@(x) mean(x)+2*std(x)/sqrt(length(x)), all_tms(rs(idx)))';
    lw_bnd = cellfun(@(x) mean(x)-2*std(x)/sqrt(length(x)), all_tms(rs(idx)))';

    fill([dpi;flipud(dpi)],[lw_bnd;flipud(up_bnd)], [0.9, 0.9, 0.9], ...
        'FaceColor', clrs{j}, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    subset(j, 2)=plot(dpi, mds, clrs{j});
    xlabel('dpi')
    ylabel('durations')
    
%     pvals = zeros(length(idx)-1, 1);
%     for t=1:length(idx)-1
%         [~, pvals(t)] = ttest2(all_tms{rs(idx(t))}, ...
%             all_tms{rs(idx(t+1))}, 'vartype', 'unequal');
%         
%         if pvals(t) < 0.05/105
%             plot(dpi(t), mds(t), ['*' clrs{j}])
%             plot(dpi(t+1), mds(t+1), ['*' clrs{j}])
%         end
%     end
end
subplot(2, 1, 1)
legend(subset(:, 1), all_birds)
subplot(2, 1, 2)
legend(subset(:, 2), all_birds)
saveas(gcf, [saveFig 'amp_vs_dur_over_time'], 'fig')
saveas(gcf, [saveFig 'amp_vs_dur_over_time'], 'jpg')
close all
