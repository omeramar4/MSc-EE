function [ W ] = SimpleHopCase( Hmin,Nodes,Dest )
%CHECK Summary of this function goes here
%   Detailed explanation goes here
W = cell(length(Nodes),length(Nodes));
for i =1:length(Nodes)
    for j=1:length(Dest)
        if (i==Dest(j))
            continue;
        end
        temp = Hmin(i,Dest(j));
        W{i,Dest(j)} = (temp:(length(Nodes)-1))';
    end
end
end

