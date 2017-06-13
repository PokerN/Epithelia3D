function [ ] = voronoiOnEllipsoidSurface( centerOfEllipsoid, ellipsoidDimensions, maxNumberOfCellsInVoronoi, minDistanceBetweenCentroids )
%VORONOIONELLIPSOIDSURFACE Summary of this function goes here
%   Detailed explanation goes here
    s = RandStream('mcg16807','Seed',0);
    RandStream.setGlobalStream(s);
    


    %Init all the info for creating the voronoi
    ellipsoidInfo.xCenter = centerOfEllipsoid(1);
    ellipsoidInfo.yCenter = centerOfEllipsoid(2);
    ellipsoidInfo.zCenter = centerOfEllipsoid(3);
    
    ellipsoidInfo.xRadius = ellipsoidDimensions(1);
    ellipsoidInfo.yRadius = ellipsoidDimensions(2);
    ellipsoidInfo.zRadius = ellipsoidDimensions(3);
    
    ellipsoidInfo.maxNumberOfCellsInVoronoi = maxNumberOfCellsInVoronoi;
    ellipsoidInfo.cellHeight = 0;
    ellipsoidInfo.minDistanceBetweenCentroids = minDistanceBetweenCentroids;
    
    
    ellipsoidInfo.areaOfEllipsoid = ellipsoidSurfaceArea([ellipsoidInfo.xRadius, ellipsoidInfo.yRadius, ellipsoidInfo.zRadius]);

    %(resolutionEllipse + 1) * (resolutionEllipse + 1) number of points
    %generated at the surface of the ellipsoid
    ellipsoidInfo.resolutionEllipse = 300; %300 seems to be a good number
    [x, y, z] = ellipsoid(ellipsoidInfo.xCenter, ellipsoidInfo.yCenter, ellipsoidInfo.zCenter, ellipsoidInfo.xRadius, ellipsoidInfo.yRadius, ellipsoidInfo.zRadius, ellipsoidInfo.resolutionEllipse);
    
    totalNumberOfPossibleCentroids = size(x, 1) * size(x, 1);
    
    %The actual number of centroids that will be increased per iteration
    numberOfCentroids = 1;
    %First Centroid created
    indexRandomCentroid = randi(totalNumberOfPossibleCentroids);
    randomCentroid = [x(indexRandomCentroid), y(indexRandomCentroid), z(indexRandomCentroid)];
    finalCentroids = randomCentroid;
    %The remaining centroids
    %We'll add a maxNumberOfCellsInVoronoi or if the distance doesn't allow
    %us the number will be decreased
    while numberOfCentroids < maxNumberOfCellsInVoronoi && totalNumberOfPossibleCentroids ~= 0
        %Generate a random index
        indexRandomCentroid = randi(totalNumberOfPossibleCentroids);
        %Get the centroid
        randomCentroid = [x(indexRandomCentroid), y(indexRandomCentroid), z(indexRandomCentroid)];
        %Remove the centroid because we don't want to have the same
        %centroid twice
        x(indexRandomCentroid) = [];
        y(indexRandomCentroid) = [];
        z(indexRandomCentroid) = [];
        totalNumberOfPossibleCentroids = totalNumberOfPossibleCentroids - 1;

        %Check if the minimum distance is satisfaed
        minDistanceToExistingCentroids = min(pdist2(randomCentroid, finalCentroids));
        %If it is farther enough it can be added
        if minDistanceToExistingCentroids > minDistanceBetweenCentroids
            numberOfCentroids = numberOfCentroids + 1;
            finalCentroids(numberOfCentroids, :) = randomCentroid;
        end
    end
    
    %Paint the ellipsoid voronoi
    ellipsoidInfo.verticesPerCell = paintVoronoi(finalCentroids(:, 1), finalCentroids(:, 2), finalCentroids(:, 3), ellipsoidInfo.xRadius, ellipsoidInfo.yRadius, ellipsoidInfo.zRadius);
    xs = cellfun(@(x) x(:, 1), ellipsoidInfo.verticesPerCell, 'UniformOutput', false);
    ys = cellfun(@(x) x(:, 2), ellipsoidInfo.verticesPerCell, 'UniformOutput', false);
    zs = cellfun(@(x) x(:, 3), ellipsoidInfo.verticesPerCell, 'UniformOutput', false);
    allTheVertices = [vertcat(xs{:}), vertcat(ys{:}), vertcat(zs{:})];
    uniqueVertices = unique(allTheVertices, 'rows');
    %goodVertices = zeros(size(uniqueVertices, 1), 1);
    cellsUnifyedPerVertex = cell(size(uniqueVertices, 1), 1);
    for vertexIndex = 1:size(uniqueVertices, 1)
        %goodVertices(vertexIndex) = sum(cellfun(@(x) ismember(uniqueVertices(vertexIndex, :), x, 'rows'), ellipsoidInfo.verticesPerCell)) > 2;
        cellsUnifyedPerVertex(vertexIndex) = {find(cellfun(@(x) ismember(uniqueVertices(vertexIndex, :), x, 'rows'), ellipsoidInfo.verticesPerCell))};
    end
    
    totalNumberOfUniqueVertices = size(uniqueVertices, 1);
    refinedVertices = uniqueVertices;
    numberOfVertex = 1;
    while numberOfVertex <= totalNumberOfUniqueVertices
        sequenceToSearch = 1:totalNumberOfUniqueVertices;
        sequenceToSearch(numberOfVertex == sequenceToSearch) = [];
        if (any(cellfun(@(x) all(ismember(cellsUnifyedPerVertex{numberOfVertex}, x, 'rows')), cellsUnifyedPerVertex(sequenceToSearch))));
            cellsUnifyedPerVertex(numberOfVertex) = [];
            refinedVertices(numberOfVertex, :) = [];
            numberOfVertex = numberOfVertex - 1;
            totalNumberOfUniqueVertices = totalNumberOfUniqueVertices - 1;
        end
        numberOfVertex = numberOfVertex + 1;
    end

    ellipsoidInfo.verticesPerCellRefined = cellfun(@(x) x(ismember(x, refinedVertices, 'rows'), :), ellipsoidInfo.verticesPerCell, 'UniformOutput', false);
    figure;
    clmap = colorcube();
    ncl = size(clmap,1);
    
    for cellIndex = 1:size(ellipsoidInfo.verticesPerCellRefined, 1)
        cl = clmap(mod(cellIndex,ncl)+1,:);
        VertCell = ellipsoidInfo.verticesPerCellRefined{cellIndex};
        KVert = convhulln(VertCell);
        patch('Vertices',VertCell,'Faces', KVert,'FaceColor', cl ,'FaceAlpha', 1, 'EdgeColor', 'none')
        hold on;
    end
    
    [ ellipsoidInfo.polygonDistribution, ellipsoidInfo.neighbourhood ] = calculatePolygonDistributionFromVerticesInEllipsoid(finalCentroids, ellipsoidInfo.verticesPerCellRefined);
    ellipsoidInfo.finalCentroids = finalCentroids;
    savefig(strcat('results/ellipsoid_x', num2str(ellipsoidInfo.xRadius), '_y', num2str(ellipsoidInfo.yRadius), '_z', num2str(ellipsoidInfo.zRadius), '.fig'));
    %Saving info
    save(strcat('results/ellipsoid_x', strrep(num2str(ellipsoidInfo.xRadius), '.', ''), '_y', strrep(num2str(ellipsoidInfo.yRadius), '.', ''), '_z', strrep(num2str(ellipsoidInfo.zRadius), '.', '')), 'ellipsoidInfo', 'minDistanceBetweenCentroids');
    
    for cellHeight = 3.5:0.5:(min(ellipsoidDimensions)-0.1)
        ellipsoidInfo.cellHeight = cellHeight;
        %Creating the reduted centroids form the previous ones and the apical
        %reduction
        xReducted = finalCentroids(:, 1) * (ellipsoidInfo.xRadius - cellHeight) / ellipsoidInfo.xRadius;
        yReducted = finalCentroids(:, 2) * (ellipsoidInfo.yRadius - cellHeight) / ellipsoidInfo.yRadius;
        zReducted = finalCentroids(:, 3) * (ellipsoidInfo.zRadius - cellHeight) / ellipsoidInfo.zRadius;

        ellipsoidInfo.verticesPerCell = paintVoronoi(xReducted, yReducted, zReducted, ellipsoidInfo.xRadius - cellHeight, ellipsoidInfo.yRadius - cellHeight, ellipsoidInfo.zRadius - cellHeight);
        ellipsoidInfo.finalCentroids = horzcat([xReducted, yReducted, zReducted]);
        [ ellipsoidInfo.polygonDistribution, ellipsoidInfo.neighbourhood ] = calculatePolygonDistributionFromVerticesInEllipsoid(ellipsoidInfo.finalCentroids, ellipsoidInfo.verticesPerCell);
        savefig(strcat('results/ellipsoidReducted_x', num2str(ellipsoidInfo.xRadius), '_y', num2str(ellipsoidInfo.yRadius), '_z', num2str(ellipsoidInfo.zRadius), '_cellHeight', num2str(cellHeight), '.fig'));
        
        %Saving info
        save(strcat('results/ellipsoidReducted_x', strrep(num2str(ellipsoidInfo.xRadius), '.', ''), '_y', strrep(num2str(ellipsoidInfo.yRadius), '.', ''), '_z', strrep(num2str(ellipsoidInfo.zRadius), '.', ''), '_cellHeight', strrep(num2str(cellHeight), '.', '')), 'ellipsoidInfo', 'minDistanceBetweenCentroids');
    end
end

