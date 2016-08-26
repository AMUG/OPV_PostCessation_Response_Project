function [Exp] = metaparameterHandler(remain, ValueTable, TestPoints, Exp, json_paths, i, j)
if( ~isempty(regexp( remain, 'Base_Incubation_Period', 'ONCE') ) )	%Must be round number
    BIP = round(ValueTable{j}{TestPoints(i,j)});
    Exp.config.parameters.Base_Incubation_Period = BIP;
    addTag(Exp.simTags, json_paths{j},BIP);
    clear BIP
elseif( ~isempty(regexp( remain, 'Sinusoidal_Forcing_Phase', 'ONCE') ) )	%Must be round number
    SFP = mod(ValueTable{j}{TestPoints(i,j)}, 365);
    Exp.config.parameters.Infectivity_Sinusoidal_Forcing_Phase = SFP;
    addTag(Exp.simTags, json_paths{j},SFP);
    clear SFP
    
elseif( ~isempty(regexp( remain, 'Base_Infectious_Period', 'ONCE') ) )	%Must be round number
    BIP = round(ValueTable{j}{TestPoints(i,j)});
    Exp.config.parameters.Base_Infectious_Period = BIP;
    addTag(Exp.simTags, json_paths{j},BIP);
    clear BIP
    
elseif( ~isempty(regexp( remain, 'Structured_Campaign_Demographic_Coverage', 'ONCE')))
    cov_val = ValueTable{j}{TestPoints(i,j)};
    %                    Exp.campaign.Events{2}.Event_Coordinator_Config.Demographic_Coverage = cov_val;
    %                    Exp.campaign.Events{3}.Event_Coordinator_Config.Demographic_Coverage = cov_val;
    addTag(Exp.simTags, json_paths{j},cov_val);
    clear cov_val
    
elseif( ~isempty(regexp( remain, 'R0_and_susceptibility_scaling', 'ONCE')))
    R0 = ValueTable{j}{TestPoints(i,j)};
    BI = R0/Exp.config.parameters.Base_Infectious_Period;
    Exp.config.parameters.Base_Infectivity = BI;
    
    A = [0.663460258142446  -0.158922999834951   0.104560553523265  -0.029203911168736    0.003205131777094  -0.000121557938681];
    SSR = polyval(fliplr(A), R0);
    Exp.config.parameters.Susceptibility_Scaling_Rate = SSR;
    addTag(Exp.simTags, 'Base_Infectivity',BI);
    addTag(Exp.simTags, 'Susceptibility_Scaling_Rate',SSR);
    
    clear R0 BI A SSR
elseif( ~isempty(regexp( remain, 'R0', 'ONCE')))
    R0 = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.Base_Infectivity = R0/Exp.config.parameters.Base_Infectious_Period;
    
    addTag(Exp.simTags, json_paths{j},R0);
    clear R0
    
elseif( ~isempty(regexp( remain, 'Target_Age_Min_All', 'ONCE')))
    Agemin = ValueTable{j}{TestPoints(i,j)};
    for ii = 1:length(Exp.campaign.Events)
        if isfield(Exp.campaign.Events{ii}.Event_Coordinator_Config, 'Target_Age_Min')
            Exp.campaign.Events{ii}.Event_Coordinator_Config.Target_Age_Min = Agemin;
        end
    end
    
    addTag(Exp.simTags, 'Target_Age_Min_All',Agemin);
    clear Agemin
    
elseif( ~isempty(regexp( remain, 'OPV_IPV_response_coverage_setter', 'ONCE')))
    Cov = ValueTable{j}{TestPoints(i,j)};
    for ii = 1:length(Exp.campaign.Events)
        if ~isempty(regexp(Exp.campaign.Events{ii}.Event_Coordinator_Config.Event_Name, 'OPV', 'ONCE'))
            Exp.campaign.Events{ii}.Event_Coordinator_Config.Demographic_Coverage = Cov/2;
        end
        if ~isempty(regexp(Exp.campaign.Events{ii}.Event_Coordinator_Config.Event_Name, 'IPV', 'ONCE'))
            Exp.campaign.Events{ii}.Event_Coordinator_Config.Demographic_Coverage = Cov;
        end
    end
    
    addTag(Exp.simTags, 'Response_Coverage',Cov);
    clear Cov
    
