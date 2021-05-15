clc;
clear all;
close all;

Region = 'SFO'; %'SFO'/'DFW'/'LAX'
Landing_Sites_Scenario = 206; %no. of landing sites set 50/75/100/200/300/400
CPM = 1.1; %cost per mile 1/1.1/1.2/.../3
boundary = sm2deg(0.5); %bufwidth of bufferm considers width in degrees of arc
No_of_Landing_Pads = 2; %if a vertiport has 2 or more pads,start looking for big enough land, if there's no land, split
No_of_splits = 2; %n is the number of splits a landing site will be split into in the k-means clustering method
Acre2Sqft = 43560; %1 Acre = 43,560 square feet
Taxi_Config = 'Ground_Taxi'; %switch between Ground_Taxi and Hover_Taxi

Directory = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\',Region,'\'];

%load excel spreadsheet with the coordinates of the different landing sites
%set
[numdata] = xlsread([Directory,num2str(Landing_Sites_Scenario),'_Landing_Sites_',num2str(CPM),'_',Region,'.xlsx'],'Sheet1');
%reading only numerical values of the data to the text file
save([Directory,num2str(Landing_Sites_Scenario),'_UAM_Landing_Sites_',num2str(CPM),'_',Region,'.txt'],'numdata','-ASCII');
%read the landing site data
fid = fopen([Directory,num2str(Landing_Sites_Scenario),'_UAM_Landing_Sites_',num2str(CPM),'_',Region,'.txt']);
data = textscan(fid,'%f%f%f%f%f%f%f%f%f',Landing_Sites_Scenario);
fclose(fid);

for i = 1:Landing_Sites_Scenario
    %save the data to a struct file under specific variable names
    UAM_Landing_Sites(i).Rank = data{1}(i); %ranked in descending order of 1-Way Person Roundtrips
    UAM_Landing_Sites(i).ID = data{2}(i);
    UAM_Landing_Sites(i).Origin_Lat = data{4}(i);
    UAM_Landing_Sites(i).Origin_Long = data{3}(i);
    UAM_Landing_Sites(i).Outbound_Person_Round_Trips = round(data{5}(i));
    UAM_Landing_Sites(i).Inbound_Person_Round_Trips = round(data{6}(i));
    UAM_Landing_Sites(i).Person_1Way_Trips = data{7}(i);
    UAM_Landing_Sites(i).TLOF_Pads = data{8}(i);
    UAM_Landing_Sites(i).Gates = data{9}(i);
end

save([Directory,num2str(Landing_Sites_Scenario),'_Landing_Sites_',Region,'.mat'],'UAM_Landing_Sites');

%function to estimate land arear requirements for landing sites
Estimate_Land_Area_Requirements(Region, Landing_Sites_Scenario);
load([Directory,num2str(Landing_Sites_Scenario),'_Vertiports_',Region,'.mat']);

% Landing_Pads = Vertiports.TLOF_Pads;
% if Landing_Pads >= No_of_Landing_Pads
%     %first finds all landing sites that can be split
%     Landing_Site_Split(Region, CPM, Landing_Sites_Scenario, boundary, No_of_Landing_Pads, n, Acre2Sqft, Taxi_Config);
%     if Landing_Pads < No_of_Landing_Pads
%         %then goes ahead and consolidates rest of the landing sites
%         Landing_Site_Consolidation(Region, CPM, Landing_Sites_Scenario, boundary, No_of_Landing_Pads, Acre2Sqft, Taxi_Config);
%     end
% end