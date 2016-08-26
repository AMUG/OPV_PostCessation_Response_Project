function [ obj ] = traverseMerge( objBase, oblOverlay, varargin )
%TRAVERSEMERGE Traverses an object composed of structures, arrays, and basic
%types
%
% [ obj ] = traverseMerge( objBase, oblOverlay, varargin )
%
%
%   define a merge operator,
% [ obj ] = traverseMerge( ..., 'MergeFunction', funcHandle)
%   func = @(objBase.leafnode, objOverlay.leafnode) function handle to apply to each node
%   Default=@(xBase, yOver) yOver
%
%   what type of merge operation on the data structure
% [ obj ] = traverseMerge( ..., 'MergeStructure', type)
%   type = 'Union', Default='Overlay'
%
%   choose when to apply merge if there is an empty value in a leafnode
% [ obj ] = traverseMerge( ..., 'MergeIfEmpty', object)
%   empty element occurs in object = 'Base', 'Overlay', 'NotBase', 'NotOverlay', 'Neither', Default='Any'
%

options = struct('mergefunction', @defaultOperator, 'mergestructure', 'Overlay', 'mergeifempty', 'Any');
%read optional parameters
for pair = reshape(varargin,2,[])
    inpName = lower(pair{1}); %make case insensitive
    if any(strcmp(inpName, fieldnames(options)))
        options.(inpName) = pair{2};
    else   error('MATLAB:initPolio', '%s is not a recognized parameter name.\n', inpName);
    end;
end;

funMergeIfEmpty = str2func( ['empty_' lower(options.mergeifempty)] );

[ obj ~ ] = do_tMerge( objBase, oblOverlay, lower(options.mergestructure), options.mergefunction, funMergeIfEmpty );
end


function y = defaultOperator(~, y)
end

function tf = empty_any(~, ~)
tf = true;
end

function tf = empty_neither(x, y)
tf = ~(isempty(x) || ~isempty(y));
end

function tf = empty_base(x, ~)
tf = isempty(x);
end

function tf = empty_overlay(~, y)
tf = isempty(y);
end

function tf = empty_notbase(x, ~)
tf = ~isempty(x);
end

function tf = empty_notoverlay(~, y)
tf = ~isempty(y);
end

function [ obj1 obj2] = do_tMerge( obj1, obj2, mergeStructure, mergeFunc, checkConditions)

if (isstruct(obj1))
    
    if(~isstruct(obj2)), return; end;
    [obj1 obj2] =  traverse_struct(obj1, obj2);
    
elseif (iscell(obj1))
    if(~iscell(obj2)), return; end;
    [obj1 obj2] = traverse_array(obj1, obj2);
    
elseif (isnumeric(obj1))
    if(~isnumeric(obj2)) % if conflict, take the overlay
        obj1 = obj2;
        return;
    end;
    
    if( checkConditions(obj1, obj2) )
        obj1 = mergeFunc(obj1, obj2); %num2str(obj,20);
    end
    
elseif (ischar(obj1))
    if(~ischar(obj2))
        obj1 = obj2;
        return;
    end;
    % json = ['"', obj,'"'];
    if( checkConditions(obj1, obj2) )
        obj1 = mergeFunc(obj1, obj2);
    end;
else
    
    error('traverseMerge:invalidObjectClass', 'Json encoding of class %s not supported', class(obj));
end;

    function [objX objY] = traverse_struct(objX, objY)
        
        fn = fieldnames(objX);
        for n = 1:length(fn)
            
            if(isfield(objY, fn{n}))
                objX.(fn{n}) = do_tMerge(objX.(fn{n}), objY.(fn{n}), mergeStructure, mergeFunc, checkConditions);
            end;
        end;
        if(strcmp(mergeStructure, 'union'))
            yFields = setdiff(fieldnames(objY), fn);
            for n = 1:length(yFields)
                objX.(yFields{n}) = objY.(yFields{n});
            end;
        end;
    end

    function [objX objY] = traverse_array(objX, objY)
        
        if(length(objX) ~= length(objY)) % if conflict, use overlay
            objX = objY;
            return;
        end;
        
        for n = 1:length(objX) % attempt to merge each element individually
            
            if(iscell(objX))
                
                objX{n} = do_tMerge(objX{n}, objY{n}, mergeStructure, mergeFunc, checkConditions);
            else
                
                objX(n) = do_tMerge(objX(n), objY{n}, mergeStructure, mergeFunc, checkConditions);
            end;
        end;
    end
end

