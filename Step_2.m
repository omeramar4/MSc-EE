function [ Queue,DelayTrack,HowManyTrack,FinalDestination,FinalDestinationTracks,WhosNextTrack ] = Step_2( max_queue,Gamma,max_index,P,link,Queue,weights,DelayTrack,HowManyTrack,finish,FinalDestination,FinalDestinationTracks,WhosNextTrack,distribution,flag,isDirected )

% This function finds the next queue to pass the current packet as described in the
% Shortest-Path-Aided Backpressure Algorithm in the paper

index = find(Gamma(max_index,:)>0);
for j=1:length(index)
    if (isDirected == 1)
        if (flag(index(j))==0)
            mid_src = link(index(j),1);
            mid_dest = link(index(j),2);
        else
            continue;
        end
    else
        if (flag(index(j))==0)
            mid_src = link(index(j),1);
            mid_dest = link(index(j),2);
        elseif (flag(index(j))==1)
            mid_src = link(index(j),2);
            mid_dest = link(index(j),1);
        end
    end
    if (P(mid_src,mid_dest)>0)      %Find if link (mid_src,mid_dest) is going to transmit packet
        dest = max_queue{mid_src,mid_dest}(1);
        curr_weight = max_queue{mid_src,mid_dest}(3);
        if (mid_dest==dest)
            next_weight = 0;
        else
            next_weight = max_queue{mid_src,mid_dest}(5);
        end
        check = 0;
        if (Queue{mid_src,dest}(curr_weight) > 0)
            check = 1;
            Queue{mid_src,dest}(curr_weight) = Queue{mid_src,dest}(curr_weight) - 1;
        end      
        
        %If the next hop isn't the packet's destination
        if (next_weight~=0 && dest~=mid_dest && check == 1)
            Queue{mid_dest,dest}(next_weight) = Queue{mid_dest,dest}(next_weight) + 1;
            if (HowManyTrack{mid_src,dest}(curr_weight)~=0)    
                HowManyTrack{mid_dest,dest}(next_weight) = HowManyTrack{mid_dest,dest}(next_weight) + 1;
                if (DelayTrack{mid_src,dest}{curr_weight}{WhosNextTrack{mid_src,dest}(curr_weight),1}(1)==0)
                    WhosNextTrack{mid_src,dest}(curr_weight) = WhosNextTrack{mid_src,dest}(curr_weight) - 1;
                end
                
                for u = 1:8
                    DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),u} = DelayTrack{mid_src,dest}{curr_weight}{WhosNextTrack{mid_src,dest}(curr_weight),u};
                end
                [~,rowOfLink] = ismember([mid_src,mid_dest],link,'rows');
                if (rowOfLink == 0)
                    [~,rowOfLink] = ismember([mid_dest,mid_src],link,'rows');
                end
                DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),1}(min(find(DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),1}==0))) = finish;
                DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),4} = DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),4} + weights(index(j));
                DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),6}(min(find(DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),6}==0))) = mid_dest;
                DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),7}(min(find(DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),7}==0))) = max_queue{mid_src,mid_dest}(4);
                WhosNextTrack{mid_src,dest}(curr_weight) = WhosNextTrack{mid_src,dest}(curr_weight) + 1;
                
                tempIndex = min(find(DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),8}==0));
                if (tempIndex == 1)
                    DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),8}(tempIndex) = distribution(rowOfLink,finish);
                else
                    DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),8}(tempIndex) = DelayTrack{mid_dest,dest}{next_weight}{HowManyTrack{mid_dest,dest}(next_weight),8}(tempIndex - 1) + distribution(rowOfLink,finish);
                end
            end
            
        %Next hop is the packet's destination
        elseif (next_weight == 0 && HowManyTrack{mid_src,dest}(curr_weight) > 0 && check == 1)
            FinalDestinationTracks(dest) = FinalDestinationTracks(dest) + 1;
            if (DelayTrack{mid_src,dest}{curr_weight}{WhosNextTrack{mid_src,dest}(curr_weight),1}(1)==0)
                    WhosNextTrack{mid_src,dest}(curr_weight) = WhosNextTrack{mid_src,dest}(curr_weight) - 1;
            end
            for u = 1:8
                FinalDestination{dest}{FinalDestinationTracks(dest),u} = DelayTrack{mid_src,dest}{curr_weight}{WhosNextTrack{mid_src,dest}(curr_weight),u};
            end
            [~,rowOfLink] = ismember([mid_src,mid_dest],link,'rows');
            if (rowOfLink == 0)
                [~,rowOfLink] = ismember([mid_dest,mid_src],link,'rows');
            end
            FinalDestination{dest}{FinalDestinationTracks(dest),4} = FinalDestination{dest}{FinalDestinationTracks(dest),4} + weights(index(j));
            WhosNextTrack{mid_src,dest}(curr_weight) = WhosNextTrack{mid_src,dest}(curr_weight) + 1;
            FinalDestination{dest}{FinalDestinationTracks(dest),6}(min(find(FinalDestination{dest}{FinalDestinationTracks(dest),6}==0))) = dest;
            FinalDestination{dest}{FinalDestinationTracks(dest),5} = finish;
            tempIndex = min(find(FinalDestination{dest}{FinalDestinationTracks(dest),8}==0));
            if (tempIndex == 1)
                FinalDestination{dest}{FinalDestinationTracks(dest),8}(1) = distribution(rowOfLink,finish);
            else
                FinalDestination{dest}{FinalDestinationTracks(dest),8}(tempIndex) = FinalDestination{dest}{FinalDestinationTracks(dest),8}(tempIndex - 1) + distribution(rowOfLink,finish);
            end          
        end
    end
end

end

