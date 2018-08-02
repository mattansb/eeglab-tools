clear all
clc;

load('C:\Users\ratzbasky\Dropbox\copy Rachel\EEG reference back\chanlocs.mat');
load('C:\Users\ratzbasky\Dropbox\copy Rachel\EEG reference back\EEG.times.mat');
load('C:\Users\ratzbasky\Dropbox\copy Rachel\EEG reference back\Power_sw2comp_allSubj.mat');
load('C:\Users\ratzbasky\Dropbox\copy Rachel\EEG reference back\Power_nosw2comp_allSubj.mat');

%cue locked data
times2save = -400:20:1000; %0 to 1000 is cells 21:71

%stim locked data
times2save(1,1:11) = -1600:20:-1400;
times2save(1,12:52) = 0:20:800; %corresponds to 12:52

min_freq = 2;
max_freq = 50;
num_frex = 15;
wavelet_cycles1= 3; 
wavelet_cycles2= 12; 
frex = logspace(log10(min_freq),log10(max_freq),num_frex);

%% topoplot before channel selection
frx=5:6; %delat frex [1 4]; alpha frex [7 9]; theta frex [5 6]
    cond1_power_meanFrex=squeeze(mean(mean(Power_sw2ref_allSubj(:,:,frx,31:71),4),3));%31:71 for cue locked
    cond2_power_meanFrex=squeeze(mean(mean(Power_nosw2ref_allSubj(:,:,frx,31:71),4),3));
    cond3_power_meanFrex=squeeze(mean(mean(Power_sw2comp_allSubj(:,:,frx,31:71),4),3));
    cond4_power_meanFrex=squeeze(mean(mean(Power_nosw2comp_allSubj(:,:,frx,31:71),4),3));

    clear meanCond_power meanCond_AvgSubj
    meanCond_power=(cond1_power_meanFrex+ cond2_power_meanFrex+ cond3_power_meanFrex+ cond4_power_meanFrex)/4;  
    meanCond_AvgSubj=squeeze(mean(meanCond_power,1)); 

figure (10)
topoplot(squeeze(meanCond_AvgSubj(1,1:64)),chanlocs,'plotrad',.53,'maplimits',[-0.5 0.5]);
title([ 'mean conditions theta, ' ' mean 200-1000 ms' ])

%%
% statistics via permutation testing
% number of permutations
numsubjects=35;
tp=length(times2save);

%important!!
%change the relevant cond in tf acording to the difference of interest

ch1= [25 26 27 62 63 64];
ch2= [38];
ch3= [10 11];

clear cond1 cond2 
%cond1=squeeze(mean(Power_sw2ref_allSubj(:,ch3,:,:),2));
%cond2=squeeze(mean(Power_nosw2ref_allSubj(:,ch3,:,:),2));
cond1=squeeze(mean(Power_sw2comp_allSubj(:,ch3,:,:),2)); 
cond2=squeeze(mean(Power_nosw2comp_allSubj(:,ch3,:,:),2));

clear tf
tf(1,:,:,:)=cond1; %one matrix for both conditions (permutation between conditions)
tf(2,:,:,:)=cond2;

clear diffmap_AvgSubj diffmap_Subj
diffmap_AvgSubj= squeeze(mean(tf(1,:,:,:),2)) - squeeze(mean(tf(2,:,:,:),2));
diffmap_subj= squeeze(tf(1,:,:,:)) - squeeze(tf(2,:,:,:));

%% next run the cluster permutation (F5 on the script)

%% now find clusters in the real difference map

clear h p stats
[h,p,ci,stats]=ttest(diffmap_subj,0); %take each pixal from all subjects (dimension 1)
h=squeeze(h);
tvals=squeeze(stats.tstat);
%find clusters (significant t-vals which are grouped) in each permuted TF.
%Note that you need to test seperatly significant positive and negative t-vals, if the prediction is two-tailed
clear sum_max_negCluster_real sum_max_posCluster_real
sig_tvals=tvals.*h; % Save all the significant t_values to sig_tvals

