function [ max_index,flag ] = Step_1( P,schedule,links,Gamma,Gmat,isDirected )
% This function solves the optimization problem described in the
% Shortest-Path-Aided Backpressure Algorithm in the paper
    max_val = 0;
    max_index = 0;
    for i=1:schedule            %Loop for all possible schedules
        temp = 0;
        flag_temp = zeros(1,links);
        for j=1:links           %Loop for all Links
            if (Gamma(i,j)==0)
                flag_temp(j) = -1;
                continue;
            end
            temp1 = temp + (Gamma(i,j)*P(Gmat(j,1),Gmat(j,2)));
            if (isDirected == 8)
                temp2 = temp + (Gamma(i,j)*P(Gmat(j,2),Gmat(j,1)));
            else
                temp2 = -1;
            end
            if (temp1>=temp2)
                flag_temp(j) = 0;
                temp = temp1;
            else
                flag_temp(j) = 1;
                temp = temp2;
            end
        end
        if (temp>max_val)
            max_val = temp;
            max_index = i;
            flag = flag_temp;
        end
    end
    if (max_index==0)
        flag = flag_temp;
    end
end

