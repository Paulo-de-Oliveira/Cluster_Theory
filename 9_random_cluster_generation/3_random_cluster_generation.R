
##Paths and files
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
output_folder = "9_random_cluster_generation"
epanet_folder = "3_network_modifications"

##Important parameters
n_clusters = 4
n_cases_total = 100
min_nodes_limit = 7 #half of the average size

output_folder = paste(common_folder, output_folder, sep = "")
epanet_folder = paste(common_folder, epanet_folder, sep = "")


seed = sample.int(n = 10000, size = 1, replace = FALSE, prob = NULL)
set.seed(seed)
#######Important line####
set.seed(1377)


##Loading the base demands
setwd(epanet_folder)

base_demands = read.table("base_demands.csv", 
                       header = FALSE,
                       sep = ",")
base_demands = base_demands[,1]
demand_nodes = which(base_demands > 0)
n_nodes = length(base_demands)

##Loading the grid and distance matrix
setwd(output_folder)

shortest_paths = read.table("shortest_paths.csv", 
                            header = FALSE,
                            sep = ",")
n_grid = nrow(shortest_paths)

##Loading the node grid association
node_grid = read.table("node_grid_association.csv", 
                       header = FALSE,
                       sep = ",")

##Generating the random clusters
tentatives = 0
n_cases = 0
cluster_cases = NULL

while(n_cases < n_cases_total){
  
  ##Generating a random cluster case
  cluster_centers = sample(1:n_grid, size = n_clusters, 
                           replace = FALSE)
  
  ##Finding the grid points membership
  membership = NULL
  dist_vector = rep(0, n_clusters)
  for(i in 1:n_grid){
    for(j in 1:n_clusters){
      center_index = cluster_centers[j]
      dist_vector[j] = shortest_paths[i, center_index]
    }
    membership = c(membership, which.min(dist_vector))
  }
  
  ##Finding the node points membership
  node_membership = NULL
  for(i in 1:n_nodes){
    position = node_grid[i,2]
    node_membership = c(node_membership, 
                        membership[position])
  }
  
  ##Finding if the generate cluster is suitable
  demand_nodes_membership = node_membership[demand_nodes]
  summary_cluster = table(demand_nodes_membership)
  mininum_nodes_count = min(summary_cluster)
  actual_n_clusters = length(summary_cluster)

  if(mininum_nodes_count >= min_nodes_limit & actual_n_clusters == n_clusters){
    cluster_cases = cbind(cluster_cases, node_membership)
    n_cases = n_cases + 1
  }
  tentatives =  tentatives + 1
}

##Save the cluster_cases to file
write.table(cluster_cases, "cluster_cases.csv", 
            sep = ",", row.names = FALSE,
            col.names = FALSE)




