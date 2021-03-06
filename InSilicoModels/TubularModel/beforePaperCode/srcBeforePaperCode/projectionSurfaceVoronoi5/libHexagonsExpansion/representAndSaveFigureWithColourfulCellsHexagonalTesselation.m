function representAndSaveFigureWithColourfulCellsHexagonalTesselation( L_original,numCells,seeds,directory,name2save,extension)

    figure('Visible','off');
    colormap(colorcube(numCells));
    image(L_original)
%     set(gca,'box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[]);
    set(gca,'Visible','off')
    axis equal

    for k=1:numCells
        text(seeds(k,2),seeds(k,1),sprintf('%d',k),'Color','black','HorizontalAlignment','center','VerticalAlignment','middle','FontSize',4);
    end
    
    if ~exist(directory)  
        mkdir(directory)
    end
    
    print('-f1','-dtiff','-r300',[directory name2save  extension '.tiff'])
%     print('-f1','-dpdf','-r300',[directory name2save '\' name2save extension '.pdf'])
    close all
    
    
end
