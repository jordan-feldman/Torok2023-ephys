function weird_voc_JF(dataDir, saveFig, btitle)
%% get weird song times
base_dir = [dataDir '/Weird_sounds_day5_bird2/'];
song_dir = [base_dir '735_Bouts/'];
voc_files = dir(song_dir);
voc_files = voc_files(4:end);
voc_times = cell(1);
for i = 1:length(voc_files)
    voc_times{i, 1} = voc_files(i).name(31:end-4);
end
%% load data

pathNameAft = [base_dir '2021-05-05_11-56-32_Or296_B138_afternoon'];
jsonFileAft = fullfile(pathNameAft, 'Record Node 101', 'experiment1', 'recording1', 'structure.oebin');
jsondecode(fileread(jsonFileAft));
index = 1;
A=load_open_ephys_binary(jsonFileAft,'continuous',index,'mmap');

pathNameMorn = [base_dir '2021-05-04_22-15-26_Or296_B138_overnight'];
jsonFileMorn = fullfile(pathNameMorn, 'Record Node 101', 'experiment1', 'recording1', 'structure.oebin');
jsondecode(fileread(jsonFileMorn));
index = 1;
M=load_open_ephys_binary(jsonFileMorn,'continuous',index,'mmap');

fs = 30000;
hour2sec = 3600;
min2sec = 60;

%% extract weird song times from data
aft_hr = 11;
aft_min = 56;

%remember this is the previous day
morn_hr = 22-24;
morn_min = 15;

