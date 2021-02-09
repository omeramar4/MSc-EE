%This program takes the algorithm presented in the paper "On combining
%shortest path and back pressure routing over multihop wireless networks"
%and invert it to a case where links are weighted by a known value

%% Add folders paths
%---------------------------------------------------------
addpath('Pre-main Functions');
addpath('Main Algorithm Functions');
addpath('Post-main Functions');
addpath('Supporting Functions');
addpath('Saved Data');
addpath('Test');
%---------------------------------------------------------

%% SETTINGS AND INPUT
%---------------------------------------------------------
global known M q_levels flow_time
% K = [0.1 1 10 100]; %Shortest-Path weight over Backressure 
M = 100;
q_levels = linspace(0,1,M);
K = 1;
p = 0.1:0.1:1;
p = 0.5;
N = 200000;         %Time Horizon
cost_range = 1;     %Interval of link weights
% cost_range = 0.3:0.1:0.9;
allTheWayFlag = 0;
UpdateWeightsJump = 10;
network = input('Choose network: ');
isDirected = input(' 0 - Undirected Network, 1 - Directed Network: ');
known = input('0 - Unknown, 1 - Known: ');

%% SET NETWORK'S LINKS
%---------------------------------------------------------

switch network
    case 1      %4x4 Grid   
        net_size = 4;
        flow = [6 16];
    case 2      %8x8 Grid
        net_size = 8;
        flow = [17 62; 1 48];
end
flow_time = ones(size(flow,1),1);
Nodes = 1:net_size^2;
[s, t] = create_links(net_size);
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

%% FIND PATHS
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
elseif (network == 2)
    Paths = Cell2Mat2(importdata('Saved Data\8x8Paths.mat'), Nodes);
end
%---------------------------------------------------------

%% Barycentric Spanner
%---------------------------------------------------------
% for k = 1:length(Nodes)
%     for m = 1:length(Nodes)
%         paths = Paths{k,m};
%         if (isempty(paths) || (size(paths,1) == 1))
%             continue;                
%         end
%         P = zeros(size(links,1),size(paths,1));
%         for i = 1:size(paths,1)
%             path = paths(i,:);
%             for j = 1:length(path)-1
%                 [~,link_idx] = ismember([path(j) path(j+1)],links,'rows');
%                 P(link_idx,i) = 1;
%             end
%         end
%         [spanner, paths_to_keep] = licols(P);
%         paths = paths(paths_to_keep,:);
%         Paths{k,m} = paths;
%     end
% end


%---------------------------------------------------------

%% SET NETWORK'S FLOWS
%---------------------------------------------------------
Dest = unique(sort(flow(:,2)));
F = size(flow,1);
flowPaths = FlowPaths(Nodes,flow,Paths);
Gamma = ones(1,size(links,1));
%---------------------------------------------------------

%% SET LINKS' WEIGHTS WITH RANDOM GAUSSIAN DISTRIBUTIONS
%---------------------------------------------------------
distribution = zeros(length(s),N);
mu = zeros(length(s),1);
gauss_dist = cell(1,length(s));

best_path = zeros(length(Nodes));
favoritePathLinks = cell(length(Nodes));
for c = 1:size(flow,1)
    [favoritePathLinks{flow(c,1),flow(c,2)}, best_path(flow(c,1),flow(c,2))] = ChooseFavoritePath(links,Paths{flow(c,1),flow(c,2)});
    mu(favoritePathLinks{flow(c,1),flow(c,2)}) = 0.01;
    sigma = 0.004;
    for i = 1:length(favoritePathLinks{flow(c,1),flow(c,2)})
        distribution(favoritePathLinks{flow(c,1),flow(c,2)}(i),:) = normrnd(mu(favoritePathLinks{flow(c,1),flow(c,2)}(i)),sigma,1,N);
        gauss_dist{favoritePathLinks{flow(c,1),flow(c,2)}(i)} = makedist('Normal','mu',mu(favoritePathLinks{flow(c,1),flow(c,2)}(i)),'sigma',sigma);
    end
    
    
