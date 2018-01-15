function [out] = get_migration_median(type)

local = textread(['..\OPV_response_simulations\input\migration\WestAfrica_Provincelevel_' type '_local_migration.txt']);
regional = textread(['..\OPV_response_simulations\input\migration\WestAfrica_Provincelevel_' type '_regional_migration.txt']);
combined = [local; regional];

demog = loadJson('..\OPV_response_simulations\input\demographics\WestAfrica_ProvinceLevel_demographics.json');
nodeids = cellfun(@(x) x.NodeID, demog.Nodes);
pops = cellfun(@(x) x.NodeAttributes.InitialPopulation, demog.Nodes);

[~, ~, fromind] = unique(combined(:, 1));
totmig = accumarray(fromind, combined(:, 3), [], @sum);

[~, ind] = sort(nodeids);
pops = pops(ind)';

[TMsort, ind] = sort(totmig);
Psort = pops(ind);

[~, ind] = min(abs(cumsum(Psort)/sum(Psort) - 0.5));

out = TMsort(ind);

end