function tf_power_over_time_JF(freqoi, cwt_F, birds, sv_cwt, sv_cwt_no_def, saveFig)
b_for_pval = zeros(1,4);
doi = 5; %dpi of interest
btable = cell2table(birds(:, 1));
all_birds = table2cell(unique(btable));
all_birds(categorical(btable.Var1)=='OR251') = [];
start_days = [datetime('2022-04-30'), datetime('2022-09-1'), ...
    datetime('2022-04-29'), datetime('2022-09-10')];
dt = cellfun(@(x) ['2022-' x], birds(:, 4), 'UniformOutput', false);
dt = datetime(dt);
rel_pwr_in_freq = cell(1);
for i = 1:length(freqoi)
    figure
    frng = find(abs(cwt_F-freqoi(i, 2))==min(abs(cwt_F-freqoi(i, 2)))):...
            find(abs(cwt_F-freqoi(i, 1))==min(abs(cwt_F-freqoi(i, 1))));
    for b = 1:size(birds, 1)
        rel_spec = ((sv_cwt{b}-mean(sv_cwt_no_def{b}, 2))./mean(sv_cwt_no_def{b}, 2))*100;
        rel_pwr_in_freq{b, i} = mean(rel_spec(frng, :), 1);
    end
    hold on
    clrs = {'r', 'g', 'b', 'k'};
    subset=zeros(1, length(all_birds));
    for j = 1:length(all_birds)
        rs = find(categorical(btable.Var1)==all_birds{j});
        [~, idx ] = sort(dt(rs));
        dpi = datenum(dt(rs(idx))-start_days(j));
%         mds = cellfun(@median, rel_pwr_in_freq(rs(idx), i));
%         up_bnd = cellfun(@(x) prctile(x, 25), rel_pwr_in_freq(rs(idx), i));
%         lw_bnd = cellfun(@(x) prctile(x, 75), rel_pwr_in_freq(rs(idx), i));
        b_for_pval(j) = rs(abs(dpi-doi) == min(abs(dpi-doi)));
        mds = cellfun(@mean, rel_pwr_in_freq(rs(idx), i));
        up_bnd = cellfun(@(x) mean(x)+2*std(x)/sqrt(length(x)), rel_pwr_in_freq(rs(idx), i));
        lw_bnd = cellfun(@(x) mean(x)-2*std(x)/sqrt(length(x)), rel_pwr_in_freq(rs(idx), i));

        fill([dpi;flipud(dpi)],[lw_bnd;flipud(up_bnd)], [0.9, 0.9, 0.9], ...
            'FaceColor', clrs{j}, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        subset(j)=plot(dpi, mds, clrs{j});
        flbl = [num2str(freqoi(i, 1)) '-' num2str(freqoi(i, 2)) ' Hz'];
        title(['Deflection power relative to non-deflection power in freqs: ' flbl])
        %put stars on adjacent days that are significantly different from
        %each other
%         pvals = zeros(length(idx)-1, 1);
%         for t=1:length(idx)-1
%             [~, pvals(t)] = ttest2(rel_pwr_in_freq{rs(idx(t)), i}, ...
%                 rel_pwr_in_freq{rs(idx(t+1)), i}, 'vartype', 'unequal');
% 
%             if pvals(t) < 0.05/105
%                 plot(dpi(t), mds(t), ['*' clrs{j}])
%                 plot(dpi(t+1), mds(t+1), ['*' clrs{j}])
%             end
%         end
    end
    xlabel('dpi')
    ylabel('% increase')
    legend(subset, all_birds)
    saveas(gcf, [saveFig 'freq_over_time' flbl], 'fig')
    saveas(gcf, [saveFig 'freq_over_time' flbl], 'jpg')
    close all
end

pval = ones(size(freqoi, 1), length(all_birds), length(all_birds))*NaN;
for i = 1:length(freqoi)
    for j = 1:length(all_birds)
        mn_pwr = mean(rel_pwr_in_freq{b_for_pval(j), i});
        sd_pwr = std(rel_pwr_in_freq{b_for_pval(j), i});
        disp(['The mean power relative to non-deflection times for bird '...
            all_birds{j} ' at freqs ' num2str(freqoi(i,1)) '-' num2str(freqoi(i,2))...
            ' near dpi 5 was ' num2str(mn_pwr) char(177) num2str(sd_pwr)])
        for k = j:length(all_birds)
            [~, pval(i, j, k)] = ttest2(rel_pwr_in_freq{b_for_pval(j), i}, rel_pwr_in_freq{b_for_pval(k), i});
        end
    end
end


