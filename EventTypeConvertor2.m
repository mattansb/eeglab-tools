% PURPOSE:  Convert EEG.event.type according to EEG.event.codes. Useful for
%           interpreting TRSPs.
%
% 
% FORMAT
% ------
% [ EEG ] = EventTypeConvertor2(EEG, EventTypes)
% 
%
% INPUTS
% ------
%   EEG         - input dataset
%   EventTypes  - A n-by-3 cell list. See more details bellow.
%
%
% OUTPUTS:
% --------
%   EEG - dataset with converted EEG.event.types.
%
%
%
% EventTypes
% ----------
% Each `EventTypes` row consists of 3 parts: {type,condition(s),new_type}
% - type    - A string to match the name of the EEG.event.type to convert. 
% - cond(s) - A n-by-2 cell list of conditions with the following
%             structure: {code_name,cond} 
%               + code_name: a strng to match in EEG.event.codes(:,1).
%               + cond: a string specifying the condition
%                 EEG.event.codes(:,2) must match. The first charatcter in
%                 the string must match one of the following: = ~ < >
%                 the rest of the string is the value to be compared
%                 (numeric or string).
% - type2   - The new name to be given to the matching EEG.event.type.
%
%
% EXAMPLE:
% --------
% Specifying
% EventTypes = {'TRSP',{'eval','>0'; 'numL', '=bonus'},'corr_G10';...
%               'TRSP',{'eval','~0'; 'numL', '=test'},'incorr_L';};
% Will do the following:
%   1) Change any TRSP event type with a code of 'eval' larger than 0, and
%      a code of 'numL' equal to 'bonus' to 'corr_G10'.
%   2) Change any TRSP event type with a code of 'eval' not equal to 0, and
%      a code of 'numL' equal to 'test' to 'incorr_L'.
%
%
% Author: Mattan S. Ben Shachar, BGU, Israel

%{
Change log:
-----------
05-05-2018  Added help
%}
function [ EEG ] = EventTypeConvertor2(EEG, EventTypes)
%{

%}

EventTypes(:,4) = num2cell(zeros(size(EventTypes,1),1)); % this will be used for counting

%% Fint Relevant Event Types

% to spare some time, find events that match ANY of the type names
eventNames = unique({EventTypes{:,1}});                                     % gets all event types with no repetations
eventMatch = find(cellfun(@(x) strcmpi(x,eventNames), {EEG.event.type}));   % which events match by name


%% Start Matching

for evnt = eventMatch
    
    for type = 1:size(EventTypes,1)
        
        if strcmpi(EEG.event(evnt).type,EventTypes{type,1}) % if current event name matches
            
            match = true;
            
            for cr = 1:size(EventTypes{type,2},1) % match conditions - if not, next cr

                ind = find(strcmpi(EventTypes{type,2}{cr,1},EEG.event(evnt).codes(:,1)));  
                if isempty(ind), continue; end % if it doesn't match, got to next code

                % Get values
                val1    = EEG.event(evnt).codes{ind,2};     % value from EEG events
                val2    = EventTypes{type,2}{cr,2}(2:end);  % value from EventTypes
                opr     = EventTypes{type,2}{cr,2}(1);      % the operator between them

                switch opr
                    case '=' % equal
                        if ischar(val1)
                            match = match & strcmp(val1,val2);
                        else
                            match = match & str2num(val2)==val1;
                        end
                    case '~' % not equal
                        if ischar(val1)
                            match = match & ~strcmp(val1,val2);
                        else
                            match = match & str2num(val2)~=val1;
                        end
                    case '<' % smaller
                        match = match & val1<str2num(val2);
                    case '>' % larger
                        match = match & val1>str2num(val2);
                    otherwise
                        error('some operators are bad!')
                end

                if ~match % if it doesn't match, got to next event type
                    break
                end
            end
            if match % if all criterion match:
                EventTypes{type,4}      = EventTypes{type,4} + 1;   % increase count by 1
                EEG.event(evnt).type    = EventTypes{type,3};       % change name
            end
        end
    end
end

%% Results
T1 = cell2table(EventTypes(:,3:4),'VariableNames',{'Type','Count'});
T2 = ['TOTAL: ' num2str(sum(T1{:,2})) ' of ' num2str(size(EEG.event,2))];
disp(T1)
disp(T2)

end