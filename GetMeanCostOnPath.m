function [costs] = GetMeanCostOnPath(src,dst,links,paths,mu)
%GETMEANCOSTONPATH Summary of this function goes here
%   Detailed explanation goes here

len = size(paths{src,dst},1);
costs = zeros(len,1);


for i = 1:len
    tempPath = paths{src,dst}(i,:);
    for j = 2:length(tempPath)
        if (tempPath(j) == 0)
            break;
        end
        [~,linkIndex] = ismember([tempPath(j - 1) tempPath(j)],links,'rows');
        if (linkIndex == 0)
            [~,linkIndex] = ismember([tempPath(j) tempPath(j - 1)],links,'rows');
        end
        costs(i) = costs(i) + mu(linkIndex);
    end
end


end

