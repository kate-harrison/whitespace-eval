function [fn] = make_file_index(filename, title, file_struct, varargin)
%   [] = make_file_index(filename, title, file_struct, [base_href], [footer])
%
%   filename = location to save the file
%   title = title of the page + header
%   file_struct = structure with first level of fields as category name,
%       second level of fields as file name
%   base_href (optional) = base HREF tag (HTML)
%   footer (optional) = footer (HTML format)

file_string = [];

% Base HREF
if (nargin >= 4)
    base_href = varargin{1};
else
    base_href = '/';
end

% Footer
if (nargin >= 5)
    extras = ['<br><br><br>' varargin{2}];
else
    extras = '';
end

header = ['<html><head><title>' title '</title></head><body>' ...
    '<font size="2pt"><table width=100%><base href="' base_href '">' ...
    '<h2>' title '</h2><table width=70% border=1><tr>' ...
    '<td width=20%><b>Filename</b></td><td><b>Description</b></td></tr>'];


file_string = [file_string header];


categories = fieldnames(file_struct);

for c = 1:length(categories)
    sub_struct = eval(['file_struct.' categories{c}]);
    
    
    cat_name = categories{c};
    cat_name = regexprep(cat_name, '_', ' ');
    cat_name(1) = upper(cat_name(1));
    str = ['<tr><td colspan=2><center><b><br>' cat_name '</b></center></td><tr>'];
    file_string = [file_string str];
    
    files = fieldnames(sub_struct);
    for f = 1:length(files)
        descr = eval(['sub_struct.' files{f}]);
        name = files{f};
%         descr = file.d;
        str = ['<tr><td><a href="' name '.html">' name '.m</a></td>' ...
            '<td>' descr '</td></tr>'];
%         file_string = [file_string '<br>' name '<br>'];
        file_string = [file_string str];


    end
    
end






footer = ['</table>' extras '<tr><td nowrap></td></tr></table></font></body></html>'];

file_string = [file_string footer];

fid = fopen(filename, 'w');
fprintf(fid, '%s', file_string);
fclose(fid);


fn = [pwd '/' filename];

end