%% plot mean pow in time

load('C:\Users\ratzbasky\Dropbox\copy Rachel\EEG reference back\Power_sw2comp_allSubj.mat');
load('C:\Users\ratzbasky\Dropbox\copy Rachel\EEG reference back\Power_nosw2comp_allSubj.mat');

%the x axis:
times2save = -400:20:1000; %0 to 1000 is cells 21:71


clear  cond1_meanFrex cond2_meanFrex cond3_meanFrex cond4_meanFrex
ch1= [25 26 27 62 63 64];
ch2= [37 38];
ch3= [10 11];
frx=1:4; %delat frex [1 4]; alpha frex [7 9]; theta frex [5 6]
    cond1_meanFrex=squeeze(mean(mean(Power_sw2ref_allSubj(:,ch3,frx,:),2),3));%subj*ch*frex*time
    cond2_meanFrex=squeeze(mean(mean(Power_nosw2ref_allSubj(:,ch3,frx,:),2),3));
    cond3_meanFrex=squeeze(mean(mean(Power_sw2comp_allSubj(:,ch3,frx,:),2),3));
    cond4_meanFrex=squeeze(mean(mean(Power_nosw2comp_allSubj(:,ch3,frx,:),2),3));
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
%xlim([12 53]);
%set(gca,'FontSize',14,'XTick',[12 22 32 42 52],'XTickLabel',...
  %0','200','400','600','800'});
  
% Set the remaining axes properties fot cue locked
xlim([21 72]);%x axes is time. present data starting from O (no-basline) until the end
set(gca,'FontSize',14,'XTick',[21 31 41 51 61 71],'XTickLabel',...
   {'0','200','400','600','800', '1000'});
xlabel('Time (ms)'), ylabel('Power (dB)')
title('FC1 FC3 theta power cue locked')
hold off