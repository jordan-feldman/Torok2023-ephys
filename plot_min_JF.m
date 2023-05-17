function plot_min_JF(jsonFile, saveFile, btitle, ephys_ch)
% plot the first minute of recording in the bird across all channels to
% identify bad channels
jsondecode(fileread(jsonFile));
index = 1;
A=load_open_ephys_binary(jsonFile,'continuous',index,'mmap');
fs = 30000;
min2sec = 60;

rng=1:fs*min2sec;
ephys_all=double(A.Data.Data.mapped(ephys_ch, rng))*0.195;
xax = (1:length(ephys_all))/fs;
ephys_plot = ephys_all + [1:size(ephys_all, 1)]'*1000;
figure
plot(xax, ephys_plot)
yticks(mean(ephys_plot, 2))
yticklabels([1:16])
xlabel('seconds')
title(strrep(btitle, '_', ' '))
saveas(gcf, [saveFile btitle 'first_min_all_ch'], 'jpg')
close all