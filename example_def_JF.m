function example_def_JF(dataDir, btitle, startInd, defSec, saveFig)
% plot 1 min of ephys with def_inds in green and a zoomed in 0.5 second
% plot of the deflection closest to defSec in that minute
ephys_all =  load([dataDir btitle '.mat'], 'ephys_all').ephys_all; 
ephys = mean(cat(2, ephys_all{:}), 1);
def_inds = load([dataDir '/defs/' btitle 'def_times.mat'], 'def_inds').def_inds;
%plot the detected sharp waves
figure
fs_new = 125;
xax = ((1:length(ephys))-startInd)/(fs_new);
plot(xax, ephys)
hold on
plot(xax(def_inds), ephys(def_inds), 'o g')
hold off
xlim([0 60])
xlabel('time (seconds)')
ylabel('voltage (\muV)')
title(['example sharp waves in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'ex_min_trace'], 'fig')
saveas(gcf, [saveFig btitle 'ex_min_trace'], 'jpg')
close all


figure
ex_ind = defSec*fs_new+startInd;
def_num = abs(def_inds-ex_ind) == min(abs(def_inds-ex_ind));
ephys_def_up_mn = load([dataDir '/defs/' btitle 'ephys_def_mn.mat'], 'ephys_def_up_mn').ephys_def_up_mn;
fs=30000;
xax = (1:length(ephys_def_up_mn))*(1000/fs);
plot(xax, ephys_def_up_mn(def_num, :))
xlabel('time (ms)')
ylabel('voltage (\muV)')
title(['example sharp wave in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'ex_half_second_trace'], 'fig')
saveas(gcf, [saveFig btitle 'ex_half_second_trace'], 'jpg')
close all

