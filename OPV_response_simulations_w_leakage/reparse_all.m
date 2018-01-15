clc, close all, clear variables, clear import
import Separatrix.*

%% Choose server/configuration
server = 'Belegost';
simout_dir = '\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_Project\OPV_response_WestAfrica_simulations\Simulator';
toolsDir = 'C:\kevmc\EMOD_Research\tools\trunk';

addpath(fullfile(toolsDir, 'Dependencies\ToolsUserGlobals'));
addPaths( toolsDir );

hUser_globals = ToolsUserGlobals.getHandle();
hUser_globals.Optional.pathRepoTools = toolsDir;

resume_dirs = dir([simout_dir '\0*']);

for ii = 1:length(resume_dirs)
    close all
   if exist([simout_dir '\' resume_dirs(ii).name '\CSL.json'], 'file')
      copyfile([simout_dir '\' resume_dirs(ii).name '\CSL.json'], '.\Configs_Templates\CSL.json');       
      overlayConfigFiles('Configs_Templates', ['Configs_Overlay\\', server], 'Configs_Merged', true);
      S = Separatrix('SeparatrixConfigSimulator.json', [simout_dir '\' resume_dirs(ii).name '\'], hUser_globals);
      S.runSeparatrix();
   end
end