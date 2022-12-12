%% Step 1: Preprocessing
%{
1. Preprocess CCEP in similiar fashion to task data
2. Identify time of stimulation for time locking
3. Clean raw signal to remove stimulation artifacts
%}

%% Step 2: Wavelet decomposition
%{
1. Decompose raw signal into frequency components
2. 59 frequencies log spaced between 1Hz and 256Hz
    (Only use up to 100 for ITPC)
    freqs = genFreqs('SpecDense');
3. Downsample to 200 Hz
4. Epoch data [-0.5,2] surrounding stimulation onset
%}

%% Step 3: Calculate Intertrial Phase Coherence (ITPC) for each stimulation/recording pair
%{
Input: phase = (trials x freqs x time) matrix for each channel pair
    represents instantaneous phase for each frequency/time point
Output: ccep_ITPC = (channel_pairs x freqs x time) matrix for each channel pair
    represents trial coherence (consistency of phase) for eact
    frequency/time point

spec_tmp: data structure with fields:
    power(freqs x trials x time)
    phase(freqs x trials x time)
    freqs(1 x freqs)
    time (1x time)

%}
%change pathname!!
spec_path = '';
ccep_files = dir(spec_path);
ccep_files = {ccep_files(find(~[ccep_files.isdir])).name};
%loop through channel pairs
for channel_pair = 1:length(ccep_files)
    %load wavelet data
    spec_tmp = load([spec_path,ccep_files{channel_pair}]);
    if channel_pair == 1
        %data structure to hold ITPC for each stimulation/recording pair
        freqs = spec_tmp.data.freqs;
        time = spec_tmp.data.time;
        %select phase data for ITPC
        freq_ind = find(spec_tmp.data.freqs < 100);
        freqs = freqs(freq_ind);
        ccep_ITPC = NaN(length(ccep_files),length(freq_ind),length(time));
    end
    
    phase = spec_tmp.data.phase(freq_ind,:,:);
    ccep_itpc_tmp = NaN(length(freq_ind),length(spec_tmp.data.time));
    %calculate ITPC for each frequency
    for fi = 1:length(freq_ind)
        %input: (trials x time) matrix for phase of each frequency
        %calculates ITPC across first dimension
        %output: (1 x time) vector of ITPC for each frequency/time point
        ccep_itpc_tmp(fi,:) = ITPC_CellFun_raw(squeeze(phase(fi,:,:)));
    end
    %save or concatinate ccep_itpc
    ccep_ITPC(channel_pair,:,:) = ccep_itpc_tmp;
end%channel pairs

%% Step 4: Generate Cluster representing general effect of stimulation on ITPC
%{
1. Remove ccep stimulation/recording pairs where stimulation artifact
    removal failed
2. Calculate cluster of change in ITPC caused by stimulation

Input: ccep_ITPC = (channel_pairs x freqs x time) matrix for each channel pair
    represents trial coherence (consistency of phase) for each
    frequency/time point
Output: structure containing matrix of pixel indexes to use for averaging
%}
%baseline change 300ms before stimulation

base_ind = find(time >= -0.5 & time <= -0.2);
ccep_ITPC = ccep_ITPC - nanmean(nanmean(ccep_ITPC(:,:,base_ind),3),1);
%calculate significant cluster across all channel pairs
stat_cfg = [];
stat_cfg.nperm = 500;
stat_cfg.alpha = 0.05;
stat_cfg.ncorrect = 1;
time_window = [0,1];%window to look for significant cluster
[specReturn,sig_struct] = CalcPermSpec(ccep_ITPC,time,time_window,freqs,stat_cfg);

%% Plot Significant cluster for visualization
plot_params = genPlotParams('Memoria','ERSP');
fsample = spec_tmp.data.fsample;
winSize = floor(fsample*plot_params.sm);
twodgauss = fspecial('gaussian',winSize,2.5);
gusWin= twodgauss/sum(twodgauss(:));
%set up freq ticks
freq_ticks = 1:4:length(freqs);
freq_labels = cell(1,length(freq_ticks));
for i = 1:length(freq_ticks)
    freq_labels{i}=num2str(round(freqs(freq_ticks(i))));
