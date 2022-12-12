function [ITPC] = ITPC_CellFun_raw(chan1_dat)

%calculate ITPC
phase_exp = exp(1i.*(chan1_dat));
ITPC = abs(nanmean(phase_exp,1));

end