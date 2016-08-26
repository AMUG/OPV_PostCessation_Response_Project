function [] = immunity_to_csv()
%Rename columns and convert to csv for use in INLA smoothing
load immunity_type1.mat;

T1 = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\Africa_allAFP_2003_2010_aliased.xlsx');
T2 = readtable('\kevmc\AMUG_DataRepos\OPV_PostCessation_Response_NotForUpload\Africa_allAFP_2010_2015_aliased.xlsx');

ExpectedImmunity = zeros(numel(ExpImm), 1);
TimeIndex = zeros(numel(ExpImm), 1);
TimeIndex2 = zeros(numel(ExpImm), 1);
L2IDs = zeros(numel(ExpImm), 1);
L2Index = zeros(numel(ExpImm), 1);
L1IDs = zeros(numel(ExpImm), 1);
L1Index = zeros(numel(ExpImm), 1);
NObserved = zeros(numel(ExpImm), 1);
outTable = table(ExpectedImmunity, TimeIndex, TimeIndex2,L2IDs, L2Index, L1IDs, L1Index, NObserved);
 [~, ~, id1s] = unique(uniqueid1s);

for ii = 1:size(ExpImm, 2)
    fillInds = (1:size(ExpImm, 1)) + (ii-1)*size(ExpImm, 1);
    outTable.ExpectedImmunity(fillInds) = ExpImm(:, ii);
    outTable.NObserved(fillInds) = NObs(:, ii);
    outTable.TimeIndex(fillInds) = ii;
    outTable.TimeIndex2(fillInds) = ii;
    outTable.L2IDs(fillInds) = uniqueid2s;
    outTable.L1IDs(fillInds) = uniqueid1s;
    outTable.L2Index(fillInds) = (1:size(ExpImm, 1));
    outTable.L1Index(fillInds) = id1s;
    
end

writetable(outTable, 'Immunity_Type1.csv');
end