function [ delay_avg ] = CalcDelayAverage( FinalDestination,D )
%This function calculates the average of all active queues in the network
%for a single iteration
    
    sum = 0;
    count = 0;
    for i=1:length(D)        
        for m=1:size(FinalDestination{D(i)},1)      %All zero hops
            if (FinalDestination{D(i)}{m,1}(1)~=0)
                sum = sum + FinalDestination{D(i)}{m,5} - FinalDestination{D(i)}{m,1}(1);
                count = count + 1;
            end
        end
    end
   delay_avg = sum/count; 
end

