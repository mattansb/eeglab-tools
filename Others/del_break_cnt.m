
function EEG = del_break_cnt(EEG)



strcmpi('break cnt',{EEG.event.type}));

bads = round(bads);
EEG = eeg_eegrej(EEG, bads); % rejects in samples
end