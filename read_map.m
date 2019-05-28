function map = read_map(image)
    map = imread(image);
    map = rgb2gray(map);
    map = map./255;
end
