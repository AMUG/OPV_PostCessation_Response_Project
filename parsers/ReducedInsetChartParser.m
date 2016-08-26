classdef ReducedInsetChartParser < IOutputFileParser
	properties(SetAccess=public)
		insetCharts
	end
	
	methods
		function obj = ReducedInsetChartParser(params, nPts, nRep)
			args = {[], 0, 0};
			if(nargin>=1)
				args{1} = params;
			end
			if(nargin==3)
				args{2} = nPts;
				args{3} = nRep;
			end
			
			obj = obj@IOutputFileParser(args{:});
			if(nargin == 3)
				obj.Initialize(nPts, nRep);
			end
		end
		
		function Initialize(obj, nPts, nRep)
			obj.Resize(nPts, nRep);
			obj.Reset();
		end
		
		function Reset(obj)
			obj.insetCharts.channelMap = [];	% Could save the channel map
			obj.haveEntry = false(obj.nPts, obj.nRep);
		end
		
		function Resize(obj, nPts, nRep)
			if(isempty(obj.insetCharts) || isempty(obj.nPts) || ...
					isempty(obj.nRep) || obj.nPts ~= nPts || ...
					obj.nRep ~= nRep)	% Could be more clever about allocation
				
				% Allocate memory
				myzeros = cell(nPts, nRep);
				
				obj.insetCharts.Header = myzeros;
				obj.insetCharts.ChannelTitles = myzeros;
				obj.insetCharts.ChannelData = myzeros;
				obj.insetCharts.ChannelUnits = myzeros;
				obj.insetCharts.TagString = myzeros;
				
				obj.haveEntry = false(nPts, nRep);
			end
			
			obj.nPts = nPts;
			obj.nRep = nRep;
		end
		
		function ParseStrings(obj, myStrings, tpi, rep, tagString)
			myString = myStrings{1};
			icStruct = parse_json(myString);
			obj.ParseStruct(icStruct, tpi, rep);
			obj.insetCharts.TagString{tpi,rep} = tagString;
            obj.ReduceCharts(tpi, rep);
		end
		
		function ParseFiles(obj, myFiles, tpi, rep, tagString)
			myFile = myFiles{1};
			icStruct = loadJson(myFile);
			obj.ParseStruct(icStruct, tpi, rep);
			obj.insetCharts.TagString{tpi,rep} = tagString;
            obj.ReduceCharts(tpi, rep);
		end
		
		function ParseStruct(obj, icStruct, tpi, rep)
			try
				if(isfield(icStruct, 'Header') && isfield(icStruct.Header, 'Report_Version') && icStruct.Header.Report_Version >= 2)
					obj.insetCharts.Header{tpi,rep}			= icStruct.Header;
					obj.insetCharts.ChannelTitles{tpi,rep}	= cellfun(@(x) strrep(x,'_',' '), fieldnames(icStruct.Channels), 'UniformOutput', false).';
					obj.insetCharts.ChannelData{tpi,rep}	= cellfun(@(x) cell2mat(icStruct.Channels.(x).Data).', fieldnames(icStruct.Channels), 'UniformOutput', false).';
					obj.insetCharts.ChannelUnits{tpi,rep}	= cellfun(@(x) icStruct.Channels.(x).Units, fieldnames(icStruct.Channels), 'UniformOutput', false).';
					
					if(isempty(obj.insetCharts.channelMap))
						obj.insetCharts.channelMap = containers.Map(obj.insetCharts.ChannelTitles{tpi,rep}, num2cell(1:length(obj.insetCharts.ChannelTitles{tpi,rep})) );
					end
					
					obj.haveEntry(tpi,rep) = true;
				else
					obj.insetCharts.ChannelTitles{tpi,rep}	= icStruct.ChannelTitles;
					obj.insetCharts.ChannelData{tpi,rep}	= cellfun(@(x) cell2mat(x).', icStruct.ChannelData, 'UniformOutput', false);
					obj.insetCharts.ChannelUnits{tpi,rep}	= icStruct.ChannelUnits;
					obj.haveEntry(tpi,rep) = true;

					if(isempty(obj.insetCharts.channelMap))
						obj.insetCharts.channelMap = containers.Map(icStruct.ChannelTitles, num2cell(1:length(icStruct.ChannelTitles)) );
					end
					
					if(isfield(icStruct, 'Header'))		% Not all simulations (e.g. HIV) have inset chart Header
						obj.insetCharts.Header{tpi,rep} = icStruct.Header;
					end
				end
			catch e
				obj.insetCharts.ChannelTitles{tpi,rep} = 'Failed';
				obj.insetCharts.ChannelData{tpi,rep} = [];
				obj.insetCharts.ChannelUnits{tpi,rep} = '';
				obj.haveEntry(tpi,rep) = false;
			end
        end
		
        function ReduceCharts(obj, tpi, rep)
            chartsToKeep = obj.params.Charts;
            numCharts = length(chartsToKeep);
            
            startTime = obj.params.StartTime;
            if obj.params.EndTime <=0 || obj.params.EndTime > length(obj.insetCharts.ChannelData{tpi, rep}{1})
                endTime = length(obj.insetCharts.ChannelData{tpi, rep}{1});
            else
                endTime = obj.params.EndTime;
            end
            
            reducedInsetCharts = struct('ChannelTitles', {cell(1, numCharts)}, 'ChannelData', {cell(1, numCharts)}, 'ChannelUnits', {cell(1, numCharts)});
            
            for currChart = 1:numCharts
                chartTitleMatch = strcmp(chartsToKeep{currChart}, obj.insetCharts.ChannelTitles{tpi, rep});
                if ~any(chartTitleMatch)
                    reducedInsetCharts.ChannelTitles{currChart} = ['Failed: No Inset Chart Channel named ' chartsToKeep{currChart}];
                    reducedInsetCharts.ChannelData{currChart} = [];
                    reducedInsetCharts.ChannelUnits{currChart} = '';
                else
                    reducedInsetCharts.ChannelTitles{currChart} = chartsToKeep{currChart};
                    reducedInsetCharts.ChannelData{currChart} = obj.insetCharts.ChannelData{tpi, rep}{chartTitleMatch}(startTime:endTime);
                    reducedInsetCharts.ChannelUnits{currChart} = obj.insetCharts.ChannelUnits{tpi, rep}{chartTitleMatch};
                
                end
            end
            obj.insetCharts.ChannelTitles{tpi, rep} = reducedInsetCharts.ChannelTitles;
            obj.insetCharts.ChannelData{tpi, rep} = reducedInsetCharts.ChannelData;
            obj.insetCharts.ChannelUnits{tpi, rep} = reducedInsetCharts.ChannelUnits;
            
        end
        
		function s = FilesToRetrieve(obj)
			s = obj.params.FilesToRetrieve;	% Should be 'Output\\InsetChart.json'
		end
		
		function p = GetParsedOutput(obj)
			p = obj.insetCharts;
		end
	end
end