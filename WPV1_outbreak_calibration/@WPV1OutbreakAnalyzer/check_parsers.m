function [] = check_parsers(obj, parsers)
%This function checks for the existence of the parser, and may set flags
%for what to do with each
    
    for curr_parser=1:length(parsers)
        parserName = parsers{curr_parser}.Name;

        
        if( ~isempty(strfind(parserName, 'RSOParser')) )
            
            obj.parser = parsers{curr_parser};
            
        end
    end
end
