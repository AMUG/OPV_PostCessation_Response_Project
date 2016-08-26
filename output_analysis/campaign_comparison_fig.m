function [] = campaign_comparison_fig()

output_base = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\OPV_response_WestAfrica_simulations\';
load([output_base '\compiled_separatrices.mat']);
campaign_files = {'campaign_base.json', 'campaign_1IPV.json', 'campaign_2IPV.json'};

y_offset = get_migration_mean('linear');

myfigure_square;
R0_final = [2, 3];
colors = [rgb2('firebrick'); rgb2('DarkTurquoise')];
linestyle = {':', '-', '--'};
hold on
for ii = 1:length(campaign_files)
    for jj = 1:length(R0_final)
        ind =  find(inrange(simconfigs.R0_final, R0_final(jj)-.01, R0_final(jj)+.01) & inrange(simconfigs.R0_init, .49, .51) & inrange(simconfigs.R0_lambda, 40, 80) & ...
            strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, campaign_files{ii}), 1, 'first');
        plot(figouts.contour_line{ind}.X, figouts.contour_line{ind}.Y+log10(y_offset), linestyle{ii}, 'Color', colors(jj, :));
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
myprint('-dpng', 'figures\Fig_camp.png');
myprint('-dtiff', 'figures\Fig_camp.tiff');
saveas(gcf, 'figures\Fig_camp.fig');
end