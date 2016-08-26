function [experiment, numPoints, numReplicates] = PolioOutbreakResponse_ExperimentBuilder(msl_obj, experiment, config, campaign, varargin)
% July 2012, Intellectual Ventures Lab
% TODO: Only works for config parameters for now, not campaign
try
	narginchk(4,4);
catch 
	warning('PolioOutbreakResponse_ExperimentBuilder:Usage', ['Usage: \n', ...
		'PolioOutbreakResponse_ExperimentBuilder(experiment, config, campaign)\n']);
%	rethrow(e);
end

ES_config = msl_obj.config;

json_paths = [];
TestPoints = [];
if(nargin==6)
    %error('PolioOutbreakResponse_ExperimentBuilder does not yet take external varargin');
	json_paths = varargin{1};
	TestPoints = varargin{2};
end

RunNumbers = eval(ES_config.EXPERIMENT.BUILDER.RunNumbers);
progress_count = 100; 
sims_created = 0;
line_length = 0;

simName = experiment.getName();

simDescription = ES_config.EXPERIMENT.Description;
simTags = createTagMapFromStruct(ES_config.EXPERIMENT.Tags);

% TODO: make sure countLeaves is accessable
[nConfigParNames, configWhere, configVals] = countLeaves(ES_config.EXPERIMENT.BUILDER.CONFIG_PARAMETERS);
[nCampaignParNames, campaignWhere, campaignVals] = countLeaves(ES_config.EXPERIMENT.BUILDER.CAMPAIGN_PARAMETERS);
DemogParNames = {};
MigParNames = {};
if isstruct(ES_config.EXPERIMENT.BUILDER.DEMOGRAPHICS_PARAMETERS)
    DemogParNames = fieldnames(ES_config.EXPERIMENT.BUILDER.DEMOGRAPHICS_PARAMETERS);
end
if isstruct(ES_config.EXPERIMENT.BUILDER.MIGRATION_PARAMETERS)
    MigParNames = fieldnames(ES_config.EXPERIMENT.BUILDER.MIGRATION_PARAMETERS);
end
    

if isempty(TestPoints)
    [TestPoints, ValueTable, json_paths] = SweepSetup(ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS, campaign);
