% PURPOSE:  Fix event offset
%
% 
% FORMAT
% ------
% EEG = fix_event_offset(EEG,events,offset)
% 
%
% INPUTS
% ------
%   EEG         - input dataset
%   events      - A cell list of event types.
%   offset      - the offset (in ms). Can be positive or negative.
%
%
% OUTPUTS:
% --------
%   EEG - dataset with converted EEG.event latencies and init_time.
%
%
% Author: Mattan S. Ben Shachar, BGU, Israel

%{
Change log:
-----------
08-05-2018  New function written in MatlabR2017a
%}
function EEG = fix_event_offset(EEG,events,offset)

ossamps = ceil(offset/(1000/EEG.srate));

event_ind = cellfun(@(x) any(strcmpi(x,events)),{EEG.event.type})';

new_init_time   = num2cell([EEG.event(event_ind).init_time] + offset);
new_latency     = num2cell([EEG.event(event_ind).latency] + ossamps);

[EEG.event(event_ind).init_time]    = new_init_time{:};
[EEG.event(event_ind).latency]      = new_latency{:};

EEG = eeg_checkset(EEG);

end