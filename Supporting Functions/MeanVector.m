function [vec] = MeanVector(vec)

vec = cummean(vec);
vec = cumsum(vec);

end

