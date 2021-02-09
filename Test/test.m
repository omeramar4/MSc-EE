%% SETUP
% s = [1 1 2 2 3 3 4 5 5 6 6 7 7 8 9 9 10 10 11 11 12 13 14 15];     %Sources
% t = [2 5 3 6 4 7 8 6 9 7 10 8 11 12 10 13 11 14 12 15 16 14 15 16];    %Targets
% s = [1 1 2 2 3 4 4 5 5 6 7 8]';     %Sources
% t = [2 4 3 5 6 5 7 6 8 9 8 9]';    %Targets
% g = digraph(s,t);

% %% getpaths
% paths = cell(length(unique(t)));
% nodes = unique(s);
% for i = 1:length(nodes)
%     g = digraph(s,t);
%     paths{nodes(i),9} = getpaths(g);
%     ex_node = i;
%     ex_node_ind = find(s == ex_node);
%     s(ex_node_ind) = [];
%     t(ex_node_ind) = [];
% end

%% pathsbetweennodes
[s, t] = create_links(10);
nnode = max(s);
nedge = length(s);
adj = sparse(s,t,ones(nedge,1),nnode,nnode);
paths = cell(nnode);
for i = 1:nnode
    for j = 1:nnode
        if j > i
            paths{i,j} = pathbetweennodes(adj,i,j);
        end
        disp([i j]);
    end
end

% %% pathof
% paths = pathof(g,2,9);
