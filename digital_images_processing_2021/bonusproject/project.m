close all;
photo_in = imread('cameraman.tif');
width = size(photo_in,1)
height = size(photo_in,2)


% Quantization(Part A)
images=zeros(8,255,255);
uni_scalar(photo_in,8);


% Part B

% first level Haar(B1)
figure
imshowpair(photo_in,haar(photo_in), 'montage');
title('First Level Haar');

% second level Haar(B2)
figure
imshowpair(photo_in,two_level_haar(photo_in), 'montage');
% tlh = two_level_haar(photo_in)
% imshow(tlh, [min(min(tlh)), max(min(tlh))] );
title('Second Level Haar');

% quantization of Haar Levels(B3)
% level 1, with R=2
uni_scalar(haar(photo_in),2);

% level 2, with R=4
tlh = two_level_haar(photo_in);
uni_scalar(tlh(1:width/2,1:height/2),4);  % get only the second level Haar

% get entropy of subbands(B4)
H1 = entropy(tlh(width/2:width,1:height/2))
H2 = entropy(tlh(width/2:width,height/2:height))
H3 = entropy(tlh(1:width/2,1:height/2))
H4 = entropy(tlh(width/4:width/2,1:height/4))
H5 = entropy(tlh(width/4:width/2,height/4:height/2))
H6 = entropy(tlh(1:width/4,height/4:height/2))
H7 = entropy(tlh(1:width/4,1:height/4))

total_entropy = H1+H2+H3+H4+H5+H6+H7






    
    


