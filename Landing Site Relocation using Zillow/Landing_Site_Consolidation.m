%This script is written to find and consolidate the original landing sites
%which are generated from the demand responsive block group analysis
%Sayantan Tarafdar, May 2019

%function Landing_Site_Consolidation(Region, CPM, Landing_Sites_Scenario, boundary, No_of_Landing_Pads, Acre2Sqft, Taxi_Config)


clc
clear all;
close all;
Region = 'SFO'; %'SFO'/'DFW'/'LAX'
CPM = 1.1; %cost per mile 1/1.1/1.2/.../3
Landing_Sites_Scenario = 206; %no. of landing sites set 50/75/100/200/300/400
boundary = sm2deg(0.5); %bufwidth of bufferm considers width in degrees of arc
No_of_Landing_Pads = 7; %if a vertiport has 2 or more pads,start looking for big enough land, if there's no land, split
Acre2Sqft = 43560; %1 Acre = 43,560 square feet
Taxi_Config = 'Ground_Taxi'; %switch between Ground_Taxi and Hover_Taxi

Directory = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\',Region,'\'];
Zillow_Asmt_Dir = ['C:\ATSL_Git\OnDemand_Electric_Aircraft_Mobility_Concept\Landing Site Relocation using Zillow\Zillow Asmt Data\'];

load([Directory,num2str(Landing_Sites_Scenario),'_Vertiports_',Region,'.mat']);
%load excel spreadsheet with the coordinates of the different landing sites set
[numdata] = xlsread([Directory,num2str(Landing_Sites_Scenario),'_Landing_Sites_',num2str(CPM),'_',Region,'.xlsx'],'Sheet1');
save([Directory,num2str(Landing_Sites_Scenario),'_UAM_Landing_Sites_',num2str(CPM),'_',Region,'.txt'],'numdata','-ASCII');
fid = fopen([Directory,num2str(Landing_Sites_Scenario),'_UAM_Landing_Sites_',num2str(CPM),'_',Region,'.txt']);
data1 = textscan(fid,'%f%f%f%f%f%f%f%f%f',Landing_Sites_Scenario);
fclose(fid);

load 'TLOF_Pad.mat';
[numdata1] = xlsread('LandingPadRequirements','Revised_Pad');
save('Landing_Pad_Area_Requirements.txt','numdata1','-ASCII');
fid1 = fopen('Landing_Pad_Area_Requirements.txt');
data2 = textscan(fid1,'%f%f%f%f%f%f%f');
fclose(fid1);

load([Zillow_Asmt_Dir,Region,'_Asmt_Cleaned.mat']);

for i = 1:Landing_Sites_Scenario
    %if i <= length(Landing_Sites_Scenario)
    if  UAM_Landing_Sites(i).TLOF_Pads < No_of_Landing_Pads
        %save the coordinates and data of the sites which have more than n number of TLOF pads
        UAM_can_be_Consolidated(i).Rank = UAM_Landing_Sites(i).Rank;
        UAM_can_be_Consolidated(i).ID = UAM_Landing_Sites(i).ID;
        UAM_can_be_Consolidated(i).Origin_Lat = UAM_Landing_Sites(i).Origin_Lat;
        UAM_can_be_Consolidated(i).Origin_Long =  UAM_Landing_Sites(i).Origin_Long;
        UAM_can_be_Consolidated(i).Outbound_Person_Round_Trips = UAM_Landing_Sites(i).Outbound_Person_Round_Trips;
        UAM_can_be_Consolidated(i).Inbound_Person_Round_Trips = UAM_Landing_Sites(i).Inbound_Person_Round_Trips;
        UAM_can_be_Consolidated(i).Person_1Way_Trips = UAM_Landing_Sites(i).Person_1Way_Trips;
        UAM_can_be_Consolidated(i).TLOF_Pads = UAM_Landing_Sites(i).TLOF_Pads;
        UAM_can_be_Consolidated(i).Gates = UAM_Landing_Sites(i).Gates;
        if strcmp(Taxi_Config,'Hover_Taxi')
            UAM_can_be_Consolidated(i).Hover_Taxi_Area_in_Acres = UAM_Landing_Sites(i).Hover_Taxi_Area_in_Acres;
        elseif strcmp(Taxi_Config,'Ground_Taxi')
            UAM_can_be_Consolidated(i).Ground_Taxi_Area_in_Acres = UAM_Landing_Sites(i).Ground_Taxi_Area_in_Acres;
        end
        geoshow(UAM_can_be_Consolidated(i).Origin_Lat,UAM_can_be_Consolidated(i).Origin_Long,'DisplayType','Point','Marker','*','MarkerEdgeColor','red','MarkerSize',20);
        
        %need these separately in an array to calculate arclen next
        Destination_Lat = data1{4};
        Destination_Long = data1{3};
        arclen = distance(Destination_Lat,Destination_Long,UAM_Landing_Sites(i).Origin_Lat,UAM_Landing_Sites(i).Origin_Long); %calculates dist in degrees
        dist_in_sm = deg2sm(arclen); %converts dist from deg to statute miles
        dist_in_sm(dist_in_sm == 0) = NaN; %removes all dist = 0 sm (removing self counting)
        greater_than_equal_to_threshold = find(data1{8} >= No_of_Landing_Pads);
        dist_in_sm(greater_than_equal_to_threshold) = NaN; %the distance calcualted for the megaports are considered NaN
        dist_less_than_half_sm = find(dist_in_sm <= deg2sm(boundary)); %finds the indices of sites in the 0.5 sm boundary
        
        UAM_can_be_Consolidated(i).Dist_from_other_Sites = dist_in_sm; %save both the distances and indices
        %saves the latitudes, longitudes, demands of landing sites which fall within the 0.5 sm boundary of the corresponding landing site
        UAM_can_be_Consolidated(i).Sites_Halfsm.Rank = dist_less_than_half_sm;
        UAM_can_be_Consolidated(i).Sites_Halfsm.ID = data1{2}(dist_less_than_half_sm);
        UAM_can_be_Consolidated(i).Sites_Halfsm.Lat = data1{4}(dist_less_than_half_sm);
        UAM_can_be_Consolidated(i).Sites_Halfsm.Long = data1{3}(dist_less_than_half_sm);
        UAM_can_be_Consolidated(i).Sites_Halfsm.Person_1Way_Trips = round(data1{7}(dist_less_than_half_sm));
        UAM_can_be_Consolidated(i).Sites_Halfsm.TLOF_Pads = data1{8}(dist_less_than_half_sm);
        UAM_can_be_Consolidated(i).Sites_Halfsm.Gates = data1{9}(dist_less_than_half_sm);
        UAM_can_be_Consolidated(i).Sites_Halfsm.Dist = dist_in_sm(dist_in_sm <= deg2sm(boundary));
        %summing person 1-way trips, landing pads and parking stalls
        %         UAM_can_be_Consolidated(i).Sites_Halfsm.sumOutbound = UAM_can_be_Consolidated(i).Outbound_Person_Round_Trips(:) + UAM_can_be_Consolidated(i).Outbound_Person_Round_Trips;
        %         UAM_can_be_Consolidated(i).Sites_Halfsm.sumInbound = UAM_can_be_Consolidated(i).Inbound_Person_Round_Trips(:) + UAM_can_be_Consolidated(i).Inbound_Person_Round_Trips;
        UAM_can_be_Consolidated(i).Sites_Halfsm.sumDemand = UAM_can_be_Consolidated(i).Sites_Halfsm.Person_1Way_Trips(:) + UAM_can_be_Consolidated(i).Person_1Way_Trips;
        UAM_can_be_Consolidated(i).Sites_Halfsm.sumTLOF_Pads = UAM_can_be_Consolidated(i).Sites_Halfsm.TLOF_Pads(:) + UAM_can_be_Consolidated(i).TLOF_Pads;
        UAM_can_be_Consolidated(i).Sites_Halfsm.sumGates = UAM_can_be_Consolidated(i).Sites_Halfsm.Gates(:) + UAM_can_be_Consolidated(i).Gates;
        
        %finds land for all landing sites considered for consolidation
        if ~isempty(UAM_can_be_Consolidated(i).Rank)
            [latx,lonx] = bufferm(UAM_can_be_Consolidated(i).Origin_Lat,UAM_can_be_Consolidated(i).Origin_Long,boundary,'out',100);
            UAM_can_be_Consolidated(i).Boundary.Latitude = latx;
            UAM_can_be_Consolidated(i).Boundary.Longitude = lonx;
            geoshow(latx,lonx,'DisplayType','Polygon','FaceColor','none');
            %check how many plots of Zillo Assessment data are within 0.5 sm boundary
            IN = inpolygon(Zillow_Asmt.Latitude,Zillow_Asmt.Longitude,latx,lonx);
            %saves all Zillow data and their properties within 0.5 sm boundary
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.Count = numel(Zillow_Asmt.Latitude(IN));
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.County = Zillow_Asmt.County(IN);
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.Lat = Zillow_Asmt.Latitude(IN);
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.Long = Zillow_Asmt.Longitude(IN);
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.LotSize_Acres = Zillow_Asmt.LotSize_Acres(IN);
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.LotSize_SqFt = Zillow_Asmt.LotSize_SqFt(IN);
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.Stories = Zillow_Asmt.Stories(IN);
            UAM_can_be_Consolidated(i).Zillow_inside_Bound.Land_Use_Type = Zillow_Asmt.Land_Use_Type(IN);
            
            %finds all Zillow data that satisfies the land area requirements for all landing sites
            if strcmp(Taxi_Config,'Hover_Taxi')
                satisfies_land_area = find(Zillow_Asmt.LotSize_Acres(IN) >= max(UAM_can_be_Consolidated(i).Hover_Taxi_Area_in_Acres));
            elseif strcmp(Taxi_Config,'Ground_Taxi')
                satisfies_land_area = find(Zillow_Asmt.LotSize_Acres(IN) >= max(UAM_can_be_Consolidated(i).Ground_Taxi_Area_in_Acres));
            end
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.Indices = satisfies_land_area;
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.County = UAM_can_be_Consolidated(i).Zillow_inside_Bound.County(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.Lat = UAM_can_be_Consolidated(i).Zillow_inside_Bound.Lat(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.Long = UAM_can_be_Consolidated(i).Zillow_inside_Bound.Long(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.LotSize_Acres = UAM_can_be_Consolidated(i).Zillow_inside_Bound.LotSize_Acres(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.LotSize_SqFt = UAM_can_be_Consolidated(i).Zillow_inside_Bound.LotSize_SqFt(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.Stories = UAM_can_be_Consolidated(i).Zillow_inside_Bound.Stories(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied.Land_Use_Type = UAM_can_be_Consolidated(i).Zillow_inside_Bound.Land_Use_Type(satisfies_land_area);
            UAM_can_be_Consolidated(i).Land_Area_Satisfied = struct2table(UAM_can_be_Consolidated(i).Land_Area_Satisfied);
            %geoshow(UAM_can_be_Consolidated(i).Land_Area_Satisfied.Lat,UAM_can_be_Consolidated(i).Land_Area_Satisfied.Long,'DisplayType','Point','Marker','o','MarkerEdgeColor','blue','MarkerSize',15);
        end
        
        if ~isempty(dist_less_than_half_sm)
            %checking area requirements for new landing pads and gates configurations
            [~, Locb] = ismember([[UAM_can_be_Consolidated(i).Sites_Halfsm.sumTLOF_Pads], [UAM_can_be_Consolidated(i).Sites_Halfsm.sumGates]],...
                [[TLOF_Pad.TLOF_Pads]', [TLOF_Pad.Parking_Stalls]'],'rows');
            Area_Indices(i).Locb = Locb;
            if Locb > 0
                Area_Indices(i).Hover_Taxi_Area_in_Acres = data2{5}(Locb); %corresponding area in sqft for hover taxi config
                Area_Indices(i).Ground_Taxi_Area_in_Acres = data2{7}(Locb); %corresponding area in sqft for ground taxi config
%             else
%                 isnan(Area_Indices(i).Hover_Taxi_Area_in_Acres);
%                 isnan(Area_Indices(i).Ground_Taxi_Area_in_Acres);
            end
            UAM_can_be_Consolidated(i).Sites_Halfsm.Hover_Taxi_Area_in_Acres = Area_Indices(i).Hover_Taxi_Area_in_Acres;
            UAM_can_be_Consolidated(i).Sites_Halfsm.Ground_Taxi_Area_in_Acres = Area_Indices(i).Ground_Taxi_Area_in_Acres;
            
            %finding lat and long of 0.5 sm boundary to invoke inpolygon, function to find all Zillow Assessment data within the boundary
            [lata,lona] = bufferm(UAM_can_be_Consolidated(i).Origin_Lat,UAM_can_be_Consolidated(i).Origin_Long,boundary,'out',100);
            UAM_can_be_Consolidated(i).Boundary.Latitude = lata;
            UAM_can_be_Consolidated(i).Boundary.Longitude = lona;
            geoshow(lata,lona,'DisplayType','Polygon','FaceColor','none');
            %check how many plots of Zillo Assessment data are within 0.5 sm boundary
            in = inpolygon(Zillow_Asmt.Latitude,Zillow_Asmt.Longitude,lata,lona);
            %saves all Zillow data and their properties within 0.5 sm boundary
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Count = numel(Zillow_Asmt.Latitude(in));
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.County = Zillow_Asmt.County(in);
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Lat = Zillow_Asmt.Latitude(in);
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Long = Zillow_Asmt.Longitude(in);
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.LotSize_Acres = Zillow_Asmt.LotSize_Acres(in);
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.LotSize_SqFt = Zillow_Asmt.LotSize_SqFt(in);
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Stories = Zillow_Asmt.Stories(in);
            UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Land_Use_Type = Zillow_Asmt.Land_Use_Type(in);
                
            %finds all Zillow data that satisfies the land area requirements for the landing sites those will be consolidated
            if ~isempty(UAM_can_be_Consolidated(i).Sites_Halfsm.Hover_Taxi_Area_in_Acres)
                if strcmp(Taxi_Config,'Hover_Taxi')
                    land_area_satisfied = find(Zillow_Asmt.LotSize_Acres(in) >= max(UAM_can_be_Consolidated(i).Sites_Halfsm.Hover_Taxi_Area_in_Acres));
                elseif strcmp(Taxi_Config,'Ground_Taxi')
                    land_area_satisfied = find(Zillow_Asmt.LotSize_Acres(in) >= max(UAM_can_be_Consolidated(i).Sites_Halfsm.Ground_Taxi_Area_in_Acres));
                end
                
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Indices = land_area_satisfied;
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.County = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.County(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Lat = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Lat(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Long = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Long(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.LotSize_Acres = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.LotSize_Acres(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.LotSize_SqFt = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.LotSize_SqFt(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Stories = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Stories(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Land_Use_Type = UAM_can_be_Consolidated(i).Zillow_inside_Boundary.Land_Use_Type(land_area_satisfied);
                UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req = struct2table(UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req);
                geoshow(UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Lat,UAM_can_be_Consolidated(i).Satisfies_Land_Area_Req.Long,'DisplayType','Point','Marker','o','MarkerEdgeColor','blue','MarkerSize',15);
                
                
                UAM_can_be_Consolidated(i).Neighbors.Rank = UAM_can_be_Consolidated(i).Sites_Halfsm.Rank;
                UAM_can_be_Consolidated(i).Neighbors.ID = UAM_can_be_Consolidated(i).Sites_Halfsm.ID;
                UAM_can_be_Consolidated(i).Neighbors.Lat = UAM_can_be_Consolidated(i).Sites_Halfsm.Lat;
                UAM_can_be_Consolidated(i).Neighbors.Long = UAM_can_be_Consolidated(i).Sites_Halfsm.Long;
                UAM_can_be_Consolidated(i).Neighbors.Person_1Way_Trips = UAM_can_be_Consolidated(i).Sites_Halfsm.Person_1Way_Trips;
                UAM_can_be_Consolidated(i).Neighbors.TLOF_Pads = UAM_can_be_Consolidated(i).Sites_Halfsm.TLOF_Pads;
                UAM_can_be_Consolidated(i).Neighbors.Gates = UAM_can_be_Consolidated(i).Sites_Halfsm.Gates;
                UAM_can_be_Consolidated(i).Neighbors.Dist = UAM_can_be_Consolidated(i).Sites_Halfsm.Dist;

                UAM_can_be_Consolidated(i).Neighbors.sumDemand = UAM_can_be_Consolidated(i).Sites_Halfsm.sumDemand;
                UAM_can_be_Consolidated(i).Neighbors.sumPads = UAM_can_be_Consolidated(i).Sites_Halfsm.sumTLOF_Pads;
                UAM_can_be_Consolidated(i).Neighbors.sumGates = UAM_can_be_Consolidated(i).Sites_Halfsm.sumGates;
                
                [M,I] = min(UAM_can_be_Consolidated(i).Neighbors.Dist);
                
                %Contains only the sites closest to the parent sites contains all five columns of UAM_Landing_Site(i).Sites_Halfsm
                UAM_can_be_Consolidated(i).Closest_Site.Rank = getfield(UAM_can_be_Consolidated(i).Neighbors,'Rank',{I});
                UAM_can_be_Consolidated(i).Closest_Site.ID = getfield(UAM_can_be_Consolidated(i).Neighbors,'ID',{I});
                UAM_can_be_Consolidated(i).Closest_Site.Lat = getfield(UAM_can_be_Consolidated(i).Neighbors,'Lat',{I});
                UAM_can_be_Consolidated(i).Closest_Site.Long = getfield(UAM_can_be_Consolidated(i).Neighbors,'Long',{I});
                UAM_can_be_Consolidated(i).Closest_Site.Person_1Way_Trips = getfield(UAM_can_be_Consolidated(i).Neighbors,'Person_1Way_Trips',{I});
                UAM_can_be_Consolidated(i).Closest_Site.Dist = getfield(UAM_can_be_Consolidated(i).Neighbors,'Dist',{I});
                UAM_can_be_Consolidated(i).Closest_Site.sumDemand = getfield(UAM_can_be_Consolidated(i).Neighbors,'sumDemand',{I});
                UAM_can_be_Consolidated(i).Closest_Site.sumPads = getfield(UAM_can_be_Consolidated(i).Neighbors,'sumPads',{I});
                UAM_can_be_Consolidated(i).Closest_Site.sumGates = getfield(UAM_can_be_Consolidated(i).Neighbors,'sumGates',{I});
                
                %this part of script arranges the landing sites pair is uch a way that the one with higher demand
                %is marked as parent site and the one with the lower demand is marked as the child site
                if UAM_can_be_Consolidated(i).Closest_Site.Rank > UAM_can_be_Consolidated(i).Rank
                    UAM_can_be_Consolidated(i).Child_Site_Phase1 = UAM_can_be_Consolidated(i).Closest_Site;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.Rank = UAM_Landing_Sites(i).Rank;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.ID = UAM_Landing_Sites(i).ID;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.Lat = UAM_Landing_Sites(i).Origin_Lat;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.Long = UAM_Landing_Sites(i).Origin_Long;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.PersonDemand = UAM_Landing_Sites(i).Person_1Way_Trips;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.Dist = UAM_can_be_Consolidated(i).Closest_Site.Dist;

                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumDemand = UAM_can_be_Consolidated(i).Closest_Site.sumDemand;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumPads = UAM_can_be_Consolidated(i).Closest_Site.sumPads;
                    UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumGates = UAM_can_be_Consolidated(i).Closest_Site.sumGates;
                    
                    %contain the parent and child site in one column of struct file, parent site is one with higher demand, child is the one with lower demand
                    UAM_can_be_Consolidated(i).Site_Pairs_1.Rank = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Rank,UAM_can_be_Consolidated(i).Child_Site_Phase1.Rank];
                    UAM_can_be_Consolidated(i).Site_Pairs_1.ID = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.ID,UAM_can_be_Consolidated(i).Child_Site_Phase1.ID];
                    UAM_can_be_Consolidated(i).Site_Pairs_1.Lat = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Lat,UAM_can_be_Consolidated(i).Child_Site_Phase1.Lat];
                    UAM_can_be_Consolidated(i).Site_Pairs_1.Long = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Rank,UAM_can_be_Consolidated(i).Child_Site_Phase1.Long];
                  
                    UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.PersonDemand,UAM_can_be_Consolidated(i).Child_Site_Phase1.Person_1Way_Trips];
                    UAM_can_be_Consolidated(i).Site_Pairs_1.LandingPads = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumPads,UAM_can_be_Consolidated(i).Child_Site_Phase1.sumPads];
                    UAM_can_be_Consolidated(i).Site_Pairs_1.ParkingStalls = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumGates,UAM_can_be_Consolidated(i).Child_Site_Phase1.sumGates];
                    UAM_can_be_Consolidated(i).Site_Pairs_1.Dist = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Dist,UAM_can_be_Consolidated(i).Child_Site_Phase1.Dist];
                    
                else UAM_can_be_Consolidated(i).Parent_Site_Phase1 = UAM_can_be_Consolidated(i).Closest_Site;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.Rank = UAM_Landing_Sites(i).Rank;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.ID = UAM_Landing_Sites(i).ID;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.Lat = UAM_Landing_Sites(i).Origin_Lat;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.Long = UAM_Landing_Sites(i).Origin_Long;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.PersonDemand = UAM_Landing_Sites(i).Person_1Way_Trips;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.Dist = UAM_can_be_Consolidated(i).Closest_Site.Dist;

                    UAM_can_be_Consolidated(i).Child_Site_Phase1.sumDemand = UAM_can_be_Consolidated(i).Closest_Site.sumDemand;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.sumPads = UAM_can_be_Consolidated(i).Closest_Site.sumPads;
                    UAM_can_be_Consolidated(i).Child_Site_Phase1.sumGates = UAM_can_be_Consolidated(i).Closest_Site.sumGates;
                    
%                     if UAM_can_be_Consolidated(i).Child_Site_Phase1.sumPads <=6   
                        %contain the parent and child site in one column of struct file, parent site is one with higher demand, child is the one with lower demand
                        UAM_can_be_Consolidated(i).Site_Pairs_1.Rank = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Rank,UAM_can_be_Consolidated(i).Child_Site_Phase1.Rank];
                        UAM_can_be_Consolidated(i).Site_Pairs_1.ID = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.ID,UAM_can_be_Consolidated(i).Child_Site_Phase1.ID];
                        UAM_can_be_Consolidated(i).Site_Pairs_1.Lat = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Lat,UAM_can_be_Consolidated(i).Child_Site_Phase1.Lat];
                        UAM_can_be_Consolidated(i).Site_Pairs_1.Long = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Rank,UAM_can_be_Consolidated(i).Child_Site_Phase1.Long];
                        
                        UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Person_1Way_Trips,UAM_can_be_Consolidated(i).Child_Site_Phase1.PersonDemand];
                        UAM_can_be_Consolidated(i).Site_Pairs_1.LandingPads = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumPads,UAM_can_be_Consolidated(i).Child_Site_Phase1.sumPads];
                        UAM_can_be_Consolidated(i).Site_Pairs_1.ParkingStalls = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumGates,UAM_can_be_Consolidated(i).Child_Site_Phase1.sumGates];
                        UAM_can_be_Consolidated(i).Site_Pairs_1.Dist = [UAM_can_be_Consolidated(i).Parent_Site_Phase1.Dist,UAM_can_be_Consolidated(i).Child_Site_Phase1.Dist];
