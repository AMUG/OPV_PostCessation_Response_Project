function [] = separatrix_fig()
output_base = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\OPV_response_WestAfrica_simulations\';
load([output_base '\compiled_separatrices.mat']);

ind = find(inrange(simconfigs.R0_final, 1.99, 2.01) & inrange(simconfigs.R0_init, 0.4, 0.6) & inrange(simconfigs.R0_lambda, 40, 80) & ...
    strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'));

y_offset = get_migration_mean('linear');

myfigure_square;
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
ylabel('log_{10}(mean daily migration rate)');
cl = colorbar;
set(get(cl, 'YLabel'), 'string', 'Probability of exportation');
myprint('-dpng', 'figures\Fig1.png');
myprint('-dtiff', 'figures\Fig1.tiff');
saveas(gcf, 'figures\Fig1.fig');
end