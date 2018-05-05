% EEG           - eeglab data struct (will compute for all channels)
% freq_range    - [min max] frequency (Hz) range to compute
% num_frex      - number of frequencies to compute (NOTE: will be]
%                 log-scaled).
% cycles_range  - [min max] range of cycels to use for range of
%                 frequencies.
% baselinetime  - [start end] baseline (in ms) for dB correction
% times_power   - vector of time (in ms) indicating the time points of
%                 power to save (for down sampling, or removing buffer
%                 zone). If empty, will save all time points. 
% times_phase   - vector of time (in ms) indicating the time points of
%                 phase (ITC) to save (for down sampling, or removing
%                 buffer zone). If empty, will use the same as
%                 times_ds_power.

function [dbconverted,itpc,frex,times_power,times_phase] = wavelet_conv(EEG,freq_range,num_frex,cycles_range,baselinetime,times_power,times_phase)

nbchan = size(EEG.data,1); % number of channels

%% Define Wavelet parameters

min_freq        = freq_range(1);    % min freq to compute
max_freq        = freq_range(2);    % max freq to compute
num_frex        = num_frex;         % number of frex to compute
wavelet_cycles1 = cycles_range(1);  % for min freq
wavelet_cycles2 = cycles_range(2);  % for max freq

% Length of wavelet in seconds (p. 167-168)
time    = -2:1/EEG.srate:2;

% Frequencies (Hz) & number of cycles for each (p. 168, 196) - LOG-SCALED
frex    = logspace(log10(min_freq),log10(max_freq),num_frex);
cyc     = logspace(log10(wavelet_cycles1),log10(wavelet_cycles2), num_frex)./(2*pi*frex); 

%% Power & ITPC

% Definte convolution parameters:
n_wavelet            = length(time);
n_data               = EEG.pnts*EEG.trials;
n_convolution        = n_wavelet+n_data-1;
n_conv_pow2          = pow2(nextpow2(n_convolution));
half_of_wavelet_size = (n_wavelet-1)/2;


% initialize
eegfft      = zeros(nbchan,n_conv_pow2);
itpc        = zeros(nbchan,length(frex),EEG.pnts);
eegpower    = zeros(nbchan,num_frex,EEG.pnts); % elec X frequencies X time
dbconverted = zeros(nbchan,num_frex,EEG.pnts);


% get FFT of data
for ch = 1:nbchan % each channel
    eegfft(ch,:) = fft(reshape(EEG.data(ch,:,:),1,EEG.pnts*EEG.trials),n_conv_pow2);
end


% Loop through frequencies and compute synchronization
fprintf('Computing power and coherence... ');
for ch = 1:nbchan % each channel
    for fi = 1:num_frex % each freq
        try fprintf(repmat('\b',[1 pp])); end
        pp = fprintf('%1$d%%',round(((ch-1)*num_frex+fi)*100/(num_frex*nbchan)));
        
        % Create Wavelet for current frequency
        wavelet = fft( sqrt(1/(cyc(fi)*sqrt(pi))) * exp(2*1i*pi*frex(fi).*time) .* exp(-time.^2./(2*(cyc(fi)^2))) , n_conv_pow2 );

        % Perform convolution
        eegconv = ifft(wavelet.*eegfft(ch,:));
        eegconv = eegconv(1:n_convolution);
        eegconv = eegconv(half_of_wavelet_size+1:end-half_of_wavelet_size);

        % Average power over trials 
        temppower           = mean(abs(reshape(eegconv,EEG.pnts,EEG.trials)).^2,2);
        eegpower(ch,fi,:)   = temppower;

        % extract ITPC
        eegconv_ITPC    = reshape(eegconv,EEG.pnts,EEG.trials);
        temp_ITPC       = abs(mean(exp(1i*angle(eegconv_ITPC)),2));
        itpc(ch,fi,:)   = temp_ITPC;
    end
end
fprintf([repmat('\b',[1 pp]) 'done! '])

%% dB correction
% correction is preformed compared to baseline

% convert baseline window time to indices
[~,baselineidx(1)] = min(abs(EEG.times-baselinetime(1)));
[~,baselineidx(2)] = min(abs(EEG.times-baselinetime(2)));

% dB-correct
fprintf('\nConverting power to dB... ');
for ch = 1:nbchan % each channel
    temp_pow            = reshape(eegpower(ch,:,:),num_frex,EEG.pnts);
    baseline_power      = mean(temp_pow(:,baselineidx(1):baselineidx(2)),2);    % mean power in baseline
    dbtemp              = 10*log10( bsxfun(@rdivide,temp_pow,baseline_power));  % convert to dB
    dbconverted(ch,:,:) = dbtemp(:,:); 
end
fprintf('done! ');


%% Save selected time points
% Downsample the data, or remove buffer-zone segments.
fprintf('\nSaving... ');
if isempty(times_power)
    times_power = EEG.times;
end

if isempty(times_phase)
    times_phase = times_power;
end

% Save POWER
timesidx_power	= dsearchn(EEG.times',times_power');
dbconverted     = dbconverted(:,:,timesidx_power);

% Down Sample (sd) PHASE
timesidx_phase  = dsearchn(EEG.times',times_phase');
itpc            = itpc(:,:,timesidx_phase);

fprintf('DONE.\n')
end

