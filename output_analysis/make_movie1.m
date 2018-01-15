output_base = ('C:\Users\kmccarthy\Dropbox (IDM)\Repo\KM_OPV_PCR\OPV_response_WestAfrica_simulations\Suite_740cd493-5655-e611-93fd-f0921c16b9e4\Experiment_750cd493-5655-e611-93fd-f0921c16b9e4\');

p1 = load([output_base '\work\Parser_RSOParser.mat']);
p2 = load([output_base '\work\Parser_ReducedInsetChartParser.mat']);
shapes = shape_get('C:\Users\kmccarthy\Dropbox (IDM)\Repo\KM_OPV_PCR\shapefiles\Africa.shp');
demog = loadJson([output_base '\input\demographics\WestAfrica_ProvinceLevel_demographics.json']);
mig_rates = cellfun(@(x) str2double(get(x, 'x_Local_Migration')), p2.parser.insetCharts.TagString) +  log10(get_migration_mean('quad'));
time_since = cellfun(@(x) str2double(get(x, 'Target_Age_Min_All')), p2.parser.insetCharts.TagString);

%myfigure;
nodes = p1.parser.spatialOutput.nodeIDList{1}{1};
adminIDs = containers.Map(cellfun(@(x) x.NodeID, demog.Nodes), cellfun(@(x) x.HierarchyID, demog.Nodes));
shapeIDs = [shapes.Attribute.hid_id];
bins = [-Inf, -7, linspace(-4, -1, 253), 0];
cmap(1, :) = [1 1 1];
cmap(2:256, :) = cbrewer('seq', 'Reds', 255);
for ii = 1:500
    
    myoutput = log10(p1.parser.spatialOutput.channelTimeSeries{ii}{3} + 1e-9);
    F(size(myoutput, 2)) = struct('cdata', [], 'colormap', []);
    for jj = 1:size(myoutput, 2)
        clf;
        incidences = myoutput(:, jj);
        for kk = 1:length(myoutput)
            thisShape = shapes.Shape(shapeIDs == adminIDs(nodes(kk)));
            thisBin = find(bins <= incidences(kk), 1, 'last');
            
            color = cmap(thisBin, :);
            
            inds = SplitVec(isnan(thisShape.x), 'equal', 'bracket');
            for mm = 1:2:size(inds, 1)      
                patch(thisShape.x(inds(mm,1):inds(mm,2)), ...
                    thisShape.y(inds(mm,1):inds(mm,2)), ...
                    [0 0 0], 'EdgeColor', 'k', 'FaceColor', color, 'LineWidth', 2);
                hold on
            end
        end
        cb = colorbar;
        colormap(cmap);
        set(cb, 'Ticks', [0, .33, .66, 1]);
        set(cb, 'TickLabels', {'0', '1e-3', '1e-2', '1e-1'});
        set(get(cb, 'YLabel'), 'String', 'Prevalence');
        set(gca, 'XTick', []);
        set(gca, 'YTick', []);
        axis equal;
        drawnow
        F(jj) = getframe;
    end
    v = VideoWriter(['movies3\movie_' num2str(ii) '.avi'], 'Uncompressed AVI');
    v.FrameRate = 1;
    open(v);
    writeVideo(v, F);
    close(v);
end


