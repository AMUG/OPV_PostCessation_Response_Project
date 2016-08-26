function [json, full_filename] = rapidLoad(filename)
	
	% To get the full filename:
	fid = fopen(filename);
	full_filename = fopen(fid);
	fclose(fid);

	% Now to rapid load
	json_mex_data = rjLoadChannelData(filename);
	
	filesize = size(json_mex_data.ChannelData);
	size1 = filesize(1);
	size2 = filesize(2);
	
	assimilated_mex_data_1 = mat2cell(json_mex_data.ChannelData,ones(1,size1),size2);
	assimilated_mex_data_2 = cellfun(@(x) mat2cell(x,1,ones(1,size2)), assimilated_mex_data_1, 'UniformOutput',false);
	
	
	json.ChannelTitles = json_mex_data.ChannelTitles';
	json.ChannelUnits = json_mex_data.ChannelUnits';
	json.ChannelData = assimilated_mex_data_2;
end