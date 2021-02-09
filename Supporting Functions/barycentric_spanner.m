function [spanner] = barycentric_spanner(paths,links)

P = zeros(size(links,1),size(paths,1));
for i = 1:size(paths,1)
    path = paths(i,:);
    for j = 1:length(path)-1
        [~,link_idx] = ismember([path(j) path(j+1)],links,'rows');
        P(link_idx,i) = 1;
    end
end

spanner = licols(P);

% max_coeffs = zeros(1,20);
% for i = 1:20
%     max_coeffs(i) = max(linsolve(bary_P,P(:,i)));
% end
% 
% disp(['Max coefficient: ' num2str(max(max_coeffs))]);
end
