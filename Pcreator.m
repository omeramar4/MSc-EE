function [ P,max_queue ] = Pcreator( Gmat,queue,W,D,Nodes,isDirected )
%PCREATOR2 Summary of this function goes here
%   Detailed explanation goes here

max_queue = cell(length(Nodes));
P = zeros(length(Nodes));

if (isDirected == 1)
    a = 1;
else
    a = 2;
end

for i=1:size(Gmat,1)
    src = Gmat(i,1);
    dst = Gmat(i,2);
    queueP = zeros(1,a);
    for t=1:a
        if (t==2)
            dst = Gmat(i,1);
            src = Gmat(i,2);
        end
        for j=1:length(D)  
            for k=1:length(W{src,D(j)})       %Every weight from m

                if (dst==D(j))
                    if (queue{src,D(j)}(k)>queueP(t))
                        queueP(t) = queue{src,D(j)}(k);
                        max_queue{src,dst} = [D(j) W{src,D(j)}(k) k 0 0];
                    end
                    continue;
                end
                
                possQueue = find(W{dst,D(j)}<=W{src,D(j)}(k));
                if (length(possQueue)<1)
                    continue;
                end
                for q=1:length(possQueue)
                    if (queue{src,D(j)}(k) - queue{dst,D(j)}(possQueue(q))>queueP(t))
                        queueP(t) = queue{src,D(j)}(k) - queue{dst,D(j)}(possQueue(q));
                        max_queue{src,dst} = [D(j) W{src,D(j)}(k) k W{dst,D(j)}(possQueue(q)) possQueue(q)];
                    end
                end
                
            end
        end
    end
    [max_temp,I] = max([queueP 0]);
    if (max_temp == 0 || I == 3)
        continue;
    elseif (I == 2 && isDirected == 0)
        P(src,dst) = max_temp;
        max_queue{dst,src} = [];
    elseif (I == 1 && isDirected == 0)
        P(dst,src) = max_temp;
        max_queue{src,dst} = [];
    elseif (I == 1 && isDirected == 1)
        P(src,dst) = max_temp;
        max_queue{dst,src} = [];
    end
end

end

