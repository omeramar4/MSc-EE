function [ Queue,DelayTrack,HowManyTrack,CountPackets,totalSimilarDecisions,totalDecisions,empiricTotalCost,genieTotalCost,NumOfTimesPathChosen,FinalDestination,FinalDestinationTracks,reward,rewardOpt,regret,NumOfTimesGenieChosen ] = Step_0( flow,Queue,K,p,DelayTrack,start,HowManyTrack,W,CountPackets,pathsMeanCosts,totalSimilarDecisions,totalDecisions,distribution,Paths,links,empiricTotalCost,genieTotalCost,NumOfTimesPathChosen,FinalDestination,FinalDestinationTracks,flag,reward,rewardOpt,regret,best_path,NumOfTimesGenieChosen)
% This function gives the next random flow of the network and decides in which 
% queue to put the packets in according to the 
% Shortest-Path-Aided Backpressure Algorithm in the paper
global known flow_time
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
        q = Queue{sf,df};
        best_q = q(best_path(sf,df));
        best_q = best_q - 3;
        best_q(best_q < 0) = 0;
        q(best_path(sf,df)) = best_q;
        q = (q*0.3)/10;
        if known == 0
%             map = zeros(length(temp_weights),1);
%             for i = 1:length(map)
%                 [~,m] = min(abs(q_levels - temp_weights(i)));
%                 map(i) = q(m);
%             end
%             olsb = (K*temp_weights + map);
            olsb = (K*temp_weights + q);
            olsb = olsb./max(olsb);
            [~, flow_index] = ismember([sf, df], flow, 'rows');
            [~,weight] = max(-olsb + sqrt(2*log(flow_time(flow_index))./NumOfTimesPathChosen{sf,df}));
            flow_time(flow_index) = flow_time(flow_index) + 1;
            NumOfTimesPathChosen{sf,df}(weight) = NumOfTimesPathChosen{sf,df}(weight) + 1;
%             genie_map = zeros(length(pathsMeanCosts{sf,df}),1);
%             for i = 1:length(map)
%                 [~,m] = min(abs(q_levels - pathsMeanCosts{sf,df}(i)));
%                 genie_map(i) = q(m);
%             end
%             [~,genieWeight] = min(K*pathsMeanCosts{sf,df} + genie_map);
            [~,genieWeight] = min(K*pathsMeanCosts{sf,df} + q);
            reward = reward + temp_weights(weight);
            rewardOpt = rewardOpt + temp_weights(genieWeight);
            regret{sf,df}(length(regret{sf,df}) + 1) = reward - rewardOpt;
%             if (flag == 1)
%                 [FinalDestination,FinalDestinationTracks] = TakePath(sf,df,weight,distribution,Paths,links,start,FinalDestination,FinalDestinationTracks);
%             end
%             g = temp_weights;
%             if start < 150000
            
%             else
%                 [genieBestVal,genieWeight] = max(-(K*pathsMeanCosts{sf,df} + q) + sqrt(2*log(start)./NumOfTimesPathChosen{sf,df}));
%                 a = randsrc(1,1,[0 1;0.2 0.8]);
%                 if a == 1
%                     g = temp_weights;
%                 else
%                     g = pathsMeanCosts{sf,df};
%                 end
%             end
%             NumOfTimesGenieChosen{sf,df}(genieWeight) = NumOfTimesGenieChosen{sf,df}(genieWeight) + 1;
%             if (abs(genieBestVal - empiricBestVal) < epsilon)
%                 empiricBestVal = genieBestVal;
%             end
%             totalDecisions = totalDecisions + 1;
%             if (weight == genieWeight)
%                 totalSimilarDecisions = totalSimilarDecisions + 1;
%             end
%             empiricTotalCost(length(empiricTotalCost) + 1) = empiricBestVal;
%             genieTotalCost(length(genieTotalCost) + 1) = genieBestVal;
        elseif known == 1
            [~,weight] = min(K*temp_weights + q);
%             [~,weight] = min(K*temp_weights);
%             [~,weight] = min(Queue{sf,df});
            NumOfTimesPathChosen{sf,df}(weight) = NumOfTimesPathChosen{sf,df}(weight) + 1;
        end
%         est_w = temp_weights(weight);
%         [~,level] = min(abs(q_levels - est_w));
%         weight = level;
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

