% Initialize current location maze array
curr_loc = [...
    1 1 1 1
    1 1 1 1
    1 1 1 1
    1 1 1 1
    1 1 1 0];

visited_info = zeros(5,4);

% Set maze walls: W E S N (ie. walls on N W would = 9)
wall_loc = [...
    9 3 3 5
    12 9 5 12
    12 0 0 12
    12 0 2 12
    10 3 3 6];

% Draw initial grid 

%imshow(curr_loc, 'InitialMagnification', 'fit');
colormap spring;
imagesc(curr_loc);
draw_walls(wall_loc);

% Starting position
start_pos = [5,4];

% Create stack
stack = CStack();

% DFS traverse through maze
% First, push starting position onto stack;
stack.push(start_pos);
all_visited = all(all(visited_info,1));
while (~stack.isempty)

    % Visit next pos and mark it as visited
    curr_pos = stack.top();
    curr_r = curr_pos(1);
    curr_c = curr_pos(2);
    curr_loc(curr_r, curr_c) = 0;
    visited_info(curr_r, curr_c) = 1; 
    
    % Look for next position to visit
    % First get wall information at current location
    wall_bin = de2bi(wall_loc(curr_r,curr_c), 4, 'right-msb'); % [N S E W]
    % Next, figure out next position to be visited by: 
    % wall location and if they already have been visited
    % Priority: N, E, W, S
    if (wall_bin(1) == 0)
        go_north = ~visited_info(curr_r - 1, curr_c);
    else
        go_north = 0;
    end
    
    if (wall_bin(3) == 0)
        go_east  = (~visited_info(curr_r, curr_c + 1) & ~go_north);
    else 
        go_east = 0;
    end
    
    if (wall_bin(4) == 0)
        go_west  = (~visited_info(curr_r, curr_c - 1) & ~go_east);
    else
        go_west = 0;
    end
   
    if (wall_bin(2) == 0) 
        go_south = (~visited_info(curr_r + 1, curr_c) & ~go_west);
    else
        go_south = 0;
    end
    
    if (go_north)
        next_pos = [curr_r - 1, curr_c];
        stack.push(next_pos);
    elseif (go_east)
        next_pos = [curr_r, curr_c + 1];
        stack.push(next_pos);
    elseif (go_west) 
        next_pos = [curr_r, curr_c - 1];
        stack.push(next_pos);
    elseif (go_south)
        next_pos = [curr_r + 1, curr_c];
        stack.push(next_pos);
    else
        next_pos = stack.pop;
    end

    pause(1)
    %imshow(curr_loc, 'InitialMagnification', 'fit');
    imagesc(curr_loc);
    draw_walls(wall_loc)
    
    % Check if all nodes have been visited
    all_visited = all(all(visited_info,1));
    
    % Make current position previous position
    prev_r = curr_r;
    prev_c = curr_c;
    % Save prev pos in maze arra
    curr_loc(prev_r, prev_c) = 0.5;
end

display('done!');


 