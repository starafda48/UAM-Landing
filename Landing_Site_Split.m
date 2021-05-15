%This script is written to find and split the original landing sites
%which are generated from the demand responsive block group analysis
%Sayantan Tarafdar, July 2019

%function Landing_Site_Split(Region, CPM, Landing_Sites_Scenario, boundary, No_of_Landing_Pads, n, Acre2Sqft, Taxi_Config)


clc;
clear all;
close all;
Region = 'SFO'; %'SFO'/'DFW'/'LAX'
CPM = 1.1; %cost per mile 1/1.1/1.2/.../3
Landing_Sites_Scenario = 206; %no. of landing sites set 50/75/100/200/300/400
boundary = sm2deg(0.5); %bufwidth of bufferm considers width in degrees of arc
No_of_Landing_Pads = 2; %if a vertiport has 2 or more pads,start looking for big enough land, if there's no land, split
No_of_splits = 2; %n is the number of splits a landing site will be split into in the k-means clustering method
Acre2Sqft = 43560; %1 Acre = 43,560 square feet
Taxi_Config = 'Ground_Taxi'; %switch between Ground_Taxi and Hover_Taxi

Directory = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\',Region,'\'];
Zillow_Asmt_Dir = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\Zillow Asmt Data\'];

load([Directory,num2str(Landing_Sites_Scenario),'_Vertiports_',Region,'.mat']);
load([Zillow_Asmt_Dir,Region,'_Asmt_Cleaned.mat']);

%load excel spreadsheet with the geoids and centroids of the block groups from the last iteration
[numdata2] = xlsread([Directory,'BlockGroup_Population_Centroids_',Region,'.xlsx'],'BlockGroup_Population_Centroids');
save([Directory,'BlockGroup_Population_Centroids_',Region,'.txt'],'numdata2','-ASCII');
fid2 = fopen([Directory,'BlockGroup_Population_Centroids_',Region,'.txt']); %read the landing site data
data2 = textscan(fid2,'%f%f%f%f');
fclose(fid2);
%loading mat file containing indices of home and work block groups along with their corresponding roundtrip demand
load ([Directory,num2str(Landing_Sites_Scenario),'_Valid_OD_Pairs_Roundtrip_',num2str(CPM),'_',Region,'.mat']);
%creating table with the demand from Block Groups
BlockGroup_Population_Centroid = table();
BlockGroup_Population_Centroid.Index = data2{1};
BlockGroup_Population_Centroid.Geoid = data2{2};
BlockGroup_Population_Centroid.PopCentroid_Lat = data2{4};
BlockGroup_Population_Centroid.PopCentroid_Long = data2{3};
Num_BG = length(data2{1});
Outgoing_Trips = zeros(Num_BG,1);
Incoming_Trips = zeros(Num_BG,1);
Total_Demand = zeros(Num_BG,1);
for j = 1:Num_BG
    IND1 = ismember(Valid_OD_Pairs_Roundtrip(:,1),j);
    Outgoing_Trips(j) = sum(Valid_OD_Pairs_Roundtrip(IND1,3));
    IND2 = ismember(Valid_OD_Pairs_Roundtrip(:,2),j);
    Incoming_Trips(j) = sum(Valid_OD_Pairs_Roundtrip(IND2,3));
    Total_Demand = Outgoing_Trips + Incoming_Trips;
end
BlockGroup_Population_Centroid.Incoming_Trips = Incoming_Trips;
BlockGroup_Population_Centroid.Outgoing_Trips = Outgoing_Trips;
BlockGroup_Population_Centroid.Total_Demand = Total_Demand;

