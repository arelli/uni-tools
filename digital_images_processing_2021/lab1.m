original = imread('retriever.tiff')  % load the image

close all;  % close all remaining open windows
figure;  % enable the window

%first scaling parameters
subplot(4,6,1);  % configure the window that shows the images
imshow(original);
title('original')  

subplot(4,6,2);
temp = downsample(original,2);  % downsample rows by factor of 2
final = downsample(temp.',4).';  % rotate 90 degrees, downsample rows by factor 4, rotate -90 degrees
imshow(final)
title({['downsampled'] ['rows:1/2,columns:1/4)']}) 

subplot(4,6,3);
temp = upsample(final,2); 
upsampled1 = upsample(temp.',4).';  
imshow(upsampled1)
title({['upsampled'] ['no interpolation']})

subplot(4,6,4);
linear1 = imresize(final,[230 230],'nearest')
imshow(linear1);
error11 = immse(linear1,original);  % image MSE(mean square error)
title({['upsampled, MSE=', num2str(error11)] ['nearest-neighbour interpolation']})

subplot(4,6,5);
bilinear1 = imresize(final,[230 230],'bilinear')
imshow(bilinear1);
error12 = immse(bilinear1,original);
title({['upsampled,MSE=', num2str(error12)] ['bilinear interpolation']})

subplot(4,6,6);
cubic1 = imresize(final,[230 230],'cubic')
imshow(cubic1);
error13 = immse(cubic1,original);
title({['upsampled, MSE=', num2str(error13)] ['cubic interpolation']})

%second scaling parameters
subplot(4,6,7);  
imshow(original);

subplot(4,6,8);
temp = downsample(original,4);  
final2 = downsample(temp.',2).';  
imshow(final2)
title('rows:1/4,columns:1/2)')

subplot(4,6,9);
temp = upsample(final2,4); 
upsampled2 = upsample(temp.',2).';  
imshow(upsampled2)


subplot(4,6,10);
linear2 = imresize(final2,[230 230],'nearest')
imshow(linear2);
error21 = immse(linear2,original);
title({['MSE=', num2str(error21)]});

subplot(4,6,11);
bilinear2 = imresize(final2,[230 230],'bilinear')
imshow(bilinear2);
error22 = immse(bilinear2,original);
title({['MSE=', num2str(error22)]});


subplot(4,6,12);
cubic2 = imresize(final2,[230 230],'cubic')
imshow(cubic2);
error23 = immse(cubic2,original);
title({['MSE=', num2str(error23)]});


%third scaling parameters
subplot(4,6,13);  
imshow(original);

subplot(4,6,14);
temp = downsample(original,8);  
final3 = downsample(temp.',8).';  
imshow(final3)
title('rows:1/8,columns:1/8)')

subplot(4,6,15);
temp = upsample(final3,8); 
upsampled3 = upsample(temp.',8).';  
imshow(upsampled3)

subplot(4,6,16);
linear3 = imresize(final3,[230 230],'nearest')
imshow(linear3);
error31 = immse(linear3,original);
title({['MSE=', num2str(error31)]});

subplot(4,6,17);
bilinear3 = imresize(final3,[230 230],'bilinear')
imshow(bilinear3);
error32 = immse(bilinear3,original);
title({['MSE=', num2str(error32)]})

subplot(4,6,18);
cubic3 = imresize(final3,[230 230],'cubic')
imshow(cubic3);
error33 = immse(cubic3,original);
title({['MSE=', num2str(error33)]})


% done with the sampling



