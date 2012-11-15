function [fn] = make_directory_index(filename, title, varargin)
%   make_directory_index(filename, title)
%
%   Makes a pair of HTML pages which link to the figures.html files in the
%   subdirectories: the first page (nav_[filename]) contains the links and
%   the second page ([filename]) creates frames in which to display the
%   navigation bar and the pages. You need only navigate to [filename]. The
%   full path of the file, [fn], is passed as the output argument.
%
%   Note: directories will only be listed if they contain the file
%   figures.html which can be created using either of the functions below.
%
%   See also: make_file_index, make_toys_file_index


file_string = [];

nav_filename = ['nav_' filename];
% body_filename = ['body_' filename];
header = ['<html><head><title>' title '</title></head><body vlink="blue">' ...
    '<h2>' title '</h2>'];

file_string = [file_string header];

if nargin >= 1
    extras = varargin{1};
else
    extras = '';
end



dirs = dir;

for d = 1:length(dirs)
    if ~dirs(d).isdir
        continue
    end
    
    if string_is(dirs(d).name, '..')
        continue
    end
    
%     display(['Considering ''' dirs(d).name '''']);
    
    figures_filename = [dirs(d).name '/figures.html'];
    
    if exist(figures_filename, 'file') == 2
        file_string = [file_string '<a target=content href="' figures_filename '">' dirs(d).name '</a><br>'];

    end
    
end



footer = ['</font></body></html>'];

file_string = [file_string extras footer];

fid = fopen(nav_filename, 'w');
fprintf(fid, '%s', file_string);
fclose(fid);







% % file_string = ['<html><body><h3>' title '</h3></body></html>'];
% file_string = ['<html><body>Please click on a directory to display its figures.']
% 
% 
% fid = fopen(body_filename, 'w');
% fprintf(fid, '%s', file_string);
% fclose(fid);






file_string = ['<html>' ...
  '<head><title>' title '</title></head>' ...
    '<frameset cols="170,*">' ...
      '<frame src="' nav_filename '">' ...
      '<frame name=content>' ...% src="' body_filename '">' ...
    '</frameset>' ...
'</html>'];

fid = fopen(filename, 'w');
fprintf(fid, '%s', file_string);
fclose(fid);





fn = [pwd '/' filename];

end