function [vec] = MeanVector(vec)

vec = cumsum(vec);
vec = cummean(vec);

end

