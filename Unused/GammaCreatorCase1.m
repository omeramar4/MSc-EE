function [ Gamma ] = GammaCreatorCase1( G )
%GAMMACREATOR Summary of this function goes here
%   Detailed explanation goes here

Gmat = table2array(G.Edges);
n = 1;
for i=1:size(Gmat,1)
    sd = Gmat(i,:);
    Gamma_temp = zeros(1,size(Gmat,1));
    Gamma_temp(i) = 1;
    Gamma(n,:) = Gamma_temp;
    n = n + 1;
    members1 = neighbors(G,sd(1));
    members2 = neighbors(G,sd(2));
    Gamma_temp = ones(1,size(Gmat,1));
    for j=1:length(members1)
        if (members1(j)==sd(2))
            continue;
        end
        index = find(sum(ismember(Gmat,[sd(1) members1(j)]),2)==2);
        Gamma_temp(index) = 0;
    end
    for j=1:length(members2)
        if (members2(j)==sd(1))
            continue;
        end
        index = find(sum(ismember(Gmat,[sd(2) members2(j)]),2)==2);
        Gamma_temp(index) = 0;
    end
    Gamma(n,:) = Gamma_temp;
    n = n + 1;
end
    [C,ia] = unique(Gamma,'rows');
    ia = sort(ia);
    Gamma = Gamma(ia,:);
end

