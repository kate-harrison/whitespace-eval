m Files
--------------

calc_sum_ccdf.m 		- Calculate the ccdf of the sum of two random variables
gen_mpath_rv.m		- Generate Multipath Random Variable
get_E.m			- Generic function to get the Elecric field for a certain distance, TX height etc. This function performs all necesaary interpolation
get_path_loss.m         - 
get_path_loss_as_per_itu_P1546.m
get_rp.m                - Inverse of the get_E funtion, gets the distance where a target E field is reached
preprocess_csv_files.m  - Process .csv files and save as .mat file
preprocess_path_loss.m  - This file is used to preprocess the path loss for all channels and save it in files (pl_height_<prob_loc>_<prob_time>.mat)
                          This script uses the function get_pl_height_file( ... ) to generate the pl_height files
get_pl_height_file.m 	- Function to preprocess the path loss for all channels and save it in a file
preprocess_path_loss_wpath.m
				- Generate F(50, x) tables with multipath.  

ITU Data Files
--------------

Below are the ITU propagation tables for 100MHz, 600MHz and 2000MHz for F(50, 10) and F(50, 50) points. 
Each table is a 96 X 8 matrix (96 distances x 8 heights).

Distances: [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
Heights = [10 20 37.5 75 150 300 600 1200]; % m


ITU_F_50_10_FREQ100.csv
ITU_F_50_10_FREQ100.mat
ITU_F_50_10_FREQ2000.csv
ITU_F_50_10_FREQ2000.mat
ITU_F_50_10_FREQ600.csv
ITU_F_50_10_FREQ600.mat
ITU_F_50_50_FREQ100.csv
ITU_F_50_50_FREQ100.mat
ITU_F_50_50_FREQ2000.csv
ITU_F_50_50_FREQ2000.mat
ITU_F_50_50_FREQ600.csv
ITU_F_50_50_FREQ600.mat
ITU_F_50_50_FREQ600_.csv

Multipath Data Files
--------------
Rician PDF for various values of K (0dB, 6dB, -inf dB).

multipath_distribution_K0dB.mat
multipath_distribution_K6dB.mat
multipath_distribution_Kminusinf.mat

