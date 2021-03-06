ori = [2,2];

grid.speed = read_map('map2.png');
map_size = size(speed_func);
grid.time = ones(map_size)./0; %set time of arrival to infinity
grid.state = ones(map_size, 'uint8') .* uint8(cell_state.Unknown); %time func is same size as map with cells initialized to unkown

manhattan_neighbors = [1,0; -1,0; 0,1; 0,-1];
narrow_band = PriorityQueue(3); % x y T sorted by T (time at position (x,y))

ori_indx = sub2ind(size(grid.state),ori(1),ori(2)); % get the element index of the current position
grid.time(ori_indx) = 0;
narrow_band.insert([ori(1),ori(2),grid.time(ori_indx)]);

while narrow_band.size() > 0
    current = narrow_band.remove();
    current_indx = sub2ind(size(grid.state),current(1),current(2)); % get the element index of the current position
    grid.state(current_indx) = cell_state.Frozen; 
    for neighbor = manhattan_neighbors.'+current(1:2).'*ones(1,4)
        if all(neighbor > 0) && all(neighbor <= map_size.')
            neighbor_indx = sub2ind(size(grid.state),neighbor(1),neighbor(2)); % get the element index of the neighbors position
            if grid.state(neighbor_indx) ~= cell_state.Frozen
                t_neighbor =  double(current(3)) + 1/double(grid.speed(neighbor_indx));
                if grid.state(neighbor_indx) == cell_state.Unknown
                    narrow_band.insert([neighbor(1),neighbor(2),t_neighbor]);
                    grid.state(neighbor_indx) = cell_state.Narrow;
                elseif t_neighbor < grid.time(neighbor_indx)%implied that the cell state is already narrow b/c not unknown or frozen
                    narrow_band.remove([neighbor(1),neighbor(2),grid.time(neighbor_indx)])
                    narrow_band.insert([neighbor(1),neighbor(2),t_neighbor]);
                end
                grid.time(neighbor_indx) = min(grid.time(neighbor_indx), t_neighbor);
            end
        end
    end
end

fig1 = figure;
image(grid.time,'CDataMapping','scaled');
colorbar;
title('arrival time surface');
hold on;
[x,y] = ginput(1);
target = [uint16(y);uint16(x)];
%plot([2 5 7 8; 5, 7, 8, 99],[2 5 7 8; 5 7 8 99],'Linewidth',10);

current = target;
new = current;
sobel_x = [-1,0,1;-2,0,2;-1,0,1];
sobel_y = [-1,-2,-1;0,0,0;1,2,1];
%grad_x = conv2(grid.time,sobel_x, 'same');
%grad_y = conv2(grid.time,sobel_y, 'same');

while ~isequal(current,ori.')
%    grad_x = conv2(grid.time(current(2)-1:current(2)+1,current(1)-1:current(1)+1),sobel_x);
%    grad_y = conv2(grid.time(current(2)-1:current(2)+1,current(1)-1:current(1)+1),sobel_y);
    grad_x = 0;
    grad_y = 0;
    for i=1:3
        for j=1:3
            if ~isinf(grid.time(current(1)+i-2,current(2)+j-2))
                grad_x = grad_x + grid.time(current(1)+i-2,current(2)+j-2)*sobel_x(i,j);
                grad_y = grad_y + grid.time(current(1)+i-2,current(2)+j-2)*sobel_y(i,j);
            end
        end
    end
    
    %grad = [grad_x(current(1),current(2)),grad_y(current(1),current(2))];
    grad = [grad_x,grad_y];
    grad_mag = sqrt(grad(1)^2+grad(2)^2);
    direction = atan(grad(2)/grad(1));
    if isnan(grad(1))
        new(1) = current(1);
    end
    if isnan(grad(2))
        new(2) = current(2);
    end
    if isinf(grad(1))
        new(1) = 0;
    end
    if isinf(grad(2))
        new(2) = 0;
    end
    if new==current
        new(2) = current(2)-sin(direction);
        new(1) = current(1)-cos(direction);
%        new(1) = current(1)-grad(2)/grad_mag;
%        new(2) = current(1)-grad(1)/grad_mag;
%        new(2) = current(2)-grad_mag*cos(direction);
%        new(1) = current(1)-grad_mag*sin(direction);
    end
    if new(1) < ori(1)
        new(1) = ori(1);
    end
    if new(2) < ori(2)
        new(2) = ori(2);
    end
    x_plot = [current(2),new(2)];
    y_plot = [current(1),new(1)];
    plot(x_plot,y_plot,'Linewidth',6);
    pause(0.05);%half a second
    current = new;
end
%fig2 = figure;
%image(grid.speed,'CDataMapping','scaled');
%colorbar;
%title('speed');



%fig3 = figure;
%mesh(grid.time);
%title('3d arrival time surface');
