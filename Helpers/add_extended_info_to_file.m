function [] = add_extended_info_to_file(filename, varargin)

% Try to load the existing data file
try
    load(filename, 'debug_info');
catch error
    display(error)
    display(['Could not load ' filename '; aborting add_extended_info_to_file().']);
    return
end


% Save the contents of the files in the stack trace
for st = 1:length(debug_info.stacktrace)
    debug_info.stacktrace(st).file_contents = fileread(debug_info.stacktrace(st).file);
end


% If debug_info already has additional_files, load it instead of clobbering
% it.
if isfield(debug_info, 'additional_files')
    additional_files = debug_info.additional_files;
end

% If there are any additional arguments...
if ~isempty(varargin)
    % For each of the extra arguments...
    for of = 1:length(varargin)
        % Add the .m extension if it is missing
        temp_filename = varargin{of};
        has_extension = ~isempty(regexp(temp_filename, '\.m$'));
        if ~has_extension
            temp_filename = [temp_filename '.m'];
        end
        
        % Read the file contents
        try
            contents = fileread(temp_filename);
        catch error
            display(error)
            display(['Could not add file contents for ' temp_filename ...
                '. Skipping this file.']);
            continue;
        end
        
        % Save the contents in additional_files. The fieldname will be a
        % sanitized version of the filename.
        sanitized_filename = regexprep(temp_filename, '/', '__');
        sanitized_filename = regexprep(sanitized_filename, '\.', '_');
        additional_files.(sanitized_filename) = contents;
    end
    
    % Add additional_files to debug_info (either overwriting the previous
    % version or creating it for the first time).
    debug_info.additional_files = additional_files;
end

% Overwrite the debug_info in the original file
try
    save(filename, '-append', 'debug_info');
catch error
    display(error);
    display(['Could not add extended debug info to ' filename]);
end
end