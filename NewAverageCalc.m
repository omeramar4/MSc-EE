function [W] = NewAverageCalc(numOfPaths,tempMat,W)

tempVec = tempMat(:,9);
for i = 1:numOfPaths
    rowsOfPath = find(tempVec == i);
    if (isempty(rowsOfPath))
        continue;
    end
    costVec = tempMat(rowsOfPath,7);
    avg = mean(costVec);
    W{1,16}(i) = avg;
end

end

