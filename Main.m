function [delay_regret,regret_result,q_regret] = Main( K,p,S,t,o,k )
%This function calculates:
%1. End-to-End Delay Average.
%2. Total Path Cost Average of all successful transmitions
%3. Per-Node Queue Length Average
%4. Paths costs

%Settings and Struct Extraction
%---------------------------------------------------------
global known
N = S.Iterations;
W = S.TotalPathCosts;
weights = S.WeightsOfLinks;
Queue = S.Queue;
Dest = S.Destinations;
links = S.Links;
flow = S.Flows;
Gamma = S.Gamma;
Nodes = S.Nodes;
flowPaths = S.flowPaths;
DelayTrack = S.DelayTrack;
HowManyTrack = S.HowManyTrack;
WhosNextTrack = S.WhosNextTrack;
FinalDestination = S.FinalDestination;
FinalDestinationTracks = S.FinalDestinationTracks;
avgs = S.avgs;
distribution = S.distribution;
Paths = S.Paths;
pathsMeanCosts = S.pathsMeanCosts;
isDirected = S.isDirected;
UpdateWeightsJump = S.UpdateWeightsJump;
NumOfTimesPathChosen = S.NumOfTimesPathChosen;
allTheWayFlag = S.allTheWayFlag;
best_path = S.best_path;

NumOfTimesGenieChosen = NumOfTimesPathChosen;
delay_regret = zeros(1,N/UpdateWeightsJump);
q_regret = zeros(1,N/UpdateWeightsJump);
empiricTotalCost = 0;
genieTotalCost = 0;
totalDecisions = 0;
totalSimilarDecisions = 0;
NumberOfLinks = size(links,1);   %Number of links in the network
schedule = size(Gamma,1);   %Number of possible schedules
QueueLengths = zeros(length(Nodes),N);  
EstimateIndex = 0;
LastEstimated = zeros(length(Nodes),1);
EstimatedW = cell(1,size(flow,1));
CountPackets = 0;
regret = cell(length(Nodes));
for c = 1:size(flow, 1)
    regret{flow(c, 1), flow(c, 2)} = 0;
end
reward = 0;
rewardOpt = 0;
prevDispValue = 1000;
for i=1:size(flow,1)
    EstimatedW{i} = [W{flow(i,1),flow(i,2)} zeros(length(W{flow(i,1),flow(i,2)}),N/UpdateWeightsJump)];
end
%---------------------------------------------------------
prevMaxValue = 0;
%MAIN LOOP   
%*********************************************************
for i=1:N
    
    %STEP 0 - Shortest-Path-Aided Backpressure Algorithm
    %Deciding in which queue to inject the packet created with
    %probability p
    %-----------------------------------------------------
    [Queue,DelayTrack,HowManyTrack,CountPackets,totalSimilarDecisions,totalDecisions,empiricTotalCost,genieTotalCost,NumOfTimesPathChosen,FinalDestination,FinalDestinationTracks,reward,rewardOpt,regret,NumOfTimesGenieChosen] = Step_0(flow,Queue,K,p,DelayTrack,i,HowManyTrack,W,CountPackets,pathsMeanCosts,totalSimilarDecisions,totalDecisions,distribution,Paths,links,empiricTotalCost,genieTotalCost,NumOfTimesPathChosen,FinalDestination,FinalDestinationTracks,allTheWayFlag,reward,rewardOpt,regret,best_path,NumOfTimesGenieChosen);
    %-----------------------------------------------------

    %Ignore middle transfers of data, take packets all the way
    %-----------------------------------------------------
