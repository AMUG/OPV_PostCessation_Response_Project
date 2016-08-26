function overlayConfigFiles(template_dir, overlay_dir, merge_dir, overwrite_merged_output_files)

if nargin < 4
 overwrite_merged_output_files = true;
end
    
hUser_globals = ToolsUserGlobals.getHandle();

localPath = fileparts(mfilename('fullpath'));

config_path_table = {   'CalibConfig.json',		'pathConfigCalibTool';
                        'CSL.json',				'pathConfigCommission';
						'PSL.json',				'pathConfigProcessing';
						'ES_Credentials.json',  'pathConfigCredentials';
						'SimulatorConfig.json',	'pathConfigSimulator'};

templateConfig	= cellfun(@(x) fullfile(localPath, [template_dir, '\'], x),  config_path_table(:, 1), 'UniformOutput', false);
overlayConfig	= cellfun(@(x) fullfile(localPath, [overlay_dir, '\'], x),    config_path_table(:, 1), 'UniformOutput', false);
mergedConfig	= cellfun(@(x) fullfile(localPath, [merge_dir, '\'], x),		config_path_table(:, 1), 'UniformOutput', false);

% Read templates and overlays:
inConfigStruct	= cellfun(@loadJson, [templateConfig, overlayConfig], 'UniformOutput', false);

% convert relative paths to absolute for the current user so the user does need to have this as working directory
inConfigStruct{2, 1}.SIMULATION.configFilePath = fullfile(localPath, inConfigStruct{2, 1}.SIMULATION.configFilePath);

% Overlay user config onto project config
% inConfigStruct is a cell matrix of two columns.
% Left column is local project file path, right column is user's config file path
workingConfigStruct = cellfun(@(x) traverseMerge( x{1}, x{2}, 'MergeStructure', 'Overlay', 'MergeIfEmpty', 'Base' ),... 'MergeIfEmpty'= 'Overlay' allows user to overwrite empty values where the template has valid values
	mat2cell(inConfigStruct, ones(1, size(templateConfig,1)), 2), 'UniformOutput', false);

% write out to temp the Json files customized for the current user
for i = 1:length(mergedConfig)
    
    if overwrite_merged_output_files
	saveJson(mergedConfig{i}, workingConfigStruct{i});
    end
    
	hUser_globals.( config_path_table{i, 2} ) = mergedConfig{i}; % switch paths in user config for the modified files
end