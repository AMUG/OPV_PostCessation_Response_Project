output_base = 'C:\Users\kmccarthy\Dropbox (IDM)\Repo\KM_OPV_PCR\OPV_response_WestAfrica_simulations';
load([output_base '\compiled_separatrices_wvar.mat']);


myfigure_3x2;
%let's get three lines on here

ind1 =  find(inrange(simconfigs.R0_final, 2.99, 3.01) & inrange(simconfigs.R0_init, 0.49, 0.51) & inrange(simconfigs.R0_lambda, 40, 80) & ...
    strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'), 1, 'first');

ind2 =  find(inrange(simconfigs.R0_final, 1.99, 2.01) & inrange(simconfigs.R0_init, 0.49, 0.51) & inrange(simconfigs.R0_lambda, 40, 80) & ...
    strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'), 1, 'first');

ind3 =  find(inrange(simconfigs.R0_final, 1.49, 1.51) & inrange(simconfigs.R0_init, 0.49, 0.51) & inrange(simconfigs.R0_lambda, 40, 80) & ...
    strcmpi(simconfigs.migration_type, 'linear') & strcmpi(simconfigs.campaign_type, 'campaign_1IPV.json'), 1, 'first');

y_offset = get_migration_mean('linear');

xdm1 = figouts.surface{ind1}.XData;
ydm1 = figouts.surface{ind1}.YData;
zdm1 = figouts.surface{ind1}.ZData;
zdv1 = figouts.var_surface{ind1}.ZData;

xdm2 = figouts.surface{ind2}.XData;
ydm2 = figouts.surface{ind2}.YData;
zdm2 = figouts.surface{ind2}.ZData;
zdv2 = figouts.var_surface{ind2}.ZData;

xdm3 = figouts.surface{ind3}.XData;
ydm3 = figouts.surface{ind3}.YData;
zdm3 = figouts.surface{ind3}.ZData;
zdv3 = figouts.var_surface{ind3}.ZData;

[~, ind11] = min(abs(ydm1(1, :)+log10(y_offset)+3.0));
[~, ind22] = min(abs(ydm2(1, :)+log10(y_offset)+3.0));
[~, ind33] = min(abs(ydm3(1, :)+log10(y_offset)+3.0));

colors = [0 0 0; rgb2('slategrey'); rgb2('firebrick'); rgb2('DarkTurquoise')];
plot(xdm3(:, ind33), zdm3(:, ind33), '-', 'Color', colors(2, :));
hold on
plot(xdm2(:, ind22), zdm2(:, ind22), '-', 'Color', colors(3, :));
plot(xdm1(:, ind11), zdm1(:, ind11), '-', 'Color', colors(4, :));
jbfill(xdm3(:, ind33)', zdm3(:, ind33)'+2*sqrt(zdv3(:, ind33))', zdm3(:, ind33)'-2*sqrt(zdv3(:, ind33))',  colors(2, :),  colors(2, :), 1, 0.5);
jbfill(xdm2(:, ind22)', zdm2(:, ind22)'+2*sqrt(zdv2(:, ind22))', zdm2(:, ind22)'-2*sqrt(zdv2(:, ind22))',  colors(3, :),  colors(3, :), 1, 0.5);
jbfill(xdm1(:, ind11)', zdm1(:, ind11)'+2*sqrt(zdv1(:, ind11))', zdm1(:, ind11)'-2*sqrt(zdv1(:, ind11))', colors(4, :),  colors(4, :), 1, 0.5);




ylim([0, 1]);
xlabel('Time since cessation (years)');
ylabel('Probability of OPV2 survival');
mylegend('R_{0f} = 1.5', 'R_{0f} = 2', 'R_{0f} = 3', 'Location', 'Northwest');
myprint('-dpng', 'figures\line_plot_risk_new.png');
myprint('-dtiff', 'figures\line_plot_risk_new.tiff');
saveas(gcf, 'figures\line_plot_risk_new.fig');