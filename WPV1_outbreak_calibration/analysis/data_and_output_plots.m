function [] = data_and_output_plots()

addpath('..\');
A = WPV1OutbreakAnalyzer(struct('Enable', 1, 'Class', 'WPV1OutbreakAnalyzer', 'Name', 'WPV1OutbreakAnalyzer'));

A.get_data();

startind = floor( (datenum('Jan-1-2008') - datenum('Jan-1-2003'))/30);
endind = ceil( (datenum('Jul-1-2010') - datenum('Jan-1-2003'))/30);

myfigure;
imagesc(log10(A.data));
xlim([startind-0.5, endind+0.5]);
dates = {'Jan-1-2008', 'Jul-1-2008', 'Jan-1-2009', 'Jul-1-2009', 'Jan-1-2010','Jul-1-2010'};
xticks = round( ( datenum(dates) - datenum('Jan-1-2003') ) / 30 );
set(gca, 'XTick', xticks);
set(gca, 'XTickLabels', strrep(dates, '-1-', ''));
xlabel('Date');
set(gca, 'YTick', 1:size(A.data, 1));
set(gca, 'YTickLabel', A.countries);
colormap([ones(20, 1)*[.75 .75 .75]; flipud(cbrewer('div', 'RdYlGn', 236))]);
cb = colorbar;
set(get(cb, 'YLabel'), 'String', '# of cases')
caxis([-0.2, 2]);
set(cb, 'YTick', [-0.15, 0, 1, 2]);
set(cb, 'YTickLabel', {'0', '1', '10', '100'})
title('WPV1 outbreak - West Africa 2008-2010');

myprint('-dpng', '.\figures\outbreak_data.png');
myprint('-dtiff', '.\figures\outbreak_data.tiff');
saveas(gcf, '.\figures\outbreak_data.fig');
end