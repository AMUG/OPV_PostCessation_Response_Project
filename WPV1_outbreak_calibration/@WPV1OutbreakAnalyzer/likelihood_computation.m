function [] = likelihood_computation(obj)


obj.accumulate_spatial_output();

newinfs = obj.spatial_outputs.accum_new_infs;
cases = obj.data;

%newinfs = newinfs(:, :, 1:size(cases, 2));

%Begin the fitting in Jul 2007, end it in Jan 2010
%Both cases and newinfs begin on Jan-1-2003 and are binned into 30 day
%increments
startind = floor( (datenum('Jan-1-2008') - datenum('Jan-1-2003'))/30);
endind = ceil( (datenum('Jul-1-2010') - datenum('Jan-1-2003'))/30);

cases = cases(:, startind:endind);


newinfs = newinfs(:, :, 1:length(startind:endind));

%We shouldn't bother trying to fit outbreak sizes in this exercise, mostly aiming for
%rough outbreak timing.  Let's just sort of fit the "case-weighted mean
%time" for each province
% 
times = 1:size(cases,2 );
meancasetimes = sum(cases.*repmat(times, [size(cases, 1), 1]), 2)./(sum(cases, 2) + .05);
[~, casepeak] = max(cases(13, 1:15));
meaninftimes = sum(newinfs.*repmat(permute(times, [3, 1, 2]), [size(newinfs, 1), size(newinfs, 2), 1]), 3)./(sum(newinfs, 3)+.05);
meancasetimes = meancasetimes - casepeak;

[~, infpeak] = max(newinfs(:, 13, :), [], 3);
meaninftimes = meaninftimes - repmat(infpeak, [1, size(meaninftimes, 2), size(meaninftimes, 3)]);
% 
% %Use a simple sum of squared errors as an objective function (negative log of
%the value, since calibtool maximizes)
error = repmat(meancasetimes', [size(meaninftimes, 1), 1]) - meaninftimes;
sse = sum(error.^2, 2);



obj.log_likelihood = -10*log(sse);  %- to turn minimization into max.  10 is just a scaling factor preventing overly flat posterior, so that Calibtool doesn't converge too easily

obj.log_likelihood(isinf(obj.log_likelihood) | isnan(obj.log_likelihood)) = log(realmin);
obj.log_likelihood(obj.log_likelihood < log(realmin)) = log(realmin);
obj.likelihood = exp(obj.log_likelihood);


end


