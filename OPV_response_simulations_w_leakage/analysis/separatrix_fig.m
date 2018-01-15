function [] = separatrix_fig()
output_dirs = {'12-09-2016_14-35-47'};

figouts = struct('contour_line', {cell(length(output_dirs), 1)}, ...
    'surface', {cell(length(output_dirs), 1)}, ...
    'pos_points', {cell(length(output_dirs), 1)}, ...
    'neg_points', {cell(length(output_dirs), 1)});
y_offset = get_migration_mean('linear');
for ii = 1:1
    figouts = get_figouts(['..\simulator\' output_dirs{ii}], figouts, ii);
end
myfigure;


y_offset = get_migration_mean('linear');
ind = 1;
myfigure_3x2;
surf(figouts.surface{ind}.XData, figouts.surface{ind}.YData+log10(y_offset), figouts.surface{ind}.ZData, 'EdgeColor', 'none');
colormap(flipud(cbrewer('div', 'RdBu', 256)));
view(2);
hold on
plot3(figouts.contour_line{ind}.X, figouts.contour_line{ind}.Y+log10(y_offset), 2*ones(size(figouts.contour_line{ind}.X)), 'k-');
plot3(figouts.neg_points{ind}.X, figouts.neg_points{ind}.Y+log10(y_offset), 2*ones(size(figouts.neg_points{ind}.X)), 'o', 'Color', rgb2('slategrey'), 'MarkerSize', 8);
plot3(figouts.pos_points{ind}.X, figouts.pos_points{ind}.Y+log10(y_offset), 2*ones(size(figouts.pos_points{ind}.X)), '+', 'Color', rgb2('slategrey'), 'MarkerSize', 12);
plot3([0 5], [-3.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot3([0 5], [-2.5 -2.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot3([0 0], [-2.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot3([5 5], [-2.5 -3.5], [2 2], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
ylim([-5, -1.5]);
set(gca, 'YTick', -5:1:-2);
xlabel('Years since cessation');
set(gca, 'YTick', [-5 -4 -3.56 -3 -2.56 -2 -1.5]);
set(gca, 'YTickLabel', fliplr({'1 round-trip/month', '-2', '1/year', '-3', '1/decade', '-4', '-5'}));
yl = ylabel('log_{10}(mean daily migration rate)');
set(yl, 'Position', [-.8, -3.25, 0])
h = get(gca, 'Children');
ll = legend(h([6 5 7 4]), {'Simulations in which OPV2 extinguishes', 'Simulations in which OPV2 survives', '50% separatrix contour', 'Estimated range of plausible migration rates'});
title('30 months of persistence required')
cl = colorbar;
set(get(cl, 'YLabel'), 'string', 'OPV2 survival probability');
myprint('-dpng', 'Basecase.png');
myprint('-dtiff', 'Basecase.tiff');
saveas(gcf, 'Basecase.fig');
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