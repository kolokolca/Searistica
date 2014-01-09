function plotting()

file = 'PBencd_EuclideanCost_Sat4j.res'
field = 'TimeInSec';
[nodes, totalNodes, timeValuesForEuclideanCost] = readFile(file, field);
[nodes, totalNodes, statusForEuclideanCost] = readFile(file, 'Status');
maxYval = max(timeValuesForEuclideanCost);

file = 'PBencd_RandomSymmetric_EuclideanCostModified_Sat4j.res'
[nodes, totalNodes, timeValuesForRandomSymmetric_EuclideanCost] = readFile(file, field);
[nodes, totalNodes, statusForRandomSymmetric_EuclideanCost] = readFile(file, 'Status');
if(max(timeValuesForRandomSymmetric_EuclideanCost) > maxYval)
    maxYval = max(timeValuesForRandomSymmetric_EuclideanCost);
end

file = 'PBencd_SymmetricNoisy_50PercentEuclideanCostModified_Sat4j.res'
[nodes, totalNodes, timeValuesForSymmetricNoisy_50PercentEuclideanCost] = readFile(file, field);
[nodes, totalNodes, statusForSymmetricNoisy_50PercentEuclideanCost] = readFile(file, 'Status');
if(max(timeValuesForSymmetricNoisy_50PercentEuclideanCost) > maxYval)
    maxYval = max(timeValuesForSymmetricNoisy_50PercentEuclideanCost);
end

file = 'PBencd_AsymmetricNoisy_50PercentEuclideanCostModified_Sat4j.res'
[nodes, totalNodes, timeValuesForAsymmetricNoisy_50PercentEuclideanCost] = readFile(file, field);
[nodes, totalNodes, statusForAsymmetricNoisy_50PercentEuclideanCost] = readFile(file, 'Status');
if(max(timeValuesForAsymmetricNoisy_50PercentEuclideanCost) > maxYval)
    maxYval = max(timeValuesForAsymmetricNoisy_50PercentEuclideanCost);
end

file = 'PBencd_RandomCost_Sat4j.res'
[nodes, totalNodes, timeValuesForRandomCost] = readFile(file, field);
[nodes, totalNodes, statusForRandomCost] = readFile(file, 'Status');
if(max(timeValuesForRandomCost) > maxYval)
    maxYval = max(timeValuesForRandomCost);
end

file = 'PBencd_OceanDataCost_Sat4j.res'
[nodes, totalNodes, timeValuesForOceanDataCost] = readFile(file, field);
[nodes, totalNodes, statusForOceanDataCost] = readFile(file, 'Status');
if(max(timeValuesForOceanDataCost) > maxYval)
    maxYval = max(timeValuesForOceanDataCost);
end


figure;
s1 = subplot(6,1,1);
plotData(s1, nodes, timeValuesForEuclideanCost, statusForEuclideanCost, maxYval, totalNodes ,'Euclidean + Symmetric');

s1 = subplot(6,1,2);
plotData(s1, nodes, timeValuesForRandomSymmetric_EuclideanCost, statusForRandomSymmetric_EuclideanCost, maxYval, totalNodes ,'RandomSymmetric');

s1 = subplot(6,1,3);
plotData(s1, nodes, timeValuesForSymmetricNoisy_50PercentEuclideanCost, statusForSymmetricNoisy_50PercentEuclideanCost, maxYval, totalNodes ,'50% Euclidean + 50% Symmetric (Add or Sub little nosie at i,j and j,i)');

s1 = subplot(6,1,4);
plotData(s1, nodes, timeValuesForAsymmetricNoisy_50PercentEuclideanCost, statusForAsymmetricNoisy_50PercentEuclideanCost, maxYval, totalNodes ,'50% Euclidean + 50% Asymmetric (Add little nosie at i,j and Sub little noise at j,i)');

s1 = subplot(6,1,5);
plotData(s1, nodes, timeValuesForRandomCost, statusForRandomCost, maxYval, totalNodes,'RandomCost');

s1 = subplot(6,1,6);
plotData(s1, nodes, timeValuesForOceanDataCost, statusForOceanDataCost, maxYval, totalNodes,'OceanDataCost');


end

function plotData(subPlot, nodes, timeValues, statusValues, maxYval, totalNodes, title1 )
    
    maxYval = maxYval + 1000;
    maxXval = totalNodes + 4;
    s = 25;
    
    plot(nodes, timeValues, 'k', 'linewidth', 1); 
    set(gca, 'Ticklength', [0 0])
    set(gca,'YLim',[-1 maxYval], 'XTick',0:1:maxXval, 'FontSize', 8)
    ylabel('Time & Opt,SAT,Un')
    
    hold on
    for i = 1:totalNodes
       n = nodes(i);
       t = timeValues(i);
       value = statusValues(i);
       if(value == 1)
           fc = [154,205,50] ./ 255;
           ec = [107,142,35] ./ 255;
           scatter(subPlot,n,t,s,'fill','MarkerEdgeColor',ec, 'MarkerFaceColor',fc);
           %stem(s1,n,t, 'c', 'filled');
       elseif(value == 2)
           fc = [46,139,87] ./ 255;
           ec = [0,100,0] ./ 255;
           scatter(subPlot,n,t,s,'fill','MarkerEdgeColor',ec, 'MarkerFaceColor',fc);
           %stem(s1,n,t, 'g', 'filled');
       elseif(value == 3)
           fc = [255,160,122] ./ 255;
           ec = [220,20,60] ./ 255;
           scatter(subPlot,n,t,s,'fill','MarkerEdgeColor',ec, 'MarkerFaceColor',fc);
           %stem(s1,n,t, 'r', 'filled');
       end   
    end
    
    title(title1);

end


function  [nodes, totalNodes, values] = readFile(filename, property)
    fid=fopen(filename, 'rt');
    if fid == -1 
        error('File could not be opened, check name or path.')
    end
    tline = fgetl(fid);
    while ischar(tline)
        %lineParts = strsplit(tline,',');
        lineParts = textscan(tline, '%s', 'delimiter', ',');
        lineParts = lineParts{1};
        
        if( strcmp(lineParts(1),'TotalNodes'))
            nodesStr = lineParts(2:end);
            totalNodes = length(nodesStr);
            nodes = zeros(totalNodes,1);
            for i = 1:totalNodes
                nodes(i) = str2double(nodesStr(i));
            end
            
        end
        %TimeInSec
        if( strcmp(lineParts(1),property))
            valuesStr = lineParts(2:end);
            totalValues = length(valuesStr);
            values = zeros(1,totalValues);
            for i = 1:totalValues
                values(i) = str2double(valuesStr(i));
            end
            %values = values./60;
            
        end

        tline = fgetl(fid);
    end 
    %bar(n,t,'g')
end
