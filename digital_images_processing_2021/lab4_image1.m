close all
% LAB4 Digital Image Processing
RGB = imread('axones1.png');
photo_in = rgb2gray(RGB);

figure
imshow(photo_in)
title('Original')
pause(1)


%{
STEP 1
Image denoising: we notice that the images are degraded by a
fairly significant noise. Start by eliminating this noise. Typically, this is 
done by filtering. For example, linear filtering with a Gaussian or averaging kernel,
nonlinear filtering of the median type or sequential filtering
alternating openings and closings. You can test these different
filtering methods in order to select the one that you think as the
most appropriate.
%}

h = [1 1 1
    1 1 1
    1 1 1]/20;


photo_in_conv = imfilter(photo_in,h,'conv');
figure;
imshow(photo_in_conv*1.5);
title('gaussian');
pause(1);

%%photo_in_conv = imerode(photo_in,strel('line',10,1));
%%photo_in_conv = imerode(photo_in,strel('disk',3));

%photo_in_conv = imopen(photo_in_conv,strel('disk',4));  % strel's second argument is angle
photo_in_conv = imopen(photo_in_conv,strel('line',4,1));  % strel's second argument is angle

figure;
imshow(photo_in_conv);
title('Opening');
pause(1);


photo_in_conv = imclose(photo_in_conv,strel('line',6,45));
photo_in_conv = imclose(photo_in_conv,strel('line',6,-45));

figure
imshow(photo_in_conv)
title('Closing')
pause(1)


% EDGE DETECTION
%{
STEP 2
Enhancement of linear structures: can be carried out by
calculating the morphological gradient or by carrying out a
filtering by an adapted kernel (Prewitt, Sobel ...).
%}
photo_in_conv = imtophat(photo_in_conv,strel('disk',15));
photo_in_conv = imtophat(photo_in_conv,strel('disk',14));
photo_in_conv = imtophat(photo_in_conv,strel('disk',13));
photo_in_conv = imtophat(photo_in_conv,strel('disk',12));
photo_in_conv = imtophat(photo_in_conv,strel('disk',11));
photo_in_conv = imtophat(photo_in_conv,strel('disk',10));
photo_in_conv = imtophat(photo_in_conv,strel('disk',9));
photo_in_conv = imtophat(photo_in_conv,strel('disk',8));



%photo_in_conv = imclose(photo_in_conv,strel('disk',5));

figure
imshow(photo_in_conv)
title('Tophat')
pause(1)



% BINARIZATION
%{
STEP 3
Binarization: a threshold can be determined by the Otsu method
(have a look at the graythresh() function). Also remember to
eliminate (as far as possible) small unwanted connected
components and to fill in the holes.
%}
photo_in_conv = im2bw(photo_in_conv, graythresh(photo_in_conv));
photo_in_conv = imerode(photo_in_conv,strel('line', 6,1));
figure
imshow(photo_in_conv)
title('binarized')
pause(1)


% SKELETALIZATION
%{
STEP 4
Skeletalization: this step consists in keeping only the "central
lines" of the related components. You will be able to watch how
the Matlab bwmorph() function works and use it.
%}
%photo_in_conv = imdilate(photo_in_conv,strel('disk',12));

photo_in_conv = bwmorph(photo_in_conv,'skel',Inf);

figure
imshow(photo_in_conv)
title('skeletonized')
pause(1)


% HOLE FILLING
%{
Connection of the skeleton: finally, you have to try to fill the
holes in the skeleton as much as possible and eliminate the small
pieces of skeleton that may remain in the background. Combine
different features of bwmorph() to achieve a result as shown in
Figure 2 or alternatively use the imfill() function.
%}
