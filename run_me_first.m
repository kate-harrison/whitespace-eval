% Run this file to set up all of the directories correctly, etc.

clc; clear all; close all;

%% Reset the Matlab path to its default state
restoredefaultpath;


%% Add the Helpers/ subdirectory to the path
% We do this now so we can call get_simulation_value() below.
% Note that the strings below will be used in regexpi so we escape the
% period in .svn and .git using the \ character.
lastwarn('');   % reset warnings
addpath('Helpers');
if lastwarn    % if a warning was raised...
    display('If the warning above is about a non-existent directory ''Helpers'',');
    display('you should make sure that you are in the root directory. Exiting now');
    display('because this is required.');
    return
end

do_not_include = {'\.svn', '\.git', 'html', 'tl_', 'cvx', '/Data/'};
% Note: we exclude the Data/ directory here to avoid conflicts (bugs) when
% data exists for multiple regions. We add the Data/ paths separately
% below. Note that the trailing / is important to make sure we don't
% exclude Data_generation_files/.


%% Create the directories Data/ and Output/ if they don't already exist
for i = 1:5
    switch(i)
        case 1, dir_name = get_simulation_value('data_dir');
        case 2, dir_name = 'Output';
        case 3, dir_name = get_simulation_value('temp_dir');
        case 4, dir_name = get_simulation_value('misc_dir');
        case 5, dir_name = ['Output/' get_simulation_value('region_code')];
    end
    
    if (exist(dir_name, 'dir') ~= 7)
        display(['Creating directory ' dir_name '/...']);
        mkdir('.', dir_name);
    end
end


%% Create the Data/ directories (one for each label) if necessary and add them to the path
% Get the label names
labels = get_simulation_value('labels');
[split] = regexp(labels, ',', 'split'); % the labels are separated by commas

% Trim any whitespace
for s = 1:length(split)
    split{s} = regexprep(split{s}, '\s', '');
end

% Determine which directory will hold the new directories and make sure it
% exists; then add it to the path
dir_name = get_simulation_value('data_dir');
if ~exist(dir_name, 'dir')
    mkdir(dir_name)
end

% Make the directories and add them to the path
for i = 1:length(split)
    if ~isempty(regexpi(split{i}, 'char'))
        continue;   % skip the CHAR label
    end
    if (exist([dir_name '/' split{i}], 'dir') ~= 7)
        display(['Creating directory ' dir_name '/' upper(split{i}) '...']);
        mkdir(dir_name, upper(split{i}));
    end
end


%% Add all subdirectories to the path
display('Adding all subdirectories to the path...');
path_string = genpath(pwd);
strings = regexp(path_string, ':', 'split');

for i = 1:length(strings)
    if all(cellfun('isempty',regexpi(strings(i), do_not_include)))
        % If it does not contain any of the banned strings, add it
        addpath(cell2mat(strings(i)));
    end
end

% Add all subdirectories of Data/ to the path
path_string = genpath([pwd '/' get_simulation_value('data_dir')]);
strings = regexp(path_string, ':', 'split');

for i = 1:length(strings)
        addpath(cell2mat(strings(i)));
end


%% Done!
display(' ');
display('      ...done!');


%% Clean up
clear all;