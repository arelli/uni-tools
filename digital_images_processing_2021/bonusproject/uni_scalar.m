% phase A of the project
% Image Quantization from Lecture 12
function uni_scalar(photo_in, r_arg)
    A = 255; % the range of the image values
    errors = zeros(8,1);
    for R = 0 : r_arg
        L = 2^R; 
        D = (2*A+1)/L;  %length of the quantization levels
        Q = D*sign(photo_in).*floor((abs(photo_in)/D)+1/2);  % ".*" is elementwise multiplication
        %scaled_images(i)=Q;  % to hold all levels of quantized images
        %figure
        %imshow(Q);
        errors(R+1) = immse(photo_in,Q);
        %title(['level '  num2str(L)  ' quantization, with MSE=' num2str(errors(R+1)) ' and Entropy=' num2str(entropy(Q))]);
        
        %figure
        %x = -10:0.1:10*(2*A+1)/10;
        %plot(sign(x).*floor((abs(x)/D)+1/2));
        %title(['level '  num2str(L)  ' characteristic function']);
    end
    R = 1:1:r_arg+1;
    figure
    plot(errors(R));
    title('rate-distortion curve D(R)');
end

