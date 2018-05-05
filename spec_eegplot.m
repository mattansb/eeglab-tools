% PURPOSE:  Set time and amp sacles for pop_eegplot.
%
% 
% FORMAT
% ------
% spec_eegplot(scale, time);
% 
%
% INPUTS
% ------
%   scale   - amp scale size.
%   time    - time scale size.
%
% EXAMPLE:
% --------
% pop_eegplot(EEG, 1, 1, 1); spec_eegplot(40, 10);
%
% Author: Mattan S. Ben Shachar, BGU, Israel

%{
Change log:
-----------
05-05-2018  Added help
%}
function spec_eegplot(scale, time)

x           = get(gcf,'UserData');
x.winlength = time;
x.spacing   = scale;

set(findobj(gcf,'Tag','ESpacing'),'string',num2str(x.spacing));

%eegplot specifying extra inputs...
set(gcf,'UserData',x);
eegplot('draws',0);

end