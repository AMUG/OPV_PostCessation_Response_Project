function [] = accumulate_spatial_output(obj, parser)
if nargin == 1
parser = obj.parser;
end
demog = loadJson(obj.demog_file);

NodeIDs = cellfun(@(x) x.NodeID, demog.Nodes);
AdminID = cellfun(@(x) x.AdminID, demog.Nodes, 'UniformOutput', false);


new_infs = cell2mat(cellfun(@(x) permute(x{1}, [3, 1, 2]), parser.spatialOutput.channelTimeSeries, 'UniformOutput', false));
pops = cell2mat(cellfun(@(x) permute(x{2}, [3, 1, 2]), parser.spatialOutput.channelTimeSeries, 'UniformOutput', false));
prevs = cell2mat(cellfun(@(x) permute(x{3}, [3, 1, 2]), parser.spatialOutput.channelTimeSeries, 'UniformOutput', false));

obj.spatial_outputs.accum_new_infs = zeros(size(new_infs, 1), length(obj.countries), size(new_infs, 3));
obj.spatial_outputs.accum_pops = zeros(size(new_infs, 1), length(obj.countries), size(new_infs, 3));
obj.spatial_outputs.accum_prevs = zeros(size(new_infs, 1), length(obj.countries), size(new_infs, 3));

for ii = 1:length(obj.countries);
    cc = ~cellfun(@isempty, strfind(lower(AdminID), [':' lower(obj.countries{ii}) ':']));
    theseIDs = NodeIDs(cc);
    cc2 = ismember(parser.spatialOutput.nodeIDList{1}{1}, theseIDs);
    
    obj.spatial_outputs.accum_new_infs(:, ii, :) = sum(new_infs(:, cc2, :), 2);
    obj.spatial_outputs.accum_pops(:, ii, :) = sum(pops(:, cc2, :), 2);
    obj.spatial_outputs.accum_prevs(:, ii, :) = sum(prevs(:, cc2, :), 2);
    
end
%Each of these outputs is #sims x #countries x #months
end