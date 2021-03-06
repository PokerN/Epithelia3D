function [edgeLength,sumEdgesOfEnergy,edgeAngle,H1Length,H2Length,W1Length,W2Length,notEmptyIndex]=capturingWidthHeightAndEnergy(verticesPerCell,vertices,pairValidCellsPreserved,cellsInMotifNoContactValidCellsPreserved)
    

    %cell 1 and 2, are the cells in contact. Cell 3 and 4 are not touching between them into the four cell motif.
    verticesCell_1_2=arrayfun(@(x,y) intersect(verticesPerCell{x},verticesPerCell{y}), pairValidCellsPreserved(:,1),pairValidCellsPreserved(:,2),'UniformOutput',false);
    allVerticesCell_1_2=arrayfun(@(x,y) unique([verticesPerCell{x}',verticesPerCell{y}']), pairValidCellsPreserved(:,1),pairValidCellsPreserved(:,2),'UniformOutput',false);
    
   
    verticesCell_3=cellfun(@(x,y) intersect(x,verticesPerCell{y}),allVerticesCell_1_2,table2cell(array2table((cellsInMotifNoContactValidCellsPreserved(:,1)))),'UniformOutput', false);
    verticesCell_4=cellfun(@(x,y) intersect(x,verticesPerCell{y}),allVerticesCell_1_2,table2cell(array2table((cellsInMotifNoContactValidCellsPreserved(:,2)))),'UniformOutput', false);
    
    %H1, H2, W1 and W2 default, calculation
    vertH1default=cellfun(@(x,y) setdiff(x,y),verticesCell_3,verticesCell_1_2,'UniformOutput',false);
    vertH2default=cellfun(@(x,y) setdiff(x,y),verticesCell_4,verticesCell_1_2,'UniformOutput',false);
    vertW1default=cellfun(@(x,y,z) intersect(verticesPerCell{x},[y;z]), table2cell(array2table(pairValidCellsPreserved(:,1))),vertH1default,vertH2default,'UniformOutput',false);
    vertW2default=cellfun(@(x,y,z) intersect(verticesPerCell{x},[y;z]), table2cell(array2table(pairValidCellsPreserved(:,2))),vertH1default,vertH2default,'UniformOutput',false);

    %delete vertices with problems
    notEmptyIndex=cell2mat(cellfun(@(x,y,z,zz,zzz) (length(x)==2 & length(y)==2 & length(z)==2 & length(zz)==2 & ~isempty(zzz)),vertH1default,vertH2default,vertW1default,vertW2default,verticesCell_1_2,'UniformOutput',false));
    
    
    if sum(~notEmptyIndex)>0 
        verticesCell_1_2(~notEmptyIndex,:)={NaN};
        vertH1default(~notEmptyIndex,:)={NaN};
        vertH2default(~notEmptyIndex,:)={NaN};
        vertW1default(~notEmptyIndex,:)={NaN};
        vertW2default(~notEmptyIndex,:)={NaN};
        verticesCell_3(~notEmptyIndex,:)={NaN};
        verticesCell_4(~notEmptyIndex,:)={NaN};
    end
    
    
    
    %testing the angles to consider with edge is w and h
    edgeLength=zeros(length(verticesCell_1_2),1);
    edgeAngle=zeros(length(verticesCell_1_2),1);
    
    H1Length=zeros(length(verticesCell_1_2),1);
    H2Length=zeros(length(verticesCell_1_2),1);
    W1Length=zeros(length(verticesCell_1_2),1);
    W2Length=zeros(length(verticesCell_1_2),1);
    sumEdgesOfEnergy=zeros(length(verticesCell_1_2),1);
    
    %testing angle and edge length
    for i=1:length(verticesCell_1_2)
        
        if ~isnan(verticesCell_1_2{i}) 
        
            try
                [edgeLength(i), edgeAngle(i)] = edgeLengthAnglesCalculation([vertices.verticesPerCell{verticesCell_1_2{i}(1,1)};vertices.verticesPerCell{verticesCell_1_2{i}(2,1)}]);

                [edge1Length, edge1Angle] = edgeLengthAnglesCalculation([vertices.verticesPerCell{vertH1default{i}(1,1)};vertices.verticesPerCell{vertH1default{i}(2,1)}]);
                [edge2Length, edge2Angle] = edgeLengthAnglesCalculation([vertices.verticesPerCell{vertH2default{i}(1,1)};vertices.verticesPerCell{vertH2default{i}(2,1)}]);
                [edge3Length, edge3Angle] = edgeLengthAnglesCalculation([vertices.verticesPerCell{vertW1default{i}(1,1)};vertices.verticesPerCell{vertW1default{i}(2,1)}]);
                [edge4Length, edge4Angle] = edgeLengthAnglesCalculation([vertices.verticesPerCell{vertW2default{i}(1,1)};vertices.verticesPerCell{vertW2default{i}(2,1)}]);

                %detecting who is W and who H depending on its angle
                if (edge1Angle+edge2Angle)>(edge3Angle+edge4Angle)
                    W1Length(i)=edge1Length;
                    W2Length(i)=edge2Length;
                    H1Length(i)=edge3Length;
                    H2Length(i)=edge4Length;
                else
                    W1Length(i)=edge3Length;
                    W2Length(i)=edge4Length;
                    H1Length(i)=edge1Length;
                    H2Length(i)=edge2Length;
                end

                %get sum of energies
                sumEdgesOfEnergy(i) = getSumOfEnergyEdges(verticesCell_1_2{i},verticesCell_3{i},verticesCell_4{i},vertices);
            catch
                edgeLength(i)=NaN;
                edgeAngle(i)=NaN;
                W1Length(i)=NaN;
                W2Length(i)=NaN;
                H1Length(i)=NaN;
                H2Length(i)=NaN;
                sumEdgesOfEnergy(i)=NaN;
            end
            
                
        else
            edgeLength(i)=NaN;
            edgeAngle(i)=NaN;
            W1Length(i)=NaN;
            W2Length(i)=NaN;
            H1Length(i)=NaN;
            H2Length(i)=NaN;
            sumEdgesOfEnergy(i)=NaN;
        end
    end
        
end