elseif( ~isempty(regexp( remain, 'OPV_only_response_coverage_setter', 'ONCE')))
    Cov = ValueTable{j}{TestPoints(i,j)};
    for ii = 1:length(Exp.campaign.Events)
        if ~isempty(regexp(Exp.campaign.Events{ii}.Event_Coordinator_Config.Event_Name, 'OPV', 'ONCE'))
            Exp.campaign.Events{ii}.Event_Coordinator_Config.Demographic_Coverage = Cov/2;
        end
        if ~isempty(regexp(Exp.campaign.Events{ii}.Event_Coordinator_Config.Event_Name, 'IPV', 'ONCE'))
            Exp.campaign.Events{ii}.Event_Coordinator_Config.Demographic_Coverage = 0;
        end
    end
    
    addTag(Exp.simTags, 'OPV_only_Response_Coverage',Cov);
    clear Cov
    
elseif( ~isempty(regexp( remain, 'BI_and_susceptibility_scaling_and_campaign', 'ONCE')))
    BI = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.Base_Infectivity = BI;
    A = [2.0366   -4.3507    4.1062   -1.3796];
    SSR = polyval(fliplr(A), BI);
    Exp.config.parameters.Susceptibility_Scaling_Rate = SSR;
    
    B= [-0.6583    4.3032   -5.7392    2.4545];
    CE1 = polyval(fliplr(B), BI);
    if CE1 < 0
        CE1 = 0;
    end
    %for curr_event = 2:length(campaign.Events)
    %    Exp.campaign.Events{curr_event}.Event_Coordinator_Config.Demographic_Coverage	= CE1*Exp.campaign.Events{curr_event}.Event_Coordinator_Config.Demographic_Coverage;
    %end
    Exp.campaign.Events{2}.Event_Coordinator_Config.Distribution_Coverages = cellfun(@(x) CE1*x, Exp.campaign.Events{2}.Event_Coordinator_Config.Distribution_Coverages, 'UniformOutput', false);
    %                     if length(Exp.campaign.Events) == 3
    %                         Exp.campaign.Events{3}.Event_Coordinator_Config.Demographic_Coverage = CE1* Exp.campaign.Events{3}.Event_Coordinator_Config.Demographic_Coverage;
    %                     end
    addTag(Exp.simTags, 'META_Base_Infectivity',BI);
    addTag(Exp.simTags, 'META_Susceptibility_Scaling_Rate',SSR);
    addTag(Exp.simTags, 'META_Campaign_Efficacy', CE1);
    
elseif( strcmpi( remain, 'Dual_Migration'))
    Mig_Rate = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.x_Local_Migration = Mig_Rate;
    Exp.config.parameters.x_Regional_Migration = Mig_Rate;
    %                     check_campaign = cellfun(@(x) strcmpi(x.Event_Coordinator_Config.Intervention_Config.class, 'ImportPressure'), Exp.campaign.Events);
    %                     if any(check_campaign);
    %                         Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Intervention_Config.Daily_Import_Pressures = cellfun(@(x) Mig_Rate*x, Exp.campaign.Events{4}.Event_Coordinator_Config.Intervention_Config.Daily_Import_Pressures, 'UniformOutput', false);
    %                     end
    addTag(Exp.simTags, 'x_Local_Migration',Mig_Rate);
    addTag(Exp.simTags, 'x_Regional_Migration',Mig_Rate);
    
    clear Mig_Rate
    
