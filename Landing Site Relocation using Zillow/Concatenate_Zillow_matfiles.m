clc;
clear all;
close all;
Region = 'SFO';

FileName1 = [Region, '_Asmt_Cleaned_1.csv'];
fid1 = fopen(FileName1, 'r');
Output1 = textscan(fid1, '%s%f%f%f%f%f%s','delimiter',',','EmptyValue',NaN);

FileName2 = [Region, '_Asmt_Cleaned_2.csv'];
fid2 = fopen(FileName2, 'r');
Output2 = textscan(fid2, '%s%f%f%f%f%f%s','delimiter',',','EmptyValue',NaN);

Zillow_Asmt1.County = Output1{1};
Zillow_Asmt1.Latitude = Output1{2};
Zillow_Asmt1.Longitude = Output1{3};
Zillow_Asmt1.LotSize_Acres = round(Output1{4},1);
Zillow_Asmt1.LotSize_SqFt = round(Output1{5},1);
Zillow_Asmt1.Stories = Output1{6};
Zillow_Asmt1.Land_Use_Type = Output1{7};

Zillow_Asmt2.County = Output2{1};
Zillow_Asmt2.Latitude = Output2{2};
Zillow_Asmt2.Longitude = Output2{3};
Zillow_Asmt2.LotSize_Acres = round(Output2{4},1);
Zillow_Asmt2.LotSize_SqFt = round(Output2{5},1);
Zillow_Asmt2.Stories = Output2{6};
Zillow_Asmt2.Land_Use_Type = Output2{7};

Zillow_Asmt.County = [Zillow_Asmt1.County',Zillow_Asmt2.County'];
Zillow_Asmt.Latitude = [Zillow_Asmt1.Latitude',Zillow_Asmt2.Latitude'];
Zillow_Asmt.Longitude = [Zillow_Asmt1.Longitude',Zillow_Asmt2.Longitude'];
Zillow_Asmt.LotSize_Acres = [Zillow_Asmt1.LotSize_Acres',Zillow_Asmt2.LotSize_Acres'];
Zillow_Asmt.LotSize_SqFt = [Zillow_Asmt1.LotSize_SqFt',Zillow_Asmt2.LotSize_SqFt'];
Zillow_Asmt.Stories = [Zillow_Asmt1.Stories',Zillow_Asmt2.Stories'];
Zillow_Asmt.Land_Use_Type = [Zillow_Asmt1.Land_Use_Type',Zillow_Asmt2.Land_Use_Type'];

Zillow_Asmt.County = Zillow_Asmt.County';
Zillow_Asmt.Latitude = Zillow_Asmt.Latitude';
Zillow_Asmt.Longitude = Zillow_Asmt.Longitude';
Zillow_Asmt.LotSize_Acres = Zillow_Asmt.LotSize_Acres';
Zillow_Asmt.LotSize_SqFt = Zillow_Asmt.LotSize_SqFt';
Zillow_Asmt.Stories = Zillow_Asmt.Stories';
Zillow_Asmt.Land_Use_Type = Zillow_Asmt.Land_Use_Type';

save([Region,'_Asmt_Cleaned.mat'],'Zillow_Asmt'); %,'-v7.3'   for NYC