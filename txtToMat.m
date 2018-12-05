function [ paths ] = txtToMat( flow,Nodes )
%TXTTOMAT Summary of this function goes here
%   Detailed explanation goes here

paths = cell(length(Nodes),length(Nodes));
text = 'Paths2.txt';
txt = fopen(text,'r');
line = fgetl(txt);
out = 0;

for i=1:size(flow,1)
    [first, last] = checkDoubleDigits(line);
    while (round(first)~=flow(i,1) || round(last)~=flow(i,2))
        line = fgetl(txt);
        if (line(1)=='$')
            break;
        end
        [first, last] = checkDoubleDigits(line);
    end
    n=1;
    if (line(1)=='$')
        break;
    end
    bool = boolCheckforPath(flow(i,:),line);
    while (bool)
        p=1;
        flag=0;
        for j=1:length(line)
            if (flag==1);
                flag = 0;
                continue;
            end
            if (j==length(line))
                paths{flow(i,1),flow(i,2)}(n,p) = str2double(line(j));
                p = p + 1;
                continue;
            end
            if (line(j)==',')
                flag = 0;
                continue;
            elseif (j~=length(line))
                if (line(j+1)==',');
                    flag = 0;
                    paths{flow(i,1),flow(i,2)}(n,p) = str2double(line(j));
                else
                    paths{flow(i,1),flow(i,2)}(n,p) = 10*str2double(line(j)) + str2double(line(j+1));
                    flag = 1;
                end
            end
            p = p + 1;
        end
        if (p<length(Nodes)-1 && n==1)
            paths{flow(i,1),flow(i,2)}(n,p:length(Nodes)) = 0;
        end
        n = n + 1;
        line = fgetl(txt);
        if (line(1) == '$')
            out = 1;
            break;
        end
        bool = boolCheckforPath(flow(i,:),line);
    end
    if (out==1)
        break;
    end
end
end

