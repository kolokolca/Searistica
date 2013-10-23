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
    quiver(X,Y,U,V, scale)   
    hold on
    
    %for selected points of a cell
    xy = csvread('selectedPoints.txt');
    X =  xy(:,1);
    Y =  xy(:,2);
    U =  xy(:,3);
    V =  xy(:,4);
    scatter(X,Y,3,'O', 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineWidth',2)
    %scatter(X + U,Y + V,3,'O', 'MarkerEdgeColor','r','MarkerFaceColor','r', 'LineWidth',2)
    %quiver(X,Y,U,V, scale)
    
    xy = csvread('cellMeanVector.txt');
    X =  xy(:,1);
    Y =  xy(:,2);
    %cx = [0 0.114506883260149*10000]
    %cy = [0 -0.0450954228782883 *10000]
    plot(X, Y, 'LineWidth',  4)
    %scatter(X,Y,4,'O', 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineWidth', 5)
    
end