end
figure,
[h,p,confi,stats] = ttest(ccep_ITPC);
ersp_plot = convn(squeeze(stats.tstat),gusWin,'same');
plot_params.clim = [-10,10];
if ~isempty(specReturn)
    sig_im = imagesc(time,1:length(freqs),ersp_plot.*specReturn,plot_params.clim);
    hold on
end
tsp = imagesc(time,1:length(freqs),ersp_plot,plot_params.clim);
tsp.AlphaData = 0.6;
hold on
B = bwboundaries(specReturn);
for k = 1:length(B)
    boundary = B{k};
    plot(time(boundary(:,2)), boundary(:,1), 'Color','k', 'LineWidth', 1,'LineStyle','-')
end
hcb=colorbar;
set(gca,'fontsize',plot_params.textsize)
hcb=colorbar;
title(hcb,'t-stat')
hcb.FontSize = 15;
axis xy
hold on
colormap(plot_params.cmap);
set(gca,'YTick',freq_ticks)
set(gca,'YTickLabel',freq_labels)
plot([0 0],ylim,'k-','LineWidth',3)
%title([conds{ct,ci}]);
ylabel('Frequency (Hz)')
xlabel(plot_params.xlabel);

%% Step 5: Claculate causal effective connectivity score for each channel pair
%{
1. Identify ITPC values within significant cluster
2. average over the cluster

Input: ccep_ITPC = (channel_pairs x freqs x time) matrix for each channel pair
    represents trial coherence (consistency of phase) for eact
    frequency/time point
    sig_struct = structure containing pixel indexes for significant cluster
Output: CECS = (channel_pairs x 1) vector
%}
CECS = NaN(length(ccep_files),1);
%loop through channel pairs
for channel_pair = 1:length(ccep_files)
    connection_ITPC = squeeze(ccep_ITPC(channel_pair,:,:));%freq x time ITPC for each channel pair
    %{
    Make sure to normalize if reloading data rather than scripting
    base_ind = find(time_vec >= -0.5 & time_vec <= -0.2);
    connection_ITPC = connection_ITPC - nanmean(connection_ITPC(:,base_ind),2);
    %}
    connection_ITPC = connection_ITPC(sig_struct.PixelIdxList{1});
    CECS(channel_pair) = nanmean(connection_ITPC(:));
end%channel pair

figure('units', 'normalized', 'position', [0.0046875,0.189814814814815,0.985416666666667,0.576851851851852])
subplot(1,5,1)
histogram(CECS)
ylabel('count')
xlabel('CECS value')
[~,sort_ind] = sort(CECS);
for ci = 1:4
    subplot(1,5,ci+1)
    if ci < 3
        %lowest CECS
        c = ci;
    else
        %highest CECS
        c = length(CECS) - ci;
    end
    %% Plot Significant cluster for visualization
    ersp_plot = convn(squeeze(ccep_ITPC(sort_ind(c),:,:)),gusWin,'same');
    sig_im = imagesc(time,1:length(freqs),ersp_plot.*specReturn);
    hold on
    tsp = imagesc(time,1:length(freqs),ersp_plot);
    tsp.AlphaData = 0.6;
    hold on
    B = bwboundaries(specReturn);
    for k = 1:length(B)
        boundary = B{k};
        plot(time(boundary(:,2)), boundary(:,1), 'Color','k', 'LineWidth', 1,'LineStyle','-')
    end
    hcb=colorbar;
    set(gca,'fontsize',plot_params.textsize)
    hcb=colorbar;
    title(hcb,'ITPC')
    hcb.FontSize = 15;
    axis xy
    hold on
    colormap(plot_params.cmap);
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    %title([conds{ct,ci}]);
    ylabel('Frequency (Hz)')
    xlabel(plot_params.xlabel);
    titl = sprintf('CI = %.3f',CECS(sort_ind(c)));
    title(titl)
    
end%ci