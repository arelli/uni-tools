close all
% LAB4 Digital Image Processing
RGB = imread('axones1.png');
photo_in = rgb2gray(RGB);

figure
imshow(photo_in)
title('Original')
pause(1)


%{
Use a smoothing kernel to remove unwanted noise
%}

% the smoothing kernel
h = [1 1 1
    1 1 1
    1 1 1]/20;

photo_in_conv = imfilter(photo_in,h,'conv');

%{
Open the image to remove part of the noise islands
%}
photo_in_conv = imopen(photo_in_conv,strel('line',4,1));  % strel's second argument is angle

%{
Close the image to connect neighbouring islands of signal
%}
photo_in_conv = imclose(photo_in_conv,strel('line',6,45));
photo_in_conv = imclose(photo_in_conv,strel('line',6,-45));

%{
Remove the openings with disks of size 9 to 15 from the initial image
This is mainly used for the background blobs.
%}
for c = 9:15
    photo_in_conv = imtophat(photo_in_conv,strel('disk',c));
end

%{
Translate the grayscale image to Black/Wite with a threshold obtained
with the Otsu method through graythresh() function.
%}
photo_in_conv = im2bw(photo_in_conv, graythresh(photo_in_conv));

%{
Extracting the sceleton of the neural axon
%}
photo_in_conv = bwmorph(photo_in_conv,'skel',Inf);

figure
imshow(photo_in_conv)
title('final image(skeleton of neural axon)')
pause(1)


