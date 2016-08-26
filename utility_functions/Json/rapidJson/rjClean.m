function [] = rjClean(chart, parse)
    if (chart)
        delete('..\rjLoadChannelData.mexw64');
        delete('rjLoadChannelData.mexw64.pdb');
    end
    if (parse)
        delete('..\rjParseJson.mexw64');
        delete('rjParseJson.mexw64.pdb');
    end
end