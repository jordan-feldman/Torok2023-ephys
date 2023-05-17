function bad_trials_JF(dataDir)
% plot the top 50 amplitude deflections and see if any should be removed as
% electrical activity

ephys_def_up_mn = load([dataDir 'ephys_def_mn.mat'], 'ephys_def_up_mn').ephys_def_up_mn;
[~, ranki] = sort(min(ephys_def_up_mn, [], 2));
pcolor(ephys_def_up_mn(ranki(1:50), :))
shading interp
to_remove = input('trials to remove:');
ephys_def_up_mn(ranki(to_remove), :)=[];
save([dataDir 'ephys_def_mn.mat'], 'ephys_def_up_mn')
close all
