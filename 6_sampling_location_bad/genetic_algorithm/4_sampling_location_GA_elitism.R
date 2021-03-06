
common_folder = "C:/Users/oliveipa/Dropbox/Cluster project - Clean/"
design_folder = "6_sampling_location_bad/results"
sensitivity_folder = "4_typical_pump_situations"
epanet_folder = "3_network_modifications"

library(MASS) #necessary for ginv() function

#Define the number of additional sensors
n_additional_sensors = 4

possible_links_file = "results_4flow.csv"

design_folder = paste(common_folder, design_folder,
                      sep = "")
sensitivity_folder = paste(common_folder, sensitivity_folder,
                           sep = "")
epanet_folder = paste(common_folder, epanet_folder,
                      sep = "")

##################################################
############# Link and node id lists #############
##################################################
setwd(epanet_folder)
node_id_list = read.table("node_id_list.csv", 
                          header = FALSE,
                          sep = ",",
                          colClasses = "character")
demand_node_id_list = read.table("demand_node_id_list.csv", 
                          header = FALSE,
                          sep = ",",
                          colClasses = "character")
link_id_list = read.table("link_id_list.csv", 
                          header = FALSE,
                          sep = ",",
                          colClasses = "character")

node_id_list = node_id_list[,1]
demand_node_id_list = demand_node_id_list[,1]
link_id_list = link_id_list[,1]

n_nodes = length(node_id_list)
n_demand_nodes = length(demand_node_id_list)
n_links = length(link_id_list)

##################################################
######### Get flow sensitivity from file #########
##################################################
setwd(sensitivity_folder)
Q_sensitivity1 = read.table("Q_sensitivity_hour443.csv",
                            sep = ",")
Q_sensitivity2 = read.table("Q_sensitivity_hour448.csv",
                            sep = ",")
Q_sensitivity3 = read.table("Q_sensitivity_hour454.csv",
                            sep = ",")
Q_sensitivity4 = read.table("Q_sensitivity_hour481.csv",
                            sep = ",")

Q_sensitivity1 = as.matrix(Q_sensitivity1)
Q_sensitivity2 = as.matrix(Q_sensitivity2)
Q_sensitivity3 = as.matrix(Q_sensitivity3)
Q_sensitivity4 = as.matrix(Q_sensitivity4)         

##################################################
############ Flow standard deviation ############
##################################################
setwd(epanet_folder)
links_mean = read.table(file = "model_Q_mean.csv",
                        sep = ",", header = FALSE)

sd_fraction = 5/100
links_sd = sd_fraction*links_mean[,2]
min_sd = 1 #equivalent to 20 gal/min, 50mm pipe with v=0.64m/s
change_pos = which(links_sd < min_sd)

links_sd_lim = links_sd
links_sd_lim[change_pos] = min_sd
links_var_lim = links_sd_lim^2

##################################################
###### Objective function ######
##################################################


objective_function = function(additional_sensors){
  
  sensor_ids = c(sensors_already_installed,
                 as.character(additional_sensors))
  
  #Determining the covariance of the sensors
  sensor_pos = match(sensor_ids, link_id_list)
  measurement_var = diag(links_var_lim[sensor_pos])
  measurement_var_inverse = solve(measurement_var)
  
  demand_variance = 0
  
  #Epanet case 1
  Q_sensitivity_sensors = Q_sensitivity1[,sensor_pos]
  for(k in 1:n_demand_nodes){
    sigma2 = Q_sensitivity_sensors[k,] %*%
      measurement_var_inverse %*%
      cbind(Q_sensitivity_sensors[k,])
    sigma2 = 1 / sigma2
    demand_variance = demand_variance + sigma2
  }
  
  #Epanet case 2
  Q_sensitivity_sensors = Q_sensitivity2[,sensor_pos]
  for(k in 1:n_demand_nodes){
    sigma2 = Q_sensitivity_sensors[k,] %*%
      measurement_var_inverse %*%
      cbind(Q_sensitivity_sensors[k,])
    sigma2 = 1 / sigma2
    demand_variance = demand_variance + sigma2
  }
  
  #Epanet case 3
  Q_sensitivity_sensors = Q_sensitivity3[,sensor_pos]
  for(k in 1:n_demand_nodes){
    sigma2 = Q_sensitivity_sensors[k,] %*%
      measurement_var_inverse %*%
      cbind(Q_sensitivity_sensors[k,])
    sigma2 = 1 / sigma2
    demand_variance = demand_variance + sigma2
  }
  
  #Epanet case 4
  Q_sensitivity_sensors = Q_sensitivity4[,sensor_pos]
  for(k in 1:n_demand_nodes){
    sigma2 = Q_sensitivity_sensors[k,] %*%
      measurement_var_inverse %*%
      cbind(Q_sensitivity_sensors[k,])
    sigma2 = 1 / sigma2
    demand_variance = demand_variance + sigma2
  }
  
  return(demand_variance/4)
}

##################################################
######### Genetic Algorithm Optimization #########
##################################################
nodes_pos = match(demand_node_id_list ,node_id_list)

