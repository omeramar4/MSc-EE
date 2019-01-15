%This program takes the algorithm presented in the paper "On combining
%shortest path and back pressure routing over multihop wireless networks"
%and invert it to a case where links are weighted by a known value

%SETTINGS AND INPUT
%---------------------------------------------------------
K = [0.1 1 10 100]; %Shortest-Path weight over Backressure 
K = 5;
p = 0.1:0.1:1;      %Packet Probability by Poisson Distribution
p = 1;
N = 50000;          %Time Horizon
cost_range = 1;     %Interval of link weights
UpdateWeightsJump = 50;
network = input('Choose network: ');
isDirected = input(' 0 - Undirected Network, 1 - Directed Network: ');

%SET NETWORK'S LINKS
%---------------------------------------------------------

switch network
    
    case 1
        %4x4 Grid
        Nodes = 1:16;
        s = [1 1 2 2 3 3 4 5 5 6 6 7 7 8 9 9 10 10 11 11 12 13 14 15]';     %Sources
        t = [2 5 3 6 4 7 8 6 9 7 10 8 11 12 10 13 11 14 12 15 16 14 15 16]';    %Targets
        %flow = [1 6;3 16;9 15];
        flow = [1 15];
    case 2
        %6x6 Grid
        Nodes = 1:36;
        s = [1 1 2 2 3 3 4 4 5 5 6 7 7 8 8 9 9 10 10 11 11 12 13 13 14 14 15 15 16 16 17 17 18 19 19 20 20 21 21 22 22 23 23 24 25 25 26 26 27 27 28 28 29 29 30 31 32 33 34 35]';
        t = [2 7 3 8 4 9 5 10 6 11 12 8 13 9 14 10 15 11 16 12 17 18 14 19 15 20 16 21 17 22 18 23 24 20 25 21 26 22 27 23 28 24 29 30 26 31 27 32 28 33 29 34 30 35 36 32 33 34 35 36]';
        Paths = importdata('6x6Paths.mat');
    case 3
        Nodes = 1:8;
        s = [1 1 2 2 3 4 5 5 6 6 8]';
        t = [2 5 3 6 4 7 6 8 4 7 7]';
        flow = [1 7];
end

links = [s t];

if (isDirected == 0 && network ~= 1)
    links = [links; t s];
    [~,idx] = sort(links(:,1)); % sort just the first column
    links = links(idx,:);   % sort the whole matrix using the sort indices
    newSource = links(:,1);
    n = 1;
    for i = 1:length(Nodes)
        findSource = find(newSource == i);
        if (isempty(findSource))
            continue;
        end
        links(n:n + length(findSource) - 1,2) = sort(links(n:n + length(findSource) - 1,2));
        n = n + length(findSource);
    end
    newSource = s;
    s = [s;t];
    t = [t;newSource];
end

nnode = max([s; t]);
nedge = length(s);
adj = sparse(s,t,ones(nedge,1),nnode,nnode);
%---------------------------------------------------------

%FIND PATHS
%---------------------------------------------------------
if (network == 1 && isDirected == 0)
    flows = zeros(length(Nodes)*(length(Nodes)-1),2);
    h = 1;
    for i = 1:length(Nodes)
        for j = 1:length(Nodes)
            if (i ~= j)
                flows(h,:) = [i j];
                h = h + 1;
            end
        end
    end
    Paths = txtToMat(flows,Nodes);
elseif (network ~= 2)
    Paths = cell(nnode);
    d = zeros(nnode);
    for i = 1:nnode
        for j = 1:nnode
            if (i ~= j)
                Paths{i,j} = PathBetweenNodes(adj,i,j);
                d(i,j) = length(Paths{i,j});
            end
        end
    end
    Paths = Cell2Mat2(Paths,Nodes);
end
%---------------------------------------------------------

%SET NETWORK'S FLOWS
%---------------------------------------------------------
Dest = unique(sort(flow(:,2)));
F = size(flow,1);
flowPaths = FlowPaths(Nodes,flow,Paths);
Gamma = ones(1,size(links,1));
%---------------------------------------------------------

%SET LINKS' WEIGHTS WITH RANDOM GAUSSIAN DISTRIBUTIONS
%---------------------------------------------------------
distribution = zeros(length(s),N);
mu = zeros(length(s),1);
gauss_dist = cell(1,length(s));
for i = 1:length(s)
    mu(i) = randi(8) + 2;
    sigma = 1/(randi(5) + 1);
    distribution(i,:) = normrnd(mu(i),sigma,1,N);
    gauss_dist{i} = makedist('Normal','mu',mu(i),'sigma',sigma);
end
%---------------------------------------------------------

%Calculate total cost for each path and set averages cells
%---------------------------------------------------------
weights = randsrc(size(links,1),1,[cost_range;(1/length(cost_range))*ones(1,length(cost_range))]);
if (isDirected == 1)
    W = CalcTotalCostDirected(flowPaths,Paths,Nodes);
else
    W = CalcTotalCost2(Nodes,weights,links,Paths,Dest);
end
avgs = W;
for i=1:size(avgs,1)
    for j=1:size(avgs,2)
        avgs{i,j} = [avgs{i,j} ones(length(avgs{i,j}),1) zeros(length(avgs{i,j}),2)];
    end
end
%---------------------------------------------------------

