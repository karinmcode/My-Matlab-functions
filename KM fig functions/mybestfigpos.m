function mybestfigpos(fig)
    % Get monitor positions
    screens = get(0, 'MonitorPositions');
    
    % Find the right-most monitor
    [~, rightmost_idx] = max(screens(:, 1));
    rightmost_monitor = screens(rightmost_idx, :);
    
    % Get the figure's dimensions
    fig_pos = fig.Position;
    width = fig_pos(3);
    height = fig_pos(4);

    % Calculate figure position
    xpos = rightmost_monitor(1) + (rightmost_monitor(3) - width*2);
    ypos = rightmost_monitor(2) + (rightmost_monitor(4) - height) / 2;

    % Set the figure position
    fig.Position = [xpos, ypos, width, height];
end
