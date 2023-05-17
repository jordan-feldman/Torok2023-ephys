function event_CWT_JF(dataDir, saveFig, btitle)
%Save CWT for defs and non defs
ephys_def_up = load([dataDir btitle 'ephys_def_mn.mat'], 'ephys_def_up_mn').ephys_def_up_mn;
ephys_no_def_up = load([dataDir btitle 'ephys_no_def.mat'], 'ephys_no_def_up').ephys_no_def_up;
fs = 30000;
%get average CWT
tic
all_cwts_def=cell(1);
all_cwts_no_def = cell(1);
L = size(ephys_def_up,2);
fq_range = [1 300];
fb = cwtfilterbank('SignalLength',L,'SamplingFrequency',fs,...
    'FrequencyLimits',fq_range,'Wavelet','Morse','VoicesPerOctave',48,'TimeBandwidth',16);

for i=1:size(ephys_def_up, 1)    
    [chwin_def,~,~] = cwt(ephys_def_up(i, :),'FilterBank',fb);
    all_cwts_def{i} = abs(chwin_def(:, 1:100:length(chwin_def))).^2;
    
    [chwin_no_def,cwt_F,~] = cwt(ephys_no_def_up(i, :),'FilterBank',fb);
    all_cwts_no_def{i} = abs(chwin_no_def(:, 1:100:length(chwin_no_def))).^2;

    if mod(i, 10) == 0
        disp(i)
        toc
    end
end
save([dataDir btitle 'cwts_defs_mn'], 'all_cwts_def', 'cwt_F', '-v7.3')
save([dataDir btitle 'cwts_no_defs'], 'all_cwts_no_def', 'cwt_F', '-v7.3')

figure
per_inc = cellfun(@(x) ((x-mean(x, 2))./mean(x, 2))*100, all_cwts_def, 'UniformOutput', false);
cwt_mean = mean(cat(3, per_inc{:}), 3);
chwin_to_plot = cwt_mean;
xax = (1:100:size(ephys_def_up, 2))*(1000/fs);
pcolor(xax, cwt_F, chwin_to_plot)
shading interp
set(gca,'YScale','log','YDir','normal')
set(gca, 'YTick', flip(cwt_F(1:50:end)))
ylabel('Hz')
xlabel('time (ms)')
title(['Avg CWT of SWR in  ' strrep(btitle, '_', ' ')])
a = colorbar;
a.Label.String = '% increase';
saveas(gcf, [saveFig btitle 'SW_CWT_mn_per_increase_md'], 'fig')
saveas(gcf, [saveFig btitle 'SW_CWT_mn_per_increase_md'], 'jpg')
close all
end