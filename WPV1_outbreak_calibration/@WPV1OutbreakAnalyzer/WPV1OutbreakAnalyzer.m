% Intellectual Ventures Lab, 5/7/12
% Likelihood evaluator for Polio

classdef WPV1OutbreakAnalyzer < IAnalyzer
	properties
        config
        params
        data
        nPts
        nReps
        likelihood
        log_likelihood
        datafile_dir = '..\NotForUpload\';
        spatial_outputs
        parser
        demog
        demog_file = '\kevmc\AMUG_GitRepos\OPV_PostCessation_Response_Project\WPV1_outbreak_calibration\input\demographics\WestAfrica_ProvinceLevel_demographics.json';
        countries = {'Senegal', 'Mauritania', 'Sierra Leone', 'Guinea', 'Liberia', 'Ivory Coast', 'Mali', 'Burkina Faso', 'Ghana', ...
                'Togo', 'Benin', 'Niger', 'Nigeria', 'Cameroon', 'Chad', 'Central African Republic'};
        countryIDs = [288622, 288512, 288657, 288571, 288629, 288708, 288719, 288732, 288565, 288604, 288530, 288729, 288513, 288547, 288545, 288537];
    end
    
    properties(SetAccess=public)
        workingDir
    end
    
	methods
		function obj = WPV1OutbreakAnalyzer(config)
            obj.config = config;
            obj.params = config;           
        end        
        obj = parseTagStrings(obj, tagStr);
        obj = process(obj, parsers);
        obj = likelihood_computation(obj, parser);
        obj = get_data(obj);
        obj = accumulate_spatial_output(obj, parser);
    end
    methods (Static = true)
    end
end