elseif( strcmpi( remain, 'Dual_Migration_Log'))
    Mig_Rate = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.x_Local_Migration = 10^Mig_Rate;
    Exp.config.parameters.x_Regional_Migration = 10^Mig_Rate;
    %                     check_campaign = cellfun(@(x) strcmpi(x.Event_Coordinator_Config.Intervention_Config.class, 'ImportPressure'), Exp.campaign.Events);
    %                     if any(check_campaign);
    %                         Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Intervention_Config.Daily_Import_Pressures = cellfun(@(x) Mig_Rate*x, Exp.campaign.Events{4}.Event_Coordinator_Config.Intervention_Config.Daily_Import_Pressures, 'UniformOutput', false);
    %                     end
    addTag(Exp.simTags, 'x_Local_Migration',Mig_Rate);
    addTag(Exp.simTags, 'x_Regional_Migration',Mig_Rate);
    
    clear Mig_Rate
    
elseif(~isempty(regexp(remain, 'Import_Pressure_Scaling', 'ONCE')))
    import_rate = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Coordinator_Config.Intervention_Config.class, 'ImportPressure'), Exp.campaign.Events);
    if any(check_campaign);
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Intervention_Config.Daily_Import_Pressures = cellfun(@(x) import_rate*x, Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Intervention_Config.Daily_Import_Pressures, 'UniformOutput', false);
    end
    addTag(Exp.simTags, 'Import_Pressure_Scaling', import_rate);
    clear import_rate
elseif( ~isempty(regexp( remain, 'RI_Coverage', 'ONCE')))
    
    RI_Rate = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'RI Vaccination'), Exp.campaign.Events);
    if any(check_campaign);
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Intervention_Config.Demographic_Coverage = RI_Rate;
    end
    addTag(Exp.simTags, 'Routine Immunization Rate', RI_Rate);
    clear RI_Rate
    
elseif ( ~isempty(regexp( remain, 'Coverage_Increase_Rate_post2010', 'ONCE')))
    
    CI_Rate = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    if any(check_campaign);
        Dates = cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Times);
        %5475 = 01/01/2000.  Start Coverage ramp-up at
        %01/01/2009
        Dates = Dates - 5475 - 10*365;
        CI_Rate_vector = 1 + Dates * CI_Rate/365;
        CI_Rate_vector(CI_Rate_vector < 1) = 1;
        new_coverages = CI_Rate_vector.*cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages);
        new_coverages(new_coverages>1) = 1;
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages = num2cell(new_coverages);
    end
    addTag(Exp.simTags, 'SIA_Coverage_Increase_Rate_post2010', CI_Rate);
    clear CI_Rate Dates CI_Rate_vector new_coverages
elseif ( ~isempty(regexp( remain, 'Coverage_Increase_Rate_post2006', 'ONCE')))
    
    CI_Rate = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    if any(check_campaign);
        Dates = cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Times);
        %5475 = 01/01/2000.  Start Coverage ramp-up at
        %01/01/2009
        Dates = Dates - 5475 - 6*365;
        CI_Rate_vector = 1 + Dates * CI_Rate/365;
        CI_Rate_vector(CI_Rate_vector < 1) = 1;
        new_coverages = CI_Rate_vector.*cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages);
        new_coverages(new_coverages>1) = 1;
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages = num2cell(new_coverages);
    end
    addTag(Exp.simTags, 'SIA_Coverage_Increase_Rate_post2006', CI_Rate);
    clear CI_Rate Dates CI_Rate_vector new_coverages
    
    
elseif ( ~isempty(regexp( remain, 'Coverage_Increase_Rate', 'ONCE')))
    
    CI_Rate = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    if any(check_campaign);
        Dates = cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Times);
        %5475 = 01/01/2000.  Start Coverage ramp-up at
        %01/01/2009
        Dates = Dates - 5475 - 8*365;
        CI_Rate_vector = 1 + Dates * CI_Rate/365;
        CI_Rate_vector(CI_Rate_vector < 1) = 1;
        new_coverages = CI_Rate_vector.*cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages);
        new_coverages(new_coverages>1) = 1;
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages = num2cell(new_coverages);
    end
    addTag(Exp.simTags, 'SIA_Coverage_Increase_Rate_post2008', CI_Rate);
    clear CI_Rate Dates CI_Rate_vector new_coverages
    
    
    
