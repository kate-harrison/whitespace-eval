function [ cdfX cdfY avg med ] = calculate_cdf_from_map( data_map, population_map, is_in_us )
%CALCULATE_CDF_FROM_MAP Calculates the CDF for the map and its
%corresponding population data.
%
%   [ cdfX cdfY avg med ] = calculate_cdf_from_map( data_map,
%   population_map, is_in_us )
%
%   data_map - the map containing the data to analyze
%   population_map - the corresponding population map (to weight each point
%       in data_map equally, use ones(size(data_map))
%   is_in_us - mask to determine which values in data_map to use (to
%       consider all points, use ones(size(data_map))
%
%   cdfX - x axis values for the CDF
%   cdfY - y axis values for the CDF
%   avg - average of the data
%   med - median of the data
%
%   WARNING: infinite and NaN data will not be counted in the CDF
%   calculations!

if (ndims(data_map) >= 3)
    error(['Data map can be at most 2-dimensional; number of dimensions: ' ...
        num2str(ndims(data_map))]);
end

total_pop = sum(sum(population_map .* (is_in_us & ~isnan(population_map))));
% total_pop = sum(sum(population_map));

data_map(~is_in_us) = -inf; % Mark the points that are outside the US

% Pair each point with its population and flatten both maps
cdf_array = [reshape(data_map, 1, size(data_map,1)*size(data_map,2)); ...
             reshape(population_map, 1, size(population_map, 1)*size(population_map,2))];
         
% Sort according to capacity and preserve population correspondance
cdf_array = sortrows(cdf_array')';

% Remove those points that were outside the US
cdf_array = cdf_array(:, cdf_array(1,:) ~= -inf);

% Remove those points with infinite capacity (zero people) because they'd
% just throw it off
% Regular result of zero people
cdf_array = cdf_array(:, isfinite(cdf_array(1,:)));
% This happens when we try to make 0/0 (zero capacity and zero people)
cdf_array = cdf_array(:, ~isnan(cdf_array(1,:)));

% display(['First people: ' num2str(cdf_array(2,1))]);
% display(['    Their data rate: ' num2str(cdf_array(1,1))]);



% Our x axis will be the data rates
cdfX = cdf_array(1,:);

people = cdf_array(2,:);
cum_people = cumsum(people);

cdfY = (cum_people) / total_pop;  % Fraction of the population that can reach *at least* that data rate

% Find the median of the points we are considering
mid_pop = cum_people(end)/2;  % The middle person
index = find(cum_people > mid_pop, 1, 'first') - 1; % = (first index beyond that person) - 1 = index of that person
med = cdfX(index);

% Sum up the values, each weighted by the number of people it represents,
% and divide by the total number of people
avg = sum(cdf_array(1,:) .* cdf_array(2,:)) / total_pop; 


end

