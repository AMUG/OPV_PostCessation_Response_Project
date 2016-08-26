function process(obj, parsers)
	% Plot inset chart channels 
    
    obj.check_parsers(parsers);
    obj.get_data(); 
    obj.likelihood_computation();

end



