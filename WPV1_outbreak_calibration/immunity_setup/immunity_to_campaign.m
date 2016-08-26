function [] = immunity_to_campaign()

immtable = readtable('Immunity_Type1_smoothed.csv');
demog = loadJson('..\input\demographics\WestAfrica_ProvinceLevel_demographics.json');
base_campaign = loadJson('..\Configs_DTK\campaign_base.json');

nodeIDs = cellfun(@(x) x.NodeID, demog.Nodes);
HIDs = cellfun(@(x) x.HierarchyID, demog.Nodes);
outbreak_event = base_campaign.Events{2};
new_campaign = base_campaign;

%immtable begins Jan-1-2003.  Want to start sims Jan-1-2008
for currPeriod = 1:6
    cov_by_node = cell(1, length(nodeIDs));
    cov_by_node_event = base_campaign.Events{1};
    for currNode = 1:length(nodeIDs)
        cov_by_node{currNode} = cell(1, 2);
        cov_by_node{currNode}{1} = nodeIDs(currNode);
        thisHID = HIDs(currNode);
        if currPeriod == 1
            coverage = max(0, min(1, 1.05*immtable.SmoothedImmunity2(immtable.L2IDs == thisHID & immtable.TimeIndex == (currPeriod+10)))); 
            %1.05 makes it so that this is the average immunity over the time period, not the instantaneous one at the beginning of it
        else  
            %Find the coverage that will change current immunity to the new
            %expected immunity
            currImm = max(0, min(1,.95*immtable.SmoothedImmunity2(immtable.L2IDs == thisHID & immtable.TimeIndex == (currPeriod+9)))); %On average, about 10% of children have passed out of the cohort in 6 months and been replaced by susceptibles
            newImm = max(0, min(1, 1.05*immtable.SmoothedImmunity2(immtable.L2IDs == thisHID & immtable.TimeIndex == (currPeriod+10))));
            if newImm < currImm,
                coverage = 0;
            else
                coverage = (newImm - currImm)/(1-currImm); %Coverage necessary to bring currImm to newImm -> newImm = currImm + (1-currImm)*coverage;
            end
        end
        cov_by_node{currNode}{2} = coverage;
    end
    cov_by_node_event.Event_Coordinator_Config.Coverage_By_Node = cov_by_node;
    cov_by_node_event.Start_Day = 1 + round(182.5 * (currPeriod-1));
    new_campaign.Events{currPeriod} = cov_by_node_event;
end
new_campaign.Events{length(new_campaign.Events)+1} = outbreak_event;

saveJson('..\Configs_DTK\campaign.json', new_campaign);

end