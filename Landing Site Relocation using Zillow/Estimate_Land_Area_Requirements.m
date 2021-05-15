%function to create a lookup table and figure out the land area
%requirements for the landing sites
function Estimate_Land_Area_Requirements(Region, Landing_Sites_Scenario)


% clc;
% clear all;
% close all;
% Region = 'SFO';
% Landing_Sites_Scenario = 199;
% Acre2Sqft = 43560;

Directory = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\',Region,'\'];

[numdata1] = xlsread('LandingPadRequirements','Revised_Pad');
save('Landing_Pad_Area_Requirements.txt','numdata1','-ASCII');
fid1 = fopen('Landing_Pad_Area_Requirements.txt');
data1 = textscan(fid1,'%f%f%f%f%f%f%f');
fclose(fid1);

%loading mat files with area requirements
load 'TLOF_Pad.mat';
load([Directory,num2str(Landing_Sites_Scenario),'_Landing_Sites_',Region,'.mat']);

%adding new column that has the land area requirements of the landing sites
for i = 1:Landing_Sites_Scenario
    %if i <= length(UAM_Landing_Sites)
        %code to estimate land area from the land area requirement mat files on the basis of number of TLOF pads and gates of each landing sites
        
        %figure out the indices in the TLOF_Pad table which correspond to
        %the given landing sites in the Vertiports struct array
        [~, Locb] = ismember([[UAM_Landing_Sites(i).TLOF_Pads]', [UAM_Landing_Sites(i).Gates]'], [[TLOF_Pad.TLOF_Pads]', [TLOF_Pad.Parking_Stalls]'],'rows');
        Area_Indices(i).Locb = Locb;
        Area_Indices(i).Hover_Taxi_Area_in_Acres = data1{5}(Locb); %corresponding area in sqft for hover taxi config
        Area_Indices(i).Ground_Taxi_Area_in_Acres = data1{7}(Locb); %corresponding area in sqft for ground taxi config
        
        %new column in Vertiports struct array for landing pad area
        %requirements in acres
        UAM_Landing_Sites(i).Hover_Taxi_Area_in_Acres = Area_Indices(i).Hover_Taxi_Area_in_Acres;
        UAM_Landing_Sites(i).Ground_Taxi_Area_in_Acres = Area_Indices(i).Ground_Taxi_Area_in_Acres;    
    %end
    geoshow(UAM_Landing_Sites(i).Origin_Lat,UAM_Landing_Sites(i).Origin_Long,'DisplayType','Point','Marker','*','MarkerEdgeColor','red','MarkerSize',15);
    hold on;
end
save([Directory,num2str(Landing_Sites_Scenario),'_Vertiports_',Region,'.mat'],'UAM_Landing_Sites');


return