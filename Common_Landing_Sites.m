% find the common landing sites among sets of landing sites for a given
% region
clc;
clear all;
close all;

Region = 'DFW'; %'SFO'/'DFW'/'LAX'/'NY'
Landing_Sites_Set_1 = 49; %there are 3 landing sites set for each region
Landing_Sites_Set_2 = 102;
Landing_Sites_Set_3 = 209;
CPM_1 = 1.2; %there are 3 CPM corresponding to each landing sites set
CPM_2 = 0.95;
CPM_3 = 0.8;

Directory = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\',Region,'\'];

%load excel spreadsheet with the coordinates of the different landing sites
%set
[numdata1] = xlsread([Directory,num2str(Landing_Sites_Set_1),'_Landing_Sites_',num2str(CPM_1),'_',Region,'.xlsx'],'Sheet1');
%reading only numerical values of the data to the text file
save([Directory,num2str(Landing_Sites_Set_2),'_UAM_Landing_Sites_',num2str(CPM_1),'_',Region,'.txt'],'numdata1','-ASCII');
%read the landing site data
fid1 = fopen([Directory,num2str(Landing_Sites_Set_1),'_UAM_Landing_Sites_',num2str(CPM_1),'_',Region,'.txt']);
data1 = textscan(fid1,'%f%f%f%f%f%f%f%f%f',Landing_Sites_Set_1);
fclose(fid1);

%load excel spreadsheet with the coordinates of the different landing sites
%set
[numdata2] = xlsread([Directory,num2str(Landing_Sites_Set_2),'_Landing_Sites_',num2str(CPM_2),'_',Region,'.xlsx'],'Sheet1');
%reading only numerical values of the data to the text file
save([Directory,num2str(Landing_Sites_Set_2),'_UAM_Landing_Sites_',num2str(CPM_2),'_',Region,'.txt'],'numdata2','-ASCII');
%read the landing site data
fid2 = fopen([Directory,num2str(Landing_Sites_Set_2),'_UAM_Landing_Sites_',num2str(CPM_2),'_',Region,'.txt']);
data2 = textscan(fid2,'%f%f%f%f%f%f%f%f%f',Landing_Sites_Set_2);
fclose(fid2);

%load excel spreadsheet with the coordinates of the different landing sites
%set
[numdata3] = xlsread([Directory,num2str(Landing_Sites_Set_3),'_Landing_Sites_',num2str(CPM_3),'_',Region,'.xlsx'],'Sheet1');
%reading only numerical values of the data to the text file
save([Directory,num2str(Landing_Sites_Set_3),'_UAM_Landing_Sites_',num2str(CPM_3),'_',Region,'.txt'],'numdata3','-ASCII');
%read the landing site data
fid3 = fopen([Directory,num2str(Landing_Sites_Set_3),'_UAM_Landing_Sites_',num2str(CPM_3),'_',Region,'.txt']);
data3 = textscan(fid3,'%f%f%f%f%f%f%f%f%f',Landing_Sites_Set_3);
fclose(fid3);

[~, Loca] = ismember([[data1{4}], [data1{3}]],...
    [[data2{4}], [data2{3}]],'rows');

[~, Locb] = ismember([[data1{4}], [data1{3}]],...
    [[data3{4}], [data3{3}]],'rows');

[~, Locc] = ismember([[data2{4}], [data2{3}]],...
    [[data3{4}], [data3{3}]],'rows');