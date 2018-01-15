function [] = compile_results()
output_base = ('C:\Users\kmccarthy\Dropbox (IDM)\Repo\KM_OPV_PCR\OPV_response_WestAfrica_simulations\');
output_dirs = dir(output_base);

simconfigs = struct('R0_final',       zeros(length(output_dirs), 1), ...
    'R0_init',        zeros(length(output_dirs), 1), ...
    'R0_lambda',      zeros(length(output_dirs), 1), ...
    'campaign_type', {cell(length(output_dirs), 1)}, ...
    'migration_type',{cell(length(output_dirs), 1)});

figouts = struct('contour_line', {cell(length(output_dirs), 1)}, ...
    'surface', {cell(length(output_dirs), 1)}, ...
    'pos_points', {cell(length(output_dirs), 1)}, ...
    'neg_points', {cell(length(output_dirs), 1)});

ind2fill = 1;
for ii = 1:length(output_dirs)
        
    if strcmpi(output_dirs(ii).name, '.') || strcmpi(output_dirs(ii).name, '..') || ~exist([output_base '\' output_dirs(ii).name '\CSL.json'], 'file')
        continue
    end
    this_dir = [output_base '\' output_dirs(ii).name '\'];
    
    simconfigs = get_simouts(this_dir, simconfigs, ind2fill);
    figouts = get_figouts(this_dir, figouts, ind2fill);
        
    ind2fill = ind2fill+1;
    
end

simconfigs = clear_empties(simconfigs, ind2fill);
figouts = clear_empties(figouts, ind2fill);

save([output_base '\compiled_separatrices.mat'], 'simconfigs', 'figouts', '-v7.3');
end

function [thisstruct] = clear_empties(thisstruct, ind2clear)
    myfields = fieldnames(thisstruct);
    for ii = 1:length(myfields)
        thisstruct.(myfields{ii})(ind2clear:end) = [];
    end
end

function [sim_configs] = get_simouts(this_dir, sim_configs, ind2fill)
    CSL = loadJson([this_dir '\CSL.json']);
    
    sim_configs.R0_final(ind2fill) = CSL.EXPERIMENT.Tags.R0*4/5;  %Forgot to put age-dependent susceptibility correction factor when setting this tag
    sim_configs.R0_init(ind2fill) = CSL.EXPERIMENT.Tags.Infectivity_Exponential_Baseline;
    sim_configs.R0_lambda(ind2fill) = CSL.EXPERIMENT.Tags.Infectivity_Exponential_Rate;
    sim_configs.campaign_type{ind2fill} = CSL.EXPERIMENT.Tags.Campaign_File;
    sim_configs.migration_type{ind2fill} = CSL.EXPERIMENT.Tags.Gravity_Model_Distance_Dependence;
end

function [figouts] = get_figouts(this_dir, figouts, ind2fill)
    thisfig = openfig([this_dir '\iteration_2\Mode_N1000.fig'], 'invisible');
    figC = get(thisfig, 'children');
    thisax = [];
    for jj = 1:length(figC);
        if strcmpi(class(figC(jj)), 'matlab.graphics.axis.Axes')
            thisax = figC(jj);
        end
    end
    
    %Going to flip to put migration on Y, time since cessation on X
    if ~isempty(thisax)
        axC = get(thisax, 'Children');
        for jj = 1:length(axC)
            if strcmpi(class(axC(jj)), 'matlab.graphics.chart.primitive.Contour');
                figouts.contour_line{ind2fill}.Y = axC(jj).ContourMatrix(1, 2:end);
                figouts.contour_line{ind2fill}.X = axC(jj).ContourMatrix(2, 2:end);
            
            elseif strcmpi(class(axC(jj)), 'matlab.graphics.chart.primitive.Surface');
                figouts.surface{ind2fill}.YData = axC(jj).XData;
                figouts.surface{ind2fill}.XData = axC(jj).YData;
                figouts.surface{ind2fill}.ZData = axC(jj).ZData;

            elseif strcmpi(class(axC(jj)), 'matlab.graphics.chart.primitive.Line');
                if strcmpi(axC(jj).Marker, 'o')
                     figouts.neg_points{ind2fill}.X = get(axC(jj), 'YData');
                     figouts.neg_points{ind2fill}.Y = get(axC(jj), 'XData');
                elseif strcmpi(axC(jj).Marker, '+')
                     figouts.pos_points{ind2fill}.X = get(axC(jj), 'YData');
                     figouts.pos_points{ind2fill}.Y = get(axC(jj), 'XData');
                end
            end
        end        
    end
    close(thisfig);
end