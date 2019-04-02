function [ link ] = findPossibleLinks( G,st,en )
%function [ links ] = findPossibleLinks( G,st,en,flag )
%find possible links that can be activated at the same time.
%st=start,en=end

currlink=ismember(G,[st;en]','rows')';
link=currlink;
for row=1:size(G,1)
    if ~(sum((G(row,1)>=st(end))==0)&&sum((G(row,2)>=en(end))==0))
        if ~(sum(ismember(G(row,:),st))||sum(ismember(G(row,:),en)))
            checklink=ismember(G,G(row,:),'rows')';
            otherLinksThatCanWork=findPossibleLinks( G,[st G(row,1)],[en G(row,2)]);
            if isempty(otherLinksThatCanWork)
                link=[link;currlink+checklink];
            else
                link=[link;otherLinksThatCanWork];
                %                 link=[link;currlink;repmat(currlink,size(otherLinksThatCanWork,1),1)+otherLinksThatCanWork];
            end
        end
        
    end
end

