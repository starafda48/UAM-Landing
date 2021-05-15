%creating the mat file needed with the block group indices and their
%respective demand

%do the entire thing in the COMMAND WINDOW
load 'ODM_OD_Demand'
%file path for ODM_OD_Demand.mat
%ODM Demand Analysis\Output\Region\BlockGroup\Div 2 Iter 75/200
%4/6/7\Landing Sites Scenario Number\CPM_1.2/1.8\

load 'Valid_OD_Pairs_SFO'

%***IMPORTANT!!!!***
%before doing the next few lines first import
%"LODESBlockGroup2BlockGroupIndices.txt" using MATLAB's "Import" option and
%import it as a table

%file path for LODESBlockGroup2BlockGroupIndices.txt
%Census Tract Data\Output\Region\BlockGroup\Div 2 Iter 75/200
%4/6/7\

Valid_OD_Lodes = LODESBlockGroup2BlockGroupIndicesSFO(Valid_OD_Pairs.All,:);
Valid_OD_Pairs_Roundtrip = [table2array(Valid_OD_Lodes) ODM_OD_Demand.Person_Round_Trips];

%always save the mat files ending with study area names: SFO, LAX, DFW, NY
%and their CPM and Landing Sites No.
save('200_Valid_OD_Pairs_Roundtrip_1.2_SFO.mat','Valid_OD_Pairs_Roundtrip');