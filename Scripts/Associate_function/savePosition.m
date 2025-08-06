function savePosition(matrix1,matrix2)
    global col_bac row_bac
    f1=figure
    h=imagesc(matrix1)
    colormap(gray)
    axis tight; % Fit the axes to the data
    set(gca, 'ButtonDownFcn', @getPosition);
    set(h, 'HitTest', 'off');
    clim([0 inf])
    axis square

    f2=figure
    t=imagesc(matrix2)
    colormap(jet)
    clim([0 inf])
    axis tight; % Fit the axes to the data
    axis square

    uiwait(f1)

    function getPosition(~,event)
        ax=gca;
        clickPos=ax.CurrentPoint; % Get the current point in axes units
        clickX=clickPos(1,1);
        clickY=clickPos(1,2);
    
        xLim=ax.XLim; % Get the x-axis limits
        yLim=ax.YLim; % Get the y-axis limits
        matrixSize = size(ax.Children.CData); % Get the size of the matrix used to generate the heatmap
        row_bac = round(interp1(linspace(yLim(1), yLim(2), matrixSize(1)), 1:matrixSize(1), clickY));
        col_bac = round(interp1(linspace(xLim(1), xLim(2), matrixSize(2)), 1:matrixSize(2), clickX));

        uiresume(f1)

        close(f1)
        close(f2)  
    
        fprintf('Callback Triggered');
    end
end