elseif ( ~isempty(regexp( remain, 'Coverage_Bump_Post2008', 'ONCE')))
    CI_Increase = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    if any(check_campaign);
        Dates = cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Times);
        %5475 = 01/01/2000.  Start Coverage ramp-up at
        %01/01/2009
        Dates = Dates - 5475 - 8*365;
        CI_Increase_vector = ones(size(Dates));
        CI_Increase_vector(Dates > 1) = 1 + CI_Increase;
        new_coverages = CI_Increase_vector.*cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages);
        new_coverages(new_coverages>1) = 1;
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages = num2cell(new_coverages);
    end
    addTag(Exp.simTags, 'Coverage_Bump_post2008', CI_Increase);
    clear CI_Increase Dates CI_Increase_vector new_coverages
    
elseif ( ~isempty(regexp( remain, 'Coverage_Increase_Post2010', 'ONCE')))
    CI_Increase = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    if any(check_campaign);
        Dates = cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Times);
        %5475 = 01/01/2000.  Start Coverage ramp-up at
        %01/01/2009
        Dates = Dates - 5475 - 10*365;
        CI_Increase_vector = ones(size(Dates));
        CI_Increase_vector(Dates > 1) = 1 + CI_Increase;
        new_coverages = CI_Increase_vector.*cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages);
        new_coverages(new_coverages>1) = 1;
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages = num2cell(new_coverages);
    end
    addTag(Exp.simTags, 'SIA_Coverage_Bump_post2010', CI_Increase);
    clear CI_Increase Dates CI_Increase_vector new_coverages
    
elseif ( ~isempty(regexp( remain, 'Coverage_Increase_StartYear', 'ONCE')))
    CI_Start_Year = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    if any(check_campaign);
        Dates = cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Times);
        Dates = Dates - 5475 - CI_Start_Year*365;
    end
    addTag(Exp.simTags, 'SIA_Coverage_Increase_Start_Year', CI_Start_Year);
    clear CI_Start_Year check_campaign
    
    
elseif ( ~isempty(regexp( remain, 'Coverage_Slope', 'ONCE')))
    CI_Rate = ValueTable{j}{TestPoints(i,j)};
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    assert(exist('Dates', 'var'), 'Error in metaparameterHandler: If using Coverage_Slope, Coverage_Increase_Start_Year must appear first in list of sweep/calib variables');
    if any(check_campaign);
        CI_Rate_vector = 1 + Dates * CI_Rate/365;
        CI_Rate_vector(CI_Rate_vector < 1) = 1;
        new_coverages = CI_Rate_vector.*cell2mat(Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages);
        new_coverages(new_coverages>1) = 1;
        Exp.campaign.Events{check_campaign}.Event_Coordinator_Config.Distribution_Coverages = num2cell(new_coverages);
    end
    addTag(Exp.simTags, 'SIA_Coverage_Slope', CI_Rate);
    clear CI_Rate Dates CI_Rate_vector new_coverages
    
    
elseif( ~isempty(regexp( remain, 'BI_and_susceptibility_scaling', 'ONCE')))
    BI = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.Base_Infectivity = BI;
    A = [2.0366   -4.3507    4.1062   -1.3796];
    SSR = polyval(fliplr(A), BI);
    Exp.config.parameters.Susceptibility_Scaling_Rate = SSR;
    addTag(Exp.simTags, 'Base_Infectivity',BI);
    addTag(Exp.simTags, 'Susceptibility_Scaling_Rate',SSR);
    
elseif ( ~isempty(regexp( remain, 'Demographic_Cov_Outbreak_Response', 'ONCE')))
    this_cov = ValueTable{j}{TestPoints(i,j)};
    Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage = this_cov;
    Exp.campaign.Events{5}.Event_Coordinator_Config.Demographic_Coverage = this_cov;
    Exp.campaign.Events{6}.Event_Coordinator_Config.Demographic_Coverage = this_cov;
    addTag(Exp.simTags, 'Response_Coverage',this_cov);
    
    
    clear this_cov
    
