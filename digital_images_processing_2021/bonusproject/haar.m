function haar_output = haar(photo_in)
    width = size(photo_in,1);
    height = size(photo_in,2);

    %check if width and height is even
    if mod(width,2)~= 0 
        photo_padded = padarray(photo_in.',1,0,'post');
        photo_padded = photo_padded.';
    elseif mod(height,2)~= 0 
        photo_padded = padarray(photo_in,1,0,'post');
    else
        photo_padded = photo_in;
    end
    
    haar_output = zeros(width,height);
    haar_intermediate = zeros(width,height);
    
    photo_padded = photo_padded.';

    for x=1:2:width
        for y=1:1:height
           h0 = (photo_padded(x,y)+ photo_padded(x+1,y))/2;
           h1 = (photo_padded(x,y)- photo_padded(x+1,y))/2;
           haar_intermediate(ceil(x/2),y) = h0;
           haar_intermediate(width/2+ceil(x/2),y) = h1;
        end
    end
    
    haar_intermediate = haar_intermediate.';
    
    for x=1:2:width
        for y=1:1:height
           h0 = (haar_intermediate(x,y)+ haar_intermediate(x+1,y))/2;
           h1 = (haar_intermediate(x,y)- haar_intermediate(x+1,y))/2;
           haar_output(ceil(x/2),y) = h0;
           haar_output(width/2+ceil(x/2),y) = h1;
        end
    end

    %{
    % Reverse
    
    haar_intermediate =  haar_output;
     
    haar_intermediate = haar_intermediate.';
     
    for x=1:1:width/2
        for y=1:1:height
           haar_intermediate(2*x,y) = haar_intermediate(x,y)- haar_intermediate(ceil(width/2)+x,y);
           haar_intermediate(2*x+1,y) = haar_intermediate(x,y)+ haar_intermediate(ceil(width/2)+x,y);
        end
    end
   

    haar_intermediate = haar_intermediate.';
    
    for x=1:1:width/2
        for y=1:1:height
           haar_intermediate(2*x,y) = haar_intermediate(x,y)- haar_intermediate(ceil(width/2)+x,y);
           haar_intermediate(2*x+1,y) = haar_intermediate(x,y)+ haar_intermediate(ceil(width/2)+x,y);
        end
    end
    
    haar_output = haar_intermediate;
    

    %}
    
end

