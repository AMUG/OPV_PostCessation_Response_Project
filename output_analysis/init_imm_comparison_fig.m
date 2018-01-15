function [] = init_imm_comparison_fig()

output_base = 'C:\Users\kmccarthy\Dropbox (IDM)\Repo\KM_OPV_PCR\OPV_response_WestAfrica_simulations\';
load([output_base '\compiled_separatrices.mat']);
R0f = [1.2, 1.5, 2.0, 3.0];
campaigns = {'campaign_base.json', 'campaign_high_immunity_base.json'};
y_offset = get_migration_mean('linear');

myfigure_3x2;
linestyle = {'-', '--'};
colors = [0 0 0; rgb2('slategrey'); rgb2('firebrick'); rgb2('DarkTurquoise')];
hold on
for jj = 1:length(campaigns);
    
    for ii = 1:length(R0f)
        ind =  find(inrange(simconfigs.R0_final, R0f(ii)-.01, R0f(ii)+.01) & inrange(simconfigs.R0_init, .49, .51) & inrange(simconfigs.R0_lambda, 40, 80) & ...
            strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, campaigns{jj}), 1, 'first');
        
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
set(gca, 'YTick', [-5 -4  -3 -2]);
yl = ylabel('log_{10}(mean daily migration rate)');
text(0.025, -3.56, 5, '1/decade', 'Color', 'black', 'FontSize', 14);
text(0.025, -2.56, 5, '1/year', 'Color', 'black', 'FontSize', 14);
text(0.025, -1.56, 5, '~1 round trip/month', 'Color', 'black', 'FontSize', 14);
%Matlab's legend is annoying me, build my own.
plot([0.07, 0.3], [-3.8, -3.8], '-', 'Color', colors(1, :));
plot([0.07, 0.3], [-4.0, -4.0], '-', 'Color',colors(2, :));
plot([0.07, 0.3], [-4.2, -4.2], '-', 'Color',colors(3, :));
plot([0.07, 0.3], [-4.4, -4.4], '-', 'Color',colors(4, :));

plot([0.07, 0.3], [-4.6, -4.6], 'k-');
plot([0.07, 0.3], [-4.8, -4.8], 'k--', 'LineWidth', 4);
text(0.35, -3.82, 'R_{0f} = 1.2');
text(0.35, -4.02, 'R_{0f} = 1.5');
text(0.35, -4.22, 'R_{0f} = 2');
text(0.35, -4.42, 'R_{0f} = 3');
text(0.35, -4.59, 'Med. immunity at cessation');
text(0.35, -4.79, 'High immunity at cessation');
myprint('-dpng', 'figures\Fig_immunity_new.png');
myprint('-dtiff', 'figures\Fig_immunity_new.tiff');
saveas(gcf, 'figures\Fig_immunity_new.fig');
end