function [] = make_pop_info(year)
%   [] = make_pop_info(year)
%
% Reads in the population information and turns it into the format expected
% by make_tract_info.m. Expects population data to be stored in
%   Population_and_tower_data/Population/[year]/Population/all_pops.csv
%
%   year = year for census data (valid: 2000, 2010)
%
% Please see Population_and_tower_data/Population/thankyou.txt for
% information on obtaining this data for yourself.



%% Old documentation for the ZCTA version -- we're using census tracts now
% First, we read the total population files which link ZCTAs with
% populations. These files were downloaded from the <factfinder2.census.gov
% American FactFinder>.
%
% We read the data in using the following command:
%
%       file = importdata(filename, ',', 2);
%
% Note that the first two rows are header data.
%
% Relevant information for row |i| is accessed using:
%
%       file.text_data(i,2) = [state_code zcta_code] where the state code
%       is 1-2 digits and the ZCTA code is 5 digits
%       file.data(i) = population for the ZCTA
%
% _To obtain this information again, use the following steps:_
%
% # Go to http://factfinder2.census.gov/
% # Click on *"2010 Census Summary File 1"* (_"View the 2010 Census Summary
% File 1 for detailed data on age, sex, households, families, the
% population in group quarters, and housing units. Also included are counts
% for many race and Hispanic or Latino categories. Data will be released on
% a state by state basis."_).
% #  *Remove the "Quick Table" option* under "Product Type" (left-hand column)
% # Click *"Geographies"* (left-hand column)
% # Under "Geography Filters", choose *"ZIP Code/ZCTA"*
% # Select *approximately 10 states* and click "Add". (If you try to do
% more, the download will hang or take you to an error page; if you get
% this, back up and choose fewer states.)
% # Close the Geographies page
% # Under *"Topics"*, click *"People"*, then *"Basic Count/Estimate"*
% # In the center frame, choose *"P1 - TOTAL POPULATION"*
% # Click *"Download"* and follow the instructions on the screen
% # Data is stored in the *CSV file* in the downloaded .zip file
%
%%

% Check to make sure it's a valid year
validate_flags('', 'pop_data_year', year)

% If you want to force a regeneration of the data (even if it already
% exists), set this to 1. Otherwise, set it to 0. Here, we choose the
% default option.
regenerate = get_simulation_value('recompute');



% This is the directory in which we'll be working
data_path = ['Population_and_tower_data/Population/' num2str(year)];

% This is the file we need to read
raw_filename = [data_path '/Population/popbytract' num2str(year) '.csv'];

% This is the file we will save
result_filename = [data_path '/Population/pop_data' num2str(year) '.mat'];




% If the file already exists and we don't want to regenerate the file, exit
% now.
if ( (exist(result_filename, 'file') == 2) && ~regenerate )
    return;
end



% Read the raw population file
pop_file = importdata(raw_filename, ',', 1);

% Take a peek at some of the data (don't pay attention to LOGRECNO):
pop_file.colheaders
pop_file.data(1:10, :)


% pop_data.data = [pop_file.data(:, col.geoid) pop_file.data(:,col.population)];
pop_data.data = pop_file.data(:, 2:end);

pop_data.geoid_idx = 1;
pop_data.landarea_idx = 2;
pop_data.waterarea_idx = 3;
pop_data.pop_idx = 4;
pop_data.thu_idx = 5;



% Save the data
save(result_filename, 'pop_data');
