% PURPOSE:  Easily select files from a folder.
%
% 
% FORMAT
% ------
% [set_list] = select_set(dirc,extention,select)
% 
%
% INPUTS
% ------
%   dirc        - directory of files.
%   extention   - the file extention (defults to 'set').
%   select      - [1|0] should a selection window pop-up? (defults to 0).
%
% OUTPUTS:
% --------
%   set_list - a cell list of the file names.
%
% Author: Mattan S. Ben Shachar, BGU, Israel

%{
Change log:
-----------
05-05-2018  Added help
%}
function [set_list] = select_set(dirc,extention,select)

if isempty(extention),  extention   = 'set';    end
if isempty(select),     select      = 0;        end

set_files = dir([dirc '\*.' extention]);

if select
    [ind,ok] = listdlg('ListString',{set_files.name});
    if ~ok || isempty(ind)
        error('you didn''t select any sets!')
    end
    set_list = set_files(ind);
else
    set_list = set_files;
end


end





