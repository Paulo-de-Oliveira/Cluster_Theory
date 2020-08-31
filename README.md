# Cluster_Theory

This repository contains all data, codes and outputs that were utilized for the Cluster Theory paper which was published at JWRPM.

The folders are organized sequentially under the execution order. Since there are multiple dependencies between source codes inside different folders you should execute the project in the suggested order.

Follow bellow a brief description of the reasoning behind each folder and their main files.

**2_pattern_generation**

Generates correlated demand pattern for each network cluster based on a SARMA time series model

**6_sampling_location**

Generates the optimal sensor locations. Two optimization algorithms were utilized: complete enumeration and a genetic algorithm. The algorithms were executed for number of additional sensors varying from 1 to 5. The related folder sampling_location_bad is corresponding to the pseudo A-optimal sensor location method. 

**7_stochastic_demands**

Generates stochastic demands for each network node and update the net3 network. Two .R files need to be executed sequentially.

**8_measurements_generation**

Generates the net3 synthetic measurements by running the network with updated demand patterns and adding measurement error. Just need to run the 3 steps sequentially. The folder with name _bad is corresponding to the pseudo A optimal sensor location.

**9_random_cluster_generation**

Generates the random clusters for the net3. There are 3 .R files inside to be executed sequentially.

**10_demand_estimation**

Stores the necessary files to proceed the demand estimation for each condition. In total 100 cluster scenarios were estimated for each sensor location. Each of those demand estimations were made in a different folder composed by 7 files:

pumps_free_estimation_v3.00

estimation_options.csv

global_pattern.csv

Net3_4DMA_static_reservoirs.inp

standard_errors.csv

node_cluster_list.csv

sensor_data_3.0.csv

The sensor location files ending with _bad are corresponding to the pseudo A optimal sensor location.

**11_summary**

Stores the results from the demand estimation. Each zip file is corresponding to one sensor location situation. The zip with _bad is corresponding to the pseudo A optimal sensor location.
