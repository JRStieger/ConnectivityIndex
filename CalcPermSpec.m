function [specReturn,sig_struct] = CalcPermSpec(ersp,time_vec,calc_lims,freqs,cfg)

valid_height = find(~isnan(squeeze(ersp(:,10,100))));
ersp = ersp(valid_height,:,:);
zero_ind = find((time_vec <= calc_lims(1)) | (time_vec >= calc_lims(2)));
ersp_tmp = ersp;
ersp_tmp(:,:,zero_ind) = 0;
%get observed values
[h,p,confi,stats] = ttest(ersp_tmp);
alpha = cfg.alpha;
sig_spots_pos = squeeze(p<alpha & stats.tstat > 0);
se = strel('disk',3,6);
sig_spots_pos = imopen(sig_spots_pos,se);
CC_pos = bwconncomp(sig_spots_pos);

sig_spots_neg = squeeze(p<alpha & stats.tstat < 0);
se = strel('disk',3,6);
sig_spots_neg = imopen(sig_spots_neg,se);
CC_neg = bwconncomp(sig_spots_neg);

CC = CC_pos;
CC.PixelIdxList = cat(2,CC_pos.PixelIdxList,CC_neg.PixelIdxList);
CC.NumObjects = size(CC.PixelIdxList,2);

thresh = 150;
nperm = cfg.nperm;
con_spots = find(cell2mat(cellfun(@(x) length(x), CC.PixelIdxList,'UniformOutput',0))>thresh);

if isempty(con_spots)
    specReturn = [];
    sig_struct = [];
    return
end

sig_struct.PixelIdxList = CC.PixelIdxList(con_spots);
sig_struct.t_obs = zeros(length(con_spots),1);
sig_struct.p_obs = zeros(length(con_spots),1);

t_obs_spec = squeeze(stats.tstat);
for c = 1:length(con_spots)
    sig_struct.t_obs(c) = sum(t_obs_spec(CC.PixelIdxList{con_spots(c)}));
end

maxt_perm = zeros(1,nperm);
mint_perm = zeros(1,nperm);
tic
parfor r = 1:nperm
    r
    rand_dat = zeros(size(ersp));
    
    for sub = 1:height(ersp)
        f_ind = circshift(1:size(ersp,2),randi(size(ersp,2)));
        t_ind = circshift(1:size(ersp,3),randi(size(ersp,3)));
        rand_dat(sub,:,:) = ersp(sub,f_ind,t_ind);
    end
    
    %null out extra indexes
    rand_dat(:,:,zero_ind) = 0;
    
    %compute t stats
    [h,p_rand,confi,stats_rand] = ttest(rand_dat);
    
    sig_spots_rand_pos = squeeze(p_rand<alpha & stats_rand.tstat > 0);
    sig_spots_rand_pos = imopen(sig_spots_rand_pos,se);
    CC_rand_pos = bwconncomp(sig_spots_rand_pos);

    sig_spots_rand_neg = squeeze(p_rand<alpha & stats_rand.tstat < 0);
    sig_spots_rand_neg = imopen(sig_spots_rand_neg,se);
    CC_rand_neg = bwconncomp(sig_spots_rand_neg);
    
    CC_rand = CC_rand_pos;
    CC_rand.PixelIdxList = cat(2,CC_rand_pos.PixelIdxList,CC_rand_neg.PixelIdxList);
    CC_rand.NumObjects = size(CC_rand.PixelIdxList,2);
    
    con_spots_rand = find(cell2mat(cellfun(@(x) length(x), CC_rand.PixelIdxList,'UniformOutput',0))>thresh);
    
    if isempty(con_spots_rand)
        continue
    end
    
    t_rand_spec = squeeze(stats_rand.tstat);
    t_rand = zeros(length(con_spots_rand),1);
    for c = 1:length(con_spots_rand)
        t_rand(c) = sum(t_rand_spec(CC_rand.PixelIdxList{con_spots_rand(c)}));
    end
    
    maxt_perm(r) = max(t_rand);
    mint_perm(r) = min(t_rand);
    
end%for permutation
toc
valid_sig = zeros(length(con_spots),1);
for c = 1:length(con_spots)
    if sig_struct.t_obs(c) > 0
        p_obs = sum(maxt_perm > sig_struct.t_obs(c))/nperm;
    else
        p_obs = sum(mint_perm < sig_struct.t_obs(c))/nperm;
    end
    sig_struct.p_obs(c) = p_obs;
    if p_obs < (alpha/cfg.ncorrect)
        valid_sig(c) = 1;
    end
    
end

valid_sig = find(valid_sig);

if isempty(valid_sig)
    specReturn = [];
end

sig_struct.PixelIdxList = sig_struct.PixelIdxList(valid_sig);
sig_struct.t_obs = sig_struct.t_obs(valid_sig);
sig_struct.p_obs = sig_struct.p_obs(valid_sig);

%get bounding box
time_mat = repmat(time_vec,length(freqs),1);
freq_mat = repmat(freqs',1,length(time_vec));
freq_mat_ind = repmat((1:length(freqs))',1,length(time_vec));
time_lims = zeros(length(valid_sig),2);
freq_lims = zeros(length(valid_sig),2);
rec_lims = zeros(length(valid_sig),4);

specReturn = zeros(size(sig_spots_pos));
for c= 1:length(valid_sig)
    %freq_lims
    tmp_freq = freq_mat(sig_struct.PixelIdxList{c});
    freq_lims(c,:) = [min(tmp_freq),max(tmp_freq)];
    %time_lims
    tmp_time = time_mat(sig_struct.PixelIdxList{c});
    time_lims(c,:) = [min(tmp_time),max(tmp_time)];
    %bounding box
    %freq_ind_lims
    tmp_freq = freq_mat_ind(sig_struct.PixelIdxList{c});
    tmp_lims = [min(tmp_freq),max(tmp_freq)];
    rec_lims(c,:) = [time_lims(c,1),...
        tmp_lims(1),...
        time_lims(c,2)-time_lims(c,1),...
        tmp_lims(2)-tmp_lims(1)];
    %significance mat
    specReturn(sig_struct.PixelIdxList{c}) = 1;
    
end

sig_struct.freq_lims = freq_lims;
sig_struct.time_lims = time_lims;
sig_struct.rectangle = rec_lims;

end