#Vectors defined manually one by one
sensors_already_installed = c("20", "40", "50", 
                              "10", "329")
similar_pipes = c("60","330","333","125",
                  "133","101","335","201",
                  "289")

#Subsetting the sensors to search
sensors_to_search = link_id_list
remove_sensors = c(sensors_already_installed,
                   similar_pipes)
pos = match(remove_sensors, sensors_to_search)
sensors_to_search = sensors_to_search[-pos]
n_sensors = length(sensors_to_search)



#Parameters for the GA
population_size = 100
crossover_prob = 0.7
mutation_prob = 0.2
elitism = 88
n_generations = 20
limit_fitness_evaluations = 5000

##Optimizing the genetic parameters
range1 = c(50, 100, 200)
range2 = c(0.5, 0.7, 0.9)
range3 = c(0.01, 0.05, 0.2, 0.5)
range4 = c(4, 16, 48, 88)

results = NULL

for(population_size in range1){
for(crossover_prob in range2){
for(mutation_prob in range3){
for(elitism in range4){

  summary_found_answer = NULL

  n_elite = elitism * population_size / 100
  n_evolve = population_size - n_elite
    
for(trial in 1:2){
  
  found_answer = 1

  fitness_evaluations = 0
  
  #Generate a random genetic population
  population = NULL
  for(i in 1:population_size){
    individual = as.numeric(sample(sensors_to_search, 
                                   size = n_additional_sensors,
                                   replace = FALSE))
    fitness = objective_function(individual)
    fitness_evaluations = fitness_evaluations + 1
    population = rbind(population, 
                       c(individual,fitness))
  }
  
  fitness_values = population[,n_additional_sensors+1]
  population = population[order(fitness_values),]
  previous_best_fitness = population[1,n_additional_sensors+1]
  solution = c(population_size,
               crossover_prob,
               mutation_prob,
               elitism,
               population[1,], 
               fitness_evaluations)

  generations = 0
  #Evolve the population
  while(fitness_evaluations < limit_fitness_evaluations){

    fitness_values = population[,n_additional_sensors+1]
    inverse_fitness = 1/fitness_values
    selection_fitness = inverse_fitness/sum(inverse_fitness)*100
    
    new_population = NULL
    
    for(i in 1:(n_evolve/2)){
    
    some_duplicated = TRUE  
    
    while(some_duplicated == TRUE){
      
    #Selection of the parents
    parents = sample(1:population_size, size = 2,
                     replace = FALSE, 
                     prob = selection_fitness)
    
    mother = population[parents[1],1:n_additional_sensors]
    father = population[parents[2],1:n_additional_sensors]
    
    #Crossover step
    for(j in 1:n_additional_sensors){
      
      prob = runif(n=1, min=0, max=1)
      
      if(prob < crossover_prob){
        
        gene_mother = mother[j]
        gene_father = father[j]
        
        mother[j] = gene_father
        father[j] = gene_mother
      }
      
    }
    
    #Mutation
    for(j in 1:n_additional_sensors){
      
      prob = runif(n=1, min=0, max=1)
      if(prob < mutation_prob){
        mother[j] = as.numeric(sample(sensors_to_search, 
                                      size = 1))
      }
      
      prob = runif(n=1, min=0, max=1)
      if(prob < mutation_prob){
        father[j] = as.numeric(sample(sensors_to_search, 
                                      size = 1))
      }
      
    }
    
    mother_duplicated = any(duplicated(mother))
    father_duplicated = any(duplicated(father))
    
    if(mother_duplicated == FALSE & father_duplicated == FALSE){
      some_duplicated = FALSE
    }
    
    }#end of some duplicated loop
    
    #Adding the child to the population
    fitness_mother = objective_function(mother)
    fitness_father = objective_function(father)
    fitness_evaluations = fitness_evaluations + 2
    new_population = rbind(new_population, 
                       c(mother,fitness_mother))
    new_population = rbind(new_population, 
                       c(father,fitness_father))
    
    }#end of new_population creation
    
    #join the new population with previous elite
    new_population = rbind(new_population, 
                           population[1:n_elite,])
    
    
    #Order again
    fitness_values = new_population[,n_additional_sensors+1]
    new_population = new_population[order(fitness_values),]

    generations = generations + 1
    
    population = new_population
    
    actual_best_fitness = population[1,n_additional_sensors+1]
    
    if(actual_best_fitness < previous_best_fitness){
      found_answer = fitness_evaluations
      previous_best_fitness =  actual_best_fitness
      solution = c(population_size,
                   crossover_prob,
                   mutation_prob,
                   elitism,
                   population[1,], 
                   found_answer)
    }
    
    
  }#end of evolve populations
  
  summary_found_answer = rbind(summary_found_answer,
                               solution)
  
  
}  #end of trials
  
  results = rbind(results, summary_found_answer)
    
}
}  
}
}

setwd(design_folder)
write.table(results, possible_links_file, 
            sep = ",", row.names = FALSE,
            col.names = FALSE)




