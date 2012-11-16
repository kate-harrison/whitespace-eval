% This script takes the fieldnames of the variable 'struct' and assigns
% them to local variables.
%
%   Example:
%     Input:
%       struct.a = 1;
%       struct.b = 'b';
%       struct_to_vars;
%       who
%     Output:
%       Your variables are:
%       a       b       struct
%
%
% WARNING: This is a script, not a function, so it will modify local
%           variables.
%
% See also: fieldnames, isstruct, eval

if ~isstruct(struct)
    error('The variable "struct" is not actually a structure.');
end
PRIVATE_field_names = fieldnames(struct);

for PRIVATE_fn = 1:length(PRIVATE_field_names)
    PRIVATE_field_name = PRIVATE_field_names{PRIVATE_fn};
    eval([PRIVATE_field_name ' = struct.(PRIVATE_field_name)']);
end

clear PRIVATE_*
