function [ W ] = CalcTotalCostDirected(flows,Paths,Nodes)
%This function calculates the number of hops for every possible flow in the
%network. This is the starting point of the algorithm and only implemented
%once. This function is implemented only on directed graph.

W = cell(length(Nodes));

for i = 1:size(flows,1)
    src_dest = flows(i,:);
    paths_temp_mat = Paths{src_dest(1),src_dest(2)};
    W{src_dest(1),src_dest(2)} = zeros(size(paths_temp_mat,1),1);
end

end

