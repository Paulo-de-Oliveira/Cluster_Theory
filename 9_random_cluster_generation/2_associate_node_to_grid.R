
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
output_folder = "9_random_cluster_generation"
epanet_folder = "3_network_modifications"

output_folder = paste(common_folder, output_folder,
                     sep = "")
epanet_folder = paste(common_folder, epanet_folder,
                     sep = "")

##Loading the grid coordinates
setwd(output_folder)

grid_coordinates = read.table("grid_coordinates.csv", 
                              header = FALSE,
                              sep = ",")
n_grid = nrow(grid_coordinates)

##Loading the node coordinates
setwd(epanet_folder)

node_coordinates = read.table("node_coordinates.csv", 
                              header = FALSE,
                              sep = ",")
n_nodes = nrow(node_coordinates)

##Associating the nodes with the grid
##node_grid stores for each node which grid point is associated
node_grid = NULL
for(i in 1:n_nodes){
  node_x = node_coordinates[i,2]
  node_y = node_coordinates[i,3]
  
  dist_node_grid = NULL
  for(j in 1:n_grid){
    grid_x = grid_coordinates[j,2]
    grid_y = grid_coordinates[j,3]
    
    dist = sqrt((node_x - grid_x)^2 + (node_y - grid_y)^2)
    dist_node_grid = c(dist_node_grid, dist)
  }
  
  node_grid = c(node_grid,which.min(dist_node_grid))
  
}

#Saving the node_grid to file
setwd(output_folder)
node_grid = data.frame(node_coordinates[,1],node_grid)
write.table(node_grid, file = "node_grid_association.csv",
            sep = ",", row.names = FALSE, col.names = FALSE)