else
    %Input taken from a calibration run.  JSON paths assumed to be correct
    %(or META, where necessary).
    ValueTable = cell(1, size(TestPoints, 2));
    for ii = 1:size(TestPoints, 2);
        ValueTable{ii} = num2cell(TestPoints(:, ii)');
    end
    TestPoints = repmat((1:size(TestPoints, 1))', [1, size(TestPoints, 2)]);
end

if( isempty(TestPoints) )
	error('PolioOutbreakResponse_ExperimentBuilder:find_sweep_dim', 'Failed to identify the sweep dimension');
end

numPoints = max(1,size(TestPoints, 1));	% Do base when TestPoints is empty
numReplicates = length(RunNumbers);
if numPoints*numReplicates > 20000
   error('PolioOutbreakResponse_ExperimentBuilder:numberofSims', [num2str(numPoints*numReplicates) ' is too many simulations to submit at once.  Reduce sweep points or number of repetitions, or write a batching script']); 
end

Base_Demog_File = loadJson(fullfile(ES_config.EXPERIMENT.BUILDER.Base_Demog_File_Dir, ES_config.EXPERIMENT.BUILDER.Base_Demog_File_Name));

[~, unique_name] = fileparts(msl_obj.root);
    
    
for i = 1:numPoints 	
	for replicate = 1:numReplicates 
		Exp.config = config;
		Exp.simDescription = simDescription;
		Exp.simTags = java.util.HashMap(simTags);
		Exp.campaign = campaign;
        Curr_Demog_File = Base_Demog_File;
        migration_matrix = ones(length(Curr_Demog_File.Nodes));
        demog_key_str = [];
        mig_key_str = [];
		% Add calibration-specific parameters to the config
        addTag(Exp.simTags, 'TestPointIndex', i);
        addTag(Exp.simTags, 'Replicate', replicate);	
        
		% Fixed parameters from config
        if RunNumbers(replicate) < 0
            Exp.config.parameters.Run_Number = round(-1*RunNumbers(replicate)*rand(1,1));
            addTag(Exp.simTags, 'Random_Run_Numbers', 1);
        else
            Exp.config.parameters.Run_Number = RunNumbers(replicate);
        end
         addTag(Exp.simTags, 'Run_Number', Exp.config.parameters.Run_Number);
        
		% Fixed parameters from config        
        for ipar = 1:nConfigParNames
            if(isempty(configVals{ipar}))
                continue;
            end
            Exp = addParameter(Exp, ['config', 'parameters', configWhere{ipar}], configVals{ipar});
            addTag(Exp.simTags, configWhere{ipar}{end}, configVals{ipar});
        end
        Exp.config.parameters.Campaign_Filename = strrep(Exp.config.parameters.Campaign_Filename, 'Configs_DTK\', '');
		% Fixed parameters from campaign
        for ipar = 1:nCampaignParNames
            if(isempty(campaignVals{ipar}))
                continue;
            end
            Exp = addParameter(Exp, ['campaign', campaignWhere{ipar}], campaignVals{ipar});
            addTag(Exp.simTags, campaignWhere{ipar}{end}, campaignVals{ipar});
        end
        
     	% Fixed parameters from demographics
        for ipar = 1:length(DemogParNames)
            this_struct = ES_config.EXPERIMENT.BUILDER.DEMOGRAPHICS_PARAMETERS.(DemogParNames{ipar});
            paramval = this_struct.PARAMETER_VALUE;
            fh = str2func(this_struct.FUNCTION_HANDLE);
            Curr_Demog_File = fh(Curr_Demog_File, this_struct.INPUT_PARAMS, paramval);
            migration_matrix = ones(length(Curr_Demog_File.Nodes));
            addTag(Exp.simTags, this_struct.NAME,paramval);
            
            demog_key_str = [demog_key_str '_' num2str(ipar)];
        end
        
		% Modifications from test points, will skip if no test points
        for j=1:size(TestPoints,2)
            [token, remain]=strtok(json_paths{j}, '.');
            remain = remain(2:end);	% Chop off initial '.'
            
            if( strcmp(token, 'META') == 1 )
                if( ~isempty(regexp( remain, 'DEMO_PARAM', 'ONCE') ) )	%Handle demographics
                    this_struct = ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS.DEMOGRAPHICS.(remain);
                    paramval = ValueTable{j}{TestPoints(i,j)};
                                        
                    fh = str2func(this_struct.FUNCTION_HANDLE);
                    Curr_Demog_File = fh(Curr_Demog_File, this_struct.INPUT_PARAMS, paramval);
                    migration_matrix = ones(length(Curr_Demog_File.Nodes));
                    addTag(Exp.simTags, this_struct.NAME,paramval);
                    
                    demog_key_str = [demog_key_str '_' num2str(TestPoints(i,j))];
                    
%                    if strcmp(this_struct.NAME, 'N_HINT_Groups')
%                        Exp.campaign.Events{1}.Event_Coordinator_Config.Demographic_Coverage = Exp.campaign.Events{1}.Event_Coordinator_Config.Demographic_Coverage * paramval;
%                    end

                    clear this_struct fh
                    
                    
                elseif( ~isempty(regexp( remain, 'MIG_PARAM', 'ONCE') ) )	%Handle migration
                    %Trying to handle multiple parameters
                    this_struct = ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS.MIGRATION.(remain);
                    paramval = ValueTable{j}{TestPoints(i,j)};
                    
                    if isfield(this_struct.INPUT_PARAMS, 'SaveDistanceMatrix') && strcmpi(this_struct.INPUT_PARAMS.SaveDistanceMatrix, 'true');
                        if ~isfield(this_struct.INPUT_PARAMS, 'DistanceMatrixSaveFile')
                            DistanceMatrixSaveFile = ['C:\Temp\DistMat_' datestr(now, 'yyyy-mm-dd-HH-MM-SS') '.mat'];
                            ES_config.EXPERIMENT.BUILDER.SWEEP_PARAMETERS.MIGRATION.(remain).INPUT_PARAMS.DistanceMatrixSaveFile = DistanceMatrixSaveFile;
                            this_struct.INPUT_PARAMS.DistanceMatrixSaveFile = DistanceMatrixSaveFile;
                        end
                    end
                    fh = str2func(this_struct.FUNCTION_HANDLE);
                    %Migration file must receive demographics file as input
                    if isempty(mig_key_str) && ~isempty(demog_key_str)
                            mig_key_str = [mig_key_str demog_key_str];
                    end
                    mig_key_str = [mig_key_str '_' num2str(TestPoints(i,j))];  
                    migration_matrix = fh(Curr_Demog_File, this_struct.INPUT_PARAMS, paramval, migration_matrix);
                    addTag(Exp.simTags, this_struct.NAME,paramval);

                    clear this_struct fh
                else 
                    Exp = metaparameterHandler(remain, ValueTable, TestPoints, Exp, json_paths, i, j);
                end
            else
                eval_str = [ 'Exp.', json_paths{j}, ' = ', num2str(ValueTable{j}{TestPoints(i,j)}), ';' ];
                eval(eval_str);
                addTag(Exp.simTags, regexprep(json_paths{j}, '\.', '_'), ValueTable{j}{TestPoints(i,j)});
            end
        end
        
        % Fixed parameters from migration - Must come last in case of
        % changes to demographics file in the calibration test points
        for ipar = 1:length(MigParNames)
            
            this_struct = ES_config.EXPERIMENT.BUILDER.MIGRATION_PARAMETERS.(MigParNames{ipar});
            
            paramval = this_struct.PARAMETER_VALUE;
            fh = str2func(this_struct.FUNCTION_HANDLE);
            
            if isfield(this_struct.INPUT_PARAMS, 'SaveDistanceMatrix') && strcmpi(this_struct.INPUT_PARAMS.SaveDistanceMatrix, 'true');
                if ~isfield(this_struct.INPUT_PARAMS, 'DistanceMatrixSaveFile')
                    DistanceMatrixSaveFile = ['C:\Temp\DistMat_' datestr(now, 'yyyy-mm-dd-HH-MM-SS') '.mat'];
                    ES_config.EXPERIMENT.BUILDER.MIGRATION_PARAMETERS.(MigParNames{ipar}).INPUT_PARAMS.DistanceMatrixSaveFile = DistanceMatrixSaveFile;
                    this_struct.INPUT_PARAMS.DistanceMatrixSaveFile = DistanceMatrixSaveFile;
                end
            end
            
            if isempty(mig_key_str) && ~isempty(demog_key_str)
                mig_key_str = [mig_key_str demog_key_str];
            end
            
            mig_key_str = [mig_key_str '_' num2str(ipar)];
            migration_matrix = fh(Curr_Demog_File, this_struct.INPUT_PARAMS, paramval, migration_matrix);
            addTag(Exp.simTags, this_struct.NAME,paramval);
            clear this_struct fh
        end
        
        
        if ~isempty(demog_key_str)
            Curr_Demog_File_Name = strrep(ES_config.EXPERIMENT.BUILDER.Base_Demog_File_Name, '_base', demog_key_str);
        else
            Curr_Demog_File_Name = ES_config.EXPERIMENT.BUILDER.Base_Demog_File_Name;
        end
        
        if ~exist(fullfile(msl_obj.root, 'input', 'demographics'), 'dir')
            mkdir(fullfile(msl_obj.root, 'input', 'demographics'));
        end
        if ~exist(fullfile(msl_obj.root, 'input', 'demographics', Curr_Demog_File_Name), 'file')
            saveJson(fullfile(msl_obj.root, 'input', 'demographics', Curr_Demog_File_Name), Curr_Demog_File);
            status = system([ES_config.EXPERIMENT.BUILDER.Demographics_Compile_Command ' ' fullfile(msl_obj.root, 'input', 'demographics', Curr_Demog_File_Name)]);
            assert(status==0, 'PolioOutbreakResponse_ExperimentBuilder:compiledemog, Error compiling demographics file');
        end
        if ~isempty(mig_key_str)
            Mig_TextFile_Name = [ES_config.EXPERIMENT.BUILDER.Base_Mig_File_Name mig_key_str '_' ES_config.EXPERIMENT.BUILDER.Migration_File_Type '.txt'];
            if ~exist(fullfile(msl_obj.root, 'input', 'migration'), 'dir')
                mkdir(fullfile(msl_obj.root, 'input', 'migration'));
            end
            if ~exist(fullfile(msl_obj.root, 'input', 'migration', Mig_TextFile_Name), 'file')
                migration_texttowrite = Finalize_Migration_TextFile(Curr_Demog_File, migration_matrix, ES_config.EXPERIMENT.BUILDER.Migration_File_Type);
                fid = fopen(fullfile(msl_obj.root, 'input', 'migration', Mig_TextFile_Name), 'w');
                fprintf(fid, migration_texttowrite);
                fclose(fid);
                
                %Generate migration header
                status = system([ES_config.EXPERIMENT.BUILDER.Migration_Header_Compile_Command ' ' fullfile(msl_obj.root, 'input', 'demographics', strrep(Curr_Demog_File_Name, '.json', '.compiled.json')) ' ' ES_config.EXPERIMENT.BUILDER.Migration_File_Type]);
                assert(status==0, 'PolioOutbreakResponse_ExperimentBuilder:generate_migration_header, Error generating migration header from demo file');
                movefile(fullfile(msl_obj.root, 'input', 'demographics', strrep(Curr_Demog_File_Name, '_demographics.json', ['_' ES_config.EXPERIMENT.BUILDER.Migration_File_Type '_migration.bin.json'])), ...
                    fullfile(msl_obj.root, 'input', 'migration', strrep(Mig_TextFile_Name, '.txt', '_migration.bin.json')));

                %compile migration file to binary
                status = system([ES_config.EXPERIMENT.BUILDER.Migration_Binary_Compile_Command ' ' fullfile(msl_obj.root, 'input', 'migration', Mig_TextFile_Name) ' ' fullfile(msl_obj.root, 'input', 'migration', [ES_config.EXPERIMENT.BUILDER.Base_Mig_File_Name mig_key_str]) ' ' ES_config.EXPERIMENT.BUILDER.Migration_File_Type]);
                assert(status==0, 'PolioOutbreakResponse_ExperimentBuilder:compilemig, Error compiling migration file');
                

            end
            config_mig = [upper(ES_config.EXPERIMENT.BUILDER.Migration_File_Type(1)) ES_config.EXPERIMENT.BUILDER.Migration_File_Type(2:end)];
            Exp.config.parameters.Migration_Model = 'FIXED_RATE_MIGRATION';            
            Exp.config.parameters.(['Enable_' config_mig '_Migration']) = 1;
            Exp.config.parameters.([config_mig '_Migration_Filename']) = ['migration_' unique_name '\\' ES_config.EXPERIMENT.BUILDER.Base_Mig_File_Name mig_key_str '_' ES_config.EXPERIMENT.BUILDER.Migration_File_Type '_migration.bin'];
            addTag(Exp.simTags, [config_mig '_Migration_Filename'], Exp.config.parameters.([config_mig '_Migration_Filename']));
            
        end
        
        sim = msl_obj.CreateAndAddNewSimulation( simName, simDescription, Exp.simTags, Exp.config, Exp.campaign, ES_config.SIMULATION.inputArgString );
        sim.setExperimentId(experiment.getId());
        sims_created = sims_created + 1;
        if sims_created == numPoints*numReplicates || mod(sims_created, progress_count) == 0
            if line_length > 0
                fprintf(1, repmat('\b',1,line_length));
            end
            line_length = fprintf('Created %d simulations', sims_created);
        end
	end
end

%Now send the input files
input_token = regexp(ES_config.SIMULATION.inputArgString, '-I (\S+)', 'tokens');
base_destination = input_token{1}{1};
assert(~isempty(base_destination), 'PolioOutbreakResponse_ExperimentBuilder:sendInputFiles, Could not determine input file directory from ES_config.SIMULATION.inputArgString');
    

demog_destination = ['demographics_' unique_name];
mig_destination = ['migration_' unique_name];

if isempty(demog_key_str)
    Curr_Demog_File_Name = ES_config.EXPERIMENT.BUILDER.Base_Demog_File_Name;
    if ~exist(fullfile(msl_obj.root, 'input', 'demographics'), 'dir')
        mkdir(fullfile(msl_obj.root, 'input', 'demographics'));
    end
    if ~exist(fullfile(msl_obj.root, 'input', 'demographics', Curr_Demog_File_Name), 'file')
        saveJson(fullfile(msl_obj.root, 'input', 'demographics', Curr_Demog_File_Name), Curr_Demog_File);
        status = system([ES_config.EXPERIMENT.BUILDER.Demographics_Compile_Command ' ' fullfile(msl_obj.root, 'input', 'demographics', Curr_Demog_File_Name)]);
        assert(status==0, 'PolioOutbreakResponse_ExperimentBuilder:compiledemog, Error compiling demographics file');
    end

end

%pathname_map = Client.getAuthManager().getEnvironmentMacros(ES_config.EXPERIMENT.BUILDER.EnvironmentName)
%uname = Client.getAuthManager().getUsername() 
if ~isempty(demog_key_str)
    Exp.config.parameters.Demographics_Filename = ['demographics_' unique_name '\\' strrep(Curr_Demog_File_Name, '.json', '.compiled.json')];
    Zip_Send_and_Unzip(ES_config, strrep(base_destination, '$COMPS_PATH(USER)', ES_config.EXPERIMENT.BUILDER.COMPS_PATH_USER_Resolution), demog_destination, fullfile(msl_obj.root, 'input', 'demographics'));
    addTag(Exp.simTags, 'Demographics_File', Exp.config.parameters.Demographics_Filename);
end

if ~isempty(mig_key_str)
    Zip_Send_and_Unzip(ES_config, strrep(base_destination, '$COMPS_PATH(USER)', ES_config.EXPERIMENT.BUILDER.COMPS_PATH_USER_Resolution), mig_destination, fullfile(msl_obj.root, 'input', 'migration'));
end
end

function Exp = addParameter( Exp, where, value)
    mystr = 'Exp';
    for(i=1:length(where))

        if(isnumeric(where{i}))
            mystr = [ mystr, '{', num2str(where{i}), '}' ];
        else
            mystr = [ mystr, '.', where{i} ];
        end

    end
    
    if ~ischar(value)
        mystr = [ mystr, '=', num2str(value), ';' ];
    else
        mystr = [ mystr, '=''', value, ''';' ];
    end
    
    eval(mystr);
end

function [SweepKeyTable, SweepValueTable, JsonPathTable] = SweepSetup(SweepParamStruct, campaign_template)
    %First, initialize my variables
    sweepdims = 0;
    paramStructFields = fieldnames(SweepParamStruct);

    for currParamStructField = 1:length(paramStructFields)
        if ~isempty(SweepParamStruct.(paramStructFields{currParamStructField}))
            sweepdims = sweepdims + length(fieldnames(SweepParamStruct.(paramStructFields{currParamStructField})));
        end
    end

    JsonPathTable = cell(1, sweepdims);
    SweepKeys = cell(1, sweepdims);
    SweepValueTable = cell(1, sweepdims);
    %Now go through the config, campaign, demographics, migration fields
    output_ind = 0;
    for currParamStructField = 1:length(paramStructFields)
        if ~isempty(SweepParamStruct.(paramStructFields{currParamStructField}))
            CurrParamFields = fieldnames(SweepParamStruct.(paramStructFields{currParamStructField}));
        else
            CurrParamFields = [];
        end
        for currParam = 1:length(CurrParamFields)
            output_ind = output_ind+1;
            this_struct = SweepParamStruct.(paramStructFields{currParamStructField}).(CurrParamFields{currParam});
            %First handle json-path
            if isfield(this_struct, 'JSON_PATH')
                JsonPathTable{output_ind} = this_struct.JSON_PATH;
            else
                if strcmpi((paramStructFields{currParamStructField}), 'CONFIG')
                    JsonPathTable{output_ind} = ['config.parameters.' CurrParamFields{currParam}];
                elseif strcmpi((paramStructFields{currParamStructField}), 'CAMPAIGN')
                    where = findKey( campaign_template.Events, CurrParamFields{currParam} );
                    JsonPathTable{output_ind} = 'campaign.Events';
                    for i=1:length(where)
                        if isnumeric(where{i})
                            JsonPathTable{output_ind} = [ JsonPathTable{output_ind}, '{', num2str(where{i}), '}' ];
                        else
                            JsonPathTable{output_ind} = [ JsonPathTable{output_ind}, '.', where{i} ];
                        end
                    end
                    JsonPathTable{output_ind} = regexprep(JsonPathTable{output_ind}, '__SP\d+', '');
                    if ~isempty(regexp(JsonPathTable{output_ind}, 'META_', 'ONCE'))
                        JsonPathTable{output_ind} = ['META.' regexprep(JsonPathTable{output_ind}, 'META_', '')];
                    end
                elseif strcmpi((paramStructFields{currParamStructField}), 'DEMOGRAPHICS')
                    JsonPathTable{output_ind} = ['META.' CurrParamFields{currParam}];
                elseif strcmpi((paramStructFields{currParamStructField}), 'MIGRATION')
                    JsonPathTable{output_ind} = ['META.' CurrParamFields{currParam}];                    
                end
            end
    
            
            %Now handle whether we defined values or min/max/NPoints
            if isfield(this_struct, 'VALUES')
                SweepValueTable{output_ind} = this_struct.VALUES;
                
            elseif isfield(this_struct, 'MIN') && isfield(this_struct, 'MAX') &&...
                    isfield(this_struct, 'NPOINTS') && isfield(this_struct, 'SPACING')
                if strcmpi(this_struct.SPACING, 'LINEAR')
                    SweepValueTable{output_ind} =  num2cell(linspace(this_struct.MIN, this_struct.MAX, this_struct.NPOINTS));
                elseif strcmpi(this_struct.SPACING, 'LOG')
                    SweepValueTable{output_ind} =  num2cell(10.^linspace(log10(this_struct.MIN), log10(this_struct.MAX), this_struct.NPOINTS));
                else
                    error('PolioOutbreakResponse_ExperimentBuilder:setup_sweep', ['Unclear how to define values to sweep over for parameter ' CurrParamFields{currParam} '.  SPACING must be LINEAR or LOG']);
                end
            else
                error('PolioOutbreakResponse_ExperimentBuilder:setup_sweep', 'Unclear how to define values to sweep over.  Define with VALUES array, or MIN, MAX, NPOINTS, SPACING');
                
            end              
            
            SweepKeys{output_ind} = 1:length(SweepValueTable{output_ind});
            
        end        
    end
    
    SweepKeyTable = allcomb(SweepKeys{:});



end


function [] = Zip_Send_and_Unzip(ES_config, base_destination, specific_destination, local_dir)
    zipfile = [fullfile(fileparts(local_dir), specific_destination) '.zip'];
    zip(zipfile, {[local_dir '\*.bin'], [local_dir '\*.json']});
    
    tic  %Note - if the folder doesn't exist, it creates a file names 'base_destination'.  Need to handle this behavior.
    [s r m_id] = movefile(zipfile, base_destination);
    if(~s), error(m_id, r); end; % movefile does not follow error code convention
    fprintf('Uploading input files took %f sec\n', toc);
    
    cred = loadJson(ToolsUserGlobals.getHandle().pathConfigCredentials);
    loginStr = '';
    if(isfield(cred, 'HEADNODE') && ~isempty(cred.HEADNODE.Username))
        loginStr = sprintf('/user:%s ', cred.HEADNODE.Username);
    end;
    
    tic
    job_str = [	'job submit ' loginStr,...
        ' /scheduler:',	ES_config.EXPERIMENT.BUILDER.Scheduler,...
        ' /nodegroup:',	ES_config.EXPERIMENT.BUILDER.Nodegroup, ...
        ' /priority:Highest ', ES_config.EXPERIMENT.BUILDER.UnzipCmd, ...
        ' -o ', base_destination,'\\', specific_destination, '.zip -d ', base_destination, '\\', specific_destination];
    
    fprintf('Deploying configuration files. Refresh credentials for headnode if job submit is stalled. Starting job...\n%s', strrep(job_str, cred.HEADNODE.Password, '*********'));
    [s r] = dos(job_str);
    if(s), error(r); end;
    jobId = sscanf(r, 'Job has been submitted. ID: %d.');
    if isempty(jobId)
        error('Failed to get job id for unzip job: command string\n%s\nResult:\n%s\n', job_str, r);
    end
    while true
        % 	[status,result] = dos(['job view /scheduler:headnode.emodgh.com ',num2str(taskid)]);
        [status result] = dos(['job view /scheduler:',ES_config.EXPERIMENT.BUILDER.Scheduler,' ',num2str(jobId)]);
        if(status), error(result); end;
        start = strfind(result, [char(10) 'State']);
        if isempty(start)
            disp('Failed to parse state, waiting 60 sec');
            pause(60);
            break
        end
        
        if ~isempty(regexp(result, 'State\W*(?=Finished)','once'))
            break;
        elseif ~isempty(regexp(result, 'State\W*(?=Failed)','once'))
            error('unzip job failed.\n%s\n', result);
        else
            fprintf('.')
            pause(1);
        end
    end
    fprintf('\nUnzipping input files took %f sec\n', toc);
    
end



function tags = createTagMapFromStruct( tagstruct )
    names = fieldnames(tagstruct);
    tags = java.util.HashMap();

    cellfun(@(x) tags.put(x, java.lang.String(num2str(tagstruct.(x)))), names, 'UniformOutput', false);
end

function tagmap = addTag( tagmap, key, value ) 
    tagmap.put(key, java.lang.String(num2str(value))); 
end 