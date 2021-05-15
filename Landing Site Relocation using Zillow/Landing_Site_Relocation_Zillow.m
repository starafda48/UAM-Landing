%This script is written to find possible plots from
%the Zillow Assessment data to place/ relocate landing sites
%Sayantan Tarafdar, February 22, 2019

clc;
clear all;
close all;

%Defines City, Landing_Site_Scenario and boundary to relocate sites as a global variable
global Region Landing_Sites_Scenario boundary
Region = SFO;
Landing_Sites_Scenario = 200;
boundary = sm2deg(0.5); %bufwidth of bufferm considers width in degrees of arc
%sm2deg converts 0.5 statute miles to degrees

%reads the coordinates for all the plots in the Zillow Assessment database
%data range D2:E368056 contains the coordinates only
[textData, rawData] = xlsread('SFO_Zillow_Assessment.xlsx','0.25Acres','A2:G368056');

%reading only numerical values of the data to the text file
save('SFO_Zillow_Assessment.txt','textData','-ASCII');
fid = fopen('SFO_Zillow_Assessment.txt');
text_SFO_Zillow = textscan(fid,'%f %f %s %f %s %f %f',368055);
latZillow = text_SFO_Zillow{1};
lonZillow = text_SFO_Zillow{2};
storiesZillow = text_SFO_Zillow{4};
taxyearZillow = text_SFO_Zillow{6};
lotsizeacresZillow = text_SFO_Zillow{7};

%separately reading the type of plot and Counties as they are string
%variables
landuseZillow = rawData(:,1);
countyZillow = rawData(:,3);

%On the basis of Scenario, reads the required spreadsheet containing the
%Coordinates of the landing sites and creates a boundary/ buffer of 0.5
%miles around each of the coordinates
if Landing_Sites_Scenario == 200
    [numData] = xlsread('Landing_Sites_Coordinates_200.xlsx');
    save('Landing_Sites_Coordinates_200.txt', 'numData', '-ASCII'); %replace numData with the lat and lon of the sites
    fid = fopen('Landing_Sites_Coordinates_200.txt');
    data = textscan(fid,'%f%f',Landing_Sites_Scenario);
    fclose(fid);
    original_lat = data{1};
    original_lon = data{2};
    for i = 1:Landing_Sites_Scenario
        lat = data{1}(i);
        lon = data{2}(i);
        [latb,lonb] = bufferm(lat,lon,boundary,'out',100);
        geoshow(latb,lonb,'DisplayType','Polygon','FaceColor','white');
        in = inpolygon(latZillow,lonZillow,latb,lonb);
        x = find(in == 1);
        y = length(x);
        save(['C:\UAM Output\200\Landing Site_', num2str(i), '_inpolygon.mat'],'x')
        save(['C:\UAM Output\200\Zillow200_3\Zillow Records for Site Number_', num2str(i), '.mat'],'y')
          
        geoshow(latZillow(in),lonZillow(in),'DisplayType','Point','Marker','o','MarkerEdgeColor','blue');
        geoshow(original_lat,original_lon,'DisplayType','Point','Marker','*','MarkerEdgeColor','red','MarkerSize',10);
    end
    legend('0.5-mile boundary','Zillow Assessment Data','Original Landing Sites','Location','southwest')
    title('200 Landing Sites Scenario')
else
    disp('error')
end