store = cell(1);
for v = 1:length(voc_times)
    v_hr = extractBefore(voc_times(v), '_');
    v_hr = str2double(v_hr{1});
    %only have 5 hours in afternoon
    if v_hr > 17 || (v_hr == 17 && v_min > 15); continue; end 
    v_min = extractBefore(extractAfter(voc_times(v), '_'), '_');
    v_min = str2double(v_min{1});
    store{v, 1} = v_hr;
    store{v, 2} = v_min;
    
    is_aft = v_hr > aft_hr || (v_hr == aft_hr && v_min > aft_min);
    store{v, 3} = is_aft;
    
    %get 5 min around the vocalization
    if is_aft
        min_in = (v_hr*60+v_min)-(aft_hr*60+aft_min);
        bird2_sound = A.Data.Data.mapped(40, ...
            (min_in-.5)*min2sec*fs:(min_in+.5)*min2sec*fs)';
    else
        min_in = (v_hr*60+v_min)-(morn_hr*60+morn_min);
        bird2_sound = M.Data.Data.mapped(40, ...
            (min_in-.5)*min2sec*fs:(min_in+.5)*min2sec*fs)';
    end
    
    [template_aud,w_fs] = audioread([base_dir '735_Bouts/' voc_files(v).name]);
    template = resample(template_aud, fs, w_fs);
    
    [template,F,T]=zftftb_pretty_sonogram(normalize(template,'range'),fs,...
        'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);
    figure
    subplot(2, 1, 1)
    imagesc(T*fs, F, template)
    axis xy
    title('target song')
    store{v, 4} = template;
    
    [img,F,T]=zftftb_pretty_sonogram(normalize(bird2_sound,'range'),fs,...
        'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);
    
    r = normxcorr2(template(25:250, :),img(25:250, :));
    r = r(fix(size(r,1)/2),:);
    [pks,locs] = findpeaks(r);     % change similarity level    
    locs = locs(pks==max(pks));
    
    inds = locs-size(template, 2):locs;
    Tt = fix(fs*T(inds));
    Tt = min(Tt):max(Tt);
    store{v, 5} = Tt;
    store{v, 6} = Tt + (min_in-.5)*min2sec*fs;
    
    subplot(2, 1, 2)
    imagesc(T*fs, F, img(:, inds))
    axis xy
    title('extracted song')
    store{v, 5} = img(:, inds);
    close all
end
%% align song starts manually
ephys_ch = 17:32;
ephys_ch(3) = [];
for v = 1:size(store, 1)
    if isempty(store{v, 1}); continue; end
    pad = fs;
    inds = store{v, 6}(1)-pad:store{v, 6}(end)+pad;
    if store{v, 3} %afternoon
        bird2_sound = A.Data.Data.mapped(40, inds)';
        bird2_ephys = A.Data.Data.mapped(ephys_ch, inds)*0.195;
    else
        bird2_sound = M.Data.Data.mapped(40, inds)';
        bird2_ephys = M.Data.Data.mapped(ephys_ch, inds)*0.195;
    end
    [tmp,F,T]=zftftb_pretty_sonogram(normalize(double(bird2_sound)),fs,...
        'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);
    figure
    subplot(5, 1, 1:4)
    imagesc(T*fs, F, tmp)
    axis xy
    subplot(5, 1, 5)
    plot(mean(bird2_ephys))
    xlim([0 length(mean(bird2_ephys))])
    pause(1);
    rect = getrect(gcf);
    store{v, 13} = inds(floor(rect(1)));
    disp('draw rectangle')
    close all
end

%% get CWT for each song
ephys_ch = 17:32;
ephys_ch(3) = [];
ephys_total= cell(1);
cwt_all = cell(1);
songs = cell(1);
count=0;
for v = 1:size(store, 1)
    if isempty(store{v, 1}); continue; end
    count=count+1;
    pad = fs*1/6;
    align_inds = store{v, 13}-pad: store{v, 13}+2*pad;
    if store{v, 3} %afternoon
        ephys = A.Data.Data.mapped(ephys_ch, align_inds)*0.195;
        ephys = mean(ephys, 1);
        bird2_sound = A.Data.Data.mapped(40, align_inds)';
    else
        ephys = M.Data.Data.mapped(ephys_ch, align_inds)*0.195;
        ephys = mean(ephys, 1);
        bird2_sound = M.Data.Data.mapped(40, align_inds)';
    end
    ephys_total{count} = ephys;
    
    L = size(ephys,2);
    fq_range = [1 300];
    fb = cwtfilterbank('SignalLength',L,'SamplingFrequency',fs,...
        'FrequencyLimits',fq_range,'Wavelet','Morse','VoicesPerOctave',48,'TimeBandwidth',16);
    [chwin,cwt_F,~] = cwt(double(ephys),'FilterBank',fb);
    temp = abs(chwin).^2;
    cwt_all{count} = ((temp-mean(temp, 2))./mean(temp, 2))*100;
    
    [tmp,F,T]=zftftb_pretty_sonogram(normalize(double(bird2_sound)),fs,...
        'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);
    songs{count} = tmp;
end 
%% 
to_plot = [1:9];
figure
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
title(['aligned weird vocalizations in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'weird_voc_aligned'], 'fig')
saveas(gcf, [saveFig btitle 'weird_voc_aligned'], 'jpg')
close all

%% plot example song
ephys_ch = 17:32;
ephys_ch(3) = [];
inds = store{1, 6}(1)-fs*30:store{1, 6}(end)+fs*30;
bird2_sound = M.Data.Data.mapped(40, inds)';
bird2_ephys = M.Data.Data.mapped(ephys_ch, inds)*0.195;
[tmp,F,T]=zftftb_pretty_sonogram(normalize(double(bird2_sound), 'range'),fs,...
'len',34,'overlap',33,'clipping',[-3 2],'filtering',500);

figure
subplot(5, 1, 1:4)
imagesc(T, F, tmp)
ylabel('Hz')
axis xy
subplot(5, 1, 5)
xax = (1:length(bird2_ephys))*(1/fs);
plot(xax, mean(bird2_ephys))
xlim([0 60])
xlabel('seconds')
ylabel('\muV')
saveas(gcf, [saveFig btitle 'weird_voc_example_min'], 'fig')
saveas(gcf, [saveFig btitle 'weird_voc_example_min'], 'jpg')


figure
subplot(5, 1, 1:4)
imagesc(T, F, tmp)
ylabel('Hz')
xlim([28 29])
axis xy
subplot(5, 1, 5)
xax = (1:length(bird2_ephys))*(1/fs);
plot(xax, mean(bird2_ephys))
xlim([28 29])
xlabel('seconds')
ylabel('\muV')
saveas(gcf, [saveFig btitle 'weird_voc_example_sec'], 'fig')
saveas(gcf, [saveFig btitle 'weird_voc_example_sec'], 'jpg')

