function GradientDescentFinal(learningRate)
    %ncdisp('H:\Study\MUN\Data\nefbasnc\nb90a    
    m = csvread('parsedVelocity.txt');
    %size(m)
    U =  m(:,2);
    V =  m(:,3);    
    xy = csvread('paresedXY.txt');
    %size(m)
    X =  xy(:,2);
    Y =  xy(:,3);    
    figure;
    scale = 2;
    quiver(X,Y,U,V, scale, 'MarkerFaceColor','c', 'MarkerEdgeColor','c')   
    hold on    
    figure;
    %for selected points of a cell
    xy = csvread('selectedPoints.txt');
    sX =  xy(:,1);
    sY =  xy(:,2);
    sU =  xy(:,3);
    sV =  xy(:,4);
    %scatter(sX,sY,3,'O', 'MarkerEdgeColor','r','MarkerFaceColor','w', 'LineWidth', 0.1)
    %scatter(X + U,Y + V,3,'O', 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineWidth',2)
    %quiver(X,Y,U,V, scale)
    
     %Reading NaN point
    %xy = csvread('NaNPoints.txt');
    nX =  xy(:,1);
    nY =  xy(:,2);
    %scatter(nX,nY,4,'O', 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineWidth', 0.1)
    
    %Totoal area
    minX = min(X)
    maxY = max(Y)
    scatter(minX,maxY,4,'O', 'MarkerEdgeColor','k','MarkerFaceColor','k', 'LineWidth', 1)
    
    %Cell mean vector
    xy = csvread('cellMeanVector.txt');
    cX =  xy(:,1);
    cY =  xy(:,2);
    cU =  xy(:,3);
    cV =  xy(:,4);
    %cx = [0 0.114506883260149*10000]
    %cy = [0 -0.0450954228782883 *10000]
    %plot(X, Y, 'LineWidth',  4)
    %scatter(cX,cY,4,'O', 'MarkerEdgeColor','g','MarkerFaceColor','g', 'LineWidth', 1)
    scatter(cX,cY,4,'O', 'MarkerEdgeColor','g','MarkerFaceColor','g', 'LineWidth', 1)
    quiver(cX,cY,cU,cV, 2, 'MarkerFaceColor','g', 'MarkerEdgeColor','g')
    
    
end