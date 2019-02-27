function [ W,LastEstimated,avgs ] = EstimatePathCosts( FinalDestination,W,Dest,LastEstimated,avgs,Paths )
%This function is called every "UpdateWeightsJump" iteration. It calculates
%the average path cost realizations for every packet that has arrived to
%its destination.


sources = 0;
n = 1;
for i=1:length(Dest)
    LastIndex = (min(find([FinalDestination{Dest(i)}{:,2}] == 0))) - 1;
    if (isempty(LastIndex) || LastIndex == 0)
        continue;
    else
        tempCell = FinalDestination(Dest(i));
        tempMat = tempCell{1}((LastEstimated(Dest(i))+1):LastIndex,:);
        LastEstimated(Dest(i)) = LastIndex;
    end
    
    if (size(tempMat,1) == 0)
        continue;
    end
    
    for j=1:size(tempMat,1)
        tempMatRow = tempMat(j,:);
        cutTempMatZeros = (min(find([tempMatRow{1}] == 0))) - 1;
        cutTempMatPahts = (min(find([tempMatRow{6}] == 0))) - 1;
        tempPath = tempMatRow{6}(1:cutTempMatPahts);
        sumOfWeightsForPath = flip(tempMatRow{8}(1:length(tempPath) - 1));
        for k=1:cutTempMatZeros
            tempVec = [tempMatRow{1}(k) tempMatRow{2} tempMatRow{3} tempMatRow{4} tempMatRow{5} tempMatRow{6}(k) tempMatRow{7}(k) sumOfWeightsForPath(k)];
            sources(n) = tempVec(6);
            n = n + 1;
            try
                pathSerialNum = IsMember2(tempPath',Paths{tempPath(1),Dest(i)});
            catch
                break;
            end
            avgs{tempVec(6),Dest(i)}(pathSerialNum,3) = avgs{tempVec(6),Dest(i)}(pathSerialNum,3) + tempVec(8);
            avgs{tempVec(6),Dest(i)}(pathSerialNum,4) = avgs{tempVec(6),Dest(i)}(pathSerialNum,4) + 1;
            tempPath(1) = [];
        end
    end
    if (isempty(sources))
        sources = 0;
    end
    sources = unique(sources);
    if (ismember(0,sources))
        sources(find(sources == 0)) = [];
    end
    lenSrc = length(sources);
    for m=1:lenSrc
        len = size(avgs{sources(m),Dest(i)},1);
        for h=1:len
            if (avgs{sources(m),Dest(i)}(h,1) == 0) 
                continue; 
            end
            avgs{sources(m),Dest(i)}(h,1) = ((avgs{sources(m),Dest(i)}(h,1)*avgs{sources(m),Dest(i)}(h,2)) + avgs{sources(m),Dest(i)}(h,3))/(avgs{sources(m),Dest(i)}(h,2) + avgs{sources(m),Dest(i)}(h,4));  
            W{sources(m),Dest(i)}(h) = avgs{sources(m),Dest(i)}(h,1);
            avgs{sources(m),Dest(i)}(h,2) = avgs{sources(m),Dest(i)}(h,2) + avgs{sources(m),Dest(i)}(h,4);
            avgs{sources(m),Dest(i)}(h,3) = 0;
            avgs{sources(m),Dest(i)}(h,4) = 0;
        end
    end
end

end

