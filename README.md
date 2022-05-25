# Yu_et_al_CRP_PRF
Replication package for Yu, Goodrich, and Graven "Competing Farm Programs: Does the Introduction of a Risk Management Program Reduce the Enrollment in the Conservation Reserve Program?"

# data
This folder has the datasets used in the study:
1. main_sample.dta: This is the dataset we used as a preferred main dataset. See the paper for the detail.
2. rent_subsample.dta: This is the subset of the main dataset only with the counties that have CRP rent information available.
3. full_sample.dta: This is for one of the robustness checks. See the paper for the detail.

# code
1. 1_data_cleaning.do: This is the Stata do file that generates the datasets in the data folder from the raw data. The raw data are all publicly available and described in the paper.
2. 2_main_analysis.R: This is the R code that replicates the results in the paper.
3. 3_appendix_RI.R and 4_appendix.do: These codes replicate the results in the appendix.
