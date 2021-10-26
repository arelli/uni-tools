original = imread('beach.tiff')  % load the image

close all;  % close all remaining open windows
figure;  % enable the window

%nearest-neighbour interpolation
subplot(3,2,1);
final = imresize(original,[115 58],'nearest', 'Antialiasing', true);  % rotate 90 degrees, downsample rows by factor 4, rotate -90 degrees
imshow(final)
title({['downsampled'],['rows:1/2,columns:1/4)']}) 

subplot(3,2,2);
linear1 = imresize(final,[230 230],'nearest')
imshow(linear1);
error11 = immse(linear1,original);  % image MSE(mean square error)
title({['Nearest-neighbour Interpolation'],['upsampled, MSE=', num2str(error11)],['PSNR=', num2str(psnr(linear1,original))]})

subplot(3,2,3);
final = imresize(original,[58 115],'nearest', 'Antialiasing', true);  % rotate 90 degrees, downsample rows by factor 4, rotate -90 degrees
imshow(final)
title({['downsampled'],['rows:1/4,columns:1/2)']}) 

subplot(3,2,4);
linear1 = imresize(final,[230 230],'nearest')
imshow(linear1);
error11 = immse(linear1,original);  % image MSE(mean square error)
title({['upsampled, MSE=', num2str(error11)],['PSNR=', num2str(psnr(linear1,original))]})

subplot(3,2,5);
final = imresize(original,[29 29],'nearest', 'Antialiasing', true);  % rotate 90 degrees, downsample rows by factor 4, rotate -90 degrees
imshow(final)
title({['downsampled'],['rows:1/8,columns:1/8)']}) 

subplot(3,2,6);
linear1 = imresize(final,[230 230],'nearest')
imshow(linear1);
error11 = immse(linear1,original);  % image MSE(mean square error)
title({['upsampled, MSE=', num2str(error11)],['PSNR=', num2str(psnr(linear1,original))]})




% bilinear interpolation
figure;
subplot(3,2,1);
final2 = imresize(original,[115 58],'bilinear');  
imshow(final2)
title({['downsampled'],['rows:1/2,columns:1/4)']}) 

subplot(3,2,2);
bilinear2 = imresize(final2,[230 230],'bilinear')
imshow(bilinear2);
error22 = immse(bilinear2,original);
title({['Bilinear Interpolation'],['upsampled,MSE=', num2str(error22)],['PSNR=', num2str(psnr(bilinear2,original))]});

subplot(3,2,3);
final2 = imresize(original,[58 115],'bilinear');  
imshow(final2)
title({['downsampled'],['rows:1/4,columns:1/2)']}) 

subplot(3,2,4);
bilinear2 = imresize(final2,[230 230],'bilinear')
imshow(bilinear2);
error22 = immse(bilinear2,original);
title({['upsampled, MSE=', num2str(error22)],['PSNR=', num2str(psnr(bilinear2,original))]});

subplot(3,2,5);
final2 = imresize(original,[29 29],'bilinear');  
imshow(final2)
title({['downsampled'],['rows:1/8,columns:1/8)']}) 

subplot(3,2,6);
bilinear2 = imresize(final2,[230 230],'bilinear')
imshow(bilinear2);
error22 = immse(bilinear2,original);
title({['upsampled, MSE=', num2str(error22)],['PSNR=', num2str(psnr(bilinear2,original))]});



% cubic interpolation
figure;
subplot(3,2,1);  
final3 = imresize(original,[115 58],'bicubic', 'Antialiasing', true);  
imshow(final3)
title({['downsampled'],['rows:1/2,columns:1/4)']}) 

subplot(3,2,2);
cubic3 = imresize(final3,[230 230],'bicubic')
imshow(cubic3);
error33 = immse(cubic3,original);
title({['BiCubic Interpolation'],['upsampled, MSE=', num2str(error33)]})

subplot(3,2,3);  
final3 = imresize(original,[58 115],'bicubic', 'Antialiasing', true);  
imshow(final3)
title({['downsampled'],['rows:1/4,columns:1/2)']}) 

subplot(3,2,4);
cubic3 = imresize(final3,[230 230],'bicubic')
imshow(cubic3);
error33 = immse(cubic3,original);
title({['upsampled, MSE=', num2str(error33)]})

subplot(3,2,5);  
final3 = imresize(original,[29 29],'bicubic', 'Antialiasing', true);  
imshow(final3)
title({['downsampled'],['rows:1/8,columns:1/8)']}) 

subplot(3,2,6);
cubic3 = imresize(final3,[230 230],'bicubic')
imshow(cubic3);
error33 = immse(cubic3,original);
title({['upsampled, MSE=', num2str(error33)]})



