function [pathSerialNum] = IsMember2(vec,lookUpMat)

numOfPaths = size(lookUpMat,1);

for i = 1:numOfPaths
    firstZeroIndex = min(find(lookUpMat(i,:) == 0));
    if (isempty(firstZeroIndex))
        firstZeroIndex = length(lookUpMat(i,:)) + 1;
    end
    tempPath = lookUpMat(i,1:firstZeroIndex - 1);
    if (length(tempPath) ~= length(vec))
        continue;
    else
        if (isequal(vec,tempPath) == 1)
            pathSerialNum = i;
        end
    end
end

end

