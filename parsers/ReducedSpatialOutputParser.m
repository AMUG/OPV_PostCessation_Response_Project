classdef ReducedSpatialOutputParser < IOutputFileParser
	properties(SetAccess=private)
		spatialOutput
	end
	
	methods
		function obj = ReducedSpatialOutputParser(params, nPts, nRep)
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
			obj.spatialOutput.nodeIDList = [];
			obj.spatialOutput.channelTimeSeries = [];
			
			obj.haveEntry = false(obj.nPts, obj.nRep);
		end
		
		function Resize(obj, nPts, nRep)
			if(isempty(obj.spatialOutput) || isempty(obj.nPts) || ...
					isempty(obj.nRep) || obj.nPts ~= nPts || ...
					obj.nRep ~= nRep)	% Could be more clever about allocation
				
				% Allocate memory
				myzeros = cell(nPts, nRep);
				
				obj.spatialOutput.nodeIDList = myzeros;
				obj.spatialOutput.channelTimeSeries = myzeros;
				
				obj.haveEntry = false(nPts, nRep);
			end
			
			obj.nPts = nPts;
			obj.nRep = nRep;
		end
		
		function ParseStrings(obj, myStrings, tpi, rep)
			error('ReducedSpatialOutputParser:ParseStrings', 'Spatial output parser is currently incompatible with parsing strings, use DirectOutputFileAccess=true instead.');
			% 			myString = myStrings{1};
			% 			icStruct = parse_json(myString);
			% 			obj.ParseStruct(icStruct, tpi, rep);
		end
		
		function ParseFiles(obj, myFiles, tpi, rep)
			nFiles = length(myFiles);
			obj.spatialOutput.channelTimeSeries{tpi,rep} = cell(nFiles,1);
			obj.spatialOutput.nodeIDList{tpi,rep} = cell(nFiles,1);
			for i=1:nFiles
				[obj.spatialOutput.channelTimeSeries{tpi,rep}{i}, obj.spatialOutput.nodeIDList{tpi,rep}{i}] = obj.read_channel( myFiles{i} );
                obj.spatialOutput.channelTimeSeries{tpi,rep}{i} = obj.ReduceOutput(obj.spatialOutput.channelTimeSeries{tpi,rep}{i});
				[~,b,~] = fileparts(myFiles{i});
				obj.spatialOutput.channelTitle{tpi,rep}{i} = b(15:end);
			end
			obj.haveEntry(tpi,rep) = true;
		end
		
		function [timeSpaceData, nodeIDs] = read_channel(obj, file_path)
			
			fid	= fopen(file_path);
			
			nNodes			= fread(fid, 1, 'int32=>int32');
			nTimeSteps		= fread(fid, 1, 'int32=>int32');
			nodeIDs			= fread(fid, nNodes, 'int32=>int32');
			
			timeSpaceData	= fread(fid, [nNodes, nTimeSteps], 'float32=>float32'); % file is written by DTK in time-major order, so rows are nodes and columns are time steps. (all nodes are written out following each timestep)
			
			fclose(fid);
        end
		
        function reduced_timeseries = ReduceOutput(obj, full_timeseries)
            inds = ceil( (1:size(full_timeseries,2))/(obj.params.DaysToAggregate));
            reduced_timeseries = dimfunc(@(x) accumarray(inds', x), full_timeseries, 2, max(inds));
            reduced_timeseries = reduced_timeseries/obj.params.DaysToAggregate;
            reduced_timeseries(:, end) = reduced_timeseries(:, end) * obj.params.DaysToAggregate / sum(inds==max(inds));
        end
        
		function s = FilesToRetrieve(obj)
			s = obj.params.FilesToRetrieve;
		end
		
		function p = GetParsedOutput(obj)
			p = obj.spatialOutput;
		end
	end
end