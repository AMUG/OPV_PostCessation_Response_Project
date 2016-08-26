function [ json ] = serialize_json( obj, tabspace )
%SERIALIZE_JSON Summary of this function goes here
%   Detailed explanation goes here

% JSON type         MATLAB class
%-------------------------------
% object            struct
% array             cell array
% 

if (~exist('tabspace', 'var'))
    tabspace = ''; % array of space characters that is adjusted as indentation/uindentation happens
end
newline = 10;


if (isempty(obj) && ~ischar(obj)) % djm: let empty strings be serialized as ""
	if( iscell(obj) )
		json = '[]';	% djk: empty 0x1 cell appears as [], was 'null'
	else
		json = '{}';	% djk: empty 0x0 (double) appears as {}, was 'null'
	end

elseif (isstruct(obj))   
   json =  serialize_struct(obj);

 elseif (iscell(obj))
    json = serialize_array(obj);

elseif (isnumeric(obj) && length(obj) > 1)
    json = serialize_array(obj);

elseif (isnumeric(obj) || islogical(obj))    
    json = num2str(obj,20);

elseif (ischar(obj))
    json = ['"', escape_string(obj),'"'];

else
    error('serialize_json:invalidObjectClass', 'Json serialization of class %s not supported', class(obj));  
end
    

    function json = serialize_struct(obj)
        outer_tabspace = tabspace;
        indent();
        fn = fieldnames(obj);
        out = {};
        for n = 1:length(fn)
            out{n} = ['"', fn{n},'": ', serialize_json(obj.(fn{n}),tabspace)];            
        end
 
        % join with proper ANNOYING json commas
        
        json = [newline outer_tabspace '{ ' newline, tabspace , join([',' newline tabspace] ,out), newline outer_tabspace '}'];
        unindent();       
    end

    function json = serialize_array(obj)
       out = {};
       outer_tabspace = tabspace;        
       indent();

       obj_sz = size(obj);
       if(obj_sz(1) == 1)
           curaxis_sz = obj_sz(2);
       else
           curaxis_sz = obj_sz(1);
       end
       
       for n = 1:curaxis_sz
           if(length(obj_sz) >= 3)
               element = reshape(obj(n,:), obj_sz(2:end));
           elseif(length(obj_sz) == 2)
               if(obj_sz(1) > 1)
                   element = obj(n,:);
               else
                   if(iscell(obj))
                       element = obj{n};
                   else
                       element = obj(n);
                   end
               end
           else
               error('do we ever get here?');
           end
           
           if(n == 1)
               firstel = element;
           end
           
           out{n} = serialize_json(element, tabspace);
       end
       
       if (iscell(firstel) || (isnumeric(firstel) && length(firstel) > 1))
           json = [newline, outer_tabspace, '[', newline, tabspace, join([', ' newline tabspace],out), newline, outer_tabspace, ']'];
       else
           json = ['[ ', join(', ',out), ' ]'];
       end
       
       unindent();
    end

    function [] = indent()
        tabspace = [tabspace '    '];
    end

    function [] = unindent()
        tabspace = tabspace(1:end-4); % error if you unindent too many times
    end

end

function s = escape_string(s)

    s = strrep(s, '"', '\"');
	s = strrep(s, '\', '\\');	% djk fix file paths in output
end
