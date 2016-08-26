function [] = rate_comparison_fig()

output_base = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\OPV_response_WestAfrica_simulations\';
load([output_base '\compiled_separatrices.mat']);

y_offset = get_migration_mean('linear');

myfigure_square;
hold on
R0f = [1.2, 1.5, 2.0, 3.0];
colors = [0 0 0; rgb2('slategrey'); rgb2('firebrick'); rgb2('DarkTurquoise')];
for ii = 1:length(R0f)
        ind =  find(inrange(simconfigs.R0_final, R0f(ii)-.01, R0f(ii)+.01) & inrange(simconfigs.R0_init, .49, .51) & inrange(simconfigs.R0_lambda, 40, 80) & ...
            strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'), 1, 'first');
            
        plot(figouts.contour_line{ind}.X, figouts.contour_line{ind}.Y+log10(y_offset), '-', 'Color', colors(ii, :));
        
        ind =  find(inrange(simconfigs.R0_final, R0f(ii)-.01, R0f(ii)+.01) & inrange(simconfigs.R0_init, .49, .51) & inrange(simconfigs.R0_lambda, 100, 200) & ...
            strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'), 1, 'first');
        
        plot(figouts.contour_line{ind}.X, figouts.contour_line{ind}.Y+log10(y_offset), '--', 'Color', colors(ii, :));
end
plot([0 5], [-3.5 -3.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot([0 5], [-2.5 -2.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot([0 0], [-2.5 -3.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
plot([5 5], [-2.5 -3.5], '-.', 'Color', rgb2('black'), 'LineWidth', 1);
ylim([-5, -1.5]);
set(gca, 'YTick', -5:1:-2);
xlabel('Years since cessation');
ylabel('log_{10}(mean daily migration rate)');
myprint('-dpng', 'figures\Fig_rate.png');
myprint('-dtiff', 'figures\Fig_rate.tiff');
saveas(gcf, 'figures\Fig_rate.fig');
end