function [] = take_differences()
output_dirs = {'12-09-2016_14-35-47', '12-09-2016_22-20-17', '12-10-2016_04-25-43', '12-10-2016_11-42-31', '12-10-2016_18-30-48'};

figouts = struct('contour_line', {cell(length(output_dirs), 1)}, ...
    'surface', {cell(length(output_dirs), 1)}, ...
    'pos_points', {cell(length(output_dirs), 1)}, ...
    'neg_points', {cell(length(output_dirs), 1)});
y_offset = get_migration_mean('linear');
titles = {'Baseline case - all mOPV2 used in SIA', 'mOPV2 RI leakage for 3 months post-SIA', 'mOPV2 RI leakage for 6 months post-SIA', 'mOPV2 RI leakage for 1 year post-SIA', 'mOPV2 RI leakage for 2 years post-SIA'};
titles2 = {'baseline', '3mo', '6mo', '1yr', '2yr'};
for ii = 1:5
    figouts = get_figouts(['..\simulator\' output_dirs{ii}], figouts, ii);
end
myfigure;

for ii = 1:5
    clf;
    surf(figouts.surface{ii}.XData, figouts.surface{ii}.YData+log10(y_offset), figouts.surface{ii}.ZData, 'EdgeColor', 'none');
    view(2);
    hold on
    plot3([0 5], [-3.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    plot3([0 5], [-2.5 -2.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    plot3([0 0], [-2.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    plot3([5 5], [-2.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    ylim([-5, -1.5]);
    set(gca, 'YTick', -5:1:-2);
    xlabel('Years since cessation');
    ylabel('log_{10}(mean daily migration rate)');
    colormap(flipud(cbrewer('div', 'RdBu', 256)));
    cl = colorbar;
    set(get(cl, 'YLabel'), 'string', 'Risk of VDPV circulation');
    title(titles{ii})
    myprint('-dpng', ['Risk_' titles2{ii} '.png']);
    myprint('-dtiff', ['Risk_' titles2{ii} '.tiff']);
    saveas(gcf, ['Risk_' titles2{ii} '.fig']);
end
    
for ii = 2:5
    clf;
    surf(figouts.surface{ii}.XData, figouts.surface{ii}.YData+log10(y_offset), figouts.surface{ii}.ZData - figouts.surface{1}.ZData, 'EdgeColor', 'none');
    view(2);
    hold on
    plot3([0 5], [-3.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    plot3([0 5], [-2.5 -2.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    plot3([0 0], [-2.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    plot3([5 5], [-2.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
    ylim([-5, -1.5]);
    set(gca, 'YTick', -5:1:-2);
    xlabel('Years since cessation');
    ylabel('log_{10}(mean daily migration rate)');
    colormap(flipud(cbrewer('div', 'RdBu', 256)));
    cl = colorbar;
    set(get(cl, 'YLabel'), 'string', 'Excess risk vs. baseline');
%    caxis([-1 1]);
    title(titles{ii})
    myprint('-dpng', ['Additional_risk_' titles2{ii} '.png']);
    myprint('-dtiff', ['Fig_diff_' titles2{ii} '.tiff']);
    saveas(gcf, ['Fig_diff_' titles2{ii} '.fig']);
    
end
end


function [figouts] = get_figouts(this_dir, figouts, ind2fill)
    thisfig = openfig([this_dir '\iteration_2\Mode_N1000.fig'], 'invisible');
    figC = get(thisfig, 'children');
    thisax = [];
    for jj = 1:length(figC);
        if strcmpi(class(figC(jj)), 'matlab.graphics.axis.Axes')
            thisax = figC(jj);
        end
    end
    
    %Going to flip to put migration on Y, time since cessation on X
    if ~isempty(thisax)
        axC = get(thisax, 'Children');
        for jj = 1:length(axC)
            if strcmpi(class(axC(jj)), 'matlab.graphics.chart.primitive.Contour');
                figouts.contour_line{ind2fill}.Y = axC(jj).ContourMatrix(1, 2:end);
                figouts.contour_line{ind2fill}.X = axC(jj).ContourMatrix(2, 2:end);
            
            elseif strcmpi(class(axC(jj)), 'matlab.graphics.chart.primitive.Surface');
                figouts.surface{ind2fill}.YData = axC(jj).XData;
                figouts.surface{ind2fill}.XData = axC(jj).YData;
                figouts.surface{ind2fill}.ZData = axC(jj).ZData;

            elseif strcmpi(class(axC(jj)), 'matlab.graphics.chart.primitive.Line');
                if strcmpi(axC(jj).Marker, 'o')
                     figouts.neg_points{ind2fill}.X = get(axC(jj), 'YData');
                     figouts.neg_points{ind2fill}.Y = get(axC(jj), 'XData');
                elseif strcmpi(axC(jj).Marker, '+')
                     figouts.pos_points{ind2fill}.X = get(axC(jj), 'YData');
                     figouts.pos_points{ind2fill}.Y = get(axC(jj), 'XData');
                end
            end
        end        
    end
    close(thisfig);
end