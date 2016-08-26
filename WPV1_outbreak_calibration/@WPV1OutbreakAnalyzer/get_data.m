function [] = get_data(obj)



datatable = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\Africa_allAFP_2003_2010_aliased.xlsx');


cc = inrange(datenum(datatable.DONSET, 'mm/dd/yyyy'), datenum('Jan-1-2003'), datenum('Jan-1-2010')) & ismember(datatable.id1, obj.countryIDs) & strcmpi(datatable.WildType, 'W1');
datatable = datatable(cc, :);

bins = datenum('Jan-1-2003'):30:datenum('Jan-1-2013');
[~, inds] = histc(datenum(datatable.DONSET, 'mm/dd/yyyy'), bins);

cases = zeros(length(obj.countryIDs), length(bins));
for ii = 1:length(obj.countryIDs);
    for jj = 1:length(bins)
        cases(ii, jj) = sum(inds(datatable.id1 == obj.countryIDs(ii))==jj);
    end
end


datatable = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\Africa_allAFP_2010_2015_aliased.xlsx');
cc = inrange(datenum(datatable.Paralysis_Onset_Date, 'dd/mm/yyyy'), datenum('Jan-1-2010'), datenum('Jan-1-2013'))  & ismember(datatable.id1, obj.countryIDs) & strcmpi(datatable.PolioVirusTypes, 'Wild 1');
datatable = datatable(cc, :);
[~, inds] = histc(datenum(datatable.Paralysis_Onset_Date, 'dd/mm/yyyy'), bins);

for ii = 1:length(obj.countryIDs);
    for jj = 1:length(bins)
        cases(ii, jj) = cases(ii, jj) + sum(inds(datatable.id1 == obj.countryIDs(ii))==jj);
    end
end

    obj.data = cases;

end