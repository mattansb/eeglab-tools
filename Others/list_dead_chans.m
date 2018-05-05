% PURPOSE:  create a list of dead channels.
%
% FORMAT
% ------
% eleclist = list_dead_chans(EEG,thresh,ZP,val)
%
%
% INPUTS
% ------
% EEG       - EEGLAB data set
% thresh    - lower change threshhold (default - 0)
% ZP        - 'p', will list channels that have this val-percent of no
%             change or less. 'z', will list channels that are 'val' SDs
%             bellow the mean (compared to all other channels).
%
%
% OUTPUT
% ------
% eleclist  - cell list of channel labels
%
%
% Author: Mattan S. Ben Shachar, BGU, Israel

%{
Change log:
-----------
10-05-2017  New function (written in MATLAB R2015a)
%}

function eleclist = list_dead_chans(EEG,thresh,ZP,val)

switch lower(ZP)
    case 'z'
        if val < 0, error('z must be positive.'); end
    case 'p'
        if val < 0 || val > 1, error('p must be: 0 < p < 1'); end
end

if isempty(thresh)
    thresh = 0;
end

%% Compute ~Derivative~

% get diff
diff_data = diff(EEG.data,1,2);

% reshape data
dim1 = size(diff_data,1);
dim2 = size(diff_data,2)*size(diff_data,3);
data2dim = reshape(diff_data,dim1,dim2);

% get percentile of 0's
zero_more = sum(abs(data2dim) > thresh,2)/size(data2dim,2);

% hist(zero_more)

%% List channels

switch lower(ZP)
    case 'p'
        chan_ind = zero_more<val;
    case 'z'
         chan_ind = zscore(zero_more) > -val;
end


eleclist = {EEG.chanlocs(chan_ind).labels};
end