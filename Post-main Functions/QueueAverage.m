function [ len ] = QueueAverage( queue,D,Nodes )
%QUEUE_LENGTH Summary of this function goes here
%   Detailed explanation goes here

len = zeros(length(Nodes),1);
for i=1:length(Nodes)
    avg = 0;
    count = 0;
    for j=1:length(D)
        for k=1:length(queue{i,D(j)})
            if (queue{i,D(j)}(k))
               avg = avg + queue{i,D(j)}(k);
               count = count + 1;
            end
        end
    end
    if (count==0)
        len(i) = 0;
    else
        len(i) = avg/count;
    end
end
end

