[set, gset] = readData('Series_4_3DTOF 2 slab.dcm');

[sizex,sizey,sizez] = size(gset);

bmax = 0
counter = 1;
while bmax == 0 && counter <= sizez
    % imshow(gset(:, :, counter));

    % binarize image using standard deviation
    
    std1 = mean(mean(std(double(gset))));
    tset = gset > std1;
    % imshow(tset(:, :, 26));
    fset = imfill(tset, 'holes');
    % imshow(fset(:, :, 26));

    % Complement of the image

    cset(:, :, counter) = imcomplement(fset(:, :, counter));
    % imshow(cset(:, :, 26), []);

    % 2D wavelet decompsition

    [C,S] = wavedec2(cset(:, :, counter), 2, 'db1');
    sizeA = S(1, :);
    A1 = appcoef2(C, S, 'db1', 2);

    % Re-composition of the image
    % imshow(A1);

    % Resize image using interpolation
    % rset = imresize(A1, 4);
    % imshow(rset);

    % Re-complement

    % rcset = imcomplement(rset);
    % imshow(rcset);

    % Labeling Image

    [L, NUM] = bwlabeln(A1);
    lset = imresize(L, 4);
    % imshow(lset);

    % extract Largest connected component
    llset = logical(lset);
    biggest4 = bwareafilt(logical(llset), 1, 'largest');
    % imshow(biggest4);

    % complement and fill
    clset = imcomplement(biggest4);
    fclset = imfill(clset, 'holes');
    % imshow(fclset);

    % dfclset = imerode(fclset)

    % select largest connected component again
    b4 = bwareafilt(fclset, 1, 'largest');
    % imshow(b4);

    % convexhull of the image
    CH = bwconvhull(b4, 'objects');
    test = imerode(CH,strel('disk',100));
    
    if max(max(test)) == 0
        CH1 = prev;
        % imshow(CH);
        bmax = 1
        imshow(test);
    
    end
    
    prev = CH; 
    % scalar prduct of convexhull with original image
    for i = 1:sizex
        for j = 1:sizey
            nset(i, j, counter) = double(CH(i, j)) * double(gset(i, j, counter));
        end
    end
    
    
    
    % imshow(nset, []);
    counter = counter + 1
end

while counter <= sizez
    for i = 1:sizex
        for j = 1:sizey
            nset(i, j, counter) = double(CH1(i, j)) * double(gset(i, j, counter));
        end
    end
    counter=counter+1;
end

for k = 1:sizez
    for i = 1:3
        rgb(:,:,i,k)= nset(:,:,k);
    end
end
dicomwrite(uint8(rgb), 'result1.dcm');
