function [] = map_figure()
output_base = 'AMUG_DataRepos\OPV_PostCessation_Response_Project\OPV_response_WestAfrica_simulations\';
load([output_base '\compiled_separatrices.mat']);
ShapeFile = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\shapefiles\Africa.shp';
PopFile = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\worldpop\africa2010ppp.tif';
ShapeFileLevel = 2;
CountryList = {':Senegal:', ':Mauritania:', ':Sierra Leone:', ':Guinea:', ':Liberia:', ...
    ':Ivory Coast:', ':Mali:', ':Burkina Faso:', ':Ghana:', ':Togo:', ':Benin:', ':Niger:', ...
    ':Nigeria:', ':Cameroon:', ':Chad:', ':Central African Republic:'};

shapes = shape_get(ShapeFile);
shapes = GetShapesAtLevel(shapes, ShapeFileLevel);
shapes = CutShapesByCountry(shapes, CountryList);

popMapStruct = process_imagefile(PopFile);

myfigure_square;
imagesc(popMapStruct.longitudes, popMapStruct.latitudes, log10(popMapStruct.image_data*4));
set(gca, 'YDir', 'normal');

for ii = 1:length(shapes.Shape)
    thisShape = shapes.Shape(ii);%unique(IDs.distID(IDs.DistInd == ii));
    
    inds = SplitVec(isnan(thisShape.x), 'equal', 'bracket');
    for jj = 1:2:size(inds, 1)
        
        patch(thisShape.x(inds(jj,1):inds(jj,2)), ...
            thisShape.y(inds(jj,1):inds(jj,2)), ...
            [0 0 0], 'EdgeColor', 'k', 'FaceColor', 'none', 'LineWidth', 1);
    end
end
shapes = shape_get(ShapeFile);
shapes = GetShapesAtLevel(shapes, ShapeFileLevel-1);
shapes = CutShapesByCountry(shapes, regexprep(CountryList, ':$', '$'));
for ii = 1:length(shapes.Shape)
    thisShape = shapes.Shape(ii);%unique(IDs.distID(IDs.DistInd == ii));
    
    inds = SplitVec(isnan(thisShape.x), 'equal', 'bracket');
    for jj = 1:2:size(inds, 1)
        
        patch(thisShape.x(inds(jj,1):inds(jj,2)), ...
            thisShape.y(inds(jj,1):inds(jj,2)), ...
            [0 0 0], 'EdgeColor', 'k', 'FaceColor', 'none', 'LineWidth', 3);
    end
end
axis equal
xlim([-18, 28]);
ylim([0, 30]);
caxis([-1, 3]);
colormap(flipud(cbrewer('div', 'RdYlBu', 256)))
cb = colorbar;
set(get(cb, 'YLabel'), 'string', 'Log_{10}(Population per arcmin^2)');
xlabel('Longitude');
ylabel('Latitude');
myprint('-dpng', 'figures\region_map.png');
myprint('-dtiff', 'figures\region_map.tiff');

end



function [shapes] = GetShapesAtLevel(shapes, level)
    cc = cellfun(@(x) length(regexp(x, ':'))==level, {shapes.Attribute.dt_name});
    shapes.Attribute = shapes.Attribute(cc);
    shapes.Shape = shapes.Shape(cc);
end

function [mapstruct] = process_imagefile(geofile)
    image_data = imread(geofile);
    Tinfo        = imfinfo(geofile);
    mapstruct.image_data = flipud(image_data);
    mapstruct.dx = Tinfo.ModelPixelScaleTag(1);
    mapstruct.dy = Tinfo.ModelPixelScaleTag(2);
    x0 = Tinfo.ModelTiepointTag(4);
    y0 = Tinfo.ModelTiepointTag(5);
    mapstruct.image_data(mapstruct.image_data<0) = 0;

    width = Tinfo.Width;
    height = Tinfo.Height;

    mapstruct.latitudes = linspace( y0 - mapstruct.dy*(height-1), y0, height);
    mapstruct.longitudes = linspace(x0, x0 + mapstruct.dx*(width-1), width);
end


function [shapes] = CutShapesByCountry(shapes, CountryList)

for ii = 1:length(shapes.Attribute)
    shapes.Attribute(ii).dt_name = strrep(shapes.Attribute(ii).dt_name, 'CÔTE D''IVOIRE', 'Ivory Coast');
end
dt_namelist = {shapes.Attribute.dt_name};

countrylistcut = false(size(dt_namelist));

for ii = 1:length(CountryList)
   countrylistcut = countrylistcut | ~cellfun(@isempty, regexpi(dt_namelist, CountryList{ii})); 
end

shapes.Attribute = shapes.Attribute(countrylistcut);
shapes.Shape = shapes.Shape(countrylistcut);
end