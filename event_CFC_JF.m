function event_CFC_JF(dataDir, saveFig, btitle)
%Plot cross freqeuncy cohereograms
fs=30000;
ephys_def_up = load([dataDir btitle 'ephys_def_mn.mat'], 'ephys_def_up_mn').ephys_def_up_mn;
wvl_cc = zeros(60,60,size(ephys_def_up, 1));
tic
for i = 1:size(ephys_def_up, 1)
    fr = [1 120];
    fb = cwtfilterbank('SignalLength',size(ephys_def_up, 2),'SamplingFrequency',fs,...
        'FrequencyLimits',fr,'Wavelet','Morse','VoicesPerOctave',12,'TimeBandwidth',32);
    [chwin,fq,~] = cwt(ephys_def_up(i, :),'FilterBank',fb);
    %get power
    wvl_power = power(abs(chwin),2);
    %calculate the coherence
    wvl_cc(:,:,i) = mscohere(wvl_power', ephys_def_up(i, :), [], [], fq, fs);
    disp(['burst index: ' num2str(i) ' time: ' num2str(toc)])
end

figure
pcolor(fq,fq,mean(wvl_cc, 3)')
shading interp
xlabel('Phase Frequency(Hz)')
ylabel('Power Frequency(Hz)')
colorbar
title(['Mean Cross-frequency coupling in HVC during bursts in ' strrep(btitle, '_', ' ')])
saveas(gcf, [saveFig btitle 'CFC_mn'], 'fig')
saveas(gcf, [saveFig btitle 'CFC_mn'], 'jpg')
close all
end