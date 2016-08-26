function [] = plot_outputs()

addpath('..\');
A = WPV1OutbreakAnalyzer(struct('Enable', 1, 'Class', 'WPV1OutbreakAnalyzer', 'Name', 'WPV1OutbreakAnalyzer'));
mkdir('.\figures\');
CP = [];
LL = [];
Infs = [];

outdir = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\WPV1_outbreak_calibration\Suite_d3b59fa5-476a-e611-93fd-f0921c16b9e4';
Exps = dir([outdir '\Experiment_*']);
for ii = 1:5
    load([outdir '\' Exps(ii).name '\results\likelihood.mat']);
    LL = [LL; log_likelihood];
    load([outdir '\' Exps(ii).name '\work\CalibPoints.mat']);
    CP = [CP; CalibPoints];
    load([outdir '\' Exps(ii).name '\work\Parser_RSOParser.mat']);
    A.accumulate_spatial_output(parser);
    Infs = [Infs; A.spatial_outputs.accum_new_infs];
end

startind = floor( (datenum('Jan-1-2008') - datenum('Jan-1-2003'))/30);
endind = ceil( (datenum('Jul-1-2010') - datenum('Jan-1-2003'))/30);
Infs = Infs(:, :, 1:length(startind:endind));


myfigure;
yshift = get_migration_mean('linear');
[~, inds] = sort(LL, 'ascend');
scatter(27*4/5*CP(inds, 1), CP(inds, 2)+log10(yshift), 40, LL(inds)/10, 'filled')
ylim([-6, 0])
xlim([5, 8.5])
xlabel('Base Reproductive Number');
ylabel('log_{10}(Mean per-person per-day migration rate)')
title('Migration rate calibration');
cb = colorbar;
set(get(cb, 'YLabel'), 'String', '-log_{10}(\sigma)');
myprint('-dpng', '.\figures\objective_space.png');
myprint('-dtiff', '.\figures\objective_space.tiff');
saveas(gcf, '.\figures\objective_space.fig');

[~, inds] = sort(LL, 'descend');
theseinds = inds([2 6]);
for ii = 1:length(theseinds)
    thisind = theseinds(ii);
    clf;
    imagesc(log10(squeeze(Infs(thisind, :, :))));
    xlim([0.5, size(Infs, 3)+.5]);
    dates = {'Jan-1-2008', 'Jul-1-2008', 'Jan-1-2009', 'Jul-1-2009', 'Jan-1-2010','Jul-1-2010'};
    title(['R_0 = ' num2str(4/5*27*CP(thisind, 1)) ', log_{10}(Mig. rate) = ' num2str(CP(thisind, 2) + log10(yshift))]);
    xticks = ceil( ( datenum(dates) - datenum('Jan-1-2008') ) / 30 );
    set(gca, 'XTick', xticks+1.5);  %Annoying offset in sim to data dates.  Doesn't matter since all is referenced to outbreak peak
    set(gca, 'XTickLabels', strrep(dates, '-1-', ''));
    xlabel('Date');
    set(gca, 'YTick', 1:size(Infs, 2));
    set(gca, 'YTickLabel', A.countries);
    colormap([ones(20, 1)*[.75 .75 .75]; flipud(cbrewer('div', 'RdYlGn', 246))]);
    caxis([-0.2, 2]);
    cb = colorbar;
    set(get(cb, 'YLabel'), 'String', '# of infections')
    set(cb, 'YTick', [-0.15, 0, 1, 2]);
    set(cb, 'YTickLabel', {'0', '100', '1e3', '1e4'})
    myprint('-dpng', ['.\figures\outbreak_goodfit_' num2str(ii) '.png']);
    myprint('-dtiff', ['.\figures\outbreak_goodfit_' num2str(ii) '.tiff']);
    saveas(gcf, ['.\figures\outbreak_goodfit_' num2str(ii) '.fig']);
end

inds = find(CP(:, 2)+log10(yshift) > -1.5);
for ii = 1:2
    thisind = inds(ii);
    clf;
    imagesc(log10(squeeze(Infs(thisind, :, :))));
    xlim([0.5, size(Infs, 3)+.5]);
    dates = {'Jan-1-2008', 'Jul-1-2008', 'Jan-1-2009', 'Jul-1-2009', 'Jan-1-2010','Jul-1-2010'};
    title(['R_0 = ' num2str(4/5*27*CP(thisind, 1)) ', log_{10}(Mig. rate) = ' num2str(CP(thisind, 2) + log10(yshift))]);
    xticks = round( ( datenum(dates) - datenum('Jan-1-2008') ) / 30 );
    set(gca, 'XTick', xticks+1.5);
    set(gca, 'XTickLabels', strrep(dates, '-1-', ''));
    xlabel('Date');
    set(gca, 'YTick', 1:size(Infs, 2));
    set(gca, 'YTickLabel', A.countries);
    colormap([ones(20, 1)*[.75 .75 .75]; flipud(cbrewer('div', 'RdYlGn', 246))]);
    caxis([-0.2, 2]);
    cb = colorbar;
    set(get(cb, 'YLabel'), 'String', '# of infections')
    set(cb, 'YTick', [-0.15, 0, 1, 2]);
    set(cb, 'YTickLabel', {'0', '100', '1e3', '1e4'})
    myprint('-dpng', ['.\figures\outbreak_toohigh_' num2str(ii) '.png']);
    myprint('-dtiff', ['.\figures\outbreak_toohigh_' num2str(ii) '.tiff']);
    saveas(gcf, ['.\figures\outbreak_toohigh_' num2str(ii) '.fig']);
end

inds = find(CP(:, 2)+log10(yshift) <-4);
for ii = 1:2
    thisind = inds(ii);
    clf;
    imagesc(log10(squeeze(Infs(thisind, :, :))));
    xlim([0.5, size(Infs, 3)+.5]);
    dates = {'Jan-1-2008', 'Jul-1-2008', 'Jan-1-2009', 'Jul-1-2009', 'Jan-1-2010','Jul-1-2010'};
    title(['R_0 = ' num2str(4/5*27*CP(thisind, 1)) ', log_{10}(Mig. rate) = ' num2str(CP(thisind, 2) + log10(yshift))]);
    xticks = round( ( datenum(dates) - datenum('Jan-1-2008') ) / 30 );
    set(gca, 'XTick', xticks+1.5);
    set(gca, 'XTickLabels', strrep(dates, '-1-', ''));
    xlabel('Date');
    set(gca, 'YTick', 1:size(Infs, 2));
    set(gca, 'YTickLabel', A.countries);
    colormap([ones(20, 1)*[.75 .75 .75]; flipud(cbrewer('div', 'RdYlGn', 246))]);
    caxis([-0.2, 2]);
    cb = colorbar;
    set(get(cb, 'YLabel'), 'String', '# of infections')
    set(cb, 'YTick', [-0.15, 0, 1, 2]);
    set(cb, 'YTickLabel', {'0', '100', '1e3', '1e4'})
    myprint('-dpng', ['.\figures\outbreak_toolow_' num2str(ii) '.png']);
    myprint('-dtiff', ['.\figures\outbreak_toolow_' num2str(ii) '.tiff']);
    saveas(gcf, ['.\figures\outbreak_toolow_' num2str(ii) '.fig']);
end