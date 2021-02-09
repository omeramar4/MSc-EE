function [favoritePathLinks, row] = ChooseFavoritePath(links,paths)

row = randi(size(paths,1));
path = paths(row,:);
path(path == 0) = [];
favoritePathLinks = zeros(1,length(row) - 1);
for j=1:length(path) - 1
    [~,link] = ismember([path(j) path(j+1)],links,'rows');
    favoritePathLinks(j) = link;
end

end

