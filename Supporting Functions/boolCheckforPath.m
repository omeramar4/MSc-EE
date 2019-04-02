function [ bool ] = boolCheckforPath( flow,line )
%BOOLCHECKFORPATH Summary of this function goes here
%   Detailed explanation goes here


% Result:
%   1 - two single digit
%   2 - first single digit, last double digit
%   3 - first double digit, last single digit
%   4 - two double digits

%Action:
%   1 - Normal
%   2 - New


    if (line(length(line)-1)==',' && line(2)==',')
        bool = str2double(line(1))==flow(1) && str2double(line(length(line)))==flow(2);
    elseif (line(2)==',' && line(length(line)-1)~=',')
        temp = 10*str2double(line(length(line)-1)) + str2double(line(length(line)));
        bool = str2double(line(1))==flow(1) && temp==flow(2);
    elseif (line(2)~=',' && line(length(line)-1)==',')
        temp = 10*str2double(line(1)) + str2double(line(2));
        bool = temp==flow(1) && str2double(line(length(line)))==flow(2);
    else
        temp = 10*str2double(line(1)) + str2double(line(2));
        temp2 = 10*str2double(line(length(line)-1)) + str2double(line(length(line)));
        bool = temp==flow(1) && temp2==flow(2);
    end

    
end

