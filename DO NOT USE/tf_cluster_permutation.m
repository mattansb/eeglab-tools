tic
clear sum_max_negCluster sum_max_posCluster permmaps
n_permutes=1000;
pval=0.05;
numsubjects=35;
tp=length(times2save);
num_frex=15;
sum_max_negCluster=zeros(n_permutes,1);
sum_max_posCluster=zeros(n_permutes,1);
permmaps=zeros(numsubjects,num_frex,tp);


for permi = 1:n_permutes
   % disp(permi);
    for s=1:numsubjects
        
        randorder = randperm(2);
        
        % refute the "difference" map
        % what is the difference under the null hypothesis?
        permmaps(s,:,:)= squeeze(tf(randorder(1),s,:,:)) - squeeze(tf(randorder(2),s,:,:));
    end
    
    [h_perm,p_perm,ci,stats_perm]=ttest(permmaps,0, 'Dim',1); %take each pixal from all subjects (dimension 2)
    h_perm=squeeze(h_perm);
    tvals_perm=squeeze(stats_perm.tstat);
    sig_tvals_perm=tvals_perm.*h_perm;
    
    % Calculation of negative clusters %
    % -------------------------------- %
    
    negative_perm_tstat=sig_tvals_perm<0;    % Find all negative significant values (logical)
    negative_perm_tstat=negative_perm_tstat.*sig_tvals_perm; % Save all the negative significant t_vals
    neg_islands_perm = bwconncomp(negative_perm_tstat); %find clusters of negative t-vals
    
    if numel(neg_islands_perm.PixelIdxList)>0 % Check if there are any clusters
        neg_tempclustsizes_perm = cellfun(@length,neg_islands_perm.PixelIdxList); % count sizes of negative clusters
        % store the sum of t-vals of biggest negative cluster
        clear v1 % v1 is the index of the biggest negative island
        v1 = find(neg_tempclustsizes_perm==max(neg_tempclustsizes_perm), 1, 'last' );
        % In case there are clusters of the same size, the 'last' cluster is chosen
        indx_max_neg_clus=neg_islands_perm.PixelIdxList{1,v1};  % Indices of the largest cluster
        temp=squeeze(negative_perm_tstat); % Sum of the T values of the largest cluster
        temp=temp(indx_max_neg_clus);
        sum_max_negCluster(permi,1)=sum(temp);
    end
    
    % Calculation of positive clusters %
    % -------------------------------- %
    
    positive_perm_tstat=sig_tvals_perm>0;    % Find all positive significant values (logical)
    positive_perm_tstat=positive_perm_tstat.*sig_tvals_perm; % Save all the positive significant t_vals
    positive_perm_tstat(isnan(positive_perm_tstat))=0;  % Replace all NaN with zeros
    pos_islands_perm = bwconncomp(positive_perm_tstat); %find clusters of positive t-vals
    
    if numel(pos_islands_perm.PixelIdxList)>0 % Check if there are any clusters
        pos_tempclustsizes_perm = cellfun(@length,pos_islands_perm.PixelIdxList); % count sizes of positive clusters
        % store the sum of t-vals of biggest positive cluster
        clear v2 % v2 is the index of the biggest positive island
        v2 = find(pos_tempclustsizes_perm==max(pos_tempclustsizes_perm), 1, 'last' );
        % In case there are clusters of the same size, the 'last' cluster is chosen
        indx_max_pos_clus=pos_islands_perm.PixelIdxList{1,v2};  % Indices of the largest cluster
        temp=squeeze(positive_perm_tstat); % Sum of the T values of the largest cluster
        temp=temp(indx_max_pos_clus);
        sum_max_posCluster(permi,1)=sum(temp);
    end
  
end  

% find cluster threshold (need image processing toolbox for this!)
% based on p-value and null hypothesis distribution
%cluster_thresh = prctile(max_cluster_sizes,100-(100*pval));
pos_cluster_thresh = prctile(sum_max_posCluster,100-(100*pval))
neg_cluster_thresh = prctile(sum_max_negCluster,(100*pval))

toc