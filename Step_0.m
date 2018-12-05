function [ Queue,DelayTrack,HowManyTrack,CountPackets,totalSimilarDecisions,totalDecisions ] = Step_0( flow,Queue,K,p,DelayTrack,start,HowManyTrack,W,CountPackets,pathsMeanCosts,totalSimilarDecisions,totalDecisions )
% This function gives the next random flow of the network and decides in which 
% queue to put the packets in according to the 
% Shortest-Path-Aided Backpressure Algorithm in the paper
    
f = flow(:,1);
j = 1;
while (j<=max(f))
    Af = poissrnd(p);
    if (Af > 0)
        
        node = find(f==j);
        if (length(node)==1)
            rand = 1;
        elseif (length(node)>1)
            rand = randi([1 length(node)]);
        else
            j = j + 1;
            continue;
        end
        
        CountPackets = CountPackets + Af;    
        curr_flow = flow(node(rand),:);  
        sf = curr_flow(1);
        df = curr_flow(2);
        temp_weights = W{sf,df};
        [~,weight] = min((K*temp_weights) + Queue{sf,df});
        [~,genieWeight] = min((K*pathsMeanCosts{sf,df}) + Queue{sf,df});
        totalDecisions = totalDecisions + 1;
        if (weight == genieWeight)
            totalSimilarDecisions = totalSimilarDecisions + 1;
        end
        Queue{sf,df}(weight) = Queue{sf,df}(weight) + Af;
        HowManyTrack{sf,df}(weight) = HowManyTrack{sf,df}(weight) + 1;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),1}(1) = start; 
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),2} = sf;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),3} = df;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),4} = 0;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),5} = 0;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),6}(1) = sf;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),7}(1) = W{sf,df}(weight);
    end
    j = j + 1;
end
end

