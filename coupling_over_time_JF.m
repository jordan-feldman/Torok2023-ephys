function coupling_over_time_JF(phs, birds, saveFig)
btable = cell2table(birds(:, 1));

all_birds = table2cell(unique(btable));
all_birds(categorical(btable.Var1)=='OR251') = [];
start_days = [datetime('2022-04-30'), datetime('2022-09-1'), ...
    datetime('2022-04-29'), datetime('2022-09-10')];
dt = cellfun(@(x) ['2022-' x], birds(:, 4), 'UniformOutput', false);
dt = datetime(dt);
figure
hold on
clrs = {'r', 'g', 'b', 'k'};
sds = cellfun(@(x) circ_std(x)*180/pi, phs); 
mns = cellfun(@(x) circ_mean(x)*180/pi, phs);
%mns = cellfun(@(x) circ_mean(x), phs);
mns(mns<0) = 360+mns(mns<0);

subset=zeros(1, length(all_birds));
for j = 1:length(all_birds)
    rs = find(categorical(btable.Var1)==all_birds{j})';
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    subset(j)=plot(dpi, sds(rs(idx)), clrs{j});
end
xlabel('dpi')
ylabel('Standard Deviation of angle (degrees)')
legend(subset, all_birds)
title('Standard Deviation over time')
hold off
saveas(gcf, [saveFig 'SD_phase_over_time'], 'jpg')
saveas(gcf, [saveFig 'SD_phase_over_time'], 'fig')
close all

figure
subset=zeros(1, length(all_birds));
for j = 1:length(all_birds)
    rs = find(categorical(btable.Var1)==all_birds{j})';
    [~, idx ] = sort(dt(rs));
    dpi = datenum(dt(rs(idx))-start_days(j));
    subset(j)=plot(dpi, mns(rs(idx)), clrs{j});
    %subset(j)=polarplot(mns(rs(idx)), dpi, clrs{j});
    hold on
end
xlabel('dpi')
ylabel('phase angle (degrees)')
legend(subset, all_birds)
title('Mean Resultant Vector Angle')
hold off
saveas(gcf, [saveFig 'MR_angle'], 'jpg')
saveas(gcf, [saveFig 'MR_angle'], 'fig')
close all