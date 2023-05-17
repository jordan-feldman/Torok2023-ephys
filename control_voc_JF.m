function control_voc_JF(voc_dir, btitle, saveFig)
%% look for control PK31 songs and avg
FS=30000;
fs=FS;
matfiles = dir([voc_dir 'PK*chunks*.mat']);
dataset_1 = load(matfiles(1).name, 'dataset').dataset;
an_1 = normalize(dataset_1(40, :),'range');

figure
[tmp,F,T]=zftftb_pretty_sonogram(an_1,fs,...
'len',34,'overlap',33,'clipping',[-3 2],'filtering',300);
imagesc(T*fs, F, tmp)
title('p=1')

load(matfiles(2).name);
dataset_2 = load(matfiles(2).name, 'dataset').dataset;
an_2 = normalize(dataset_2(40, :),'range');

figure
[tmp,F,T]=zftftb_pretty_sonogram(an_2,FS,...
'len',34,'overlap',33,'clipping',[-3 2],'filtering',300);
imagesc(T*fs, F, tmp)
title('p=2')
close all
%% identify 9 starts to bouts in PK31 4dpi
song_starts = zeros(9, 2);
%ind: aligned to first note
song_starts(1:9, 1) = [312500;573440;833210;1281460;1537970;2033790;2556400;3135280;197900];
%p
song_starts(1:9, 2) = [1;      1;      1;      1;       1;       1;       1;       1;       2];
%% get CWT of each song start

ephys_total= cell(1);
cwt_all = cell(1);
songs = cell(1);
ephys_ch = 17:32;
for v = 1:length(song_starts)
    pad = fs*1/6;
    align_inds = song_starts(v)-pad: song_starts(v)+2*pad;
    
    audio = eval(['an_' num2str(song_starts(v, 2)) '(align_inds);']);
    
    [tmp,F,T]=zftftb_pretty_sonogram(audio,fs,...
        'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);
    songs{v} = tmp;
    
    ephys = eval(['dataset_' num2str(song_starts(v, 2)) '(ephys_ch, align_inds);']);
    ephys = mean(ephys, 1)*0.195; %convert to micro volts
    ephys_total{v} = ephys;
    
    L = size(ephys,2);
    fq_range = [1 300];
    fb = cwtfilterbank('SignalLength',L,'SamplingFrequency',fs,...
        'FrequencyLimits',fq_range,'Wavelet','Morse','VoicesPerOctave',48,'TimeBandwidth',16);
    [chwin,cwt_F,~] = cwt(double(ephys),'FilterBank',fb);
    temp= abs(chwin).^2;
    cwt_all{v}=((temp-mean(temp, 2))./mean(temp, 2))*100;
end

%% plot avg CWT across songs
figure
to_plot = 1:9;
subplot(6, 1, 3:6)
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
xlim([0 500])
subplot(6, 1, 2)
xax = (1:length(ephys_total{1}))*(1000/fs);
plot(xax, mean(cat(1, ephys_total{to_plot}), 1))
colorbar
ylabel('\muV')
xlim([0 500])
subplot(6, 1, 1)
songs_all = mean(cat(3, songs{to_plot}), 3);
imagesc(T*1000, F, songs_all)
axis xy
colorbar
xlim([0 500])
ylabel('Hz')
title(['aligned control vocalizations in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'control_voc_aligned'], 'fig')
saveas(gcf, [saveFig btitle 'control_voc_aligned'], 'jpg')
close all
%% plot example song
v=5;
align_inds = song_starts(v)-fs*30: song_starts(v)+fs*30;
audio = eval(['an_' num2str(song_starts(v, 2)) '(align_inds);']);
[tmp,F,T]=zftftb_pretty_sonogram(audio,fs,...
'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);
ephys = eval(['dataset_' num2str(song_starts(v, 2)) '(ephys_ch, align_inds);']);
ephys = mean(ephys, 1)*0.195;
figure
subplot(4, 1, 1:3);
imagesc(T, F, tmp)
ylabel('Hz')
axis xy
xlim([0 60])
subplot(4, 1, 4)
plot((1:length(ephys))*(1/fs), ephys*0.195)
xlim([0 60])
xlabel('seconds')
ylabel('\muV')
saveas(gcf, [saveFig btitle 'control_voc_example_min'], 'fig')
saveas(gcf, [saveFig btitle 'control_voc_example_min'], 'jpg')

figure
subplot(4, 1, 1:3);
imagesc(T, F, tmp)
ylabel('Hz')
axis xy
xlim([30 31])
subplot(4, 1, 4)
plot((1:length(ephys))*(1/fs), ephys*0.195)
xlim([30 31])
ylabel('\muV')
xlabel('seconds')
saveas(gcf, [saveFig btitle 'control_voc_example_sec'], 'fig')
saveas(gcf, [saveFig btitle 'control_voc_example_sec'], 'jpg')

