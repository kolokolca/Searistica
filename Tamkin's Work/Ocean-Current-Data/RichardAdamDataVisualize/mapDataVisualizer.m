function mapDataVisualizer()
    m = csvread('H:\Study\MUN\SAT\Code\Psuedo Boolean\sat4j-pbs\RichardAdamDataVisualize\forMatlabChunkTest.txt'); 
    X =  m(:,1);
    Y =  m(:,2);
    U =  m(:,3);
    V =  m(:,4);
    % Scaling vectors
    U = U.*2;
    V = V.*2;
    figure;
    quiver(X,Y,U,V,0)
    hold on
    
   
    s = 3;
    %scatter(X,Y,s,'O', 'MarkerEdgeColor','b','MarkerFaceColor','c', 'LineWidth',0.75)
    %scatter(X + U,Y + V,s,'O', 'MarkerEdgeColor','b','MarkerFaceColor','r', 'LineWidth',0.75)
    
    
    nodes = csvread('H:\Study\MUN\SAT\Code\Psuedo Boolean\sat4j-pbs\RichardAdamDataVisualize\AdamSourceNodes.dat'); 
    nodesX =  nodes(:,1);
    nodesY =  nodes(:,2);
    
    s = 100;
    scatter(nodesX,nodesY,s,'O', 'MarkerEdgeColor','r','MarkerFaceColor','k', 'LineWidth',0.75)
    
    
    dim = size(nodesX);
    len = dim(1)
    nodeCounter = 1;
    for i=1:len,
        x = nodesX(i);
        y = nodesY(i);        
        text(x+1,y+1,int2str(nodeCounter), 'FontSize', 15, 'FontWeight', 'bold');
        nodeCounter = nodeCounter + 1;
        
        
    
end



