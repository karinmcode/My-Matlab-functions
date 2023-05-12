function [color_map] = my_color_gradient(color, num_steps)

% white_to_color: creates a white to input color gradient
%
% Inputs:
%   - color: the color to which the gradient will converge, either as a string ('red', 'green', etc.) or as a RGB vector
%   - num_steps (optional): number of steps in the gradient (default: 64)
%
% Outputs:
%   - color_map: the resulting colormap from white to the input color
%
% Example usage:
%   color_map = white_to_color('blue', 128); % creates a blue-white gradient with 128 steps

% Check if color is given as a string or RGB vector
if ischar(color)
    color = colorConverter(color);
end

% Check if num_steps is provided as input, otherwise use default value
if nargin < 2
    num_steps = 64;
end

% Create the color map from white to the input color
color_map = [linspace(1,color(1),num_steps)', linspace(1,color(2),num_steps)', linspace(1,color(3),num_steps)'];

end
