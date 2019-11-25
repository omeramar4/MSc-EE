function [ W,LastEstimated,avgs ] = EstimatePathCosts2( FinalDestination,W,Dest,LastEstimated,avgs,Paths )

num_of_paths = size(Paths{1,3},1);
avg = cell(1,num_of_paths);
for i = 1:num_of_paths
    avg{i} = 0;
end

for i = 1:length(Dest)
    mat = FinalDestination{Dest(i)};
    last_row = (min(find([FinalDestination{Dest(i)}{:,2}] == 0))) - 1;
    for j=1:last_row
        path_taken = mat{j,6};
        weights_path_taken = mat{j,8};
        paths = Paths{mat{j,2},Dest(i)};
        for k = 1:size(paths,1)
            cut_zeros = (min(find(path_taken == 0))) - 1;
            if (isequal(path_taken(1:cut_zeros),paths(k,1:cut_zeros)'))
                avg{k} = [avg{k} weights_path_taken(cut_zeros - 1)];
                break
            end
        end
    end
    
    for j = 1:num_of_paths
        if (length(avg{j}) > 1)
            avg{j}(1) = [];
            W{1,3}(j) = mean(avg{j});
        end
    end
end

end
