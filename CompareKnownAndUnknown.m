function [MeanDistance] = CompareKnownAndUnknown(W,pathsMeanCosts,Nodes,flowPaths)

MeanDistance = cell(length(Nodes));

for i = 1:size(flowPaths,1)
    MeanDistance{flowPaths(i,1),flowPaths(i,2)} = abs(W{flowPaths(i,1),flowPaths(i,2)} - pathsMeanCosts{flowPaths(i,1),flowPaths(i,2)});
end

end

