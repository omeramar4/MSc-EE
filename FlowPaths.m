function [ flowPaths ] = FlowPaths( Nodes,flow,Paths )
%FLOWPATHS Summary of this function goes here
%   Detailed explanation goes here

flowPaths = 0;
firstTimeFlag = 0;
n = size(flow,1);

for i = 1:n
    src = flow(i,1);
    dest = flow(i,2);
    paths_mat = Paths{src,dest};
        
    for j = 1:length(Nodes)
        if (j == dest)
            continue;
        end
        if (ismember(j,paths_mat))
            if (firstTimeFlag)
                flowPaths = [flowPaths; j dest];
            else
                firstTimeFlag = 1;
                flowPaths = [j dest];
            end
        end
    end
    
end

flowPaths = sortrows(flowPaths,2);









% if (ismember(1,Dest))
%     flowPaths = [ones(length(Dest)-1,1) Dest(Dest~=1)'];
% else
%     flowPaths = [ones(length(Dest),1) Dest'];
% end
% for i=2:length(Nodes)
%     if (ismember(i,Dest))
%         flowPaths = [flowPaths; i*ones(length(Dest)-1,1) Dest(Dest~=i)'];
%     else
%         flowPaths = [flowPaths; i*ones(length(Dest),1) Dest'];
%     end
% end
end
