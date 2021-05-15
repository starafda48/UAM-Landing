%this script is to read the data for the landing pad requirements
%there are 4 sheets in the excel spreadsheet
%1Pad, 2Pads, 3Pads, 4Pads, depending on the number of TLOF pads for the
%landing sites
%Sayantan Tarafdar, August 12, 2019
clc;
clear all;
close all;

Acre2SqFt = 43560; %1 Acre = 43,560 square feet

%creating struct file for storing data of area requirements for 1 Pad in a
%struct array
[numdata1] = xlsread('LandingPadRequirements','Revised_Pad','A3:G116');
save('Landing_Pad_Area_Requirements.txt','numdata1','-ASCII');
fid1 = fopen('Landing_Pad_Area_Requirements.txt');
data1 = textscan(fid1,'%f%f%f%f%f%f%f');
fclose(fid1);
for m = 1:114
    TLOF_Pad(m).TLOF_Pads = data1{1}(m);
    TLOF_Pad(m).Parking_Stalls = data1{2}(m);
    TLOF_Pad(m).Safety_Landing_Pad_Area = data1{3}(m);
    TLOF_Pad(m).Hover_Taxi_Parking_Stall_Area_Acres = data1{4}(m);
    TLOF_Pad(m).Hover_Taxi_Total_Area_Acres = round(data1{5}(m),1);
    TLOF_Pad(m).Ground_Taxi_Parking_Stall_Area_Acres = data1{6}(m);
    TLOF_Pad(m).Ground_Taxi_Total_Area_Acres = round(data1{7}(m),1);
    save('TLOF_Pad.mat','TLOF_Pad');
end