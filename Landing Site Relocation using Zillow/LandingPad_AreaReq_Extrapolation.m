clc;
clear all;
close all;

[numdata1] = xlsread('LandingPadRequirements','Pad','A3:G111');
save('Landing_Pad_Area_Requirements_Extp.txt','numdata1','-ASCII');
fid1 = fopen('Landing_Pad_Area_Requirements_Extp.txt');
data1 = textscan(fid1,'%f%f%f%f%f%f%f');
fclose(fid1);

[numdata2] = xlsread('LandingPadRequirements','TLOF','A2:B34');
save('Landing_Pad_Area_Requirements_Extp2.txt','numdata2','-ASCII');
fid2 = fopen('Landing_Pad_Area_Requirements_Extp2.txt');
data2 = textscan(fid2,'%f%f%f%f%f%f%f');
fclose(fid1);

pads = data1{1};
area_pads = data1{3};

landing_pads = data2{1};
parking_stalls = data1{2};
pads_area = data2{2};
hover_parking_area = data1{4};
ground_parking_area = data1{6};

x1 = landing_pads(1:4,:);
x2 = parking_stalls(1:22,:);
y1 = pads_area(1:4,:);
y2 = hover_parking_area(1:22,:);
y3 = ground_parking_area(1:22,:);

vq1 = interp1(x1,y1,landing_pads(5:33,:),'linear','extrap');
vq2 = interp1(x2,y2,parking_stalls(23:109,:),'linear','extrap');
vq3 = interp1(x2,y3,parking_stalls(23:109,:),'linear','extrap');
h1 = horzcat(landing_pads(5:33,:),vq1);

[~, Locb] = ismember(pads(23:109,:), h1(:,1),'rows');
vq5 = area_pads(23:109,:);
vq6 = vq5(Locb);
% Area_Indices(i).Ground_Taxi_Area_in_Acres = data1{7}(Locb);