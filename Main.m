function [ QueueLengthAverage,DelayAverage,SuccessfulTranferRate,MeanDistance,DecisionDistance,totalDecisions ] = Main( K,p,S,t,o,k )
%This function calculates:
%1. End-to-End Delay Average.
%2. Total Path Cost Average of all successful transmitions
%3. Per-Node Queue Length Average
%4. Paths costs

%Settings and Struct Extraction
%---------------------------------------------------------
N = S.Iterations;
W = S.TotalPathCosts;
weights = S.WeightsOfLinks;
Queue = S.Queue;
Dest = S.Destinations;
links = S.Links;
flow = S.Flows;
flowPaths = S.flowPaths;
Gamma = S.Gamma;
Nodes = S.Nodes;
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

bestTotalCost = 0;
emphiricTotalCost = 0;

totalDecisions = 0;
totalSimilarDecisions = 0;
NumberOfLinks = size(links,1);   %Number of links in the network
schedule = size(Gamma,1);   %Number of possible schedules
QueueLengths = zeros(length(Nodes),N);  
EstimateIndex = 0;
LastEstimated = zeros(length(Nodes),1);
EstimatedW = cell(1,size(flow,1));
CountPackets = 0;
for i=1:size(flow,1)
    EstimatedW{i} = [W{flow(i,1),flow(i,2)} zeros(length(W{flow(i,1),flow(i,2)}),N/UpdateWeightsJump)];
end
%---------------------------------------------------------

%MAIN LOOP   
%*********************************************************
for i=1:N

    %STEP 0 - Shortest-Path-Aided Backpressure Algorithm
    %Deciding in which queue to inject the packet created with
    %probability p
    %-----------------------------------------------------
    [Queue,DelayTrack,HowManyTrack,CountPackets,totalSimilarDecisions,totalDecisions,emphiricTotalCost] = Step_0(flow,Queue,K,p,DelayTrack,i,HowManyTrack,W,CountPackets,pathsMeanCosts,totalSimilarDecisions,totalDecisions,distribution,Paths,links,emphiricTotalCost);
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
    [max_index,flag] = Step_1(P,schedule,NumberOfLinks,Gamma,links,isDirected);
    %-----------------------------------------------------
    
    %STEP 2 - Shortest-Path-Aided Backpressure Algorithm
    %-----------------------------------------------------
    if (max_index ~= 0)
        [Queue,DelayTrack,HowManyTrack,FinalDestination,FinalDestinationTracks,WhosNextTrack] = Step_2(max_queue,Gamma,max_index,P,links,Queue,weights,DelayTrack,HowManyTrack,i,FinalDestination,FinalDestinationTracks,WhosNextTrack,distribution,flag,isDirected);
    end
    %-----------------------------------------------------
    
    %Estimate new weights
    %-----------------------------------------------------
    if (~mod(i,UpdateWeightsJump))
        [W, LastEstimated, avgs] = EstimatePathCosts(FinalDestination,W,Dest,LastEstimated,avgs,Paths);
        EstimateIndex = EstimateIndex + 1;
    end
    %-----------------------------------------------------
    
    %Display test, probability, K-parameter and iteration
    disp([num2str(t) '  ' num2str(o) '  ' num2str(k) '  ' num2str(i)]);
    
end
%*********************************************************

%CALCULATE RESULTS
%---------------------------------------------------------
LastIndex = 0;
for i=1:length(Dest)
    LastIndex = LastIndex + (min(find([FinalDestination{Dest(i)}{:,2}] == 0))) - 1;
end
emphiricTotalCost(1) = [];
bestTotalCost = ones(1,length(emphiricTotalCost))*min(pathsMeanCosts{1,15});
bestTotalCost = MeanVector(bestTotalCost);
emphiricTotalCost = MeanVector(emphiricTotalCost);
regret = emphiricTotalCost - bestTotalCost;
DecisionDistance = totalDecisions - totalSimilarDecisions;
MeanDistance = CompareKnownAndUnknown(W,pathsMeanCosts,Nodes,flowPaths);
SuccessfulTranferRate = LastIndex/CountPackets;
DelayAverage = CalcDelayAverage(FinalDestination,Dest);
QueueLengths = QueueLengths(QueueLengths>0);
QueueLengthAverage = mean(mean(QueueLengths,2));
%---------------------------------------------------------

end

