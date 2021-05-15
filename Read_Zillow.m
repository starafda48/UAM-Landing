%the script is to read the Zillow Assessment data for different study areas
%and store them into mat files for further analysis
clc;
clear all;
close all;
Region = 'NYC';

FileName = [Region, '_Asmt_Cleaned.csv'];
fid = fopen(FileName, 'r');
Output = textscan(fid, '%s%f%f%f%f%f%s','delimiter',',','EmptyValue',NaN);

Zillow_Asmt.County = Output{1};
Zillow_Asmt.Latitude = Output{2};
Zillow_Asmt.Longitude = Output{3};
Zillow_Asmt.LotSize_Acres = round(Output{4},1);
Zillow_Asmt.LotSize_SqFt = round(Output{5},1);
Zillow_Asmt.Stories = Output{6};
Zillow_Asmt.Land_Use_Type = Output{7};

save([Region,'_Asmt_Cleaned.mat'],'Zillow_Asmt','-v7.3'); %,'-v7.3'   for LAX/ NYC