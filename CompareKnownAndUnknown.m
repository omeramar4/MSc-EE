function [MeanDistance] = CompareKnownAndUnknown(W,pathsMeanCosts,Nodes,flowPaths)
%After the main loop ends, this function calculates the distance between
%the mean value of the paths distributions and the approximation of paths'
%cost calculated in the main loop.

MeanDistance = cell(length(Nodes));

for i = 1:size(flowPaths,1)
    MeanDistance{flowPaths(i,1),flowPaths(i,2)} = abs(W{flowPaths(i,1),flowPaths(i,2)} - pathsMeanCosts{flowPaths(i,1),flowPaths(i,2)});
end

end

