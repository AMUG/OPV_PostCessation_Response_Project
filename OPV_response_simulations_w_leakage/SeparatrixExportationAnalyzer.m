classdef SeparatrixExportationAnalyzer < IAnalyzer
	
	properties(SetAccess=private)
		config		% Configuration, from SimulatorConfig.json
		Channel		% Inset chart channel to evaluate
		Threshold	% Threshold, return true if Channel is below threshold at final time
		params
		outcomes_before_thresholding	% Outcome values before thresholding
		outcomes	% Boolean outcomes for Separatrix
    end
	
	properties(SetAccess=public)
        log_likelihoods
    end
    
	methods
		function obj = SeparatrixExportationAnalyzer(config)
			
			if ~isfield(config, 'Name')
				error('Configuration is missing Name');
            end
			obj.Name = config.Name;
			
			obj.config = config;
            obj.params.Name = 'SeparatrixExportationAnalyzer';
		end
		
		function process(obj, parsers)
			% Plot inset chart channels
			
			for i=1:length(parsers)
				parserName = parsers{i}.Name;
				if strcmpi(parserName, 'RSOParser') == 1
                    parser = parsers{i};
                    inf_channel = strcmpi(parser.spatialOutput.channelTitle{1}, 'New_Infections');
					assert(any(inf_channel), 'New_Infections Channel not found in spatial output parser');
					
                    nodes = parser.spatialOutput.nodeIDList{1}{1};
                    province_node = 146539724;
                    region_nodes = [146539724, 145687766, 147588302, 147653814, 145097927];
                    country_nodes = [146539724, 145097927, 150406347, 146212013, 149423292, 148243655, 147653814, 148964555, 145687766, 147588302, 151913670, 150340788];

                    infections = cell2mat(cellfun(@(x) permute(x{inf_channel}, [3, 1, 2]), parser.spatialOutput.channelTimeSeries(:), 'UniformOutput', false));
                    cc = ~ismember(nodes, [province_node, region_nodes]);
                    tmp = apply(@(x) find(x > 0, 1, 'last'), squeeze(sum(infections(:, cc, :), 2)), 1, 'UniformOutput', false);
                    if isempty(tmp)
                        tmp = zeros(size(inds2fill));
                    end
                    if iscell(tmp)
                        cc2 = cellfun(@isempty, tmp);
                        tmp(cc2) = {0};
                        tmp = cell2mat(tmp);
                    end
                    time_to_erad_outside_region = tmp;
                    
                   
                    
                    
					obj.outcomes_before_thresholding = time_to_erad_outside_region;
					obj.outcomes = time_to_erad_outside_region>33;
				end
			end
			
			if isempty(obj.outcomes)
				error(sprintf('%s:Missing', class(obj)), ...
					'Failed to obtain outcomes, perhaps because there was no parser named RSOParser');
			end
		end
	end
end