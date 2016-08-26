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

% Merge config files
overlayConfigFiles('Configs_Templates', ['Configs_Overlay\\', server], 'Configs_Merged', true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uncomment the following line to resume Separatrix. Replace the value with the path to your simulation output directory. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % resumeFolder = 'simulator\03-14-2014_14-42-48'; % To resume, set this to your simulator folder (e.g: 'simulator\02-26-2014_13-37-07')
% resumeFolder = 'simulator\03-15-2014_00-12-57';	% 25 2D with no KL
% resumeFolder = 'simulator\03-15-2014_00-48-45';	% 25 2D with no KL
% resumeFolder = 'simulator\03-15-2014_22-59-21';	% 25 iterations of 1D, low inference res
% resumeFolder = 'simulator\03-17-2014_12-43-33';
%resumeFolder = 'simulator\test';

if ~exist('resumeFolder', 'var') || ~exist(resumeFolder, 'dir')
	resumeFolder = [];
end

%% Run separatrix
S = Separatrix('SeparatrixConfigSimulator.json', resumeFolder, hUser_globals);
S.runSeparatrix()

%% Post-separatrix analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below are examples of how you can access the run context as well as print it in a readable format %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% S.Context % You can access various details about the run here
% S.Print() % This will print the context in a readable format