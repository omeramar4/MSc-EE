function [FinalDestination,FinalDestinationTracks] = TakePath(source,dest,weight,distribution,Paths,links,timeSlot,FinalDestination,FinalDestinationTracks)

path = Paths{source,dest}(weight,:);
path(path == 0) = [];
cost = 0;
for i = 1:length(path) - 1
    [~,link] = ismember(path(i:i + 1),links,'rows');
    cost = cost + distribution(link,timeSlot);
end
FinalDestinationTracks(dest) = FinalDestinationTracks(dest) + 1;
FinalDestination{dest}(FinalDestinationTracks(dest),:) = [timeSlot source dest (length(path) - 1) timeSlot cost cost cost weight];
% FinalDestination{dest}(FinalDestinationTracks(dest),1) = timeSlot;
% FinalDestination{dest}{FinalDestinationTracks(dest),2} = source;
% FinalDestination{dest}{FinalDestinationTracks(dest),3} = dest;
% FinalDestination{dest}{FinalDestinationTracks(dest),4} = length(path) - 1;
% FinalDestination{dest}{FinalDestinationTracks(dest),5} = timeSlot;
% FinalDestination{dest}{FinalDestinationTracks(dest),6} = cost;
% FinalDestination{dest}{FinalDestinationTracks(dest),7} = cost;
% FinalDestination{dest}{FinalDestinationTracks(dest),8} = cost;
% FinalDestination{dest}{FinalDestinationTracks(dest),9} = weight;
end

