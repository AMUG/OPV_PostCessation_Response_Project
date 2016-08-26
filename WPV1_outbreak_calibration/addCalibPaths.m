function addCalibPaths(base)

% CalibTool and Simulator
addpath( fullfile(base,'Applications\CalibTool') );
addpath( fullfile(base,'Applications\Simulator') );

% EMODClient
addpath( fullfile(base, 'Dependencies\EMODClient\EMODWebServicesClients_I5-Branch_20120426.1\Matlab') );

% GenericMatlabTools (e.g. countLeaves, getColor, stringifyRange, JSON, Newtonsoft)
addpath(genpath( fullfile(base, 'Dependencies\GenericMatlabTools') ));

% Matlab Simulation Logic
addpath( fullfile(base, 'Dependencies\SimulationLogic') );

% Experiment Builders
addpath( fullfile(base, 'Dependencies\SimulationLogic\ExperimentBuilders') );

% Output file parsers
addpath( fullfile(base, 'Dependencies\SimulationLogic\OutputFileParsers') );

% Callback functions
addpath( fullfile(base, 'Dependencies\callbackFunctions') );

end