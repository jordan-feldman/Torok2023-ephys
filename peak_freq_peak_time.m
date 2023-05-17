function peak_freq_peak_time(dataDir, btitle)
fs=30000;
sv_t = 1:100:fs/2;
rng=6000:9000;
sv_rng = find(abs(sv_t-rng(1))==min(abs(sv_t-rng(1)))):...
    find(abs(sv_t-rng(end))==min(abs(sv_t-rng(end))));

tic
cwt_F = load([dataDir btitle 'cwts_defs_mn.mat'], 'cwt_F').cwt_F;
freqoi=[1 120];
frng = find(abs(cwt_F-freqoi(2))==min(abs(cwt_F-freqoi(2)))):...
    find(abs(cwt_F-freqoi(1))==min(abs(cwt_F-freqoi(1))));
all_cwts = load([dataDir btitle 'cwts_defs_mn.mat'], 'all_cwts_def').all_cwts_def;
toc

per_inc = cellfun(@(x) ((x-mean(x, 2))./mean(x, 2))*100, all_cwts, 'UniformOutput', false);
peak_fr = zeros(length(per_inc), 1);
peak_fr_time = zeros(length(per_inc), 1);

for tr = 1:length(per_inc)
    [M,I] = max(per_inc{tr}(frng, sv_rng), [], 2);
    peak_fri = find(M == max(M));
    peak_fr(tr) = cwt_F(frng(peak_fri));
    peak_fr_time(tr) = sv_t(sv_rng(I(peak_fri)));
end

save([dataDir btitle 'peak_fr_peak_time.mat'], 'peak_fr', 'peak_fr_time')
end