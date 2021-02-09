function [ queue,delay_track,track,fifo_track,NumOfTimesPathChosen ] = InitializeQueueAndTracking(N,queue,Weights,flow,delay_track,track,fifo_track,NumOfTimesPathChosen)
global M
%Initialize the queue with random packets in every possible queue

for i = 1:size(flow,1)
    queue_size = length(Weights{flow(i,1),flow(i,2)});
    queue{flow(i,1),flow(i,2)} = zeros(queue_size,1);
    NumOfTimesPathChosen{flow(i,1),flow(i,2)} = ones(queue_size,1);
    delay_track{flow(i,1),flow(i,2)} = cell(queue_size,1);
    for j=1:length(Weights{flow(i,1),flow(i,2)})
        delay_track{flow(i,1),flow(i,2)}{j} = cell(N,9);
        delay_track{flow(i,1),flow(i,2)}{j}(:,[1 6 7 8]) = {zeros(100,1)};
    end   
    track{flow(i,1),flow(i,2)} = zeros(queue_size,1);
    fifo_track{flow(i,1),flow(i,2)} = ones(queue_size,1);
end

% for i = 1:size(flow,1)
%     queue{flow(i,1),flow(i,2)} = zeros(M,1);
%     NumOfTimesPathChosen{flow(i,1),flow(i,2)} = ones(length(Weights{flow(i,1),flow(i,2)}),1);
%     delay_track{flow(i,1),flow(i,2)} = cell(M,1);
%     for j=1:M
%         delay_track{flow(i,1),flow(i,2)}{j} = cell(N,9);
%         delay_track{flow(i,1),flow(i,2)}{j}(:,[1 6 7 8]) = {zeros(100,1)};
%     end   
%     track{flow(i,1),flow(i,2)} = zeros(M,1);
%     fifo_track{flow(i,1),flow(i,2)} = ones(M,1);
% end

end

