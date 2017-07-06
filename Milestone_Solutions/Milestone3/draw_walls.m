function x = draw_walls( wall_loc )
%DRAW_WALLS
%   Takes in an array with wall locations for each grid space
%   Draws walls in the specified locations

    [num_row, num_col] = size(wall_loc);

    % Draw all walls on image
    for r = 1:num_row
        for c = 1:num_col
            wall_bin = de2bi(wall_loc(r,c), 4, 'right-msb');

            line([c-0.5,c+0.5],[r-0.5,r-0.5],'color','b','linestyle', '--');
            line([c-0.5,c+0.5],[r+0.5,r+0.5],'color','b','linestyle', '--');
            line([c+0.5,c+0.5],[r-0.5,r+0.5],'color','b','linestyle', '--');
            line([c-0.5,c-0.5],[r-0.5,r+0.5],'color','b','linestyle', '--');

            if (wall_bin(1) == 1) % NORTH wall
                line([c-0.5,c+0.5],[r-0.5,r-0.5],'color','r','linewidth', 3);
            end
            if (wall_bin(2) == 1) % SOUTH wall
                line([c-0.5,c+0.5],[r+0.5,r+0.5],'color','r','linewidth', 3);
            end
            if (wall_bin(3) == 1) % EAST wall
                line([c+0.5,c+0.5],[r-0.5,r+0.5],'color','r','linewidth', 3);
            end
            if (wall_bin(4) == 1) % WEST wall
                line([c-0.5,c-0.5],[r-0.5,r+0.5],'color','r','linewidth', 3);
            end
        end
    end
end