positive_tstat=sig_tvals>0;    % Find all positive significant values (logical)
positive_tstat=positive_tstat.*sig_tvals; % Save all the positive significant t_vals
negative_tstat=sig_tvals<0;    % Find all negative significant values (logical)
negative_tstat=negative_tstat.*sig_tvals; % Save all the negative significant t_vals
%negative_tstat(isnan(negative_tstat))=0;  % Replace all NaN with zeros

% find clusters with negative t-values in diff map

neg_islands = bwconncomp(negative_tstat); %find clusters of negative t-vals

if numel(neg_islands.PixelIdxList)>0 % Check if there are any clusters
    neg_tempclustsizes = cellfun(@length,neg_islands.PixelIdxList); % count sizes of negative clusters
    % store the sum of t-vals of all cluster
    for ii=1:length(neg_tempclustsizes)
        indx_max_neg_clus=neg_islands.PixelIdxList{1,ii};  % indices of cluster
        temp=squeeze(negative_tstat); % Sum of the T values of cluster
        temp=temp(indx_max_neg_clus);
        sum_max_negCluster_real(ii,1)=sum(temp);
        
    end
end

% find clusters with positive t-values in diff data

pos_islands = bwconncomp(positive_tstat); %find clusters of negative t-vals

if numel(pos_islands.PixelIdxList)>0 % Check if there are any clusters
    pos_tempclustsizes = cellfun(@length,pos_islands.PixelIdxList); % count sizes of positive clusters
    % store the sum of t-vals of all clusters
    for ii=1:length(pos_tempclustsizes)
        indx_max_pos_clus=pos_islands.PixelIdxList{1,ii};  % indices of the largest cluster
        temp=squeeze(positive_tstat); % Sum of the T values of the largest cluster
        temp=temp(indx_max_pos_clus);
        sum_max_posCluster_real(ii,1)=sum(temp);
    end
    
end

% plot
clear sigTmap sigmap
sigTmap = positive_tstat + negative_tstat; %all the significant t-values

%find all the t-values which are smaller than the threshold and set them to zero
for i=1:length(sum_max_negCluster_real)
    % if real clusters are too small, remove them by setting to zero!
    if abs(sum_max_negCluster_real(i))<abs(neg_cluster_thresh)
        sigTmap(neg_islands.PixelIdxList{i})=0;
    end
end

for i=1:length(sum_max_posCluster_real)
    % if real clusters are too small, remove them by setting to zero!
    if sum_max_posCluster_real(i)<pos_cluster_thresh
        sigTmap(pos_islands.PixelIdxList{i})=0;
    end
end
%sigTmap saves the location of significant pixels but with thier t-values 
%sigmap saves the power of significant pixels
sigmap=logical(sigTmap).*diffmap_AvgSubj;

%% plot cue locked
figure(11)
subplot(221)
contourf(times2save,frex,diffmap_AvgSubj,40,'linecolor','none')
set(gca,'ytick',round(logspace(log10(frex(1)),log10(frex(end)),10)*100)/100,'yscale','log','xlim',[-400 1000],'clim',[-0.5 0.5])
xlabel('Time (ms)'), ylabel('Frequency (Hz)')
title('gate opening FC1 FC3 cue locked') %switch cost reference cue locked
subplot(222)
contourf(times2save,frex,sigmap,40,'linecolor','none')
set(gca,'ytick',round(logspace(log10(frex(1)),log10(frex(end)),10)*100)/100,'yscale','log','xlim',[-400 1000],'clim',[-0.5 0.5])
xlabel('Time (ms)'), ylabel('Frequency (Hz)')
title('significant cluster')
subplot(222)
contourf(times2save,frex,diffmap_AvgSubj,40,'linecolor','none')
hold on
contour(times2save,frex,logical(sigTmap),1,'linecolor','w','linewidth',2)
%contour(times2save,frex,logical(sigmap),1,'linecolor','k')
set(gca,'ytick',round(logspace(log10(frex(1)),log10(frex(end)),10)*100)/100,'yscale','log','xlim',[-400 1000],'FontSize',14,'clim',[-0.5 0.5])
%set(gca,'clim',[-0.5 0.5],'xlim',xlim,'ydir','normal')
xlabel('Time (ms)'), ylabel('Frequency (Hz)')
title('ref-comp occipital area cue locked')

