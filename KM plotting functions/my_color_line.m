function h = my_color_line(x, y, c, varargin)
% color_line plots a 2-D "line" with c-data as color
%
%       h = color_line(x, y, c)
%       by default: 'LineStyle','-' and 'Marker','none'
%
%          or
%       h = color_line(x, y, c, mark) 
%          or
%       h = color_line(x, y, c, 'Property','value'...) 
%             with valid 'Property','value' pairs for a surface object
%
%  in:  x      x-data, orientation column
%       y      y-data, columns are repetitions
%       c      3rd dimension for colouring (orientation column)
%       mark   for scatter plots with no connecting line
%
% out:  h   handle of the surface object
% (c) Pekka Kumpulainen 
%     www.tut.fi
%karin
n = size(y,2);
npoints = numel(x);

if any(size(x)==1)
    x = x(:);
end

if any(size(c)==1)
    c= c(:);
end
for i = 1:n
    this_y = y(:,i);
    this_c = repmat(c(i,:),npoints,1);

h = surface(...
  'XData',[x(:) x(:)],...
  'YData',[this_y(:) this_y(:)],...
  'ZData',zeros(length(x(:)),2),...
  'CData',[this_c(:) this_c(:)],...
  'FaceColor','none',...
  'EdgeColor','flat',...
  'Marker','none');
end
if nargin ==4
    switch varargin{1}
        case {'+' 'o' '*' '.' 'x' 'square' 'diamond' 'v' '^' '>' '<' 'pentagram' 'p' 'hexagram' 'h'}
            set(h,'LineStyle','none','Marker',varargin{1})
        otherwise
            error(['Invalid marker: ' varargin{1}])
    end
elseif nargin > 4
    set(h,varargin{:})
end