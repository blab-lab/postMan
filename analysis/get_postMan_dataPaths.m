function dataPaths = get_postMan_dataPaths(bTstep)
if isempty(bTstep) || nargin < 1, bTstep = 0; end
allPaths = struct;

[allPaths.NoisyNoisyfb, allPaths.NormalNoisyfb] = get_dataPaths_noisyfb; %noisyfb
[~, reachAndSpeech, svec] = get_dataPaths_reachAndSpeech; %reachAndSpeech
allPaths.reachAndSpeech = reachAndSpeech((contains(svec, 'OA'))& (~contains(svec, '8'))&(~contains(svec, '14'))); %14 outlier
allPaths.fmtAlt = get_dataPaths_fmtAlt([0 4 5 8 10 11 12 14 15 16 18 20 21 22 24], 'postMan'); 
allPaths.cat = get_dataPaths_cat([12 14 15 20 21 24 28 38 45 52 58], 'postMan');%  
allPaths.cereb = get_dataPaths_cereb([1 2 3 4 5 7 9 10 13 14 15 16 17], 'random'); %8

if bTstep
    allPaths.cat = get_dataPaths_cat([12 14 15 20 21 24 28 38 45 52 58], 'postMan', 'tstep_003');% 
end

dataPaths = [allPaths.NoisyNoisyfb allPaths.NormalNoisyfb allPaths.reachAndSpeech allPaths.fmtAlt allPaths.cat allPaths.cereb]