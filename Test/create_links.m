function [s,t] = create_links(size)

s = [];
t = [];

for i = 1:size^2
    if (i + size > size^2)
        if mod(i,size)
            s = [s i];
            t = [t i+1];
        end
    else    
        if mod(i,size)
            s = [s i i];
            t = [t i+1 i+size];
        else
            s = [s i];
            t = [t i+size];
        end
    end
end

s = [s size^2]';
t = [t size^2]';

end

