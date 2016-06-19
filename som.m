clear all;

[rgb_image,gray_image] = readData('result1.dcm');

[sizex,sizey,sizez]=size(gray_image);

std1 = mean(mean(std(double(gray_image))));
    

for k = 1:sizez
    resultimage(:,:,k)=gray_image(:,:,k);
    dispx=32; 
    dispy=32;
    
    for l = 0:ceil(sizex/dispx)-1
        for g = 0:ceil(sizey/dispy)-1
            
            %Cgray_image = imcomplement();
            im = gray_image((l*dispx+1):(l*dispx+dispx),(g*dispy+1):(g*dispy+dispy),k);
            mean1=mean(im);
            m=mean(mean1);
            
            for i = (l*dispx+1) : (l*dispx+dispx)
                for j = (g*dispy+1) : (g*dispy+dispy)
                    gray_image(i,j,k)= (gray_image(i,j,k)-255*((gray_image(i,j,k)/(m))-1));
                end
            end
        end
    end
    %imshow(gray_image(:,:,k));
    
    
    thresh(:,:,k) = gray_image(:,:,k)<std1;
    %imshow(thresh(:,:,k));
    
end
    

for k=1:sizez
    min1 = min(resultimage(i,j,k));
    mean2 = median(median(max(resultimage(:,:,k))));
    for i=1:sizex
        for j=1:sizey
            if thresh(i,j,k) == 0 || resultimage(i,j,k) < mean2
                resultimage(i,j,k) = 0;
            end
        end
    end
    resultimage(:,:,k)=resultimage(:,:,k);
    imshow(resultimage(:,:,k));
end


for k = 1:sizez
    for i = 1:3
        rgb(:,:,i,k)= resultimage(:,:,k);
    end
end

dicomwrite(rgb,'result.dcm');