%                     end
                end
                Optimal_Site_1(i).Parent_Rank = UAM_can_be_Consolidated(i).Parent_Site_Phase1.Rank;
                Optimal_Site_1(i).Child_Rank = UAM_can_be_Consolidated(i).Child_Site_Phase1.Rank;
                Optimal_Site_1(i).Parent_ID = UAM_can_be_Consolidated(i).Parent_Site_Phase1.ID;
                Optimal_Site_1(i).Child_ID = UAM_can_be_Consolidated(i).Child_Site_Phase1.ID;
                
                %assigning the original landig sites and their rank, id, lat, long, demand to a separate cell array, this will be used in
                %the next part of the script to inititate working on 2nd phase of consoliadation
                if ~isempty(UAM_can_be_Consolidated(i).Closest_Site)|| isempty(UAM_can_be_Consolidated(i).Closest_Site)
                    UAM1(i).Rank = UAM_can_be_Consolidated(i).Rank;
                    UAM1(i).ID = UAM_can_be_Consolidated(i).ID;
                    UAM1(i).Latitude = UAM_can_be_Consolidated(i).Origin_Lat;
                    UAM1(i).Longitude = UAM_can_be_Consolidated(i).Origin_Long;
                    UAM1(i).Person_1Way_Trips = UAM_can_be_Consolidated(i).Person_1Way_Trips;
                    Optimal_A = cell2mat(table2cell(struct2table(UAM1)));
                end
                %creating 0.5 sm boundary around the new optimal sites
                if ~isempty(UAM_can_be_Consolidated(i).Closest_Site)
                    
                    %creating pairs of lat long for the landing site pairs
                    Boundary(i).Landing_SitePair_Lat = [UAM_can_be_Consolidated(i).Origin_Lat,UAM_can_be_Consolidated(i).Closest_Site.Lat];
                    Boundary(i).Landing_SitePair_Long = [UAM_can_be_Consolidated(i).Origin_Long,UAM_can_be_Consolidated(i).Closest_Site.Long];
                    
                    %finding the latitude and longitude by center of mass
                    Optimal_Site_1(i).sumDemand = sum(UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand);
                    Optimal_Site_1(i).meanDemand = mean(UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand);
                    Optimal_Site_1(i).centerOfMassLat = mean(UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand(:) .* Boundary(i).Landing_SitePair_Lat(:)) / Optimal_Site_1(i).meanDemand;
                    Optimal_Site_1(i).centerOfMassLong = mean(UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand(:) .* Boundary(i).Landing_SitePair_Long(:)) / Optimal_Site_1(i).meanDemand;
                    Optimal_Site_1(i).LandingPads = UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumPads;
                    Optimal_Site_1(i).ParkingStalls = UAM_can_be_Consolidated(i).Parent_Site_Phase1.sumGates;
                    
                    %this part of the code is to remove the duplicate or repeat optimal landing sites
                    %it also eliminates sites with common parent or child, for eg, site rank 19 is the common parent to sites ranked 35 and 37
                    
         
                    Optimal_1 = cell2mat(table2cell(struct2table(Optimal_Site_1)));
                    %removes the rows with the common parent
                    [Optimal_2,idx1] = unique(Optimal_1(:,1),'stable');
                    Optimal_3 = Optimal_1(idx1,:);
                    %removes the rows with common child
                    [Optimal_4,idx2] = unique(Optimal_3(:,2),'stable');
                    Optimal_5 = Optimal_3(idx2,:);
                    
                    %figures out the rank and id of landing sites which happen to be child to one site but parent to another
                    common_parent_child.rank = intersect(Optimal_5(:,1),Optimal_5(:,2),'stable','rows');
                    common_parent_child.id = intersect(Optimal_5(:,3),Optimal_5(:,4),'stable','rows');
                    
                    %finding the common elements in two sets of array to find the intersecting cells in the respective fields
                    UAM2(i).Parent_Rank = intersect(Optimal_5(:,1),UAM_can_be_Consolidated(i).Rank,'stable','rows');
                    UAM2(i).Child_Rank = intersect(Optimal_5(:,2),UAM_can_be_Consolidated(i).Child_Site_Phase1.Rank,'stable','rows');
                    UAM2(i).Parent_ID = intersect(Optimal_5(:,3),UAM_can_be_Consolidated(i).ID,'stable','rows');
                    UAM2(i).Child_ID = intersect(Optimal_5(:,4),UAM_can_be_Consolidated(i).Child_Site_Phase1.ID,'stable','rows');
                    UAM2(i).sumDemand = intersect(Optimal_5(:,5),Optimal_Site_1(i).sumDemand,'stable','rows');
                    UAM2(i).meanDemand = intersect(Optimal_5(:,6),Optimal_Site_1(i).meanDemand,'stable','rows');
                    UAM2(i).Latitude = intersect(Optimal_5(:,7),Optimal_Site_1(i).centerOfMassLat,'stable','rows');
                    UAM2(i).Longitude = intersect(Optimal_5(:,8),Optimal_Site_1(i).centerOfMassLong,'stable','rows');
                    UAM2(i).LandingPads = intersect(Optimal_5(:,9),Optimal_Site_1(i).LandingPads,'stable','rows');
                    UAM2(i).ParkingStalls = intersect(Optimal_5(:,10),Optimal_Site_1(i).ParkingStalls,'stable','rows');
                    
                    %saving the 1st iteration of removing duplicates to the main consolidation struct array
                    UAM_can_be_Consolidated(i).Optimal_Site_Phase1 = UAM2(i);
                    
                    if isempty(UAM2(i).Parent_Rank)
                        UAM2(i).Child_Rank = [];
                        UAM2(i).Child_ID = [];
                        UAM2(i).sumDemand = [];
                        UAM2(i).meanDemand = [];
                        UAM2(i).Latitude = [];
                        UAM2(i).Longitude = [];
                        UAM2(i).LandingPads = [];
                        UAM2(i).ParkingStalls = [];
                        UAM_can_be_Consolidated(i).Optimal_Site_Phase1 = [];
                    end
                    geoshow(UAM2(i).Latitude,UAM2(i).Longitude,'DisplayType','Point','Marker','*','MarkerEdgeColor','blue','MarkerSize',15);
                    %plotting circular boundary of 0.5 sm around optimal consolidated site
                    [lata,lona] = bufferm(UAM2(i).Latitude,UAM2(i).Longitude,boundary,'out',100);
                    geoshow(lata,lona,'DisplayType','Polygon','FaceColor','none');
                    %find the indexes of the landing sites which have children but were excluded from phase 1 for being common to multiple landing sites
                    [Optimal_B,idx3] = setdiff(Optimal_A(:,1),Optimal_5(:,1:2),'stable');
                    Optimal_C = Optimal_A(idx3,:);
                    
                    %creating a struct array with those landing sites to figure out a child landing site to pair up with
                    UAM3(i).Rank = intersect(Optimal_C(:,1),UAM1(i).Rank,'stable','rows');
                    UAM3(i).ID = intersect(Optimal_C(:,2),UAM1(i).ID,'stable','rows');
                    UAM3(i).Latitude = intersect(Optimal_C(:,3),UAM1(i).Latitude,'stable','rows');
                    UAM3(i).Longitude = intersect(Optimal_C(:,4),UAM1(i).Longitude,'stable','rows');
                    UAM3(i).Person_1Way_Trips = intersect(Optimal_C(:,5),UAM1(i).Person_1Way_Trips,'stable','rows');
                    UAM3(i).Sites_Halfsm = UAM_can_be_Consolidated(i).Sites_Halfsm;
                    
                    %keeping the cells that are not needed empty
                    if isempty(UAM3(i).Rank)
                        UAM3(i).Person_1Way_Trips = [];
                        UAM3(i).Sites_Halfsm = [];
                    end
                    %see if any children left for left-over landing sites to consolidate
                    if ~isempty(UAM3(i).Sites_Halfsm)
                        UAM3(i).Rank2 = ismember(UAM3(i).Sites_Halfsm.Rank,Optimal_C(:,1));
                        if UAM3(i).Rank2 == 1
                            UAM3(i).Optimal_Phase2.Parent_Rank = UAM3(i).Rank;
                            UAM3(i).Optimal_Phase2.Child_Rank = UAM3(i).Sites_Halfsm.Rank;
                            UAM3(i).Optimal_Phase2.Parent_ID = UAM3(i).ID;
                            UAM3(i).Optimal_Phase2.Child_ID = UAM3(i).Sites_Halfsm.ID;
                            UAM3(i).Optimal_Phase2.sumDemand = UAM3(i).Sites_Halfsm.sumDemand;
                            UAM3(i).Optimal_Phase2.meanDemand = mean(UAM3(i).Person_1Way_Trips,UAM3(i).Sites_Halfsm.Person_1Way_Trips);
                            UAM3(i).Optimal_Phase2.Latitude = mean(UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand(:) .* Boundary(i).Landing_SitePair_Lat(:)) / Optimal_Site_1(i).meanDemand;
                            UAM3(i).Optimal_Phase2.Longitude = mean(UAM_can_be_Consolidated(i).Site_Pairs_1.PersonDemand(:) .* Boundary(i).Landing_SitePair_Long(:)) / Optimal_Site_1(i).meanDemand;
                            
                            UAM_can_be_Consolidated(i).Optimal_Site_Phase2 = UAM3(i).Optimal_Phase2;
                            %plotting the optimal landing site phase 2
                            geoshow(UAM_can_be_Consolidated(i).Optimal_Site_Phase2.Latitude,UAM_can_be_Consolidated(i).Optimal_Site_Phase2.Longitude,'DisplayType','Point','Marker','*','MarkerEdgeColor','blue','MarkerSize',15);
                            %plotting circular boundary of 0.5 sm around optimal consolidated site
                            [latb,lonb] = bufferm(UAM_can_be_Consolidated(i).Optimal_Site_Phase2.Latitude,UAM_can_be_Consolidated(i).Optimal_Site_Phase2.Longitude,boundary,'out',100);
                            geoshow(latb,lonb,'DisplayType','Polygon','FaceColor','none');
                        end
                    end
                end
            end
        end
    end
    %end
end


return