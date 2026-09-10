function plot_mat(JR, varargin)
%PLOT_MAT Plot matrix
%   PLOT_MAT(JR) plots the joint rate index matrix JR with the default parameters. 
%   
%   PLOT_MAT(JR, VARARGIN) takes the additional arguments:
%       'FontSize' - The fontsize of the display text for each entry of the 
%       joint rate matrix. The default is 8.
%       'threshold' - For joint rate indices greater than the threshold,
%       their display text is black, otherwise it is white. The default is
%       0.5. 
%       'ratio' - The aspect ratio of the image. The default is 1. 
%       'width' - Width of the image. The default is 6. 
%       'x' - Horizontal axis values of the columns of JR. The default is
%       size(JR,2). 
%       'y' - Vertical axis values of the rows of JR. The default is
%       size(JR,1). 
%
%   See also JR_IDX 

    p = inputParser; 

    addParameter(p,'FontSize',8); 
    addParameter(p,'threshold',0.5); 
    addParameter(p,'ratio',1); %W/H
    addParameter(p,'width',6); 

    addParameter(p,'row_or_col','col'); 
    addParameter(p, 'x', 1:size(JR,2));
    addParameter(p, 'y', 1:size(JR,1)); 

    parse(p, varargin{:});

    fontsize = p.Results.FontSize; 
    threshold = p.Results.threshold; 
    ratio = p.Results.ratio;
    width = p.Results.width; 
    
    row_or_col = p.Results.row_or_col; 
    x = p.Results.x;
    y = p.Results.y; 

    figure;
    [nRows, nCols] = size(JR);
    imagesc(x,y,JR); 
    
    hold on
    if row_or_col == 'col'
        for c = 1:nCols
            rectangle('Position',[c-0.5,0.5,1,nRows], ...
                'EdgeColor',[1 1 1],'LineWidth',1.5);
        end
    elseif row_or_col == 'row'
        for r = 1:nRows
            rectangle('Position',[0.5, r-0.5, nCols, 1], ...
                'EdgeColor',[1 1 1],'LineWidth',1.5);
        end
    else 
        error("row_or_col accepts only 'row' or 'col'")
    end 
    hold off

    if ~isempty(fontsize)
        for row_idx = 1:nRows
            for col_idx = 1:nCols
                if JR(row_idx,col_idx) > threshold
                    txtColor = 'k';   
                else
                    txtColor = 'w';   
                end
                
                text(col_idx, row_idx, ...
                    num2str(round(JR(row_idx,col_idx),2)), ...
                    'HorizontalAlignment', 'center', ...
                    'Color', txtColor,'FontSize',fontsize); 
            end
        end
    end     
    height = width / ratio;
    set(gcf, 'Units', 'Inches', 'Position', [1 1 width height]);
    set(gca, 'FontSize', 16)
end 