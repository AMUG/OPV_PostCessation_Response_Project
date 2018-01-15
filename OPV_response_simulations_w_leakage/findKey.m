function where = findKey(params, key_to_find, where, here)
% Script to parse a json structure and find a key
% Often used in experiment builders.
% This function has a recursive component

	if(nargin < 4)	% Reset
		where = {};
		here = {};
	end
	
	if iscell( params )
		for ci = 1:length(params)
			new_here = here; new_here{end+1} = ci;
			where = findKeyNonCell(params{ci}, key_to_find, where, new_here);
		end
	else
		where = findKeyNonCell(params, key_to_find, where, here);
	end
end

function where = findKeyNonCell(params, key_to_find, where, here)

	if ~isempty(where)	% Already found!
		return
	end

	try
		names = fieldnames(params);
		ret = find(strcmp(key_to_find, names), 1);
		if ~isempty(ret)
			where = here; where{end+1} = names{ret};
		end
	catch e
		return
	end
	
	nNames = length(names);
	for i=1:nNames	% Recurse
		new_here = here; new_here{end+1} = names{i};
		where = findKey(params.(names{i}), key_to_find, where, new_here);
	end
end