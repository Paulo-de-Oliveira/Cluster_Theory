
##################################################
############### Initial definitions ##############
##################################################

common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
epanet_folder = "3_network_modifications"
pattern_folder = "2_pattern_generation"
output_folder = "7_stochastic_demands"
input_file = "base_demands.csv"

epanet_folder = paste(common_folder, epanet_folder, sep = "")
pattern_folder = paste(common_folder, pattern_folder, sep = "")
output_folder = paste(common_folder, output_folder, sep = "")

#PRP parameters
E_pulse_volume = 6.43 #Liters
Var_pulse_volume = 159.31 #Liters^2
Mean_arrival = 0.052 #pulses/min/res
duration = 60 #minutes

##Generating a random seed
seed = sample.int(n = 10000, size = 1, replace = FALSE, prob = NULL)
set.seed(seed)
#######Important line####
set.seed(6959) 

##################################################
################ Loading the data ################
##################################################

##Loading the actual clusters
setwd(epanet_folder)
actual_clusters = read.table(file = "actual_clusters.csv", 
                             header = FALSE, sep =",")
actual_clusters = actual_clusters[,1]
n_nodes = length(actual_clusters)

##Loading the demand patterns
setwd(pattern_folder)
demand_patterns = read.table(file = "simulated_patterns_two_days.csv", 
                             header = FALSE, sep =",")

##Subset the patterns for the last 3 weeks
simulation_time = 504
n = nrow(demand_patterns)
range = (n-simulation_time+1):n
demand_patterns = as.matrix(demand_patterns[range,])

##Loading the base demands in gal/min
setwd(epanet_folder)
base_demands = read.table(file = input_file, 
                          header = FALSE)
base_demands = as.vector(base_demands[,1])


##Calculating the number of residences
##From 2007 Filion
#Hour_flow = 1/duration * N * 
           #(arrival_rate * duration) *
           #E_pulse_volume
#Then
#N = Hour_flow / arrival_rate / E_pulse_volume
## 3.78541 Converts from gal/min to L/min
n_houses = base_demands * 3.78541 / 
               (Mean_arrival * E_pulse_volume)

demand_matrix = NULL
non_zero_demands = NULL
for(node in 1:n_nodes){
  
  demand_vector = NULL
  base_demand = base_demands[node]
  

  if(base_demand > 0){
    
    cluster = actual_clusters[node]
    non_zero_demands = cbind(non_zero_demands,
                             rep(base_demand, simulation_time))
    
    for(hour in 1:simulation_time){
      
      pattern = demand_patterns[hour, cluster]
      arrival = Mean_arrival * pattern
      
      #Calculating the variance in (L/min)^2
      #Converting the variance to (gal/min)^2
      nodal_var = 1/duration^2 * n_houses[node] * arrival * 
        duration * (E_pulse_volume^2 + Var_pulse_volume)/(3.78541^2)
      
      demand = pattern * base_demand
      variability = rnorm(n=1, mean = 0, sd = sqrt(nodal_var))
      demand = demand + variability
        
      demand_vector = c(demand_vector, demand)

    }
    
    demand_matrix = cbind(demand_matrix, demand_vector)
  }
}

pattern_matrix = demand_matrix/non_zero_demands


#Save the pattern matrix to file
setwd(output_folder)
write.table(pattern_matrix, file = "pattern_matrix.csv", 
            sep = ",", row.names = FALSE, 
            col.names = FALSE)
