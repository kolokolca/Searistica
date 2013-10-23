function visualizerTour()
    vizualizeVectorFiled()
    vizualizeSourceNodes()
    vizualizeTour()
end

function vizualizeTour()
    m = csvread('H:\Study\MUN\SAT\Code\Psuedo Boolean\sat4j-pbs\RichardAdamDataVisualize\tourForMatlab.txt'); 
    X =  m(:,1);
    Y =  m(:,2);
    U =  m(:,3);
    V =  m(:,4);
    quiver(X,Y,U,V,0, 'LineWidth', 2.5)

end

function vizualizeSourceNodes()
    nodes = csvread('H:\Study\MUN\SAT\Code\Psuedo Boolean\sat4j-pbs\RichardAdamDataVisualize\AdamSourceNodes.dat'); 
    nodesX =  nodes(:,1);
    nodesY =  nodes(:,2);
    
    s = 100;
    scatter(nodesX,nodesY,s,'O', 'MarkerEdgeColor','g','MarkerFaceColor','k', 'LineWidth',0.75)
    
    
    dim = size(nodesX);
    len = dim(1)
    nodeCounter = 1;
    for i=1:len,
        x = nodesX(i);
        y = nodesY(i);        
        text(x+1,y+1,int2str(nodeCounter), 'FontSize', 20, 'FontWeight', 'bold');
        nodeCounter = nodeCounter + 1;
    end
end

function vizualizeVectorFiled()
    m = csvread('H:\Study\MUN\SAT\Code\Psuedo Boolean\sat4j-pbs\RichardAdamDataVisualize\forMatlabChunkTest.txt'); 
    X =  m(:,1);
    Y =  m(:,2);
    U =  m(:,3);
    V =  m(:,4);
    % Scaling vectors
    U = U.*4;
    V = V.*4;
    figure;
    quiver(X,Y,U,V,0)
    hold on  
    s = 3;
    %scatter(X,Y,s,'O', 'MarkerEdgeColor','b','MarkerFaceColor','c', 'LineWidth',0.75)
    %scatter(X + U,Y + V,s,'O', 'MarkerEdgeColor','b','MarkerFaceColor','r', 'LineWidth',0.75)

end