elseif ( ~isempty(regexp( remain, 'Local_Or_Regional_Response', 'ONCE')))
    if (ValueTable{j}{TestPoints(i,j)} < 0.5);
        Exp.campaign.Events{7}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{8}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{9}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{10}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{11}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{12}.Event_Coordinator_Config.Demographic_Coverage = 0;
    elseif (inrange(ValueTable{j}{TestPoints(i,j)}, 0.5, 1.5))
        Exp.campaign.Events{7}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{8}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{9}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{10}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{11}.Event_Coordinator_Config.Demographic_Coverage = 0;
        Exp.campaign.Events{12}.Event_Coordinator_Config.Demographic_Coverage = 0;
    else
        Exp.campaign.Events{7}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{8}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{9}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{10}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{11}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
        Exp.campaign.Events{12}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{4}.Event_Coordinator_Config.Demographic_Coverage;
    end
    addTag(Exp.simTags, 'Local_Or_Regional_Response',ValueTable{j}{TestPoints(i,j)});
    
    
    
    
elseif( ~isempty(regexp( remain, 'LGA_Coverage_StdDev', 'ONCE')));
    StdDev = ValueTable{j}{TestPoints(i, j)};
    LGAs = cellfun(@(x) x.LGA_name, Curr_Demog_File.Nodes, 'UniformOutput', false);
    NodeIDs = cellfun(@(x) x.NodeID, Curr_Demog_File.Nodes);
    
    unique_LGAs = unique(LGAs);
    %Alex has produced immunity estimates over 2004-2014,
    %I've ranked them by LGA, and the variance in coverage
    %is assumed to be ranked in the same way.
    
    sorted_LGA_inds = [33, 17,  8, 22, 36, 35,  6, 12, 23, 37,  4,  9, 32, 42, 40, 14, 29,  5, 19, 27, 34, 10, 24, 25,  2, 13, 41, 28,  3,  1,  7, 38, 39, 21, 31, 30, 18, 15, 20, 44, 43, 16, 26, 11];
    myrands = randn(length(unique_LGAs), 1);
    %Bound the random number; prevent 0 coverage anywhere
    myrands(myrands<(-.9/StdDev)) = -.9/StdDev;
    myrands(myrands>(.9/StdDev)) = .9/StdDev;
    myrands = sort(myrands);
    myrands(sorted_LGA_inds) = myrands;
    newCovs = 1+StdDev*myrands;
    
    check_campaign = cellfun(@(x) strcmpi(x.Event_Name, 'SIA Calendar'), Exp.campaign.Events);
    
    if any(check_campaign);
        base_event = Exp.campaign.Events{check_campaign};
        Exp.campaign.Events(check_campaign) = [];
        for currLGA = 1:length(unique_LGAs)
            LGA_event = base_event;
            LGA_event.Event_Name = [LGA_event.Event_Name ' ' unique_LGAs{currLGA}];
            nodeset = NodeIDs(strcmp(LGAs, unique_LGAs{currLGA}));
            
            LGACovs = cell2mat(LGA_event.Event_Coordinator_Config.Distribution_Coverages)*newCovs(currLGA);
            LGACovs(LGACovs<0) = 0;
            LGACovs(LGACovs>1) = 1;
            LGA_event.Event_Coordinator_Config.Distribution_Coverages = num2cell(LGACovs);
            
            LGA_event.Nodeset_Config.class = 'NodeSetNodeList';
            LGA_event.Nodeset_Config.Node_List = num2cell(nodeset);
            
            Exp.campaign.Events{length(Exp.campaign.Events)+1} = LGA_event;
            
            
        end
    end
    
    addTag(Exp.simTags, 'LGA Campaign Heterogeneity',StdDev);
    
    clear LGA_event base_event nodeset LGACovs check_campaign newCovs unique_LGAs NodeIDs LGAs StdDev myrands sorted_LGA_inds
    
    
