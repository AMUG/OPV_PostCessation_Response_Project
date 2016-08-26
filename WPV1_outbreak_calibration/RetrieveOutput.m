% Daniel J. Klein, IVL, 7/26/2012
%clc, clear, close all, clear classes, clear import
close all

%% Choose configuration,  - set paths in ToolsUserGlobals with your own user initTools script

%from RunSimulator
set_project_user_environment('Config_Merged');
hUser_globals = ToolsUserGlobals.getHandle();
addCalibPaths( hUser_globals.Optional.pathRepoTools);
overlayConfigFiles('Config_Templates', 'Config_Overlays\\Belegost', 'Config_Merged');


import CalibTool.*

% Create instance of CalibTool
C = CalibTool();

 calibConfig = loadJson( hUser_globals.pathConfigCalibTool );
 baseDir = calibConfig.CALIBTOOL.OutputDir;
 suiteId = '27f4b4e9-166a-e611-93fd-f0921c16b9e4';
% 
 C.ResumeCalibration(baseDir, suiteId);