%     if (allTheWayFlag == 1)
%         if (~mod(i,UpdateWeightsJump))
%             tempVec = FinalDestination{16}(:,1);
%             LastIndex = min(find(tempVec == 0)) - 1;
%             [W] = NewAverageCalc(size(Paths{1,16},1),FinalDestination{16}(1:LastIndex,:),W);
%         end
%         continue;
%     end
    %-----------------------------------------------------
    
    %Create Backpressure matrix by links, The number of row is the source
    %and the number of column is the destination of each link
    %---------------------------------------------------------
    [P,max_queue] = Pcreator(links,Queue,W,Dest,Nodes,isDirected); 
    %---------------------------------------------------------
    
    %Calculate the average queue length of each node, the row represents the
    %node and the column represents the iteration
    %---------------------------------------------------------
    QueueLengths(:,i) = QueueAverage(Queue,Dest,Nodes);
    %---------------------------------------------------------
    
    %STEP 1 - Shortest-Path-Aided Backpressure Algorithm
    %-----------------------------------------------------
    [max_index,allTheWayFlag] = Step_1(P,schedule,NumberOfLinks,Gamma,links,isDirected);
    %-----------------------------------------------------
    
    %STEP 2 - Shortest-Path-Aided Backpressure Algorithm
    %-----------------------------------------------------
    if (max_index ~= 0)
        [Queue,DelayTrack,HowManyTrack,FinalDestination,FinalDestinationTracks,WhosNextTrack] = Step_2(max_queue,Gamma,max_index,P,links,Queue,weights,DelayTrack,HowManyTrack,i,FinalDestination,FinalDestinationTracks,WhosNextTrack,distribution,allTheWayFlag,isDirected);
    end
    %-----------------------------------------------------
    
    %Estimate new weights
    %-----------------------------------------------------
    if (~mod(i,UpdateWeightsJump))
        if known == 0
            [W, LastEstimated, avgs] = EstimatePathCosts(FinalDestination,W,Dest,LastEstimated,avgs,Paths);
            EstimateIndex = EstimateIndex + 1;
        end
        delay_regret(i/UpdateWeightsJump) = CalcDelayAverage2(FinalDestination,Dest);
        q_regret(i/UpdateWeightsJump) = mean(mean(QueueLengths(QueueLengths>0),2));
    end
    %-----------------------------------------------------
    
    %Display test, probability, K-parameter and iteration
    if (~mod(i,1000))
        disp([num2str(t) '  ' num2str(o) '  ' num2str(k) '  ' num2str(i)]);
%         if (prevDispValue >= max(regret{flow(1,1),flow(1,2)}) - prevMaxValue)
%             cprintf('Green', [num2str(max(regret{flow(1,1),flow(1,2)})) '      ' num2str(max(regret{flow(1,1),flow(1,2)}) - prevMaxValue) '\n'])
%         else
%             cprintf('Red', [num2str(max(regret{flow(1,1),flow(1,2)})) '      ' num2str(max(regret{flow(1,1),flow(1,2)}) - prevMaxValue) '\n'])
%         end
% %         disp([num2str(max(regret)) '      ' num2str(max(regret) - prevMaxValue)]);
%         prevDispValue = max(regret{flow(1,1),flow(1,2)}) - prevMaxValue;
%         prevMaxValue = max(regret{flow(1,1),flow(1,2)});
%         disp(['Estimated mean value of best path: ' num2str(W{flow(1,1),flow(1,2)}(best_path(flow(1,1),flow(1,2))))]);
%         disp(['Actual mean value of best path: ' num2str(pathsMeanCosts{flow(1,1),flow(1,2)}(best_path(flow(1,1),flow(1,2))))]);
%         disp(['Number of times best path was selected: ' num2str(NumOfTimesPathChosen{flow(1,1),flow(1,2)}(best_path(flow(1,1),flow(1,2))))]);
%         disp('-------------------------------');
    end
    
end
%*********************************************************s DelayAverage = CalcDelayAverage(FinalDestination,Dest);
% MeanDistance = CompareKnownAndUnknown(W,pathsMeanCosts,Nodes,flowPaths);
if known == 0
    regret_max_len = 0;
    regrets = cell(size(flow, 1), 1);
    for c = 1:size(flow, 1)
        regrets{c} = regret{flow(c, 1), flow(c, 2)};
        if (length(regrets{c}) > regret_max_len)
            regret_max_len = length(regrets{c});
        end
    end
    regret_mat = zeros(size(flow, 1), regret_max_len);
    for c = 1:size(flow, 1)
        regret_mat(c,1:length(regrets{c})) = regrets{c};
    end
    regret_mat(:,1) = [];
    regret_mat(regret_mat == 0) = NaN;
    if size(regret_mat, 1) > 1 
        regret_result = mean(regret_mat, 'omitnan');
    else
        regret_result = regret_mat;
    end
end
% QueueLengths = QueueLengths(QueueLengths>0);
% QueueLengthAverage = mean(mean(QueueLengths,2));

%CALCULATE RESULTS
%---------------------------------------------------------
% LastIndex = 0;
% for i=1:length(Dest)
%     LastIndex = LastIndex + (min(find([FinalDestination{Dest(i)}{:,2}] == 0))) - 1;
% end
% 
% empiricTotalCost(1) = [];
% genieTotalCost(1) = [];
% regret1 = MeanVector(empiricTotalCost);
% regret2 = MeanVector(genieTotalCost);
% regret = regret1 - regret2;
% DecisionDistance = totalDecisions - totalSimilarDecisions;
% DecisionRatio = totalSimilarDecisions/totalDecisions;
% MeanDistance = CompareKnownAndUnknown(W,pathsMeanCosts,Nodes,flowPaths);
% SuccessfulTranferRate = LastIndex/CountPackets;
% QueueLengths = QueueLengths(QueueLengths>0);
%  
%---------------------------------------------------------
end

