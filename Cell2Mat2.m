function [PathsMat] = Cell2Mat2(PathsCell,Nodes)

numOfNodes = length(Nodes);
PathsMat = cell(numOfNodes);

for i = 1:numOfNodes
    for j = 1:numOfNodes
        if (isempty(PathsCell{i,j}))
            continue;
        end
        
        numOfPaths = size(PathsCell{i,j},1);
        maxPathLength = 0;
        for k = 1:numOfPaths
            if (length(PathsCell{i,j}{k}) > maxPathLength)
                maxPathLength = length(PathsCell{i,j}{k});
            end
        end
        PathsMat{i,j} = zeros(numOfPaths,maxPathLength);
        
        for k = 1:numOfPaths
            PathsMat{i,j}(k,:) = [PathsCell{i,j}{k} zeros(1,maxPathLength - length(PathsCell{i,j}{k}))];
        end
    end
end
end

