function [links] = CreateRandomGraph(V,E)

adj = spalloc(V, V, E);
idx = randperm(V * V, E+V);
idx(ismember(idx, 1:V+1:V*V)) = [];
idx = idx(1:E);
adj(idx) = 1;
adj = min( adj + adj.', 1);
matrix = full(adj);

links = zeros(E,2); 
k = 1;
for i=1:size(matrix,2)
    for j=1:size(matrix,1)
        if (matrix(i,j) == 1)
            links(k,:) = [i j];
            k = k + 1;
        end
    end
end

for i=1:size(links,1)
    [bool,row] = ismember(flip(links(i,:)),links,'rows');
    if (bool)
        links(row,:) = [];
    end
    if (i == size(links,1)) 
        break;
    end
end

links = sortrows(links);
G = digraph(links(:,1),links(:,2));
plot(G);

end


