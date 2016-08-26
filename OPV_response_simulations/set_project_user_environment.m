function set_project_user_environment( merge_dir )
% apply user-specific changes to the project configurations and model input files
% customize the configuration through scripts in your user folder

base = 'C:\Users\kmccarthy\EMOD_Research';
tools = fullfile(base, 'tools', 'trunk');

% COMPS Client - have to add this early since javaaddpath clears global workspace *sigh*
jcp = javaclasspath('-dynamic');
jarpath = cd(cd(fullfile(tools,'Dependencies\COMPS.JavaClient')));  % turn relative path into absolute
jarpath = fullfile(jarpath, 'COMPS.JavaClient.jar');
if isempty(nonzeros(ismember(jcp, jarpath)))
    javaaddpath(jarpath);
end

addpath( fullfile(tools, 'Dependencies', 'ToolsUserGlobals') );

hUser_globals = ToolsUserGlobals.getHandle();
hUser_globals.Optional.pathRepoTools = tools;

config_path_table = {   'CSL.json',				'pathConfigCommission';
						'PSL.json',				'pathConfigProcessing';
						'ES_Credentials.json',  'pathConfigCredentials';
						'SimulatorConfig.json',	'pathConfigSimulator';
						'CalibConfig.json',		'pathConfigCalibTool' };

localPath = fileparts(mfilename('fullpath'));
mergedConfig = cellfun(@(x) fullfile(localPath, [merge_dir, '\'], x), ...
	config_path_table(:, 1), 'UniformOutput', false);
			
% write out to temp the Json files customized for the current user
for i = 1:length(mergedConfig)
	hUser_globals.( config_path_table{i, 2} ) = mergedConfig{i}; % switch paths in user config for the modified files
end

end