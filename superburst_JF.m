function superburst_JF(dataDir, saveFig, btitle)
data_path = [dataDir '/Jordan_NPIX/V668_day3_superburst_recs/2022-04-28_22-13-45/experiment1/recording1/structure.oebin'];
data_path2 = [dataDir '/Jordan_NPIX/V668_day3_superburst_recs/2022-04-28_22-38-40/experiment1/recording1/structure.oebin'];
itms = list_open_ephys_binary(data_path, 'continuous');
index = 2;
A=load_open_ephys_binary(data_path,'continuous',index,'mmap');
B=load_open_ephys_binary(data_path2,'continuous',index,'mmap');
%% 
c_signal = A.Data.Data.mapped*0.195;
c_signal2 = B.Data.Data.mapped*0.195;
ch_HVC = 257:321; %v668 day 3 experimental
total_length = length(c_signal);
fs = 2500;
hour2sec = 3600;
min2sec = 60;
%% look at the burst events
figure
plot(mean(c_signal(ch_HVC, :)))

szr_period = cell(1);
szr_period{1} = 119500:219600;
szr_period{2} = 2051000:2149000;
szr_period{3} = 2769000:3032000;
szr_period{4} = 79760:294900; %note this is on the second recording
szr_period{5} = 2250000:2397000; %note this is on the second recording

%% 
cwt_all = cell(1);
ephys_total = cell(1);
for i =1:5
    if i<4; cp_signal  = c_signal; end
    if i>=4; cp_signal = c_signal2; end
    ephys_period = mean(cp_signal(ch_HVC, szr_period{i}));
    [~, l] = min(ephys_period);
    defi = szr_period{i}+l;
    pad=fs;
    align_inds = floor(defi-pad:defi+pad);
    ephys_def=mean(cp_signal(ch_HVC, align_inds), 1);
    ephys_total{i} = ephys_def;
    L = size(ephys_def,2);
    fq_range = [1 300];
    fb = cwtfilterbank('SignalLength',L,'SamplingFrequency',fs,...
        'FrequencyLimits',fq_range,'Wavelet','Morse','VoicesPerOctave',48,'TimeBandwidth',16);
    [chwin,cwt_F,~] = cwt(ephys_def,'FilterBank',fb);
    temp = abs(chwin).^2;
    cwt_all{i} = ((temp-mean(temp, 2))./mean(temp, 2))*100;
end

%% 
figure
to_plot = 1:5;
subplot(5, 1, 2:5)
cwt_mean = mean(cat(3, cwt_all{to_plot}), 3);
chwin_to_plot = cwt_mean;
xax = (1:size(cwt_all{1}, 2))*(1000/fs);
pcolor(xax, cwt_F, chwin_to_plot)
shading interp
set(gca,'YScale','log','YDir','normal')
set(gca, 'YTick', flip(cwt_F(1:50:end)))
ylabel('Hz')
xlabel('time (ms)')
a = colorbar;
a.Label.String = '% increase';
xlim([0 2000])

subplot(5, 1, 1)
xax = (1:length(ephys_total{1}))*(1000/fs);
plot(xax, mean(cat(1, ephys_total{to_plot}), 1))
colorbar
ylabel('\muV')
xlim([0 2000])
saveas(gcf, [saveFig btitle 'superbursts_aligned'], 'fig')
saveas(gcf, [saveFig btitle 'superbursts_aligned'], 'jpg')




