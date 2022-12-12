function plot_params = genPlotParams(task,plottype)

%% INPUTS:
%   task: task name
%   plottype: 'timecourse'(e.g. for HFB),'ERSP' (for spectrogram),
%             or 'ITC' (for inter-trial phase coherence)
%% OUTPUTS:
%   plot_params     .single_trial: true (plot indiv. trials) or false (plot avg. across trials)
%                   .eb: error-bar type ('ste' for standard error of mean, or 'std' for standard dev.)
%                   .multielec: true or false (whether to plot multiple elecs on same figure)
%                   .blc: true or false (whether to load bl-corrected data or not)
%                   .run_blc: true or false (whether to run baseline
%                           correction before plotting, i.e. if data not already
%                           baseline corrected)
load cdcol_2018.mat

switch plottype
    case 'timecourse'
        plot_params.legend = true;
        plot_params.single_trial = false;
        plot_params.eb = 'ste';
        plot_params.xlabel = 'Time (s)';
        plot_params.ylabel = 'z-scored power';
        plot_params.textsize = 20;
        plot_params.freq_range = [70 180];
        plot_params.plot_metric = 'z';
        plot_params.multielec = false;
        plot_params.col = [cdcol.ultramarine;
            cdcol.carmine;
            cdcol.yellow_green;
            cdcol.lilac;
            cdcol.yellow;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
        plot_params.blc = 1;
    case 'timecourse_db'
        plot_params.legend = true;
        plot_params.single_trial = false;
        plot_params.eb = 'ste';
        plot_params.xlabel = 'Time (s)';
        plot_params.ylabel = 'Decibels (dB)';
        plot_params.textsize = 20;
        plot_params.freq_range = [70 180];
        plot_params.plot_metric = 'db';
        plot_params.multielec = false;
        plot_params.col = [cdcol.ultramarine;
            cdcol.carmine;
            cdcol.yellow_green;
            cdcol.lilac;
            cdcol.yellow;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
        plot_params.blc = 1;
        plot_params.blc_db = 1;
    case 'RTLock'
        plot_params.legend = false;
        plot_params.xlabel = 'Time (s)';
        plot_params.ylabel = 'RT-sorted trials';
        plot_params.textsize = 20;
        plot_params.freq_range = [70 180];
        plot_params.cmap = cbrewer2('RdBu');
        plot_params.cmap = plot_params.cmap(end:-1:1,:);
        plot_params.blc = 1;
    case 'ERSP'
        plot_params.legend = 'false';
        plot_params.textsize = 14;
        plot_params.xlabel = 'Time (s)';
        plot_params.ylabel = 'Freq (Hz)';
        plot_params.cmap = cbrewer2('RdBu');
        plot_params.cmap = plot_params.cmap(end:-1:1,:);
        plot_params.clim = [-2 2];
    case 'ITPC'
        plot_params.textsize = 16;
        plot_params.xlabel = 'Time (s)';
        plot_params.ylabel = 'Freq (Hz)';
        %         plot_params.cmap = cbrewer2('RdYlBu')
        plot_params.cmap = parula;
        %         plot_params.cmap = plot_params.cmap(end:-1:1,:);
        plot_params.clim = [0 0.4];
        plot_params.freq_range = [0 32];
    case 'RTCorr'
        plot_params.textsize = 20;
        plot_params.xlabel = 'Time (s)';
        plot_params.ylabel = 'Freq (Hz)';
        plot_params.cmap = cbrewer2('RdYlBu');
        plot_params.cmap = plot_params.cmap(end:-1:1,:);
        plot_params.clim = [0 0.3];
        plot_params.freq_range = [0 32];
        plot_params.norm = true;
    case 'ERP'
        plot_params.plot_slist = 0;
        plot_params.cmap = cbrewer2('RdBu');
        plot_params.xlabel = 'Time (s)';
        plot_params.textsize = 20;
        plot_params.col = [cdcol.ultramarine;
            cdcol.grass_green;
            cdcol.lilac;
            cdcol.yellow;
            cdcol.turquoise_blue];
end


switch task
    case 'MMR'
        plot_params.xlim = [-0.2 3];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.ultramarine;
            cdcol.yellow_green;
            cdcol.carmine;
            cdcol.turquoise_blue;
            cdcol.orange];
        plot_params.xlines = [];
    case 'IctalCognition'
        plot_params.xlim = [-0.5 2.3];
        plot_params.blc = true;
        plot_params.bl_win = [-0.5 0];
        plot_params.col = [
            cdcol.carmine;
            cdcol.turquoise_blue;
            cdcol.ultramarine;
            cdcol.yellow_green;
            cdcol.orange];
        plot_params.xlines = [];
    case 'IctalCognitionMas'
        plot_params.xlim = [-0.2 3];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.ultramarine;
            cdcol.carmine;
            cdcol.yellow_green;
            cdcol.lilac;
            cdcol.yellow;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
        plot_params.xlines = [];
    case 'LangLoc'
        plot_params.xlim = [-1 8];
        plot_params.col = [cdcol.ultramarine;
            cdcol.carmine];     
        
    case 'TOM'
        plot_params.xlim = [-10 2];
        plot_params.col = [cdcol.ultramarine;
            cdcol.carmine];   
        
    case 'UCLA'
        plot_params.xlim = [-0.2 3];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.ultramarine;
            cdcol.grass_green;
            cdcol.lilac;
            cdcol.yellow;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.pink;
            cdcol.carmine
            cdcol.apricot];
    case 'Calculia_production'
        plot_params.xlim = [-0.2 4];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
    case 'Memoria'
        plot_params.xlim = [-0.5 8.5];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.ultramarine, 
            cdcol.carmine;
            cdcol.pink];        
        plot_params.xlines = [];
        
    case 'Calculia'
        plot_params.xlim = [-0.2 6];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.carmine;
            cdcol.pink;
            cdcol.ultramarine;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
    case 'Context'
        plot_params.xlim = [-0.2 6];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.carmine;
            cdcol.pink;
            cdcol.ultramarine;
            cdcol.turquoise_blue;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
    case 'Calculia_China'
        plot_params.xlim = [-0.2 7];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = [cdcol.ultramarine;
            cdcol.grass_green;
            cdcol.lilac;
            cdcol.yellow;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
    case 'GradCPT'
        plot_params.xlim = [-0.5 1.6];
        plot_params.blc = false;
    case 'Number_comparison'
        plot_params.xlim = [-0.2 3];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col =  [[38 55 97]/255;
            [148 169 215]/255;
            [84 172 90]/255;
            [184 230 156]/255;
            cdcol.turquoise_blue;
            cdcol.flame_red;
            cdcol.periwinkle_blue;
            cdcol.pink;
            cdcol.purple];
        
        %         plot_params.col = parula(4);
        
    case 'EglyDriver'
        plot_params.xlim = [-0.2 2];
        plot_params.blc = true;
        plot_params.bl_win = [-0.2 0];
        plot_params.col = parula(5);
        
        
        %     case {'Scrambled', 'Logo', 'VTCLoc', 'SevenHeaven', 'ReadNumWord', 'AllCateg'}
        
    case 'Scrambled'
        plot_params.xlim = [-.5 2];
        plot_params.blc = true;
        plot_params.bl_win = [-0.5 0];
        plot_params.col = parula(8);
        
    case 'Logo'
        plot_params.xlim = [-.5 2];
        plot_params.blc = true;
        plot_params.bl_win = [-0.5 0];
        plot_params.col = parula(14);
        
    case 'SevenHeaven'
        plot_params.xlim = [-.250 2];
        plot_params.blc = true;
        plot_params.bl_win = [-0.250 0];
        plot_params.col = parula(5);
        
    case 'VTCLoc'
        plot_params.xlim = [-.250 1.5];
        plot_params.legend = false;
        plot_params.blc = true;
        plot_params.bl_win = [-0.250 0];
%         cols = hsv(16);
%         plot_params.col = cols;
        plot_params.col = [cdcol.indian_red;
            cdcol.raspberry_red;
            cdcol.marine_blue;
            cdcol.azurite_blue; cdcol.yellow];
%         plot_params.col(6,:) = cols(9,:);
%         plot_params.col(9,:) = cols(6,:);
%         plot_params.col(3,:) = cols(5,:);
%         plot_params.col(5,:) = cols(3,:);
    case 'AnimalLoc'
        plot_params.xlim = [-.1 0.3];
        plot_params.blc = true;
        plot_params.bl_win = [-0.250 0];
        plot_params.col = parula(6);
        
    case 'ReadNumWord'
        plot_params.xlim = [-.250 2];
        plot_params.blc = true;
        plot_params.bl_win = [-0.250 0];
        plot_params.col = parula(11);
        
    case 'AllCateg'
        plot_params.xlim = [-.250 2];
        plot_params.blc = true;
        plot_params.bl_win = [-0.250 0];
        plot_params.col = parula(11);
        
        
        %         plot_params.col = [cdcol.ultramarine;
        %             cdcol.grass_green
        %             cdcol.turquoise_blue;
        %             cdcol.flame_red;
        %             cdcol.periwinkle_blue;
        %             cdcol.pink;
        %             cdcol.purple];
        
end

plot_params.noise_method = 'trials'; %'trials','timepts', or 'none'
plot_params.ylim_min = 20; %'trials','timepts', or 'none'
plot_params.correct_label = 0;
% if eliminating trials or timepts, can select which algorithms are used to
% determine bad trials or timepts
plot_params.noise_fields_trials= {'bad_epochs_HFO','bad_epochs_raw_HFspike'}; % can combine any of the bad_epoch fields in data.trialinfo (will take union of selected fields)
plot_params.noise_fields_timepts= {'bad_inds_HFO','bad_inds_raw_HFspike'}; % can combine any of the bad_epoch fields in data.trialinfo (will take union of selected fields)
plot_params.lw = 3; % linewidth
plot_params.label = 'name';
plot_params.sm = 0.1;

plot_params.save = true;
plot_params.save_dir = [];

end
% plot_params.run_blc = true;


