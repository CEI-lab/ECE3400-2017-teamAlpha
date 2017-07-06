% Initialize robot's current location
currloc_init = [...
    1 1 1 1
    1 1 1 1
    1 1 1 1
    1 1 1 1
    1 1 1 0];

newloc_init = [...
    1 1 1 1
    1 1 1 1
    1 1 1 1
    1 1 1 1
    1 1 0 1];


% Set maze walls: W E S N (ie. walls on N W would = 9)
wall_loc = [...
    9 1 3 5
    8 0 1 4
    8 0 0 4
    8 0 0 4
    10 2 2 6];

% Draw initial grid 
imshow(currloc_init, 'InitialMagnification', 'fit');
draw_walls(wall_loc);


pause(1)
imshow(newloc_init, 'InitialMagnification', 'fit');
draw_walls(wall_loc)
 