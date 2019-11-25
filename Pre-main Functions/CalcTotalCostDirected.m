function [ W ] = CalcTotalCostDirected(flows,Paths,Nodes)
%This function calculates the number of hops for every possible flow in the
%network. This is the starting point of the algorithm and only implemented
%once. This function is implemented only on directed graph.

W = cell(length(Nodes));

for i = 1:size(flows,1)
    src_dest = flows(i,:);
    paths_temp_mat = Paths{src_dest(1),src_dest(2)};
    W{src_dest(1),src_dest(2)} = 0.02*ones(size(paths_temp_mat,1),1);
%     
%     for j = 1:size(paths_temp_mat,1)
%         firstZero = min(find(paths_temp_mat(j,:) == 0));
%         if (isempty(firstZero))
%             firstZero = length(paths_temp_mat(j,:));
%         else
%             firstZero = firstZero - 1;
%         end
%         W{src_dest(1),src_dest(2)}(j) = firstZero - 1;
%     end
    
end


end

