function [] = calc_hz2mels_postMan(dataPath, expt)

%load data from gen_fdata
load(fullfile(dataPath, 'fdata_cond.mat'));
if nargin <2 | isempty(expt), load(fullfile(dataPath, 'expt.mat'), 'expt'); end 

%get basecond
fields = fieldnames(fmtdata.hz);
basecond = char(fields(contains(fields, 'no', 'IgnoreCase', true)));

%get medians
f1MedianHz = fmtdata.hz.(basecond).mid50p.med.f1;
f2MedianHz = fmtdata.hz.(basecond).mid50p.med.f2;
f1MedianMel = fmtdata.mels.(basecond).mid50p.med.f1;
f2MedianMel = fmtdata.mels.(basecond).mid50p.med.f2;
%apply shift
if isfield(expt, 'name') && (strcmp(expt.name, 'fmtAlt')|~isfield(expt, 'name'))
    if length(expt.shifts.hz) > 2
        shifts = [expt.shifts.hz{2}(1), expt.shifts.hz{3}(1)];
    else
        shifts = [expt.shifts.hz{1}(1), expt.shifts.hz{2}(1)];
    end
    f1ShiftedUp = hz2mel(f1MedianHz + shifts(shifts > 0));
    f1ShiftedDown = hz2mel(f1MedianHz + shifts(shifts < 0));
    f2ShiftedUp = hz2mel(f2MedianHz + shifts(shifts > 0));
    f2ShiftedDown = hz2mel(f2MedianHz + shifts(shifts < 0));
    
    hzUp = shifts(shifts>0);
    hzDown = shifts(shifts<0);
    expt.shifts = rmfield(expt.shifts, 'hz');
else
    f1ShiftedUp = hz2mel(f1MedianHz + expt.shifts.shiftUp(1));
    f2ShiftedUp = hz2mel(f2MedianHz + expt.shifts.shiftUp(2));
    f1ShiftedDown = hz2mel(f1MedianHz + expt.shifts.shiftDown(1));
    f2ShiftedDown = hz2mel(f2MedianHz + expt.shifts.shiftDown(2));
    
    hzUp = expt.shifts.shiftUp;
    hzDown = expt.shifts.shiftDown;
end

%get mel shift
f1MelShiftUp = f1ShiftedUp - f1MedianMel;
f2MelShiftUp = f2ShiftedUp - f2MedianMel;
f1MelShiftDown = f1ShiftedDown - f1MedianMel;
f2MelShiftDown = f2ShiftedDown - f2MedianMel;

%put into expt file
%store hz info
%want to replace current shift fields with mel / hz fields
expt.shifts.mels{1} = [f1MelShiftUp, f2MelShiftUp];
expt.shifts.mels{2} = [f1MelShiftDown, f2MelShiftDown];
expt.shifts.hz.shiftUp = hzUp;
expt.shifts.hz.shiftDown = hzDown;
%remove old
%expt.shifts = rmfield(expt.shifts, 'shiftUp');
%expt.shifts = rmfield(expt.shifts, 'shiftDown');

save(fullfile(dataPath,'expt.mat'),'expt');