%INITIALIZE QUEUE AND TRACKING CELLS
%---------------------------------------------------------
Queue = cell(length(Nodes));
DelayTrack = cell(length(Nodes));
HowManyTrack = cell(length(Nodes));
WhosNextTrack = cell(length(Nodes));
[Queue, DelayTrack, HowManyTrack, WhosNextTrack] = InitializeQueueAndTracking(N,Nodes,Queue,W,flowPaths,DelayTrack,HowManyTrack,WhosNextTrack);
%---------------------------------------------------------

%SET UP RESULTS MATRICES
%---------------------------------------------------------
TotalCostAverage = zeros(length(K),length(p));
DelayAverage = zeros(length(K),length(p));
QueueLengthAverage = zeros(length(K),length(p));
EstimatedW = cell(length(K),length(p));
SuccessfulTranferRate = zeros(length(K),length(p));
MeanDistance = cell(length(K),length(p));
DecisionDistance = zeros(length(K),length(p));
TotalDecisions = zeros(length(K),length(p));
%---------------------------------------------------------

%Set up the delay and total cost calculation cells
%---------------------------------------------------------
FinalDestination = cell(length(Nodes),1);
for i=1:length(Dest)
    FinalDestination{Dest(i)} = cell(N + 10000,8);
    FinalDestination{Dest(i)}(:,[1 6 7 8]) = {zeros(length(Nodes),1)};
    FinalDestination{Dest(i)}(:,2) = {0};
end
FinalDestinationTracks = zeros(length(Nodes),1);
%---------------------------------------------------------

%Calculate paths mean costs for Genie Decisions
%---------------------------------------------------------
pathsMeanCosts = cell(length(Nodes));
for i = 1:size(flowPaths,1)
    pathsMeanCosts{flowPaths(i,1),flowPaths(i,2)} = GetMeanCostOnPath(flowPaths(i,1),flowPaths(i,2),links,Paths,mu);
end
%---------------------------------------------------------

%Create Struct S
%---------------------------------------------------------
S = struct;
S.Iterations = N;
S.TotalPathCosts = W;
S.WeightsOfLinks = weights;
S.Queue = Queue;
S.Destinations = Dest;
S.Links = links;
S.Flows = flow;
S.flowPaths = flowPaths;
S.Gamma = Gamma;
S.Nodes = Nodes;
S.DelayTrack = DelayTrack;
S.HowManyTrack = HowManyTrack;
S.WhosNextTrack = WhosNextTrack;
S.FinalDestination = FinalDestination;
S.FinalDestinationTracks = FinalDestinationTracks;
S.avgs = avgs;
S.distribution = distribution;
S.mu = mu;
S.Paths = Paths;
S.pathsMeanCosts = pathsMeanCosts;
S.isDirected = isDirected;
S.UpdateWeightsJump = UpdateWeightsJump;
%---------------------------------------------------------

%Main Loop - runs for each value of the pair (K,lambda)
%---------------------------------------------------------
numOfTests = 10;
sumDelay = zeros(length(K),length(p));
sumSuccessfulRate = zeros(length(K),length(p));
sumDecisionDistance = zeros(length(K),length(p));
sumQueueLengths = zeros(length(K),length(p));
for k = 1:numOfTests
    for i=1:length(K)
        for j=1:length(p)
            [QueueLengthAverage(i,j),DelayAverage(i,j),SuccessfulTranferRate(i,j),MeanDistance{i,j},DecisionDistance(i,j),TotalDecisions(i,j)] = Main(K(1),p(1),S,k,i,j);
        end
    end
    sumDelay = sumDelay + DelayAverage;
    sumSuccessfulRate = sumSuccessfulRate + SuccessfulTranferRate;
    sumDecisionDistance = sumDecisionDistance + DecisionDistance;
    sumQueueLengths = sumQueueLengths + QueueLengthAverage;
end
sumDelay = sumDelay/numOfTests;
sumSuccessfulRate = sumSuccessfulRate/numOfTests;
sumDecisionDistance = sumDecisionDistance/numOfTests;
sumQueueLengths = sumQueueLengths/numOfTests;
%---------------------------------------------------------

%% PLOT RESULTS
%---------------------------------------------------------
figure;
plot(p,DelayAverage(1,:),'-*',p,DelayAverage(2,:),'-h',p,DelayAverage(3,:),'-d',p,DelayAverage(4,:),'-^');
xlabel('\lambda'); ylabel('Delay Average'); title('End-to-End Delay Average');
legend('K = 0.1', 'K = 1', 'K = 10', 'K = 100');

figure;
plot(p,TotalCostAverage(1,:),'-*',p,TotalCostAverage(2,:),'-h',p,TotalCostAverage(3,:),'-d',p,TotalCostAverage(4,:),'-^');
xlabel('\lambda'); ylabel('Average Total Path Cost per Packet'); title('Total Path Cost Average');
legend('K = 0.1', 'K = 1', 'K = 10', 'K = 100');

figure;
plot(p,QueueLengthAverage(1,:),'-*',p,QueueLengthAverage(2,:),'-h',p,QueueLengthAverage(3,:),'-d',p,QueueLengthAverage(4,:),'-^');
xlabel('\lambda'); ylabel('Per-Node Queue Lengths'); title('Average of Queue Lengths');
legend('K = 0.1', 'K = 1', 'K = 10', 'K = 100');
%---------------------------------------------------------