end
concat = [];
for i = 1:length(Nodes)
    for j = 1:length(Nodes)
        if (~isempty(favoritePathLinks{i,j}))
            concat = [concat, favoritePathLinks{i,j}];
        end
    end
end
concat = unique(concat);
excludeLinks = 1:size(links,1);
excludeLinks(concat) = [];
worstLink = excludeLinks(randi(length(excludeLinks)));
mu(worstLink) = 0.3;
distribution(worstLink,:) = normrnd(mu(worstLink),sigma,1,N);
gauss_dist{worstLink} = makedist('Normal','mu',mu(worstLink),'sigma',sigma);
concat = [concat worstLink];

for i = 1:length(s)
    if (~ismember(i,concat)) 
        mu(i) = 0.2;
        sigma = randsrc(1,1,[0.02 0.03 0.07 0.08 0.11 0.05 0.18 0.095 0.135 0.155;0.1*ones(1,10)]);
        distribution(i,:) = normrnd(mu(i),sigma,1,N);
        gauss_dist{i} = makedist('Normal','mu',mu(i),'sigma',sigma);
    end
end
distribution = abs(distribution);
%---------------------------------------------------------

%% Calculate total cost for each path and set averages cells
%---------------------------------------------------------
weights = randsrc(size(links,1),1,[cost_range;(1/length(cost_range))*ones(1,length(cost_range))]);
if (isDirected == 1)
    W = CalcTotalCostDirected(flowPaths,Paths,Nodes);
else
    W = CalcTotalCost2(Nodes,weights,links,Paths,Dest);
end

%---------------------------------------------------------

%% Run one packet through each one of the paths
%---------------------------------------------------------
for i = 1:size(flowPaths,1)
    paths_mat = Paths{flowPaths(i,1),flowPaths(i,2)};
    for j = 1:size(paths_mat,1)
        path = paths_mat(j,:);
        path(path == 0) = [];
        for k = 1:length(path) - 1
            link = [path(k) path(k+1)];
            [~,link_index] = ismember(link,links,'rows');
            if known == 0
                W{flowPaths(i,1),flowPaths(i,2)}(j) = W{flowPaths(i,1),flowPaths(i,2)}(j) + distribution(link_index,1);
            elseif known == 1
                W{flowPaths(i,1),flowPaths(i,2)}(j) = W{flowPaths(i,1),flowPaths(i,2)}(j) + mu(link_index);
            end
        end
    end
end
%---------------------------------------------------------

avgs = W;
for i=1:size(avgs,1)
    for j=1:size(avgs,2)
        avgs{i,j} = [avgs{i,j} ones(length(avgs{i,j}),1) zeros(length(avgs{i,j}),2)];
    end
end

%% INITIALIZE QUEUE AND TRACKING CELLS
%---------------------------------------------------------
Queue = cell(length(Nodes));
DelayTrack = cell(length(Nodes));
HowManyTrack = cell(length(Nodes));
WhosNextTrack = cell(length(Nodes));
NumOfTimesPathChosen = cell(length(Nodes));
[Queue, DelayTrack, HowManyTrack, WhosNextTrack, NumOfTimesPathChosen] = InitializeQueueAndTracking(N,Queue,W,flowPaths,DelayTrack,HowManyTrack,WhosNextTrack,NumOfTimesPathChosen);
%---------------------------------------------------------

%% SET UP RESULTS MATRICES
%---------------------------------------------------------
TotalCostAverage = zeros(length(K),length(p));
DelayAverage = zeros(length(K),length(p));
regret = cell(length(K), length(p));
QueueLengthAverage = zeros(length(K),length(p));
EstimatedW = cell(length(K),length(p));
SuccessfulTranferRate = zeros(length(K),length(p));
MeanDistance = cell(length(K),length(p));
DecisionDistance = zeros(length(K),length(p));
TotalDecisions = zeros(length(K),length(p));
%---------------------------------------------------------

