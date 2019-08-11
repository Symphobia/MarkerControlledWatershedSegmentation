function [minDistance, avgDistance] = main1(readImg)

    img = rgb2gray(readImg);
    subplot(1,2,1), imshow(img);

    % Define the structuring element width
    w = 47;
    strElement = strel('square', w);

    imgEroded = imerode(img, strElement);
    imgRecon = imreconstruct(imgEroded, img);

    imgReconComp = imcomplement(imgRecon);
    imgEroded2 = imerode(imgReconComp, strElement);
    imgRecon2 = imreconstruct(imgEroded2, imgReconComp);

    fgm = imregionalmax(imgRecon2);

    distTrans = bwdist(fgm);
    wLines= watershed(distTrans);
    bgm = wLines == 0;

    seSquare3 = strel('square', 3);
    rangeImg = rangefilt(imgRecon2, getnhood(seSquare3));
    segFunc = imimposemin(rangeImg, fgm | bgm);
    grayLabel = watershed(segFunc);

    rgbLabel = label2rgb(grayLabel);
    subplot(1,2,2), imshow(rgbLabel); title('Watershed')

    % Object boundaries

    blueChannel = rgbLabel(:, :, 3);
    threshold = 254;
    outline = blueChannel <= threshold;
    subplot(1,2,2), imshow(outline);

    axis on;
    hold on;
    boundaries = bwboundaries(outline);
    boundaryCount = size(boundaries, 1);
    for k = 1 : boundaryCount
        fBoundary = boundaries{k};
        plot(fBoundary(:,2), fBoundary(:,1), 'r', 'LineWidth', 3);
    end
    hold off;

    boundaryCount = size(boundaries, 1);
    
if (boundaryCount == 2)   
    boundary1 = boundaries{1};
    boundary2 = boundaries{2};
    boundary1x = boundary1(:,2);
    boundary1y = boundary1(:,1);
    x1 = 1;
    x2 = 1;
    y1 = 1;
    y2 = 1;
    overallMinDistance = inf;

    % Drawing minimum distance

    for k = 1 : size(boundary2, 1)
        boundary2x = boundary2(k, 2);
        boundary2y = boundary2(k, 1);
        allDistances = sqrt((boundary1x - boundary2x).^2 + (boundary1y - boundary2y).^2);
        [minDistance(k), indexOfMin] = min(allDistances);
        if minDistance(k) < overallMinDistance
            x1 = boundary1x(indexOfMin);
            y1 = boundary1y(indexOfMin);
            x2 = boundary2x;
            y2 = boundary2y;
            overallMinDistance = minDistance(k);  
            finalIndex = indexOfMin;
            kFinal = k;
        end  
    end

    minDistance = min(minDistance);

    line([x1, x2], [y1, y2], 'Color', 'y', 'LineWidth', 3);
    
    message2 = sprintf('Min distance: %d', minDistance);
    uiwait(helpdlg(message2));

    % Drawing average distance

    count = 0;

    for k = finalIndex-25:finalIndex+25
        a1 = boundary1x(k);
        b1 = boundary1y(k);
        for u = kFinal-25:kFinal+25
            if ((length(boundary2) > kFinal + 25) && kFinal > 25)
                if b1 == boundary2(u,1)
                    count = count + 1;
                    a2 = boundary2(u,2);
                    b2 = boundary2(u,1);
                    line([a1, a2], [b1, b2], 'Color', 'y', 'LineWidth', 3);
                    dist(count) = sqrt((a1-a2).^2 + (b1-b2).^2);
                end
            end
         end
    end
    
    distTotal = 0;

    for k = 1:count
        distTotal = distTotal + dist(k);
    end
    
    avgDistance = distTotal / count;
    avgDistance
    
    message3 = sprintf('Average distance: %d', avgDistance);
    uiwait(helpdlg(message3));
    
else
    minDistance = 0;
    avgDistance = 0;
end
end