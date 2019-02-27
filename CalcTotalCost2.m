function [ W ] = CalcTotalCost2( Nodes,weights,links,paths,Dest )
%This function calculates the total cost of every path from every node to
%the defined destinations. This function is for fixed link weights. In this
%algorithm every weight is 1. 
%This function is implemented on undirected graph.

W = cell(length(Nodes),length(Nodes));
for i=1:length(Nodes)
    for m=1:length(Dest)
        temp = paths{i,Dest(m)};
        for j=1:size(temp,1)
            k = 1;
            sum = 0;
            while (temp(j,k)~=Dest(m))
                if (ismember([temp(j,k) temp(j,k+1)],links,'rows')==1)
                    [~,index]=ismember([temp(j,k) temp(j,k+1)],links,'rows');
                else
                    [~,index]=ismember([temp(j,k+1) temp(j,k)],links,'rows');
                end
                sum = sum + weights(index);
                k = k + 1;
            end
            W{i,Dest(m)}(j) = sum;
        end

        W{i,Dest(m)} = round(W{i,Dest(m)},1)';
    end
end

for i=1:length(Dest)
    W{Dest(i),Dest(i)} = 0;
end
end