%% Set up the delay and total cost calculation cells
%---------------------------------------------------------
FinalDestination = cell(length(Nodes),1);
for i=1:length(Dest)
    if (allTheWayFlag == 1)
        FinalDestination{Dest(i)} = zeros(N + 10000,9);
    else
        FinalDestination{Dest(i)} = cell(N + 10000,9);
        FinalDestination{Dest(i)}(:,[1 6 7 8]) = {zeros(length(Nodes),1)};
        FinalDestination{Dest(i)}(:,2) = {0};
    end
end
FinalDestinationTracks = zeros(length(Nodes),1);
%---------------------------------------------------------

%% Calculate paths mean costs for Genie Decisions
%---------------------------------------------------------
pathsMeanCosts = cell(length(Nodes));
for i = 1:size(flowPaths,1)
    pathsMeanCosts{flowPaths(i,1),flowPaths(i,2)} = GetMeanCostOnPath(flowPaths(i,1),flowPaths(i,2),links,Paths,mu);
end
%---------------------------------------------------------

%% Create Struct S
%---------------------------------------------------------
S = struct;
S.Iterations = N;
S.TotalPathCosts = W;
S.WeightsOfLinks = weights;
S.Queue = Queue;
S.Destinations = Dest;
S.Links = links;
S.Flows = flow;
S.Gamma = Gamma;
S.Nodes = Nodes;
S.DelayTrack = DelayTrack;
S.HowManyTrack = HowManyTrack;
S.WhosNextTrack = WhosNextTrack;
S.FinalDestination = FinalDestination;
S.FinalDestinationTracks = FinalDestinationTracks;
S.avgs = avgs;
S.flowPaths = flowPaths;
S.distribution = distribution;
S.mu = mu;
S.Paths = Paths;
S.pathsMeanCosts = pathsMeanCosts;
S.isDirected = isDirected;
S.UpdateWeightsJump = UpdateWeightsJump;
S.NumOfTimesPathChosen = NumOfTimesPathChosen;
S.allTheWayFlag = allTheWayFlag;
S.best_path = best_path;
%---------------------------------------------------------

%% Main Loop - runs for each value of the pair (K,lambda)
%---------------------------------------------------------
% numOfTests = 1;
% sumDelay = zeros(length(K),length(p));
% sumSuccessfulRate = zeros(length(K),length(p));
% sumDecisionDistance = zeros(length(K),length(p));
% sumQueueLengths = zeros(length(K),length(p));
% for k = 1:numOfTests
%     for i=1:length(K)
%         for j=1:length(p)
[DelayAverage, regret, QueueLengthAverage] = Main(K,p,S,k,i,j);
%         end
%     end
%     sumDelay = sumDelay + DelayAverage;
% end
% sumDelay = sumDelay/numOfTests;
% %---------------------------------------------------------

%% PLOT RESULTS
%---------------------------------------------------------
% figure;
% plot(p,DelayAverage(1,:),'-*','LineWidth',2);
% xlabel('\lambda'); ylabel('Delay Average'); title('End-to-End Delay Average');
% set(gca,'FontSize',14);
% grid on;
% 
% figure; 
% plot(regret{1},'Color',[50 191 255]./255,'LineWidth',2.5);
% title('Regret Curve','FontSize',14,'FontWeight','bold');
% xlabel('Decisions (time)'); ylabel('Regret');
% set(gca,'FontSize',14);
% grid on;
% 
% figure;
% plot(p,QueueLengthAverage(1,:),'-^');
% xlabel('\lambda'); ylabel('Average'); title('Queue Length Average');
% legend('K = 1');
% set(gca,'FontSize',14);
% grid on;
%---------------------------------------------------------

