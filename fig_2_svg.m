fig_dir = '/Volumes/GoogleDrive/My Drive/Lois Lab/code_final/figs/';
fig_dir2 = '/Volumes/GoogleDrive/My Drive/Lois Lab/code_final/organized_figs_svg/';
all_dir = dir(fig_dir);
all_names = {all_dir.name}';
figi = cellfun(@(x) contains(x, '.fig'), all_names);
fig_names = all_names(figi);
for i = 1:length(fig_names)
    open([fig_dir fig_names{i}])
    saveas(gcf, [fig_dir2 fig_names{i}(1:end-4)], 'svg')
    close all
end