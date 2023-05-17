function [sv_cwt, sv_cwt_no_def] = rel_spec_JF(dataDir, saveFig, btitle)
rng=7000:8000;
fs=30000;
sv_t = 1:100:fs/2;
sv_rng = find(abs(sv_t-rng(1))==min(abs(sv_t-rng(1)))):...
    find(abs(sv_t-rng(end))==min(abs(sv_t-rng(end))));
tic
cwt_F = load([dataDir btitle 'cwts_defs_mn.mat'], 'cwt_F').cwt_F;
all_cwts = load([dataDir btitle 'cwts_defs_mn.mat'], 'all_cwts_def').all_cwts_def;
cwt_in_rng = cellfun(@(x) mean(x(:, sv_rng), 2), all_cwts, 'UniformOutput', false);
sv_cwt = cat(2, cwt_in_rng{:});

cwt_F = load([dataDir btitle 'cwts_no_defs.mat'], 'cwt_F').cwt_F;
all_cwts = load([dataDir btitle 'cwts_no_defs.mat'], 'all_cwts_no_def').all_cwts_no_def;
cwt_in_rng = cellfun(@(x) mean(x(:, sv_rng), 2), all_cwts, 'UniformOutput', false);
sv_cwt_no_def = cat(2, cwt_in_rng{:});
toc

figure
subplot(2, 1, 1)
plot(cwt_F, mean(sv_cwt, 2))
xlabel('Frequency (Hz)')
ylabel('Power')
title(['raw spectra of: ' btitle], 'Interpreter', 'none')
set(gca,'YScale','log')

subplot(2, 1, 2)
to_plot = ((mean(sv_cwt,2)-mean(sv_cwt_no_def, 2))./mean(sv_cwt_no_def, 2))*100;
plot(cwt_F, to_plot)
ylabel('Percent Change')
xlabel('Frequency (Hz)')
title(['percent change in spectra of: ' btitle ' relative to non-deflection times']...
    , 'Interpreter', 'none')
saveas(gcf, [saveFig btitle 'relative_spectra'], 'fig')
saveas(gcf, [saveFig btitle 'relative_spectra'], 'jpg')
close all
end