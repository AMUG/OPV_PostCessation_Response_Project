function parseTagStrings(obj,tagStr)
	% Parse a tag string
	% The tagStr is a java map object
	
	obj.parsedTS = struct();
    
    %assume all sims in this experiment have same tag string format
    keys = toArray(keySet(tagStr{1}));
    for currKey = 1:length(keys)
        fieldname = matlab.lang.makeValidName(keys(currKey));
        obj.parsedTS.(fieldname) = cellfun(@(x) str2double(get(x, keys(currKey))), tagStr);
        if all(isnan(obj.parsedTS.(fieldname)))
            obj.parsedTS.(fieldname) = cellfun(@(x) get(x, keys(currKey)), tagStr, 'UniformOutput', false);
        end
    end
    
    
end
 
 