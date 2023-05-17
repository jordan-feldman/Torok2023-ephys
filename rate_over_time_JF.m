function rate_over_time_JF(dataDir, saveFig, birds)
rates = zeros(1, size(birds, 1));
fs_new=125;
for b = 1:size(birds, 1)
    btitle = [birds{b, 1} '_' birds{b, 4}];
    def_inds = load([dataDir btitle 'def_times.mat']).def_inds;
    no_mvmt_periods = load([dataDir btitle 'def_times.mat']).no_mvmt_periods;
    no_mvmt_time = sum(no_mvmt_periods)/fs_new;
    rates(b) = length(def_inds)/no_mvmt_time;
end

xlbls = cell(1);
for b = 1:size(birds, 1)
    xlbls{b} = [birds{b, 1} '_' birds{b, 4}];
end
btable = cell2table(birds(:, 1));
all_birds = table2cell(unique(btable));
all_birds(categorical(btable.Var1)=='OR251') = [];
start_days = [datetime('2022-04-30'), datetime('2022-09-1'), ...
    datetime('2022-04-29'), datetime('2022-09-10')];
dt = cellfun(@(x) ['2022-' x], birds(:, 4), 'UniformOutput', false);
dt = datetime(dt);
figure
clrs = {'r', 'g', 'b', 'k'};
for j = 1:length(all_birds)
    hold on
    rs = find(categorical(btable.Var1)==all_birds{j});
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    plot(dpi, rates(rs(idx)), ['* -' clrs{j}], 'LineWidth',4)
    a=get(gca, 'XAxis');
    set(a, 'TickLabelInterpreter', 'none')
end
title('rate of SWRs across birds')
legend(all_birds)
ylabel('1/s')
xlabel('dpi')
saveas(gcf, [saveFig 'def_rate_over_time'], 'fig')
saveas(gcf, [saveFig 'def_rate_over_time'], 'jpg')
close all
