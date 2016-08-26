function [json, full_filename] = slowLoad(filename)

try
	fid = fopen(filename);
	
	full_filename = fopen(fid);
	
	% get size
	fseek(fid, 0,1);
	bytes = ftell(fid);
	fseek(fid,0,-1); % go back to beginning
	
	%s = textscan(fid,'%s','Delimiter','','whitespace','','bufsize',bytes);
	s = fscanf(fid, '%c',bytes);
	
	fclose(fid);
	json = parse_json(s);
catch e
	fprintf('slowLoad failed to load file: %s\n', filename);
	rethrow(e);
end

end