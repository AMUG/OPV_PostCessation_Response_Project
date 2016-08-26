function [json, full_filename] = loadJson(filename)

[~, myname, ~] = fileparts(filename);

if strcmpi(myname, 'InsetChart' )
    try
        json = rapidLoad(filename);
    catch e
        warning('Tried to use rapid json, but it did not work!  Reverting to slow loadJson:');
        disp(e.message);
        [json, full_filename] = slowLoad(filename);
        
    end
    
elseif strcmpi(myname,'BinnedReport')
    try
		json = generic_rapidload(filename);
	catch e
		warning('Tried to use rapid json, but it did not work!  Reverting to slow loadJson:');
		disp(e.message);
		[json, full_filename] = slowLoad(filename);
    end

    
else
	
	[json, full_filename] = slowLoad(filename);
	
end

end