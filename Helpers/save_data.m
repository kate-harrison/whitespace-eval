function [] = save_data(filename, varargin)
%   [] = save_data(filename, varargin)
%
%   Intended to function identically to the 'save' function, at least when
%   used in the following manner:
%
%       save('sample_filename', 'var1', 'var2');
%       save_data('sample_filename', 'var1', 'var2');
%
%   These two calls will both save 'var1' and 'var2' into
%   'sample_filename'. However, save_data() adds error-checking
%   functionality which allows the user to try using a different filename
%   or, failing that, gives the user command-line access using the
%   'keyboard' function.
%
%   This function also adds some standard debug information (e.g. time of
%   data creation, stack trace, etc.) to the saved file.
%
%   See also: save, evalin, keyboard, dbcont, dbquit
%
%
%
%
%  *** TIPS FOR WHAT TO DO IF YOUR FILE STILL WON'T SAVE ***
% If you're missing a variable that you thought existed or you mistyped the
% name, just edit the local variable 'varargin' (which contains the list of
% variables) then execute the command below:
%
%   evalin('caller', generate_save_expression(filename, varargin));
%
%
% Note: the command 'dbcont' will exit debug mode and continue executing
% the rest of the file. The command 'dbquit' will exit debug mode and halt
% execution.




%% Try to save the data in the specified file
% If that doesn't work, save in a temp file (identified by the
% time-and-date string) and ask the user for a new filename. If that still
% doesn't work (e.g. you tried to save a non-existent variable), it hands
% control over to the user and directs them to look in this file for tips.

try
    % Make the call to save as if it had been done in the calling function/file
    evalin('caller', generate_save_expression(filename, varargin));
catch me
    % Display the error message
    display('Error message:');
    disp(me);
    
    % Generate a unique (enough) temporary filename
    time_string = regexprep(datestr(now, 31), ':', '-');
    temp_filename = ['TEMP_' regexprep(time_string, ' ', '_') '.mat'];
    
    % Tell the user what happened
    display(' ');
    display(['ERROR saving data to ' filename]);
    display(['  Saving in temp file ''' temp_filename ''' and then']);
    display('  requesting a new filename.');
    try
        % Try to save with the temp filename
        evalin('caller', generate_save_expression(temp_filename, varargin));
        
        % Get a new filename from the user and try saving with that
        filename = input('Filename: ', 's');
        evalin('caller', generate_save_expression(filename, varargin));
    catch me2
        % Display the error message
        disp(me2);
        
        % Tell the user what happened and hand control over to them
        display(['That didn''t work for some reason. I''m handing control ' ...
            'over to you now. You are in debug mode inside the save_data() ' ...
            'function. Good luck! Check out the source of save_data() for tips.']);
        keyboard;
    end
end

%% Add some debug information to the file

try
    warnings = evalin('caller', 'warnings');
    has_warnings = true;
catch
    has_warnings = false;
end


try
    % Compile the debug information
    debug_info.stacktrace = dbstack('-completenames');
    debug_info.creation_date = datestr(now);
    % debug_info.config = get_simulation_config();
    if has_warnings
        debug_info.warnings = warnings;
    end
    
    
    % Append it to the file
    save(filename, '-append', 'debug_info');
    
    add_extended_info_to_file(filename, 'get_simulation_value');
catch me
    display('There was an error adding debug information to your data file.');
    display('Don''t panic: the data you specified was saved successfully.');
    display('Error information:');
    disp(me);
end


end


function [expression ] = generate_save_expression(filename, variable_names)
%   generate_save_expression(filename, variable_names)
%
%   Reconstruct the call to 'save' with the given filename and variable
%   names.


% Re-construct the call to 'save' with the same arguments
expression = ['save(''' filename ''''];
for i = 1:length(variable_names)
    expression = [expression ', ''' variable_names{i} ''''];
end
expression = [expression ');'];


end