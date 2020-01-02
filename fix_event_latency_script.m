% this is a script for converting 'latency' of events from human time scale,
% to whatever the f@&k eeglab uses, in UNEPOCKED data

% load eeglab and your data
eeglab
EEG = pop_loadset();

% assuming original latencies are stored in EEG.event.latency,
% **which is also where the new ones need to be** - so we will first back them up.
[EEG.event.ur_times] = deal(EEG.event.latency);

% what is the time scale of your original time-data?
t_scale = 1;     % s
t_scale = 0.001; % ms... etc - you get the idea.

% convert:
temp_times = eeg_lat2point([EEG.event.ur_times], 1, EEG.srate, EEG.times([1 end]), t_scale);
% also see 'help eeg_lat2point'

% do some weird a$$ $h*t for Matlab...
temp_times = num2cell(temp_times);          % f@&k Matlab 1.
[EEG.event.latency] = deal(temp_times{:});  % f@&k Matlab 2.


% BONUS: see if it worked:
EEG = pop_epoch(EEG, {'10', '11'}, [-0.5 1], 'epochinfo', 'yes'); % epoch the data
pop_eegplot( EEG, 1, 1, 1);                                       % plot it
