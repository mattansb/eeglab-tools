function perm_ttest(X1,X2,varargin)

X1 = rand(30,350,128);
X2 = rand(30,350,128);

p = inputParser;
    addRequired(p,'X1',@isnumeric);
    addRequired(p,'X2',@isnumeric);
    addParameter(p,'n_permutes', 1000, @isnumeric);
    addParameter(p,'n_groups', 2, @(X) any(X==[2,1]));
    addParameter(p,'pval', 0.05, @(X) X > 0 & X < 1);
    addParameter(p,'side', 0, @(X) any(X==[-1,0,1]));
parse(p ,X1, X2, varargin{:});

n_groups    = p.Results.n_groups;
n_permutes  = p.Results.n_permutes;
pval        = p.Results.pval;
side        = p.Results.side;

%% Prep

map_size = size(X1);
map_size = map_size(2:end);

sum_negCluster = zeros(n_permutes,1);
sum_posCluster = zeros(n_permutes,1);
permmaps = zeros(map_size);

%% Permutate

for pi = 1:n_permutes
    if n_groups==1
        % Permutate data
        p_data = (X1 - X2).*datasample([-1 1],size(X1,1))';
        
        % Test permutated data
        [h_perm, ~, ~, stats_perm] = ttest(p_data,0,'Dim',1);
    else
        % Permutate data
        p_data = cat(1,X1,X2);
        p_X1 = p_data(datasample(1:size(X1,1),size(X1,1)),:,:);
        p_X2 = p_data(datasample(1:size(X2,1),size(X2,1)),:,:);
        
        % Test permutated data
        [h_perm, ~, ~, stats_perm] = ttest2(p_X1,p_X2,'Dim',1);
    end
    
    % Find clusters
    h_perm          = squeeze(h_perm);
    sig_tvals_perm  = squeeze(stats_perm.tstat).*h_perm;
    
    % Calculation of negative clusters
    % --------------------------------
    negative_perm_tstat = sig_tvals_perm < 0;                     % Find all negative significant values (logical)
    negative_perm_tstat = negative_perm_tstat .* sig_tvals_perm;  % Save all the negative significant t_vals
    sum_negCluster(pi)  = sum_max_cluster_t(negative_perm_tstat);
    
    % Calculation of positive clusters %
    % -------------------------------- %
    positive_perm_tstat = sig_tvals_perm > 0;                     % Find all negative significant values (logical)
    positive_perm_tstat = positive_perm_tstat .* sig_tvals_perm;  % Save all the negative significant t_vals
    sum_posCluster(pi)  = sum_max_cluster_t(positive_perm_tstat); 
end

if side == 0
    pval = pval/2;
end

pos_cluster_thresh = prctile(sum_posCluster,100-(100*pval));
neg_cluster_thresh = prctile(sum_negCluster,(100*pval));

%% Run ttest
if n_groups==1
    [h, ~, ~, stats] = ttest(X1 - X2,0,'Dim',1);
else
    [h, ~, ~, stats] = ttest2(X1,X2,'Dim',1);
end

h           = squeeze(h);
sig_tvals   = squeeze(stats.tstat).*h;

% Calculation of negative clusters <<<<<<<<<<<<<<<<<<<<<<<
% --------------------------------
negative_tstat = sig_tvals < 0;                 % Find all negative significant values (logical)
negative_tstat = negative_tstat .* sig_tvals;   % Save all the negative significant t_vals
islands = bwconncomp(negative_tstat);      % find clusters of sig t-vals

for cl = 1:length(islands.PixelIdxList)
    sum_max_t(cl) = sum(negative_tstat(islands.PixelIdxList{cl})); % sum T values
end

XX = sum_max_t < neg_cluster_thresh;


% make clusters
% return h map?

end

function sum_max_t = sum_max_cluster_t(sig_ts)

islands_perm = bwconncomp(sig_ts); % find clusters of sig t-vals
  
sum_max_t = 0;
if numel(islands_perm.PixelIdxList)>0 % Check if there are any clusters
    perm_clustsize = cellfun(@length,islands_perm.PixelIdxList); % count sizes of clusters

    % find clusters
    max_cluster_ind = find(perm_clustsize==max(perm_clustsize), 1, 'last' );    % index of the biggest cluster
    max_value_ind   = islands_perm.PixelIdxList{1,max_cluster_ind};             % Indices of the largest cluster
    sum_max_t       = sum(sig_ts(max_value_ind));                               % sum T values
end

end