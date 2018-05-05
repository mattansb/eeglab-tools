%{
due to smoothing, TRUE baseline should start at ~200ms. (e.g. -400--200)
in addition to that, add 3 cycels of the lowest relevant frequency before
baseline and after end of epoch - buffer zone. (see page 76 in the book).

when cleaning, no need to clean the buffer zone.
%}


%% create G and H matrices 
% compute inter-electrode distances
interelectrodedist=zeros(EEG.nbchan);
for chani=1:EEG.nbchan
    for chanj=chani+1:EEG.nbchan
        interelectrodedist(chani,chanj) = sqrt( (EEG.chanlocs(chani).X-EEG.chanlocs(chanj).X)^2 + (EEG.chanlocs(chani).Y-EEG.chanlocs(chanj).Y)^2 + (EEG.chanlocs(chani).Z-EEG.chanlocs(chanj).Z)^2);
    end
end

valid_gridpoints = find(interelectrodedist);

% extract XYZ coordinates from EEG structure
X = [EEG.chanlocs.X];
Y = [EEG.chanlocs.Y];
Z = [EEG.chanlocs.Z];

% create G and H matrices
[~,G,H] = laplacian_perrinX(rand(size(X)),X,Y,Z,[],1e-6);
% what is this for?

%% spatial filter laplacian

EEG.data = laplacian_perrinX(EEG.data,X,Y,Z,[],1e-5); 
% note: the smoothing parameter above (last input argument)is the lambda parameter. 
% Reasonable values are 1e-4 to 1e-6, and the default parameter is 1e-5.

%% Wavlet
tic
freq_range      = [1 95];
num_frex        = 50;
cycles_range    = [3 20];
baselinetime    = [-200 0];
times_power     = [];
times_phase     = [];
[dbconverted,itpc,frex,times_power,times_phase] = wavelet_conv(EEG,freq_range,num_frex,cycles_range,baselinetime,times_power,times_phase);
toc

%% Plot
ytick   = round(logspace(log10(frex(1)),log10(frex(end)),10)*100)/100;
tlim    = [-200 600];

plot_data = squeeze(dbconverted(1,:,:));
contourf(times_power,frex,plot_data,40,'linecolor','none')
xlabel('Time (ms)'), ylabel('Frequency (Hz)')
set(gca,'ytick',ytick,'yscale','log','xlim',tlim,'clim',[-3.0 3.0])

plot_data = squeeze(itpc(1,:,:));
contourf(times_phase,frex,plot_data,40,'linecolor','none')
xlabel('Time (ms)'), ylabel('Frequency (Hz)') % ?????
set(gca,'ytick',ytick,'yscale','log','xlim',tlim,'clim',[0 0.2])
