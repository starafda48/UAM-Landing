%Get landing Pads and gates from the Demand Data


%Input files on the server inside 'Capacity Analysis' folder
% Copy all the files

%Value of the paramters
Region = 'DFW'; %/'DFW'/'LAX'
number_of_Landing_Sites = 75; %/75/100/200/300/400 *Demand Data for the selected set is required
UAM_CPM = 1.2; %/1.1/1.2/...../3
Time_of_day = 'Full-Day'; %*Do NOT Change
Time_Bin_Length_min = 30; %(1 to 60)
Design_Capacity = 95; %(1 to 100) *Design percentile

%SAMPLE CALL
%[Vertiports_with_Capacity,~,~,~]=Get_NumberPads_NumberGates('SFO',200,1.2,'Full-Day',30,95);


%function [Vertiports_with_Capacity,OD_flights,Flights_Schedule,Time_Bins_Vector_Str]=Get_NumberPads_NumberGates(Region,number_of_Landing_Sites,UAM_CPM,Time_of_day,Time_Bin_Length_min,Design_Capacity)

%First Step: Generate Flights from Demand (Round Trips)

fprintf('Generating Flights...\n')

OD_flights=Generate_flights_from_trips(Region,number_of_Landing_Sites,UAM_CPM);


%Second Step: Assign Time Tags to the flights

fprintf('Assinging Departure Times and Calculating Arrival Times of the Flights...\n')
Flights_Schedule=Generate_time_tags(Region,number_of_Landing_Sites,UAM_CPM,Time_of_day);

%Thrid Step: Calculate max or critical number of operations at each
%vertiport

fprintf('Calculating Maximum Operations at each Vertiport...\n')
[Vertiports_with_Ops,Time_Bins_Vector_Str]=Calculate_max_operations(Region,UAM_CPM,number_of_Landing_Sites,Time_Bin_Length_min,Time_of_day);

%Fourth Step: Calculate Required Paths and Gates

fprintf('Calculating Number of Landing Pads and Gates...\n')
Vertiports_with_Capacity= Calculate_Required_Pads(Region,number_of_Landing_Sites,UAM_CPM,Vertiports_with_Ops,Time_Bin_Length_min,Design_Capacity,0,0);


%end