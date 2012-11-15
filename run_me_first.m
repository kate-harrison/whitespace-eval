% Run this file to set up all of the directories correctly, etc.

clc; clear all; close all;

%% Add all subdirectories to the path
% We do this now so we can call get_simulation_value() below.
% Note that the strings below will be used in regexpi so we escape the
% period in .svn and .git using the \ character.
do_not_include = {'\.svn', '\.git', 'html', 'tl_', 'cvx'};


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


%% Create the directories Data/ and Output/ if they don't already exist
for i = 1:2
    switch(i)
        case 1, dir_name = 'Data';
        case 2, dir_name = 'Output';
    end
    
    if (exist(dir_name, 'dir') ~= 7)
        display(['Creating directory ' dir_name '/...']);
        mkdir('.', dir_name);
    end
end

%% Create the Data/ directories (one for each label) if they don't already exist
% Get the label names
labels = get_simulation_value('labels');
[split] = regexp(labels, ', ', 'split');

% Make the directories
for i = 1:length(split)
    if (exist(['Data/' split{i}], 'dir') ~= 7 && isempty(regexpi(split{i}, 'char')))
        display(['Creating directory Data/' upper(split{i}) '...']);
        mkdir('Data', upper(split{i}));
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