elseif( ~isempty(regexp( remain, 'Structured_Campaign_Group_Coverage', 'ONCE')))
    n_groups = ValueTable{j}{TestPoints(i,j)};
    first_event = Exp.campaign.Events{2};
    %                    second_event = Exp.campaign.Events{3};
    for new_event = 1:n_groups
        Exp.campaign.Events{new_event + 1} = first_event;
        Exp.campaign.Events{new_event + 1}.Event_Coordinator_Config.Property_Restrictions = {['Geographic:' num2str(ceil(new_event))]};
        Exp.campaign.Events{n_groups + new_event + 1} = second_event;
        Exp.campaign.Events{n_groups + new_event + 1}.Event_Coordinator_Config.Property_Restrictions = {['Geographic:' num2str(ceil(new_event+n_groups))]};
    end
    addTag(Exp.simTags, json_paths{j},n_groups);
    clear n_groups
elseif( ~isempty(regexp( remain, 'Vaccine_Titer_mOPV', 'ONCE') ) )
    titerval = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.Vaccine_Titer_mOPV1 = titerval;
    Exp.config.parameters.Vaccine_Titer_mOPV2 = titerval;
    Exp.config.parameters.Vaccine_Titer_mOPV3 = titerval;
    addTag(Exp.simTags, regexprep(json_paths{j}, '\.', '_'), ValueTable{j}{TestPoints(i,j)});
    
elseif( ~isempty(regexp( remain, 'Paralysis_Base_Rate', 'ONCE') ) )
    val = ValueTable{j}{TestPoints(i,j)};
    Exp.config.parameters.Paralysis_Base_Rate_Sabin1 = val;
    Exp.config.parameters.Paralysis_Base_Rate_Sabin2 = val;
    Exp.config.parameters.Paralysis_Base_Rate_Sabin3 = val;
    Exp.config.parameters.Paralysis_Base_Rate_WPV1 = val;
    Exp.config.parameters.Paralysis_Base_Rate_WPV2 = val;
    Exp.config.parameters.Paralysis_Base_Rate_WPV3 = val;
    addTag(Exp.simTags, regexprep(json_paths{j}, '\.', '_'), ValueTable{j}{TestPoints(i,j)});
elseif( ~isempty(regexp( remain, 'Calendar', 'ONCE')) )
    val = ValueTable{j}{TestPoints(i,j)};
    this_struct = ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS.CAMPAIGN.META_Calendar;
    calendar_cell = cell( 1, val);
    for currDose = 1:val
        calendar_cell{currDose}.Probability = 1;
        calendar_cell{currDose}.Age = this_struct.AGES{val+1-currDose};
    end
    for currPath = 1:length(this_struct.JSON_PATHS)
        eval_str = ['Exp.' this_struct.JSON_PATHS{currPath} ' = calendar_cell;'];
        eval(eval_str);
    end
    
    addTag(Exp.simTags, 'N_RI_Doses', val);
elseif( ~isempty(regexp( remain, 'Demographic_Coverage_2places', 'ONCE')) )
    this_struct = ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS.CAMPAIGN.META_Demographic_Coverage_2places__SP1;
    val = ValueTable{j}{TestPoints(i,j)};
    for currPath = 1:length(this_struct.JSON_PATHS)
        eval_str = ['Exp.' this_struct.JSON_PATHS{currPath} ' = val;'];
        eval(eval_str);
    end
    addTag(Exp.simTags, regexprep('Demo_Coverage', '\.', '_'),ValueTable{j}{TestPoints(i,j)});
