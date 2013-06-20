% Run this file to set up all of the directories correctly, etc.

clc; clear all; close all;

%% Reset Matlab to its default state
matlabrc;


%% Add the Helpers/ subdirectory to the path
% We do this now so we can call get_simulation_value() below.
% Note that the strings below will be used in regexpi so we escape the
% period in .svn and .git using the \ character.
addpath('Helpers');

do_not_include = {'\.svn', '\.git', 'html', 'tl_', 'cvx'};


%% Exclude all region codes except the current one
all_region_codes = get_simulation_value('valid_region_codes');
current_region_code = get_simulation_value('region_code');

for rc = 1:length(all_region_codes)
    if ~string_is(all_region_codes{rc}, current_region_code)
        do_not_include{end+1} = ['Data/' all_region_codes{rc}];
    end
end


%% Create the directories Data/ and Output/ if they don't already exist
for i = 1:3
    switch(i)
        case 1, dir_name = get_simulation_value('data_dir');
        case 2, dir_name = 'Output';
        case 3, dir_name = get_simulation_value('temp_dir');
    end
    
    if (exist(dir_name, 'dir') ~= 7)
        display(['Creating directory ' dir_name '/...']);
        mkdir('.', dir_name);
    end
end


%% Create the Data/ directories (one for each label) if they don't already exist
% Get the label names
labels = get_simulation_value('labels');
[split] = regexp(labels, ',', 'split'); % the labels are separated by commas

% Trim any whitespace
for s = 1:length(split)
    split{s} = regexprep(split{s}, '\s', '');
end

% Determine which directory will hold the new directories and make sure it
% exists
dir_name = get_simulation_value('data_dir');
if ~exist(dir_name, 'dir')
    mkdir(dir_name)
end

% Make the directories
for i = 1:length(split)
    if (exist([dir_name '/' split{i}], 'dir') ~= 7 && isempty(regexpi(split{i}, 'char')))
        display(['Creating directory ' dir_name '/' upper(split{i}) '...']);
        mkdir(dir_name, upper(split{i}));
    end
end


%% Add all subdirectories to the path
% We do this again to catch the directories we just created.
display('Adding all subdirectories to the path...');
path_string = genpath(pwd);
strings = regexp(path_string, ':', 'split');
new_paths = [];

for i = 1:length(strings)
    if all(cellfun('isempty',regexpi(strings(i), do_not_include)))
        % If it does not contain any of the banned strings, put it in the
        % queue to be added
        new_paths = [new_paths ':' cell2mat(strings(i))];
    end
end

new_paths([1 end]) = [];  % chop off leading and trailing ':'
addpath(new_paths);


%% Done!
display(' ');
display('      ...done!');


%% Clean up
clear all;