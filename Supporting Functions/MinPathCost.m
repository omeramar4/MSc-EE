function [min_path, paths_sum] = MinPathCost(distribution, paths, links)

paths_sum = zeros(size(paths,1),1);
for i = 1:size(paths,1)
    for j = 1:length(paths(i,:)) - 1
        if (paths(i,j + 1) == 0)
            break;
        end
        [~,link_index] = ismember([paths(i,j) paths(i,j + 1)],links,'rows');
        paths_sum(i) = paths_sum(i) + distribution(link_index);
    end
end

min_path = min(paths_sum);

end

