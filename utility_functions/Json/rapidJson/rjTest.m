function [chart, json] = rjTest()

    addpath('..');
    tests = 0;
    passed = 0;

    % rjLoadInsetChart tests
    
    %% missing filename test
    try
        tests = tests + 1;
        foo = rjLoadChannelData(); %#ok<NASGU>
        fprintf(2, 'FAILED missing filename test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED missing filename test.\n');
    end
    
    %% non-string argument test
    try
        tests = tests + 1;
        foo = rjLoadChannelData(42.0); %#ok<NASGU>
        fprintf(2, 'FAILED non-string argument test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED non-string argument test.\n');
    end

    %% invalid JSON test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\invalid.json'); %#ok<NASGU>
        fprintf(2, 'FAILED invalid JSON test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED invalid JSON test.\n');
    end
    
    %% missing file test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\nofile'); %#ok<NASGU>
        fprintf(2, 'FAILED missing file test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED missing file test.\n');
    end
    
    %% invalid format version test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartVBad.json'); %#ok<NASGU>
        fprintf(2, 'FAILED invalid format version test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED invalid format version test.\n');
    end
    
    %% invalid v1 chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV1Bad.json'); %#ok<NASGU>
        fprintf(2, 'FAILED invalid v1 chart test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED invalid v1 chart test.\n');
    end
    
    %% invalid v2 chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV2Bad.json'); %#ok<NASGU>
        fprintf(2, 'FAILED invalid v2 chart test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED invalid v2 chart test.\n');
    end
    
    %% V1 chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV1.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V1 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V1 chart test.\n');
    end
    
    %% V2 chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV2.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V2 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V2 chart test.\n');
    end
    
    %% V2A chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV2A.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V2 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V2A chart test.\n');
    end
    
    %% V3 chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV3.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V3 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V3 chart test.\n');
    end
    
    %% 1MB chart test
    try
        tests = tests + 1;
        tic;
        foo = rjLoadChannelData('sampleJson\InsetChart1Mb.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED 1MB chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED 1MB chart test.\n');
    end
    
    %% 4MB chart test
    try
        tests = tests + 1;
        tic;
        chart = rjLoadChannelData('sampleJson\InsetChart4Mb.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED 4MB chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED 4MB chart test.\n');
    end
    
    % rjParseJson tests
    
    %% missing filename test
    try
        tests = tests + 1;
        foo = rjParseJson(); %#ok<NASGU>
        fprintf(2, 'FAILED missing filename test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED missing filename test.\n');
    end
    
    %% non-string argument test
    try
        tests = tests + 1;
        foo = rjParseJson(42.0); %#ok<NASGU>
        fprintf(2, 'FAILED non-string argument test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED non-string argument test.\n');
    end

    %% invalid JSON test
    try
        tests = tests + 1;
        foo = rjParseJson('sampleJson\invalid.json'); %#ok<NASGU>
        fprintf(2, 'FAILED invalid JSON test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED invalid JSON test.\n');
    end
    
    %% missing file test
    try
        tests = tests + 1;
        foo = rjParseJson('sampleJson\nofile'); %#ok<NASGU>
        fprintf(2, 'FAILED missing file test.\n');
    catch except
        passed = passed + 1;
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf('PASSED missing file test.\n');
    end
    
    %% V1 chart test
    try
        tests = tests + 1;
        foo = rjParseJson('sampleJson\InsetChartV1.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V1 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V1 chart test.\n');
    end
    
    %% V2 chart test
    try
        tests = tests + 1;
        foo = rjParseJson('sampleJson\InsetChartV2.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V2 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V2 chart test.\n');
    end
    
    %% V3 chart test
    try
        tests = tests + 1;
        foo = rjParseJson('sampleJson\InsetChartV3.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V3 chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V3 chart test.\n');
	end
	
	%% V3 Edward chart test
    try
        tests = tests + 1;
        foo = rjLoadChannelData('sampleJson\InsetChartV3Edward.json'); %#ok<NASGU>
        passed = passed + 1;
        fprintf('PASSED V3 Edward chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED V3 Edward chart test.\n');
    end
    
    %% 1MB chart test
    try
        tests = tests + 1;
        tic;
        foo = rjParseJson('sampleJson\InsetChart1Mb.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED 1MB chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED 1MB chart test.\n');
    end
    
    %% 4MB chart test
    try
        tests = tests + 1;
        tic;
        json = rjParseJson('sampleJson\InsetChart4Mb.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED 4MB chart test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED 4MB chart test.\n');
    end
    
    %% simple boolean test
    try
        tests = tests + 1;
        test = rjParseJson('sampleJson\boolean.json');
        if (test.boolean && ~test.false)
            passed = passed + 1;
            fprintf('PASSED simple boolean test.\n');
        else
            fprintf(2, 'FAILED simple boolean test.\n');
        end
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED simple boolean test.\n');
    end
    
    %% null value test
    try
        tests = tests + 1;
        test = rjParseJson('sampleJson\null.json');
        dimensions = size(test.nothing);
        if ((dimensions(1) == 0) && (dimensions(2) == 0))
            passed = passed + 1;
            fprintf('PASSED null value test.\n');
        else
            fprintf(2, 'FAILED null value test.\n');
        end
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED null value test.\n');
    end
    
    %% scalar value test
    try
        tests = tests + 1;
        test = rjParseJson('sampleJson\scalar.json');
        if (test.scalar == 42)
            passed = passed + 1;
            fprintf('PASSED scalar value test.\n');
        else
            fprintf(2, 'FAILED scalar value test.\n');
        end
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED scalar value test.\n');
    end
    
    %% string value test
    try
        tests = tests + 1;
        test = rjParseJson('sampleJson\string.json');
        if (strcmp(test.string, 'Hello, MATLAB!'))
            passed = passed + 1;
            fprintf('PASSED string value test.\n');
        else
            fprintf(2, 'FAILED string value test.\n');
        end
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED string value test.\n');
    end
    
    %% CMS config test
    try
        tests = tests + 1;
        tic;
        test = rjParseJson('sampleJson\cmsConfig.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED CMS config test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED CMS config test.\n');
    end
    
    %% DTK campaign test
    try
        tests = tests + 1;
        tic;
        test = rjParseJson('sampleJson\dtkCampaign.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED DTK campaign test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED DTK campaign test.\n');
    end
    
    %% DTK config test
    try
        tests = tests + 1;
        tic;
        test = rjParseJson('sampleJson\dtkConfig.json'); %#ok<NASGU>
        toc;
        passed = passed + 1;
        fprintf('PASSED DTK config test.\n');
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED DTK config test.\n');
    end
    
    %% heterogeneous array test
    try
        tests = tests + 1;
        tic;
        test = rjParseJson('sampleJson\heterogeneousArray.json');
        toc;
        if (iscell(test) && islogical(test{1}) && islogical(test{2}) && isnumeric(test{4}) && ischar(test{5}) && isstruct(test{6}) && isnumeric(test{7}))
            passed = passed + 1;
            fprintf('PASSED heterogeneous array test.\n');
        else
            fprintf(2, 'FAILED heterogeneous array test.\n');
        end
    catch except
        fprintf('Caught exception "%s - %s".\n', except.identifier, except.message);
        fprintf(2, 'FAILED heterogeneous array test.\n');
    end
    
    %% finished
    fprintf('Executed %d tests. %d passed.\n', tests, passed);
end