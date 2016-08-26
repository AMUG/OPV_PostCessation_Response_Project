function [ obj ] = traverse( obj, order, func )
%TRAVERSE Traverses an object composed of structures, arrays, and basic
%types 
%   obj is the root of the data structure 
%   order  is 'preorder' or 'postorder' (no in-order traversal since nodes
%   can have >2 children
%   func is a function handle to apply to each node

if (strcmp(order,'preorder'))
    obj= func(obj); % preorder traversal
end

if (isstruct(obj))   
    obj =  traverse_struct(obj);
    
elseif (iscell(obj))
    obj = traverse_array(obj);
    
elseif (isnumeric(obj) && length(obj) > 1)
    obj = traverse_array(obj);
        
%elseif (isnumeric(obj))
    
%    obj = func(obj); %num2str(obj,20);
    
%elseif (ischar(obj))
    %json = ['"', obj,'"'];
%    obj = func(obj);
%else
%  error('encode_json:invalidObjectClass', 'Json encoding of class %s not supported', class(obj));
  
end

if (strcmp(order,'postorder'))
    obj = func(obj);
end

    
    function obj = traverse_struct(obj)
        
        fn = fieldnames(obj);        
        for n = 1:length(fn)
            
            obj.(fn{n}) = traverse(obj.(fn{n}), order, func);
        end
        
    end

    function obj = traverse_array(obj)
       
       for n = 1:length(obj)
           if (iscell(obj))
                obj{n} = traverse(obj{n}, order, func);            
           else
                obj(n) = traverse(obj(n), order, func);            
           end
          
       end
       
       
                
    end
    
end

