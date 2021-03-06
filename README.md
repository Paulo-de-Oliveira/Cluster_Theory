# Cluster_Theory

This repository contains all data, codes and outputs that were utilized for the Cluster Theory paper which was published at JWRPM.

The folders are organized sequentially under the execution order. Since there are multiple dependencies between source codes inside different folders you should execute the project in the suggested order.

Follow bellow a brief description of the reasoning behind each folder and their main files.

**2_pattern_generation**

Generates correlated demand pattern for each network cluster based on a SARMA time series model

**3_network_modifications**

Modify the net3 network according to the objectives of the current paper. Also include additional shortcut files that will be utilized further.

**4_typical_pump_situations**

Choose 4 simulation hours as typical pump situations. The choice is made using an excel worksheet. In addition, 4 epanet files were generated with a static simulation for those 4 chosen hours and the further sensitivity matrices were calculated.

**5_previous_node_clustering**

Generates a previous separation for the network nodes using the k-mean. Inside the folder there is also a sub-folder that calculates the sensitivity of each pipe flow regarding the previous node groups. The sensitivities were calculated for 4 previously selectec hours which represent different pump status combinations.

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
