function [ EEG, counts_table ] = EventTypeConvertor3(EEG, EventTypes)
%{
=
~
>
<
%}

EventTypes(:,4) = num2cell(zeros(size(EventTypes,1),1)); % this will be used for counting

for code = 1:size(EventTypes,1) % for each code type
    match_code = strcmpi({EEG.event.code},EventTypes{code,1});
    
    keys_crit = EventTypes{code,2};
    match_key = false(size(keys_crit,1), length(match_code));
    for key = 1:size(keys_crit,1) % for each key type
        code_field  = ['mffkey_' keys_crit{key,1}];
        code_field(code_field < 48 | (code_field > 57 & code_field < 64)) = []; % remove invalid char
        code_list = {EEG.event.(code_field)};
        
        % match to criterion
        crit = keys_crit{key,2};
        match_key(key,:) = cellfun(@(x) match_crit(x,crit),code_list);    
    end
    
    match_all_keys  = all(match_key,1);
    match_full      = match_code & match_all_keys;
    
    % Count
    EventTypes{code,4} = sum(match_full);
    
    % Assign new type
    type_name = repmat(EventTypes(code,3),sum(match_full),1);
    [EEG.event(match_full).type] = type_name{:};
end


%% Results
counts_table = cell2table(EventTypes(:,3:4),'VariableNames',{'Type','Count'});
disp(counts_table)
disp(['TOTAL: ' num2str(sum(counts_table{:,2})) ' of ' num2str(size(EEG.event,2))])

end

function lgl = match_crit(val,crit)

opr  = crit(1);
crit = crit(2:end);

if isempty(val)
    lgl = false;
else
    switch opr
        case '=' % equal
            lgl = strcmp(val,crit);
        case '~' % not equal
            lgl = ~strcmp(val,crit);
        case '<' % smaller
            lgl = str2num(val)<str2num(crit);
        case '>' % larger
            lgl = str2num(val)>str2num(crit);
        otherwise
            error('some operators are bad!')
    end
end      
        
        
end