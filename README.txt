README file for SoilCompaC - prelim (2024.11.26 - Laura Sofie Harbo, laura.harbo@thuenen.de)

This version of the repository is preliminary and may be changed based on the progress of the 
project and publication of the manuscript to which this repository belongs. 

The files within this repository contain the script used to run the baseline model and the posthoc
model (both random forest models), as well as the code for generating the figures, tables and running 
the statistics included in the manuscript. 
The data required to run the scripts and the scripts cleaning and reshaping the original data 
are not available due to data protection requirements. However, the folder structure is intact, indicating 
how the data has been handled. 

The scripts are shared to enable others to understand, copy and use the developed pathways in 
their own work. 

Script 2_ReciprocalDataDriven_RandomForest_github includes 1) minimal filtering of the data, including 
splitting into training and testing data based on land use, 2) training of the grassland reference model 
including 5-fold cross validation and leave-one-survey out cross validation, 3) application of AOA 
(area of applicability) on cropland sites, 3) application of the grassland reference to the cropland 
sites that pass AOA, 4) training and validation of the post-hoc model. This script is based on a data file 
that contains cleaned, standardized data from the five soil surveys included in the study. 

Script 3_Figures_Analyses_github contains the code to run the statistics, generate the tables and create 
the figures included in the manuscript, in approximate order of occurance in the manuscript. It requires 
data produced in 2_ReciprocalDataDriven_RandomForest_github as well as additional data from the five soil 
surveys. 