elseif( strcmp( remain, 'Campaign_Efficacy') == 1)
    CE1 = ValueTable{j}{TestPoints(i,j)};
    if CE1 < 0
        CE1 = 0;
    end
    %for curr_event = 2:length(campaign.Events)
    %    Exp.campaign.Events{curr_event}.Event_Coordinator_Config.Demographic_Coverage	= CE1*Exp.campaign.Events{curr_event}.Event_Coordinator_Config.Demographic_Coverage;
    %end
    Exp.campaign.Events{2}.Event_Coordinator_Config.Distribution_Coverages = cellfun(@(x) CE1*x, Exp.campaign.Events{2}.Event_Coordinator_Config.Distribution_Coverages, 'UniformOutput', false);
    addTag(Exp.simTags, regexprep(json_paths{j}, '\.', '_'), CE1);
    %                     if length(Exp.campaign.Events) == 3
    %                         Exp.campaign.Events{3}.Event_Coordinator_Config.Demographic_Coverage = CE1* Exp.campaign.Events{3}.Event_Coordinator_Config.Demographic_Coverage;
    %                     end
elseif( ~isempty(regexp( remain, 'Start_Day', 'ONCE')) )
    this_struct = ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS.CAMPAIGN.META_TimeToOutbreak;
    val = ValueTable{j}{TestPoints(i,j)};
    eval_str = ['Exp.' strrep(this_struct.JSON_PATH, 'META.', '') ' = val;'];
    eval(eval_str);
    Exp.config.parameters.Simulation_Duration = val+731;
    %Exp.campaign.Events{4}.Start_Day = val+730;
    addTag(Exp.simTags,regexprep('Outbreak_Day', '\.', '_'),ValueTable{j}{TestPoints(i,j)});
    
elseif( strcmpi( remain, 'SingleNode_Immunity_Level'))
    Imm_Level = ValueTable{j}{TestPoints(i,j)};
    ind = cellfun(@(x) ~isempty(regexp(x.Event_Name, 'Vaccination', 'ONCE')), Exp.campaign.Events);
    Exp.campaign.Events{ind}.Event_Coordinator_Config.Demographic_Coverage = Imm_Level;
    addTag(Exp.simTags, 'SingleNode_Immunity_Level', Imm_Level);
    
elseif( strcmpi( remain, 'SingleNode_Infection_Level'))
    Inf_Level = ValueTable{j}{TestPoints(i,j)};
    ind = cellfun(@(x) ~isempty(regexp(x.Event_Name, 'Outbreak', 'ONCE')), Exp.campaign.Events);
    Exp.campaign.Events{ind}.Event_Coordinator_Config.Demographic_Coverage = Inf_Level;
    addTag(Exp.simTags, 'SingleNode_Infection_Level', Inf_Level);
    
    
elseif( strcmpi( remain, 'Immunity_1'))
    Imm_Level = ValueTable{j}{TestPoints(i,j)};
    ind = cellfun(@(x) ~isempty(regexp(x.Event_Name, 'Immunity node 1', 'ONCE')), Exp.campaign.Events);
    Exp.campaign.Events{ind}.Event_Coordinator_Config.Demographic_Coverage = Imm_Level;
    addTag(Exp.simTags, 'Immunity_1', Imm_Level);
    
elseif( strcmpi( remain, 'Immunity_2'))
    Imm_Level = ValueTable{j}{TestPoints(i,j)};
    ind = cellfun(@(x) ~isempty(regexp(x.Event_Name, 'Immunity node 2', 'ONCE')), Exp.campaign.Events);
    Exp.campaign.Events{ind}.Event_Coordinator_Config.Demographic_Coverage = Imm_Level;
    addTag(Exp.simTags, 'Immunity_2', Imm_Level);
    
    
elseif( strcmp( remain, 'Immunity_Level'))
    Threshold_Level = ValueTable{j}{TestPoints(i,j)};
    
    
