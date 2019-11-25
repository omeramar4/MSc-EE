function [ Queue,DelayTrack,HowManyTrack,CountPackets,totalSimilarDecisions,totalDecisions,empiricTotalCost,genieTotalCost,NumOfTimesPathChosen,FinalDestination,FinalDestinationTracks ] = Step_0( flow,Queue,K,p,DelayTrack,start,HowManyTrack,W,CountPackets,pathsMeanCosts,totalSimilarDecisions,totalDecisions,distribution,Paths,links,empiricTotalCost,genieTotalCost,NumOfTimesPathChosen,FinalDestination,FinalDestinationTracks,flag)
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
        [~,weight] = max(-(K*temp_weights + Queue{sf,df}) + sqrt(2*log(start)./NumOfTimesPathChosen{sf,df}));
        [empiricMaxVal,empiricWeight] = min((K*temp_weights) + Queue{sf,df});
        NumOfTimesPathChosen{sf,df}(weight) = NumOfTimesPathChosen{sf,df}(weight) + 1;
        if (flag == 1)
            [FinalDestination,FinalDestinationTracks] = TakePath(sf,df,weight,distribution,Paths,links,start,FinalDestination,FinalDestinationTracks);
        end
        [genieMaxVal,genieWeight] = min(K*pathsMeanCosts{sf,df} + Queue{sf,df});
%         disp(['Decision index: Genie - ' num2str(genieWeight) ', Empiric - ' num2str(aaa)])
        totalDecisions = totalDecisions + 1;
        if (weight == genieWeight)% || abs(pathsMeanCosts{sf,df}(genieWeight) - W{sf,df}(weight)) <= 0.1)
            totalSimilarDecisions = totalSimilarDecisions + 1;
%         else
%             disp('************************************');
        end
        
        %Previous regret definition
        %---------
        %empiricTotalCost(length(empiricTotalCost) + 1) = MinPathCost(distribution(:,start),Paths{sf,df}(weight,:),links);
        %genieTotalCost(length(genieTotalCost) + 1) = MinPathCost(distribution(:,start),Paths{sf,df}(genieWeight,:),links);
        %---------
%         if (aaa == genieWeight)
%             empiricTotalCost(length(empiricTotalCost) + 1) = empiricTotalCost(length(empiricTotalCost));
%         else
%             empiricTotalCost(length(empiricTotalCost) + 1) = empiricTotalCost(length(empiricTotalCost)) + 1;
%         end
        empiricTotalCost(length(empiricTotalCost) + 1) = empiricMaxVal;
        genieTotalCost(length(genieTotalCost) + 1) = genieMaxVal;
        Queue{sf,df}(weight) = Queue{sf,df}(weight) + Af;
        HowManyTrack{sf,df}(weight) = HowManyTrack{sf,df}(weight) + 1;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),1}(1) = start; 
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),2} = sf;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),3} = df;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),4} = 0;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),5} = 0;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),6}(1) = sf;
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),7}(1) = W{sf,df}(weight);
        DelayTrack{sf,df}{weight}{HowManyTrack{sf,df}(weight),9} = weight;
    end
    j = j + 1;
end
end

