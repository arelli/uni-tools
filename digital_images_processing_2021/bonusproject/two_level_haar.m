function haar_output = two_level_haar(photo_in)
    width = size(photo_in,1);
    height = size(photo_in,2);

    haar_intermediate = haar(photo_in);
    
    % define the top left quarter
    haar_topleft = zeros(width/2,height/2);
    
    % get the top left quarter from 1st level haar
    for x=1:1:width/2
        for y=1:1:height/2
            haar_topleft(x,y) = haar_intermediate(x,y);
        end
    end
    
    % apply haar to top left quarter
    haar_topleft = haar(haar_topleft);
    
    % return top left haar'd image to main image
    for x=1:1:width
        for y=1:1:height
            if(y>height/2 || x>width/2)
                % keep lower left, lower right and upper right quarters
                haar_output(x,y) = haar_intermediate(x,y);
            else
                % replace upper left wuarter
                haar_output(x,y) = haar_topleft(x,y);
            end
        end
    end
       
    
end
