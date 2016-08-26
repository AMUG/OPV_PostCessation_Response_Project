function [] = compute_immunity_type1()

effT = 0.194;
effB = 0.295;
effM = 0.321;

T1 = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\Africa_allAFP_2003_2010_aliased.xlsx');
T2 = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\NotForUpload\Africa_allAFP_2010_2015_aliased.xlsx');

countryIDs = [288622, 288512, 288657, 288571, 288629, 288708, 288719, 288732, 288565, 288604, 288530, 288729, 288513, 288547, 288545, 288537];

T1 = T1(ismember(T1.id1, countryIDs), :);
T2 = T2(ismember(T2.id1, countryIDs), :);

T2 = T2(~strcmpi(T2.Classification, 'Not An AFP'), :);
time_bins = linspace(datenum('Jan-1-2003'), datenum('Dec-31-2015'), 27);

[~, ~, T1.tbin] = histcounts(datenum(T1.DONSET), time_bins);
[~, ~, T2.tbin] = histcounts(datenum(T2.Paralysis_Onset_Date, 'dd/mm/yyyy'), time_bins);

[~, ~, T1.id1ind] = unique(T1.id1);
[~, ~, T2.id1ind] = unique(T2.id1);
T1.id2 = str2double(T1.id2);
T2.id2 = str2double(T2.id2);
uniqueid2s = unique([T1.id2; T2.id2]);
uniqueid2s(isnan(uniqueid2s)) = [];
uniqueid1s = zeros(size(uniqueid2s));

[~, T1.id2ind] = ismember(T1.id2, uniqueid2s);
[~, T2.id2ind] = ismember(T2.id2, uniqueid2s);
CTable = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\CampaignActivities_2005_2016_aliased.xlsx');
CTable.campaign_datenum = datenum(CTable.Parent_Start, 'dd/mm/yyyy');

ExpImm = zeros(length(uniqueid2s), length(time_bins)-1);
NObs = ExpImm;

T1.DONSETnum = datenum(T1.DONSET, 'mm/dd/yyyy');
T2.Paralysis_Onset_Datenum = datenum(T2.Paralysis_Onset_Date, 'dd/mm/yyyy');
T2.CalculatedAgeInMonth = str2double(T2.CalculatedAgeInMonth);
T2.Doses_Total = str2double(T2.Doses_Total);
T1.DOSES = str2double(T1.DOSES);
for provInd = 1:length(uniqueid2s)
    if mod(provInd, 10) == 0;
        disp(['On province ' num2str(provInd) ' of ' num2str(length(uniqueid2s))]);
    end
    for timeInd = 1:(length(time_bins)-1)
        %Grab all of the non-polio AFP cases in this province and time bin
        nDoses = nan*ones(10000, 1);
        Ages = nan*ones(10000, 1);
        onset = nan*ones(10000, 1);
        cc = T1.id2ind == provInd & T1.tbin == timeInd & cellfun(@isempty, T1.WildType) & cellfun(@isempty, T1.VDPVType);
        if any(cc)
            inds2fill = find(isnan(nDoses), 1, 'first') + (1:(sum(cc))) - 1;
            tmpDoses = T1.DOSES(cc);
            tmpDoses(isnan(tmpDoses)) = 0;
            nDoses(inds2fill) =  tmpDoses;
            Ages(inds2fill) =  T1.Age_month(cc);
            onset(inds2fill) =  T1.DONSETnum(cc);
        end
        cc = T2.id2ind == provInd & T2.tbin == timeInd & cellfun(@isempty, T2.PolioVirusTypes);
        if any(cc)
            inds2fill = find(isnan(nDoses), 1, 'first') + (1:(sum(cc))) - 1;
            tmpDoses = T2.Doses_Total(cc);
            tmpDoses(isnan(tmpDoses)) = 0;
            nDoses(inds2fill) =  tmpDoses;
            
            tmpAges = T2.CalculatedAgeInMonth(cc);
            tmpAges(isnan(tmpAges)) = 0;
            Ages(inds2fill) =tmpAges;
            onset(inds2fill) = T2.Paralysis_Onset_Datenum(cc);
        end
        frac_count = ones(sum(~isnan(nDoses)), 1);
        
        %Now look for cases that are in the country but not mapped to any
        %province
        countryInd = unique([ T1.id1ind(T1.id2ind == provInd); T2.id1ind(T2.id2ind == provInd)]);
        countryID = unique([ T1.id1(T1.id1ind == countryInd); T2.id1(T2.id1ind == countryInd) ]);
        cc = T1.id2ind == 0 & T1.tbin == timeInd & T1.id1ind == countryInd;
        uniqueid1s(provInd) = countryID;
        if any(cc)
            inds2fill = find(isnan(nDoses), 1, 'first') + (1:(sum(cc))) - 1;
            tmpDoses = T1.DOSES(cc);
            tmpDoses(isnan(tmpDoses)) = 0;
            nDoses(inds2fill) =  tmpDoses;
            
            Ages(inds2fill) =  T1.Age_month(cc);
            onset(inds2fill) = T1.DONSETnum(cc);
        end
        %Weight it down by the number of provinces 
        frac_count = [frac_count; ones(sum(cc), 1)./length(unique(T1.id2ind(T1.id1ind == countryInd)))];
        
        cc = T2.id2ind == 0 & T2.tbin == timeInd & T2.id1ind == countryInd;
        if any(cc)
            inds2fill = find(isnan(nDoses), 1, 'first') + (1:(sum(cc))) - 1;
            tmpDoses = T2.Doses_Total(cc);
            tmpDoses(isnan(tmpDoses)) = 0;
            nDoses(inds2fill) =  tmpDoses;
            
            tmpAges = T2.CalculatedAgeInMonth(cc);
            tmpAges(isnan(tmpAges)) = 0;
            Ages(inds2fill) =tmpAges;
            onset(inds2fill) = T2.Paralysis_Onset_Datenum(cc);
        end
        %Weight it down by the number of provinces 
        frac_count = [frac_count; ones(sum(cc), 1)./length(unique(T2.id2ind(T2.id1ind == countryInd)))];
                
        NObs(provInd, timeInd) = sum(frac_count);

        if all(isnan(nDoses))
            ExpImm(provInd, timeInd) = NaN;
        else

            %OK, now I've got all the doses for this province and time bin, and
            %fractional counts for the country and time bin unmapped to any
            %province.  Time to map the fractional dose amount due to exposure
            %to m/bOPV campaigns.
            effFactor = effT*ones(size(frac_count));
            for currCase = 1:length(effFactor)
                cc = CTable.id1 == countryID;
                timecut = CTable.campaign_datenum < onset(currCase) & CTable.campaign_datenum > (onset(currCase) - 30*Ages(currCase));
                numT = 0.5+sum(strcmpi(CTable.Vaccine_Type(cc & timecut), 'tOPV'));
                numB = sum(strcmpi(CTable.Vaccine_Type(cc & timecut), 'bOPV'));
                numM = sum(strcmpi(CTable.Vaccine_Type(cc & timecut), 'mOPV1'));
                denom = numT + numB + numM;
                effFactor(currCase) = ( (1-effT)*numT + (1-effB)*numB + (1-effM)*numM )/(denom);                
            end
            ExpImm(provInd, timeInd) = sum(frac_count.*( 1 - (effFactor).^min(nDoses(~isnan(nDoses)), 20) ))./sum(frac_count);
        end
    end
end
save('immunity_type1.mat', 'ExpImm', 'uniqueid2s', 'time_bins', 'uniqueid1s', 'NObs')



end
