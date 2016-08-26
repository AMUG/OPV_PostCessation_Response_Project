%% Demonstrate Separatrix based on PrimaryScenarios_7_Namawala_Vector_ITNsPEV

clc, close all, clear variables, clear import
import Separatrix.*

%% Choose server/configuration
server = 'Belegost';
toolsDir = 'C:\kevmc\EMOD_Research\tools\trunk';

addpath(fullfile(toolsDir, 'Dependencies\ToolsUserGlobals'));
addPaths( toolsDir );

hUser_globals = ToolsUserGlobals.getHandle();
hUser_globals.Optional.pathRepoTools = toolsDir;


campaign_files = {'campaign_base.json', 'campaign_1IPV.json', 'campaign_2IPV.json', 'campaign_high_immunity_base.json', 'campaign_high_immunity_1IPV.json', 'campaign_high_immunity_2IPV.json'};
mig_profiles = {'linear', 'quad'};
R0_profiles = { {1.2*5/4/27, .5, 90, 60},  {1.5*5/4/27, .5, 90, 60}, {2*5/4/27, .5, 90, 60},  {3*5/4/27, .5, 90, 60}, ...
    {1.2*5/4/27, .5, 90, 150},  {1.5*5/4/27, .5, 90, 150}, {2*5/4/27, .5, 90, 150},  {3*5/4/27, .5, 90, 150}, ...
    {1.2*5/4/27, .25, 90, 60}, {1.5*5/4/27, .25, 90, 60}, {2*5/4/27, .25, 90, 60}, {3*5/4/27, .25, 90, 60}, ...
    {1.2*5/4/27, .25, 90, 150}, {1.5*5/4/27, .25, 90, 150}, {2*5/4/27, .25, 90, 150}, {3*5/4/27, .25, 90, 150}};

s = RandStream('mt19937ar','Seed',1);
RandStream.setGlobalStream(s);

R0_start = 1;
R0_end = 4;  %length(R0_profiles)
campaign_start = 4;
campaign_end = 6; %length(campaign_files)
migration_start = 1;
migration_end = 1; %length(mig_profiles)
for curr_mig = migration_start:migration_end
    for curr_R0prof = R0_start:R0_end       
        for currCampaign = campaign_start:campaign_end  
            copyfile(['Configs_DTK\' campaign_files{currCampaign}], 'Configs_DTK\campaign.json');
            myjson = loadJson('Configs_Templates\CSL.json');

            myjson.EXPERIMENT.Tags.Campaign_File = campaign_files{currCampaign};
            myjson.EXPERIMENT.Tags.R0 = R0_profiles{curr_R0prof}{1}*27;
            myjson.EXPERIMENT.Tags.Infectivity_Exponential_Baseline = R0_profiles{curr_R0prof}{2};
            myjson.EXPERIMENT.Tags.Infectivity_Exponential_Delay = R0_profiles{curr_R0prof}{3};
            myjson.EXPERIMENT.Tags.Infectivity_Exponential_Rate = R0_profiles{curr_R0prof}{4};
            myjson.EXPERIMENT.Tags.Gravity_Model_Distance_Dependence = mig_profiles{curr_mig};
            if strcmpi(mig_profiles{curr_mig}, 'linear')
                myjson.EXPERIMENT.BUILDER.param_ranges{1}.min = -12;
                myjson.EXPERIMENT.BUILDER.param_ranges{1}.max = -5;
            end
            if strcmpi(mig_profiles{curr_mig}, 'quad')
                myjson.EXPERIMENT.BUILDER.param_ranges{1}.min = -10;
                myjson.EXPERIMENT.BUILDER.param_ranges{1}.max = -3;
            end
            myjson.EXPERIMENT.BUILDER.CONFIG_PARAMETERS.Local_Migration_Filename = ['local_migration\\WestAfrica_Provincelevel_' mig_profiles{curr_mig} '_local_migration.bin'];
            myjson.EXPERIMENT.BUILDER.CONFIG_PARAMETERS.Regional_Migration_Filename = ['regional_migration\\WestAfrica_Provincelevel_' mig_profiles{curr_mig} '_regional_migration.bin'];

            myjson.EXPERIMENT.BUILDER.CONFIG_PARAMETERS.Base_Infectivity = R0_profiles{curr_R0prof}{1};
            myjson.EXPERIMENT.BUILDER.CONFIG_PARAMETERS.Infectivity_Exponential_Baseline = R0_profiles{curr_R0prof}{2};
            myjson.EXPERIMENT.BUILDER.CONFIG_PARAMETERS.Infectivity_Exponential_Delay = R0_profiles{curr_R0prof}{3};
            myjson.EXPERIMENT.BUILDER.CONFIG_PARAMETERS.Infectivity_Exponential_Rate = R0_profiles{curr_R0prof}{4};

            saveJson('Configs_Templates\CSL.json', myjson);
            % Merge config files
            overlayConfigFiles('Configs_Templates', ['Configs_Overlay\\', server], 'Configs_Merged', true);

            resumeFolder = [];
%             if curr_R0prof == 12 && curr_mig == 2 && currCampaign == 2
%                 resumeFolder = 'simulator\08-04-2016_00-19-32';
%             end
            sepjson = loadJson('SeparatrixConfigSimulator.json');
            sepjson.SEPARATRIX.RandomSeed = randi(1000000);
            saveJson('SeparatrixConfigSimulator.json', sepjson);
            %% Run separatrix
            S = Separatrix('SeparatrixConfigSimulator.json', resumeFolder, hUser_globals);
            S.runSeparatrix()
            saveJson([S.workingDir '\CSL.json'], myjson);
        end
    end
end
%% Post-separatrix analysis
