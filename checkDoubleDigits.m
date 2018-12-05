function [ first, last ] = checkDoubleDigits( line )
%CHECKDOUBLEDIGITS Summary of this function goes here
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
        first = str2double(line(1));
        last = str2double(line(length(line)));
    elseif (line(2)==',' && line(length(line)-1)~=',')
        first = str2double(line(1));
        last = 10*str2double(line(length(line)-1)) + str2double(line(length(line)));
    elseif (line(2)~=',' && line(length(line)-1)==',')
        first = 10*str2double(line(1)) + str2double(line(2));
        last = str2double(line(length(line)));
    else
        first = 10*str2double(line(1)) + str2double(line(2));
        last = 10*str2double(line(length(line)-1)) + str2double(line(length(line)));
    end

end

