function [ flow,F ] = Flows( Nodes,D )

%Calculate all possible flows in the network

    F1 = sum(ismember(Nodes,D));
    F2 = length(Nodes)-F1;
    F = (F1*(length(D)-1)) + (F2*length(D)); %The number of all possible flows  
    flow = zeros(F,2);
    n = 0;
    for i = 1:length(Nodes)
        for j = 1:length(D)
            if (i==D(j))
                continue;
            else
                n = n + 1;
                flow(n,1) = i;
                flow(n,2) = D(j);
            end
        end
    end
end

