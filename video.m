vidObj = VideoReader('echo2.avi');

numFrames = 0;
frames = cell([],1);

% Read the frames

while hasFrame(vidObj)
    F = readFrame(vidObj);   
    numFrames = numFrames + 1;
    frames{numFrames} = F ;
end

totalMin = 0;
totalAvg = 0;
counter = 0;

for k = 1:numFrames
   index(k) = k;
   [mD(k), dA(k)] = main(frames{k});
   if ((mD(k) > 0) && (dA(k) > 0))
       totalMin = totalMin + mD(k);
       totalAvg = totalAvg + dA(k);
       counter = counter + 1;
   end
end

avgMinDist = totalMin / counter;
finalAvgDist = totalAvg / counter;

% Display the final values

T = table(index(:), mD(:), dA(:), 'VariableNames',{'Frame', 'MinimumDistance', 'AverageDistance'});
f = uifigure;
uit = uitable(f, 'Data', T);

message = sprintf('Final average distance is: %d Average Minimum Distance is: %d', finalAvgDist, avgMinDist);
uiwait(helpdlg(message));