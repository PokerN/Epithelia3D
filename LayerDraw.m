
function [LayerCentroid] = LayerDraw( LayerCentroid, Color, numFrame, initialFrame, photo_Path, name, pixel)

%%Representation of the centroids of the different layers
channel1Name{numFrame}= [name sprintf('%03d',numFrame) '_c001.tif'];
channel1PhotoPath{numFrame}=[photo_Path '\' channel1Name{numFrame}];

%for numLayer=2:size(LayerCentroid, 1)
    
    f=figure('Visible', 'on');
    imshow(channel1PhotoPath{numFrame});
    hold on;   
    
    for numLayer=1:size(LayerCentroid, 1)
        for numCentroidLayer=1:size(LayerCentroid{numLayer,1}(:, 1),1)
            if ismember(round(LayerCentroid{numLayer,1}(numCentroidLayer,2:3)),pixel{numFrame,1},'rows') == 1
                plot(LayerCentroid{numLayer,1}(numCentroidLayer,2), LayerCentroid{numLayer,1}(numCentroidLayer, 3), '*','MarkerEdgeColor', Color(numLayer,:), 'MarkerFaceColor', Color(numLayer,:));
            end
        end
    end
    %for numLayer2to2=numLayer-1:numLayer 
        %for numCentroidLayer=1:size(LayerCentroid{numLayer2to2,1}(:, 1),1)
            %plot(LayerCentroid{numLayer2to2,1}(numCentroidLayer,2), LayerCentroid{numLayer2to2,1}(numCentroidLayer, 3), '*','MarkerEdgeColor', Color(numLayer2to2,:), 'MarkerFaceColor', Color(numLayer2to2,:));
%              numLay(numLayer,:)=plot(LayerCentroid{numLayer,1}(numCentroidLayer,2), LayerCentroid{numLayer,1}(numCentroidLayer, 3), '*','MarkerEdgeColor', Color(numLayer,:), 'MarkerFaceColor', Color(numLayer,:));
        %end
%         nameLay{numLayer}=sprintf ('Layer%d', numLayer);
        
%         legend(numLay,nameLay,'Location','best');
        
        % Merge images to return
        %finalLayerPhoto=[photo_Path '\Layers\' name sprintf('%03d',numFrame) 'centroid_layers' sprintf('%d', numLayer) '.bmp'];
        finalLayerPhoto=[photo_Path '\Layers\' name sprintf('%03d',numFrame) 'centroid_layers.bmp'];
        saveas(f,finalLayerPhoto);
        
        %%Treatment of layers
        if numFrame > initialFrame+1 %This is needed because we don't have a figure before (so here it enters Frame 8)
            % To add new centroids
            want_add_centroid=input('Do you want to add centroid? 1 (yes) \n 0 (no) \n:');
            want_add_more =1;
            while want_add_more ==1
                switch want_add_centroid
                    case 0
                        break
                    case 1
                        [LayerCentroid] = addNewCentroid( f, LayerCentroid,numFrame );
                end
                want_add_more=input('Do you want to add more? 1 (yes) \n 0 (no) \n:');
            end
            want_modify=input('1 (change labelling mode) \n 0 (Next frame): ');
            want_modify_more =1;
            
            % To change a centroid from a layer to other layer
            while want_modify_more ==1
                switch want_modify
                    case 0
                        break
                    case 1
                        f = display_labelled (f, LayerCentroid);
                        [LayerCentroid] = layer_write_mode(f,LayerCentroid, numFrame);
                end
                want_modify_more=input('Do you want to make more changes? 1 (yes) \n 0 (no) \n:');
            end
        end
%     end
    %close all
% end

end



