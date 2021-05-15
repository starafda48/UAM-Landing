Before running Run_Iteration_Splitting_Consolidation.m
1. Run Landing_Pad_Requirements_Save2Mat (saves excell spreadsheet to a mat file for further use in Script)
2. Run Read_Zillow (saves csv spreadsheet containing Zillow Assessment data Study Area wise)
   In Region variable, write SFO/ LAX/ DFW/ NY

To run running Run_Iteration_Splitting_Consolidation.m, use input for the variables:
1. Region: Specifies Study Area (SFO/ LAX/ DFW/ NY)
2. CPM: Cost per mile scenario (1/1.1/1.2/.../3)
3. Landing_Sites_Scenario: No. of Landing Sites (50/ 75/ 100/ 200/ 300)
4. boundary: To establish boundary around each landing site (0.5 sm)
5. No_of_TLOF_Pads: Threshold to decide whether to Split or Consolidate landing sites (2)
6. n: Number of Sites into which a landing site will be Split using K-Means Cluster (2)
7. Acre2Sqft: Converts acre to sq. ft. and vice-versa (1 Acre = 43560 sq. ft.)
8. Taxi_Config: Choose between Ground Taxi or Hover Taxi configuration to determine land area requirements (Ground_Taxi)
