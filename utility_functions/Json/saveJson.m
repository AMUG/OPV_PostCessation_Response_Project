function [json] = saveJson(filename, json)

    fid = fopen(filename, 'w+'); % trash existing contents

    s = serialize_json(json);

    fwrite(fid,s);

    fclose(fid);

end