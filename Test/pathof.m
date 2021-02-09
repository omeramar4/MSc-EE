function pth=pathof(graph,startn,endn)
stop=0;
n=0;
while stop~=1
    n=n+1;
    Temp=shortestpath(graph,startn,endn);
    eidx=findedge(graph,Temp(1:end-1),Temp(2:end));
    if n~=1
        if length(Temp)==length(pth{n-1,1})
            if Temp==pth{n-1,1}
                stop=1;
            else
                pth{n,1}=Temp;
                graph.Edges.Weight(eidx)=100;
            end
        else
            pth{n,1}=Temp;
            graph.Edges.Weight(eidx)=100;
        end
    else
        pth{n,1}=Temp;
        graph.Edges.Weight(eidx)=100;
    end
    clear Temp eidx;
end