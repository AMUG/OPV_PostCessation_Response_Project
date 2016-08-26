function [] = rjMake(chart, parse)
    rjClean(chart, parse)
    if (chart)
        mex -v -largeArrayDims -g LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:MSVSRT.lib /NODEFAULTLIB:LIBCMT.lib" ...
            -I.\include rjLoadChannelData.cpp common.cpp
        movefile('rjLoadChannelData.mexw64', '..');
    end
    
    if (parse)
        mex -v -largeArrayDims -g LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:MSVSRT.lib /NODEFAULTLIB:LIBCMT.lib" ...
            -I.\include rjParseJson.cpp common.cpp
        movefile('rjParseJson.mexw64', '..');
    end
end