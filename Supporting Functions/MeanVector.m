function [vec] = MeanVector(vec)

vec = cumsum(vec);
vec = cummean(vec);
% n = length(vec);
% temp = vec;
% for i = 1:n
%     temp(i) = sum(vec(1:i));
% end
% 
% vec = temp;
% 
% for i = 1:n
%     temp(i) = mean(vec(1:i));
% end
% 
% vec = temp;

end

