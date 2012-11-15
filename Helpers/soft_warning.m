function [] = soft_warning(msg)
%   [] = soft_warning(msg)
%
%   Provides a warning message to the user but does not throw a warning.
%
%   EXAMPLE:
%
%          *
%         ***
%       *******
%     ***********
%   *** WARNING ***  Assuming population type real-2010
%     ***********
%       *******
%         ***
%          *


ws = '  ';

display([ws '       *']);
display([ws '      ***']);
display([ws '    *******']);
display([ws '  ***********']);
display([ws '*** WARNING ***  ' msg]);
display([ws '  ***********']);
display([ws '    *******']);
display([ws '      ***']);
display([ws '       *']);


end