%% plot mean pow in time

clear  cond1_meanFrex cond2_meanFrex cond3_meanFrex cond4_meanFrex
ch1= [25 26 27 62 63 64];
ch2= [37 38];
ch3= [10 11];
frx=1:4; %delat frex [1 4]; alpha frex [7 9]; theta frex [5 6]
    cond1_meanFrex=squeeze(mean(mean(Power_sw2ref_allSubj(:,ch1,frx,:),2),3));%subj*ch*frex*time
    cond2_meanFrex=squeeze(mean(mean(Power_nosw2ref_allSubj(:,ch1,frx,:),2),3));
    cond3_meanFrex=squeeze(mean(mean(Power_sw2comp_allSubj(:,ch1,frx,:),2),3));
    cond4_meanFrex=squeeze(mean(mean(Power_nosw2comp_allSubj(:,ch1,frx,:),2),3));
%data(1,:)=squeeze(mean(cond1_meanFrex,1));
%data(2,:)=squeeze(mean(cond2_meanFrex,1));
%data(3,:)=squeeze(mean(cond3_meanFrex,1));
%data(4,:)=squeeze(mean(cond4_meanFrex,1));


clear data 
for ii=1:length(times2save)
data(1,:)=squeeze(cond1_meanFrex(:,ii));
data(2,:)=squeeze(cond2_meanFrex(:,ii));
data(3,:)=squeeze(cond3_meanFrex(:,ii));
data(4,:)=squeeze(cond4_meanFrex(:,ii));

[p,tbl] = anova1(data);
close all hidden
MSerror_lowtheta(1,ii)=tbl(3,4);%save only the MSE from the anova table

end
MSerror_lowtheta=cell2mat(MSerror_lowtheta);%convert cell to double

n=length(times2save);
CI=sqrt(MSerror_lowtheta/n)*tinv( 0.975,n-1);%calculate confidence interval

mean_cond1=mean(cond1_meanFrex);
%std_cond1=std(cond1_meanFrex);
mean_cond2=mean(cond2_meanFrex);
%std_cond2=std(cond2_meanFrex);
mean_cond3=mean(cond3_meanFrex);
%std_cond3=std(cond3_meanFrex);
mean_cond4=mean(cond4_meanFrex);
%std_cond4=std(cond4_meanFrex);

mean_data=(mean_cond1+mean_cond2+mean_cond3+mean_cond4)/4;
mean(mean_data)
% Make the plot
x=[1:n];

figure (8)
shadedErrorBar(x,mean_cond1,CI,'lineprops','k'); 
hold on
shadedErrorBar(x,mean_cond2,CI,'lineprops','g'); 
hold on
shadedErrorBar(x,mean_cond3,CI,'lineprops','r');
hold on
shadedErrorBar(x,mean_cond4,CI,'lineprops','b');
 
% Set the remaining axes properties fot stim locked
xlim([12 53]);
set(gca,'FontSize',14,'XTick',[12 22 32 42 52],'XTickLabel',...
 {'0','200','400','600','800'});
% Set the remaining axes properties fot cue locked
%xlim([21 72]);%x axes is time. present data starting from O (no-basline) until the end
%set(gca,'FontSize',14,'XTick',[21 31 41 51 61 71],'XTickLabel',...
 %  {'0','200','400','600','800', '1000'});
xlabel('Time (ms)'), ylabel('Power (dB)')
title('occipital low-theta power probe locked')
hold off





