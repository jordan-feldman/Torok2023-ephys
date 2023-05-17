function detect_defs_JF(dataFile, saveFig, btitle)
% extract time points for deflections excluding periods with high movement
fs_new = 125;
acc_all = load([dataFile btitle '.mat'], 'acc_all').acc_all;
ephys_all = load([dataFile btitle '.mat'], 'ephys_all').ephys_all;
evnt_len = fs_new*(80/1000); %extract 80 ms events
min_evnt_len = fs_new*(10/1000);

acc_ch = double(cat(2, acc_all{:}));
ephys_ch = double(cat(2, ephys_all{:}));
[d_acc, ~] = gradient(acc_ch); %velocity
s_acc = mean(movstd(d_acc, evnt_len, 0, 2)); %deviations in velocity data show movement
mov_th = 75;

ephys = mean(ephys_ch);
ephys = bandpass(ephys, [1 40], fs_new);
th = prctile(ephys(s_acc<mov_th), 5);
[~, locs] = findpeaks(-1*ephys, 'MinPeakHeight', -1*th, 'MinPeakProminence', -0.5*th,...
    'MinPeakWidth', min_evnt_len, 'MinPeakDistance', evnt_len);
locs = locs(locs >fs_new/2 & locs < length(ephys) - fs_new/2);
pk_inds=locs;

step = 1;
rng = -evnt_len/2 : evnt_len/2;
pk_wvfs = zeros(length(pk_inds), length(rng));
mv_wvfs = zeros(length(pk_inds), length(rng));

for offset = rng
    pk_wvfs(:, step) =  ephys(pk_inds+offset);
    mv_wvfs(:, step) = s_acc(pk_inds+offset);
    step = step + 1;
end

no_mvmt = find(max(mv_wvfs, [], 2)<mov_th);
pk_inds = pk_inds(no_mvmt);
pk_wvfs = pk_wvfs(no_mvmt, :);

template = normalize(mean(pk_wvfs, 1));

[r, lags] = xcorr(ephys, template, 'none');
r = r(lags>=0);
%zscore but only for non-movment times
r = (r-mean(r(s_acc<mov_th)))/std(r(s_acc<mov_th)); 
[~, def_inds] = findpeaks(r, 'MinPeakHeight', 4, 'MinPeakProminence', 8, 'MinPeakDistance', evnt_len);
def_inds = def_inds+floor(length(template)/2);
def_inds = def_inds(def_inds >0 & def_inds <= length(ephys));

step = 1;
rng = -evnt_len/2 : evnt_len/2;
mv_wvfs2 = zeros(length(def_inds), length(rng));
for offset = rng
    mv_wvfs2(:, step) = s_acc(def_inds+offset);
    step = step + 1;
end

no_mvmt = max(mv_wvfs2, [], 2)<mov_th;
def_inds = def_inds(no_mvmt);
no_mvmt_periods = movmean(s_acc<mov_th, evnt_len)==1;

save([dataFile 'defs/' btitle 'def_times'], 'no_mvmt_periods', 'def_inds')

%plot the detected sharp waves
figure
hour2sec= 60*60;
xax = (1:length(ephys))/(hour2sec*fs_new);
plot(xax, ephys)
hold on
plot(xax(def_inds), ephys(def_inds), 'o g')
hold off
xlabel('time (hrs)')
ylabel('voltage (\muV)')
title(['detected sharp waves in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'detected_SWs'], 'fig')
saveas(gcf, [saveFig btitle 'detected_SWs'], 'jpg')
close all

