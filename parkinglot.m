clc;   
close all;   
clearvars;   
workspace;  
format long g;   
format compact;   
fontSize = 10;  

% Read in reference image with no cars (empty parking lot).
emptylot = 'C:\Users\Andy\Desktop\2022年MathorCup\Automated_Parking_System_MATLAB-master\Parking_Lot_without_Cars.jpg';

rgbEmptyImage = imread(emptylot);   
[~, ~, ~] = size(rgbEmptyImage);

% Display empty lot 输出读入的全空车位图像
figure(1);
imshow(rgbEmptyImage, []);   
axis('on', 'image');  
title('Empty Lot');  
hp = impixelinfo(); 

% Read in image with cars parked on the parking lot
withcars = 'C:\Users\Andy\Desktop\2022年MathorCup\Automated_Parking_System_MATLAB-master\Parking_Lot_with_Cars.jpg';

rgbTestImage = imread(withcars);
[columns, rows, numberOfColorChannels] = size(rgbTestImage);

%Display image w Cars
figure(2);
imshow(rgbTestImage, []);
axis('on', 'image');
title('Parking Lot with Cars');
hp = impixelinfo();   

% Set up figure properties:
% hFig1 = gcf;   % Returns the current figure handle. You can use the figure handle to query and modify  
%                            %   figure properties.
% hFig1.Units = 'Normalized';   % The input positions fill the complete window
% hFig1.WindowState = 'maximized';   % Maximizes the figure while keeping the taskbar in view
% hFig1.Name = 'Empty lots';


% Read in mask image that defines where the spaces are.
maskimage = 'C:\Users\Andy\Desktop\2022年MathorCup\Automated_Parking_System_MATLAB-master\Parking_Lot_Mask.png';

maskImage1 = imread(maskimage);
[columns, rows, numberOfColorChannels] = size(maskImage1);

% Create a binary mask from seeing where the min value is 255.
mask = min(maskImage1, [], 3) >= 200;

% Display the binary mask image 
figure(3);
imshow(mask, []);
axis('on', 'image');
title('Binary Mask');
hp = impixelinfo(); 

% Find the cars.
% First, get the absolute difference image.
diffImage = imabsdiff(rgbEmptyImage, rgbTestImage);

% Display the absolute difference image
figure(4);
imshow(diffImage, []);
axis('on', 'image');
caption = sprintf('Difference Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
hp = impixelinfo(); 

% Convert to gray scale and mask it with the spaces mask.
diffImage1 = rgb2gray(diffImage);
diffImage1(~mask) = 0;

% Get a histogram of the image so we can see where to threshold is at.
 histogram(diffImage1(diffImage1>0));

% Display the gray scale image.
figure(5);
imshow(diffImage1, []);
axis('on', 'image');
title('Gray Scale Difference Image');
hp = impixelinfo(); 

% Threshold the image to find pixels that are substantially different from the background.
kThreshold = 40; % Determined by examining the histogram.
parkedCars = diffImage1 > kThreshold;

% Fill holes.
parkedCars = imfill(parkedCars, 'holes');

% Get convex hull.
parkedCars = bwconvhull(parkedCars, 'objects');

% Display the parkedcars image.
figure(6);
imshow(parkedCars, []);
impixelinfo;
axis('on', 'image');
caption = sprintf('Parked Cars Binary Image with Threshold = %.1f', kThreshold);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');

% Measure the white pixels within each rectangular mask.
props = regionprops(mask, parkedCars, 'MeanIntensity', 'Centroid', 'BoundingBox');
centroids = vertcat(props.Centroid);

% Put yellow bounding boxes for each space
for k = 1 : length(props)
    rectangle('Position', props(k).BoundingBox, 'EdgeColor', 'y');
end

percentageFilled = [props.MeanIntensity];

% Place a red x on the image if the space is filled, and a green circle if the space is available to be parked on (it's empty).
% hFig2 = figure;
imshow(rgbTestImage);
% hFig2.WindowState = 'maximized'; Give a name to the title bar. hFig2.Name
% = 'Image Processing';
% hold on;
% % for k = 1 : length(props)
%     x = centroids(k, 1);
%     y = centroids(k, 2);
%     blobLabel = sprintf('%d', k);
%     if percentageFilled(k) > 0.10
%         % It has a car in that rectangle so we mark it with X
%         plot(x, y, 'rx', 'MarkerSize', 30, 'LineWidth', 4);
%         % the blob label.
%         text(x, y+20, blobLabel, 'Color', 'r', 'FontSize', 15, 'FontWeight', 'bold');
%     else
%         % No car is parked there.  The space is available.
%         plot(x, y, 'g.', 'MarkerSize', 40, 'LineWidth', 4);
%         % Put up the blob label.
%         text(x, y+20, blobLabel, 'Color', 'g', 'FontSize', 15, 'FontWeight', 'bold');
%     end
%     
% end

title('Marked Spaces.  Green Spot = Available.  Red X = Taken.', 'FontSize', fontSize);

fprintf('Done running %s.m ...\n', mfilename);
