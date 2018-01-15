function addPaths(base)
% Add paths to Simulator and Dependencies based on typical structure of the
% EMOD_Research SVN.  If you checked things out in pieces, you many need to
% revise this script.

% Simulator
addpath(genpath( fullfile(base,'Applications\Simulator') ));
%addpath( fullfile(base, 'Dependencies\EMODClient\EMODWebServicesClients_I5-Branch_20120426.1\Matlab') );

% COMPS Client - have to add this early since javaaddpath clears global workspace *sigh*
jcp = javaclasspath('-dynamic');
jarpath = cd(cd(fullfile(base,'Dependencies\COMPS.JavaClient')));  % turn relative path into absolute
jarpath = fullfile(jarpath, 'COMPS.JavaClient.jar');
if isempty(nonzeros(ismember(jcp, jarpath)))
    javaaddpath(jarpath);
end

% GenericMatlabTools (e.g. countLeaves, getColor, stringifyRange, JSON, Newtonsoft)
addpath(genpath( fullfile(base, 'Dependencies\GenericMatlabTools') ));

addpath(genpath( fullfile(base, 'Dependencies\ToolsUserGlobals') ));

% Matlab Simulation Logic
addpath( fullfile(base, 'Dependencies\SimulationLogic') );

% ToolsUserGlobals
addpath( fullfile(base, 'Dependencies\ToolsUserGlobals') );

%callbackFunctions, e.g. doDefaultOnJobStateQuery
addpath( fullfile(base, 'Dependencies\callbackFunctions') );

% Experiment Builders
addpath( fullfile(base, 'Dependencies\SimulationLogic\ExperimentBuilders') );

% Output file parsers
addpath( fullfile(base, 'Dependencies\SimulationLogic\OutputFileParsers') );

end