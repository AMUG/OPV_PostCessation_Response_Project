function [] = constructDemographicsFile()

ShapeFile = '\kevmc\OPV_PostCessation_Response_Project\shapefiles\Africa.shp';
PopFile = '\kevmc\OPV_PostCessation_Response_Project\worldpop\africa2010ppp.tif';
ShapeFileLevel = 2;
BaseDemographicsFile = '.\base_demographics.json';
OutputDemographicsFile = '..\OPV_response_simulations\input\demographics\WestAfrica_ProvinceLevel_demographics.json';
CountryList = {':Senegal:', ':Mauritania:', ':Sierra Leone:', ':Guinea:', ':Liberia:', ...
    ':Ivory Coast:', ':Mali:', ':Burkina Faso:', ':Ghana:', ':Togo:', ':Benin:', ':Niger:', ...
    ':Nigeria:', ':Cameroon:', ':Chad:', ':Central African Republic:'};

%Get shapefile and cut down to provinces within the country list
shapes = shape_get(ShapeFile);
shapes = GetShapesAtLevel(shapes, ShapeFileLevel);
shapes = CutShapesByCountry(shapes, CountryList);

popMapStruct = process_imagefile(PopFile);
popTable = AggregateMapByShape(shapes, popMapStruct); 

AddNodesToDemographicsFile(BaseDemographicsFile, OutputDemographicsFile, popTable);

delete(strrep(OutputDemographicsFile, '.json', '.compiled.json'));
system(['compiledemog.py ' OutputDemographicsFile]);

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

function [outTable] = AggregateMapByShape(shapes, mapStruct)
    [latgrid, longgrid] = ndgrid(mapStruct.latitudes, mapStruct.longitudes);
    outTable = table(); 
    outTable.ID = [shapes.Attribute.hid_id]';
    outTable.dt_name = {shapes.Attribute.dt_name}';
    outTable.Population = zeros(height(outTable), 1);
    outTable.LatCentroid = zeros(height(outTable), 1);
    outTable.LngCentroid = zeros(height(outTable), 1);
    
    
    for ii = 1:length(shapes.Shape);
        
        if mod(ii, 10) == 0
            disp(['Extracting data for shape ' num2str(ii) ' of ' num2str(length(shapes.Shape))]);
        end
        thisShape = shapes.Shape(ii);
        
        %Special case handling - shapefile contains some polygons that are
        %too small to contain a pixel.
        if ~isempty(regexpi(outTable.dt_name{ii}, 'Chad:Batha$')) || ...
            ~isempty(regexpi(outTable.dt_name{ii}, 'Ivory Coast:BAFING$'))
            %There is a small polygon for Chad:Batha that is problematic - appears to be too tiny to encompass a pixel, so InPolygon returns all false.  
            ind = find(isnan(thisShape.x), 1, 'first')-1;
            thisShape.x = thisShape.x(1:ind);
            thisShape.y = thisShape.y(1:ind);
        elseif ~isempty(regexpi(outTable.dt_name{ii}, 'Chad:Guera$'))
            %Chad:Guera matches the odd indices in Chad:Batha.  An empty
            %node in the demographics file should be fine. Will delete by hand later.          
            continue;
        elseif ~isempty(regexpi(outTable.dt_name{ii}, 'BURKINA FASO:CENTRE$')) || ...
                ~isempty(regexpi(outTable.dt_name{ii}, 'Ivory Coast:N''ZI COMOT$')) || ...
                ~isempty(regexpi(outTable.dt_name{ii}, 'Ivory Coast:MONTAGNES$')) || ...
                ~isempty(regexpi(outTable.dt_name{ii}, 'CAMEROON:CENTRE$')) || ...
                ~isempty(regexpi(outTable.dt_name{ii}, 'MAURITANIA:GUIDIMAKA$'))
            ind = find(isnan(thisShape.x), 1, 'first')+1;
            thisShape.x = thisShape.x(ind:end);
            thisShape.y = thisShape.y(ind:end);            
        end
        
        inds = SplitVec(isnan(thisShape.x), 'equal', 'bracket'); %necessary for handling states that may be multiple disjoint polygons.  

        %Check the splitting here, make sure we get values and not nans in
        %below loop
        if isnan(thisShape.x(inds(1, 1)))
            inds = inds(2:end, :);
        end
        
        for jj = 1:2:size(inds, 1)
            shapeCut = InPolygon(longgrid, latgrid, thisShape.x(inds(jj,1):inds(jj,2)),thisShape.y(inds(jj,1):inds(jj,2)));
            
            thisPop = sum(mapStruct.image_data(shapeCut));
            thisLatCentroid = sum(latgrid(shapeCut).*mapStruct.image_data(shapeCut))/thisPop;
            thisLngCentroid = sum(longgrid(shapeCut).*mapStruct.image_data(shapeCut))/thisPop;

            %Simple check
            assert(thisPop + outTable.Population(ii)>0, ['Error: Shape for ' outTable.dt_name{ii} ' appears to have no population']);
 
            %properly weight the mean lat/long here in case of multiple disjoint polygons
            weightOld = outTable.Population(ii)/(thisPop + outTable.Population(ii));
            weightNew = 1-weightOld;
            
            outTable.LatCentroid(ii) = weightOld*outTable.LatCentroid(ii) + ...
                weightNew*thisLatCentroid;
            
            outTable.LngCentroid(ii) = weightOld*outTable.LngCentroid(ii) + ...
                weightNew*thisLngCentroid;
                        
            outTable.Population(ii) = outTable.Population(ii) + thisPop; 
        end
        assert(~any(isnan([outTable.LatCentroid(ii), outTable.LngCentroid(ii), outTable.Population(ii)])), ...
            ['Error: Shape for ' outTable.dt_name{ii} ' appears to have NaN pop or geographic centroid']);

    end
