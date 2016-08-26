function [] = R0_comparison_fig()

output_base = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\OPV_response_WestAfrica_simulations\';
load([output_base '\compiled_separatrices.mat']);
R0f = [1.2, 1.5, 2.0, 3.0];
R0i = [.5, .25];

y_offset = get_migration_mean('linear');

myfigure_square;
linestyle = {'-', '--'};
colors = [0 0 0; rgb2('slategrey'); rgb2('firebrick'); rgb2('DarkTurquoise')];
hold on
for ii = 1:length(R0f)
    for jj = 1:length(R0i);
        ind =  find(inrange(simconfigs.R0_final, R0f(ii)-.01, R0f(ii)+.01) & inrange(simconfigs.R0_init, R0i(jj)-.01, R0i(jj)+.01) & inrange(simconfigs.R0_lambda, 40, 80) & ...
            strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'), 1, 'first');
            
        plot(figouts.contour_line{ind}.X, figouts.contour_line{ind}.Y+log10(y_offset), linestyle{jj}, 'Color', colors(ii, :));

    end
end
plot([0 5], [-3.5 -3.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot([0 5], [-2.5 -2.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot([0 0], [-2.5 -3.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot([5 5], [-2.5 -3.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1)
ylim([-5, -1.5]);
set(gca, 'YTick', -5:1:-2);
xlabel('Years since cessation');
ylabel('log_{10}(mean daily migration rate)');
myprint('-dpng', 'figures\FigR0.png');
myprint('-dtiff', 'figures\FigR0.tiff');
saveas(gcf, 'figures\FigR0.fig');
end