function [json, full_filename] =generic_rapidload(filename)
	fid = fopen(filename);
	
	full_filename = fopen(fid);
	
	% get size
	fseek(fid, 0,1);
	bytes = ftell(fid);
	fseek(fid,0,-1); % go back to beginning
	
	%s = textscan(fid,'%s','Delimiter','','whitespace','','bufsize',bytes);
	s = fscanf(fid, '%c',bytes);
	
	fclose(fid);
	json =rjParseJson(filename);
end