end

function [] = AddNodesToDemographicsFile(baseFile, outFile, popTable)
    removeset = [];
    baseDemog = loadJson(baseFile);

    baseDemog.Metadata.NodeCount = height(popTable);
 
    resolution = baseDemog.Metadata.Resolution/3600;
    nodeIDs = LatLong2NodeID(popTable.LngCentroid, popTable.LatCentroid, ...
        resolution);
    [newLongs, newLats] = NodeID2LatLong(nodeIDs, resolution);

    nodeset = cell(1, height(popTable));
    
    for ii = 1:height(popTable)
        if (popTable.Population(ii) == 0)
            baseDemog.Metadata.NodeCount = baseDemog.Metadata.NodeCount-1;
            removeset = [removeset ii];
            continue
        end
        nodeset{ii} = struct('AdminID', popTable.dt_name{ii}, ...
            'NodeID', nodeIDs(ii), ...
            'HierarchyID', popTable.ID(ii), ...
            'NodeAttributes', struct('Latitude', newLats(ii), ...
                                     'Longitude', newLongs(ii), ...
                                     'InitialPopulation', round(popTable.Population(ii))));
        
    end
    nodeset(removeset) = [];
    baseDemog.Nodes = nodeset;
    saveJson(outFile, baseDemog);

end



function [long, lat] = NodeID2LatLong(NodeId, res)

lat = double(mod(NodeId-1, 2^16))*res - 90;
long = double(floor((NodeId-1)/2^16))*res -180;

end


function [NodeId] = LatLong2NodeID(long, lat, res)

NodeId = uint64(floor((long+180)/res)*2^16) + uint64(floor((lat+90)/res) + 1);

while length(NodeId) ~= length(unique(NodeId))
    [~, ~, C] = unique(NodeId, 'stable');
    nonunique = find(C~=(1:length(C))', 1, 'first');
    NodeId(nonunique) = find_nearest_unoccupied_node(NodeId(nonunique), NodeId);    
end

end

function [newNodeId] = find_nearest_unoccupied_node(oldNodeId, NodeIdList)
newNodeId = oldNodeId;
shiftlen = 0;
%Try moving it up/down/left/right by 1, and diagonal, if it doesn't work,
%try by 2, etc.
while newNodeId == oldNodeId
    shiftlen = shiftlen+1;
    for xshift = -shiftlen:shiftlen
        for yshift = -shiftlen:shiftlen
            testNodeId = oldNodeId + xshift*2^16 + yshift;
            if ~ismember(testNodeId, NodeIdList)
                newNodeId = testNodeId;
            end
        end
    end
end
end