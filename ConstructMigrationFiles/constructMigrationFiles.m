function [  ] = constructMigrationFiles( )

demographicsFile = '..\OPV_response_simulations\input\demographics\WestAfrica_ProvinceLevel_demographics.json';
outputDir = '..\OPV_response_simulations\input\migration\';
maxLocalConnections = 8;
maxRegionalConnections = 30;
earthRadius = 6367; %km

demog = loadJson(demographicsFile);

%Pull the info from demo file
N_Nodes = length(demog.Nodes);
lat = cellfun(@(x) x.NodeAttributes.Latitude, demog.Nodes);
long = cellfun(@(x) x.NodeAttributes.Longitude, demog.Nodes);
nodeids = cellfun(@(x) x.NodeID, demog.Nodes);
pops = cellfun(@(x) x.NodeAttributes.InitialPopulation, demog.Nodes);

distance_matrix = 2*earthRadius*squareform(pdist([long' lat'], @haversine));

%Start with matrix of ones
migration_rates = ones(N_Nodes);

%divide by distance or distance^2, multiply by pop.  
migration_rates = migration_rates.* (repmat(pops, [N_Nodes, 1]));  %Could impose a max/min range on the population as well, so that rates don't blow up for extremely high populations;

%Going to end up with four migration files total - local and regional, and linear vs quadratic in distance - split them up here.
migration_rates_local_linear = migration_rates./ ((distance_matrix + 1));  %+1 "flattens" the cusp at very small distances.  Should become a parameter "distance_min";
migration_rates_local_quad = migration_rates./ ((distance_matrix + 1).^2);  %+1 "flattens" the cusp at very small distances.  Should become a parameter "distance_min";
migration_rates_regional_linear = migration_rates_local_linear;
migration_rates_regional_quad = migration_rates_local_quad;


%For local migration, zero out all rates beyond the 8 closest nodes
%For regional, zero out the 8 local nodes to avoid double counting.
%always zero out the self-connection
%Should probably do size-checking here, but I know my demographics file has
%a lot of nodes.
for ii = 1:N_Nodes
    [~, inds] = sort(distance_matrix(ii, :), 'ascend');
    migration_rates_local_linear(ii, inds([1 (maxLocalConnections+2):end])) = 0;  %ind 1 will always be zero, self-migration is not allowed;
    migration_rates_local_quad(ii, inds([1 (maxLocalConnections+2):end])) = 0;  %ind 1 will always be zero, self-migration is not allowed;
    migration_rates_regional_linear(ii, inds(1:(maxLocalConnections+1))) = 0;
    migration_rates_regional_quad(ii, inds(1:(maxLocalConnections+1))) = 0;
end


%For regional migration, zero out everything but the top
%maxRegionalConnections rates.
for ii = 1:N_Nodes
    [~, inds] = sort(migration_rates_regional_linear(ii,:), 'descend');
    migration_rates_regional_linear(ii, inds((maxRegionalConnections+1):N_Nodes)) = 0;
    
    [~, inds] = sort(migration_rates_regional_quad(ii,:), 'descend');
    migration_rates_regional_quad(ii, inds((maxRegionalConnections+1):N_Nodes)) = 0;
end


%Write the migration files
writeMigrationFiles(migration_rates_local_linear, nodeids, outputDir, 'WestAfrica_Provincelevel_linear_local_migration.txt', ...
    demographicsFile, 'local');
writeMigrationFiles(migration_rates_local_quad, nodeids, outputDir, 'WestAfrica_Provincelevel_quad_local_migration.txt', ...
    demographicsFile, 'local');
writeMigrationFiles(migration_rates_regional_linear, nodeids, outputDir, 'WestAfrica_Provincelevel_linear_regional_migration.txt', ...
    demographicsFile, 'regional');
writeMigrationFiles(migration_rates_regional_quad, nodeids, outputDir, 'WestAfrica_Provincelevel_quad_regional_migration.txt', ...
    demographicsFile, 'regional');


end

function [] = writeMigrationFiles(rateMatrix, nodeIDs, outputDir, outputFile, demographicsFile, type)


%Write the csv
text2write = '';
for ii = 1:size(rateMatrix, 1)
    for jj = 1:size(rateMatrix, 2);
        if rateMatrix(ii,jj) ~= 0
           text2write = [text2write num2str(nodeIDs(ii)) ' ' num2str(nodeIDs(jj)) ' ' num2str(rateMatrix(ii,jj), '%0.10f') ' ' sprintf('\n')]; 
        end
    end
end

fid = fopen(fullfile(outputDir, outputFile), 'w');
fprintf(fid, text2write);
fclose(fid);


%Call python to compile migration files
[status, msg] = system(['.\createmigrationheader.py ' ...
     regexprep(demographicsFile, '.json$', '.compiled.json') ' ' type]);
assert(status==0, ['writeMigrationFiles:generate_migration_header, Error generating migration header from demo file: ' msg]);

movefile(strrep(demographicsFile, '_demographics.json', ['_' type '_migration.bin.json']), ...
    fullfile(outputDir, strrep(outputFile, '.txt', '.bin.json'))) 
%movefile('.\Africa_Province_local_migration.bin.json', ...
%    '.\Africa_Province_local_migration.bin.json');

%compile migration file to binary
nameInds = regexp(outputFile, '_');

[status, msg] = system(['.\convert_txt_to_bin.py ' fullfile(outputDir, outputFile) ' ' fullfile(outputDir, outputFile(1:(nameInds(3)-1))) ' ' type]);
assert(status==0, ['writeMigrationFiles:compilemig, Error compiling migration file: ' msg]);

end

function distances = haversine(start_point, end_points)
    %start_point is 1x2 vector of long, lat
    %end_point is nx2 vector of long, lat
    %distances is nx1 vector of haversine distances (not normalized to
    %radius). 
    %Note that sind/cosd are used, as lat/long are generally reported
    %in degrees rather than radians.  asin is used however, as the returned
    %arc length should be in radians for proper conversion to distance.
    delta_lat = end_points(:, 2) - start_point(1, 2);
    delta_long = end_points(:, 1) - start_point(1, 1);
    
    distances = abs( asin( sqrt( sind(delta_lat/2).^2 + cosd(start_point(1, 2)) .* cosd(end_points(:, 2)) .* sind(delta_long/2).^2 ) ) ); 


end