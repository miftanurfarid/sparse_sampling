%% makedataparams: generate dataparams struct

dataparams.G = length(Tx1)*length(Rx1);
dataparams.g = repmat((1:dataparams.G),2,1);
dataparams.gpos = repmat([Tx1; Rx1]',2,1);
dataparams.nmax = 600;
dataparams.TM = randn(600,600);
dataparams.keepsamples = 