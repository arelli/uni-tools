clear all;
%RGB = imread('Median_Image1.png') ; % load the image
%photo_in = rgb2gray(RGB);
photo_in = imread('Median_Image1.png');


whos photo_in;

% get the size of the input image
width = size(photo_in,1);
%fprintf(int2str(width));
height = size(photo_in,2);
%fprintf(int2str(height));
figure
imshow(photo_in);

prompt = 'What is the kernel x dimension you want? ';
kernel_x = input(prompt);
prompt = 'What is the kernel y dimension you want? ';
kernel_y = input(prompt);




% pad the image around
padded_image = padarray(photo_in,kernel_x, 'replicate');  % pad in sides...
padded_image = padarray(padded_image.',kernel_y, 'replicate');  % pad in the other two sides..
padded_image = padded_image.';  % restore orientation

fprintf('The padded image is: ');
whos padded_image;

figure
imshow(padded_image);
%whos padded_image;
new_image = zeros(height,width);

counter = 1;
neighbors = zeros(kernel_x*kernel_y);
mean = 1;
total = 1;

% the extra rows and columns the filter kernel can occupy
extra_x = (kernel_x-1)/2;
extra_y = (kernel_y-1)/2;

for x = extra_x+1 : width + extra_x +1 % +1 to avoid out of bounds accesses
    for y = extra_y+1 : height + extra_y +1
        % implement the filter kernel. Go from (x-extra,y-extra) which is 
        % the top left kernel pixel, to (x+extra,y+extra), which is the 
        % lowest left pixel.
        for xx = -extra_x : extra_x
           for yy = -extra_y : extra_y
               neighbors(counter) = padded_image(x+xx,y+yy);
               counter = counter + 1;
           end
        end
       
        total = 0;
        neighbors = sort(neighbors);
        new_image(x-extra_x,y-extra_y) = neighbors(round(counter/2))/255; % IMPORTANT: divide by 255, 
                                               % because the pixels take 
                                               % values from 0 to 1!!!
        counter = 1;
    end
end

whos new_image

figure
imshow(new_image);