elseif( strcmp( remain, 'Immunity_Fraction'))
    Fraction_Above = ValueTable{j}{TestPoints(i, j)};
    
    LN_sig = 4*rand(1);
    LN_mu =  log(Threshold_Level/(1-Threshold_Level)) - sqrt(2)*LN_sig*erfinv(1-2*Fraction_Above);
    
    ind = cellfun(@(x) ~isempty(regexp(x.Event_Name, 'Immunity Level', 'ONCE')), Exp.campaign.Events);
    assert( sum(ind) == 1, 'Immunity Level event must only appear once');
    base_event = Exp.campaign.Events{ind};
    %Exp.campaign.Events(ind) = [];
    
    NodeIDs = cellfun(@(x) x.NodeID, Curr_Demog_File.Nodes);
    Coverages = rlogitnormal(LN_mu, LN_sig, length(NodeIDs));
    %Bound the random number; prevent 0 coverage anywhere
    myevent = base_event;
    myevent.Event_Coordinator_Config.Coverage_By_Node = cell(1, length(Coverages));
    for ii = 1:length(Coverages)
        
        newCov = Coverages(ii);
        if newCov < 0; newCov = 0; end
        if newCov > 1; newCov = 1; end
        
        myevent.Event_Coordinator_Config.Coverage_By_Node{1, ii} = cell(1, 2);
        myevent.Event_Coordinator_Config.Coverage_By_Node{1, ii}{1, 1} = NodeIDs(ii);
        myevent.Event_Coordinator_Config.Coverage_By_Node{1, ii}{1, 2} = newCov;
        
    end
    Exp.campaign.Events{ind} = myevent;
    addTag(Exp.simTags, 'Immunity_Level', Threshold_Level);
    addTag(Exp.simTags, 'Immunity_Fraction', Fraction_Above);
    
    clear Threshold_Level Fraction_Above LN_mu LN_sig
    
elseif( strcmp( remain, 'Infection_Level'))
    Threshold_Level2 = ValueTable{j}{TestPoints(i,j)};
elseif( strcmp( remain, 'Response_Node'))
    node2pick = ValueTable{j}{TestPoints(i,j)};
    responsenodeID = Curr_Demog_File.Nodes{round(node2pick)}.NodeID;
    Exp.campaign.Events{2}.Nodeset_Config.Node_List{1} = responsenodeID;
    addTag(Exp.simTags, 'response_node', responsenodeID);
    
    
elseif( strcmp( remain, 'Infection_Fraction'))
    Fraction_Above2 = ValueTable{j}{TestPoints(i, j)};
    
    LN_sig2 = 4*rand(1);
    LN_mu2 =  log(Threshold_Level2/(1-Threshold_Level2)) - sqrt(2)*LN_sig2*erfinv(1-2*Fraction_Above2);
    
    ind = cellfun(@(x) ~isempty(regexp(x.Event_Name, 'Outbreak', 'ONCE')), Exp.campaign.Events);
    assert( sum(ind) == 1, 'Outbreak event must only appear once');
    base_event = Exp.campaign.Events{ind};
    %Exp.campaign.Events(ind) = [];
    
    NodeIDs = cellfun(@(x) x.NodeID, Curr_Demog_File.Nodes);
    Coverages = rlogitnormal(LN_mu2, LN_sig2, length(NodeIDs));
    %Bound the random number; prevent 0 coverage anywhere
    
    myevent = base_event;
    myevent.Event_Coordinator_Config.Coverage_By_Node = cell(1, length(Coverages));
    for ii = 1:length(Coverages);
        
        newCov = Coverages(ii);
        if newCov < 0; newCov = 0; end
        if newCov > 1; newCov = 1; end
        
        myevent.Event_Coordinator_Config.Coverage_By_Node{1, ii} = cell(1, 2);
        myevent.Event_Coordinator_Config.Coverage_By_Node{1, ii}{1, 1} = NodeIDs(ii);
        myevent.Event_Coordinator_Config.Coverage_By_Node{1, ii}{1, 2} = newCov;
        
    end
    Exp.campaign.Events{ind} = myevent;
    addTag(Exp.simTags, 'Infected_Level', Threshold_Level2);
    addTag(Exp.simTags, 'Infected_Fraction', Fraction_Above2);
    
    clear Threshold_Level2 Fraction_Above2 LN_mu2 LN_sig2
    
    
else
    error('NDPolioSweep_and_Calib_ExperimentBuilder:metaparameterHandler', ['Unknown META parameter: ', remain]);
end

end