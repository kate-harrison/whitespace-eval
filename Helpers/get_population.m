function [population] = get_population(map_size, varargin)
%   [population] = get_population(map_size, [population_type], 
%                                               [num_layers])
%
%    o map_size - dimensions for the resulting map [ 200x300 | 201x301 |
%           400x600 | 800x1200]
%    o population_type (optional) - population type and year
%       [      real   |   uniform    |    min   |   max  | 
%         {real-2010} | uniform-2010 | min-2010 | max-2010
%           real-2000 | uniform-2000 | min-2000 | max-2000    ]
%       // Default specified by get_simulation_value.m //
%    o num_layers (optional) - number of copies (third dimension)
%           [ {1} | integer]


num_inputs = length(varargin);

% Parse varargin and set defaults
if (num_inputs < 1)
    population_type = get_simulation_value('pop_data_type');
else
    population_type = varargin{1};
end

if (num_inputs < 2)
    num_layers = 1;
else
    num_layers = varargin{2};
end

if (num_inputs >= 3)
    warning('Only the first three inputs to this function are used.');
end

population_label = generate_label('population', 'raw', population_type, map_size);
population = load_by_label(population_label);

population = shiftdim(repmat(population, [1 1 num_layers]),2);



end