for i = 1:Landing_Sites_Scenario
    %if i <= length(Landing_Sites_Scenario)
    if  UAM_Landing_Sites(i).TLOF_Pads >= No_of_Landing_Pads
        %save the coordinates and data of the sites which have more than n number of TLOF pads
        UAM_Sites_thatcanbe_Split(i).Rank = UAM_Landing_Sites(i).Rank;
        UAM_Sites_thatcanbe_Split(i).ID = UAM_Landing_Sites(i).ID;
        UAM_Sites_thatcanbe_Split(i).Origin_Lat = UAM_Landing_Sites(i).Origin_Lat;
        UAM_Sites_thatcanbe_Split(i).Origin_Long =  UAM_Landing_Sites(i).Origin_Long;
        UAM_Sites_thatcanbe_Split(i).Outbound_Person_Round_Trips = UAM_Landing_Sites(i).Outbound_Person_Round_Trips;
        UAM_Sites_thatcanbe_Split(i).Inbound_Person_Round_Trips = UAM_Landing_Sites(i).Inbound_Person_Round_Trips;
        UAM_Sites_thatcanbe_Split(i).Person_1Way_Trips = UAM_Landing_Sites(i).Person_1Way_Trips;
        UAM_Sites_thatcanbe_Split(i).TLOF_Pads = UAM_Landing_Sites(i).TLOF_Pads;
        UAM_Sites_thatcanbe_Split(i).Gates = UAM_Landing_Sites(i).Gates;
        if strcmp(Taxi_Config,'Hover_Taxi')
            UAM_Sites_thatcanbe_Split(i).Hover_Taxi_Area_in_Acres = UAM_Landing_Sites(i).Hover_Taxi_Area_in_Acres;
        elseif strcmp(Taxi_Config,'Ground_Taxi')
            UAM_Sites_thatcanbe_Split(i).Ground_Taxi_Area_in_Acres = UAM_Landing_Sites(i).Ground_Taxi_Area_in_Acres;
        end
        
        geoshow(UAM_Sites_thatcanbe_Split(i).Origin_Lat,UAM_Sites_thatcanbe_Split(i).Origin_Long,'DisplayType','Point','Marker','*','MarkerEdgeColor','red','MarkerSize',20);
        hold on;
        [lata,lona] = bufferm(UAM_Sites_thatcanbe_Split(i).Origin_Lat,UAM_Sites_thatcanbe_Split(i).Origin_Long,boundary,'out',100);
        UAM_Sites_thatcanbe_Split(i).Boundary.Latitude = lata;
        UAM_Sites_thatcanbe_Split(i).Boundary.Longitude = lona;
        geoshow(lata,lona,'DisplayType','Polygon','FaceColor','none');
        hold on;
        
        in = inpolygon(Zillow_Asmt.Latitude,Zillow_Asmt.Longitude,lata,lona); %check how many plots of Zillo Assessment data are within 0.5 sm boundary
        %saves all Zillow data and their properties within 0.5 sm boundary
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Count = numel(Zillow_Asmt.Latitude(in));
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.County = Zillow_Asmt.County(in);
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Lat = Zillow_Asmt.Latitude(in);
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Long = Zillow_Asmt.Longitude(in);
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.LotSize_Acres = Zillow_Asmt.LotSize_Acres(in);
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.LotSize_SqFt = Zillow_Asmt.LotSize_SqFt(in);
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Stories = Zillow_Asmt.Stories(in);
        UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Land_Use_Type = Zillow_Asmt.Land_Use_Type(in);
        
        %finds all Zillow data that satisfies the land area requirements for the landing sites
        if strcmp(Taxi_Config,'Hover_Taxi')
            land_area_satisfied = find(Zillow_Asmt.LotSize_Acres(in) >= UAM_Sites_thatcanbe_Split(i).Hover_Taxi_Area_in_Acres);
        elseif strcmp(Taxi_Config,'Ground_Taxi')
            land_area_satisfied = find(Zillow_Asmt.LotSize_Acres(in) >= UAM_Sites_thatcanbe_Split(i).Ground_Taxi_Area_in_Acres);
        end
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Indices = land_area_satisfied;
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.County = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.County(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Lat = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Lat(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Long = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Long(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.LotSize_Acres = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.LotSize_Acres(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.LotSize_SqFt = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.LotSize_SqFt(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Stories = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Stories(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Land_Use_Type = UAM_Sites_thatcanbe_Split(i).Zillow_inside_Boundary.Land_Use_Type(land_area_satisfied);
        UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req = struct2table(UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req);
        
        geoshow(UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Lat,UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req.Long,'DisplayType','Point','Marker','o','MarkerEdgeColor','blue','MarkerSize',15);
        hold on;
        %if there are no available land to place the big sites, Split them, otherwise don't. Either way save results from both to a
        %mat file, so that it can be loaded and used in the next phase of the analysis where landing sites are Split using K-Means Clustering
        if isempty(UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req)
            %if  Vertiports(i).TLOF_Pads >= No_of_TLOF_Pads save the coordinates and data of the sites which have more than n number of TLOF pads
            UAM_Split(i).Rank = UAM_Sites_thatcanbe_Split(i).Rank;
            UAM_Split(i).ID = UAM_Sites_thatcanbe_Split(i).ID;
            UAM_Split(i).Origin_Lat = UAM_Sites_thatcanbe_Split(i).Origin_Lat;
            UAM_Split(i).Origin_Long =  UAM_Sites_thatcanbe_Split(i).Origin_Long;
            UAM_Split(i).Outbound_Person_Round_Trips = UAM_Sites_thatcanbe_Split(i).Outbound_Person_Round_Trips;
            UAM_Split(i).Inbound_Person_Round_Trips = UAM_Sites_thatcanbe_Split(i).Inbound_Person_Round_Trips;
            UAM_Split(i).Person_1Way_Trips = UAM_Sites_thatcanbe_Split(i).Person_1Way_Trips;
            UAM_Split(i).TLOF_Pads = UAM_Sites_thatcanbe_Split(i).TLOF_Pads;
            UAM_Split(i).Gates = UAM_Sites_thatcanbe_Split(i).Gates;
            if strcmp(Taxi_Config,'Hover_Taxi')
                UAM_Split(i).Hover_Taxi_Area_in_Acres = UAM_Sites_thatcanbe_Split(i).Hover_Taxi_Area_in_Acres;
            elseif strcmp(Taxi_Config,'Ground_Taxi')
                UAM_Split(i).Ground_Taxi_Area_in_Acres = UAM_Sites_thatcanbe_Split(i).Ground_Taxi_Area_in_Acres;
            end
            
            % displaying the map of the landing sites that will be split along with the boundary around them
            [lata,lona] = bufferm(UAM_Split(i).Origin_Lat,UAM_Split(i).Origin_Long,boundary,'out',100);
            geoshow(lata,lona,'DisplayType','Polygon','FaceColor','none');
            hold on;

            %calculating distance of block group centroids to the landing sites
            arclen_1 = distance(data2{4},data2{3},UAM_Split(i).Origin_Lat,UAM_Split(i).Origin_Long);
            dist_in_sm = deg2sm(arclen_1);
            dist_less_than_half_sm = find(dist_in_sm <= deg2sm(boundary)); %finds the indices of block group centroids in the 0.5 sm boundary
            UAM_Split(i).Dist_from_other_BlockGroups = dist_in_sm; %save both the distances and indices
            
            %saves the latitudes, longitudes, demands of block group centroids which fall within the 0.5 sm boundary of the corresponding landing site
            UAM_Split(i).BlockGroups_Halfsm.Index = dist_less_than_half_sm;
            UAM_Split(i).BlockGroups_Halfsm.Geoid = data2{2}(dist_less_than_half_sm);
            UAM_Split(i).BlockGroups_Halfsm.Lat = data2{4}(dist_less_than_half_sm);
            UAM_Split(i).BlockGroups_Halfsm.Long = data2{3}(dist_less_than_half_sm);
            UAM_Split(i).BlockGroups_Halfsm.Dist = dist_in_sm(dist_in_sm <= deg2sm(boundary));
            UAM_Split(i).BlockGroups_Halfsm.Incoming_Trips = Incoming_Trips(dist_less_than_half_sm);
            UAM_Split(i).BlockGroups_Halfsm.Outgoing_Trips = Outgoing_Trips(dist_less_than_half_sm);
            UAM_Split(i).BlockGroups_Halfsm.Total_Demand = Total_Demand(dist_less_than_half_sm);
            UAM_Split(i).BlockGroups_Halfsm = struct2table(UAM_Split(i).BlockGroups_Halfsm);
            
            %count number of rows i.e. counts number of block groups in 0.5 sm radius
            UAM_Split(i).Length_BlockGroupsHalfsm = size(UAM_Split(i).BlockGroups_Halfsm,1);
            geoshow(UAM_Split(i).BlockGroups_Halfsm.Lat,UAM_Split(i).BlockGroups_Halfsm.Long,'DisplayType','Point','Marker','o','MarkerEdgeColor','blue','MarkerSize',12);
            hold on;
            
            %Splitting landing sites by using K-Cluster Means to Split into subsequent parts there should be greater than or equal to number of TLOF Pads
            if UAM_Split(i).Length_BlockGroupsHalfsm >= No_of_Landing_Pads
                [idx, C] = kmeans([UAM_Split(i).BlockGroups_Halfsm.Long, UAM_Split(i).BlockGroups_Halfsm.Lat], No_of_splits);
                k_cluster_split(i).site_assignments = idx;
                k_cluster_split(i).site_centroids.lat = C(:,2);
                k_cluster_split(i).site_centroids.long = C(:,1);
                k_cluster_split(i).site_centroids = struct2table(k_cluster_split(i).site_centroids);
                geoshow(k_cluster_split(i).site_centroids.lat,k_cluster_split(i).site_centroids.long,'DisplayType','Point','Marker','*','MarkerEdgeColor','blue','MarkerSize',12);
                hold on;
            elseif ~isempty(UAM_Sites_thatcanbe_Split(i).Satisfies_Land_Area_Req)
                disp('All potential Landing Site that could have been Split has found available land from Zillow Assessment dataset of the Study Area. There are no Landing Sites to perform K-Means Cluster Splitting.');
            end
        end
    end 
    %end
end

title('200 Landing Sites Scenario: Landing Sites that can be Split and Available Land within 0.5 sm','Fontsize',16)


return