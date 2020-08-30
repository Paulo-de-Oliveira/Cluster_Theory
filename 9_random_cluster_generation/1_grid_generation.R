
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
input_folder = "9_random_cluster_generation"

input_folder = paste(common_folder, input_folder,
                     sep = "")

library(sp)
library(igraph)

setwd(input_folder)

##Reading the boundary from file
boundary = read.table(file = "boundary.csv", 
                      header = FALSE, sep = ",")
boundary = as.matrix(boundary)

##Creating the grid points
network_area = SpatialPolygons(list(Polygons(list(Polygon(boundary)), "x")))
grid_points = spsample(network_area, n = 1000, "regular")
grid_coords = coordinates(grid_points)

plot(network_area)
points(grid_points, pch = 3, cex = 0.2)

##Simplifying the grid into integer coordinates
summary_x = table(grid_coords[,1])
x_values = as.numeric(rownames(as.matrix(summary_x)))
x_step = x_values[2] - x_values[1]
summary_y = table(grid_coords[,2])
y_values = as.numeric(rownames(as.matrix(summary_y)))
y_step = y_values[2] - y_values[1]

##Creating the adjacency matrix
x_vector = round((grid_coords[,1] - x_values[1])/x_step)
y_vector = round((grid_coords[,2] - y_values[1])/y_step)
n_points = length(x_vector)

xy_names = NULL
for(i in 1:n_points){
  xy_names = c(xy_names, paste(x_vector[i], "-", y_vector[i], sep = ""))
}
  
adj_matrix = matrix(0, nrow = n_points, ncol = n_points)

for(i in 1:n_points){
  for(j in 1:n_points){
    
    x1 = x_vector[i]
    y1 = y_vector[i]
    x2 = x_vector[j]
    y2 = y_vector[j]
    x_dist = abs(x1-x2)
    y_dist = abs(y1-y2)
    
    #vertical unitary line
    if(x_dist == 0 & y_dist == 1){
      adj_matrix[i,j] = 1
    }
    #horizontal unitary line
    if(x_dist == 1 & y_dist == 0){
      adj_matrix[i,j] = 1
    }
    #diagonal unitary line
    if(x_dist == 1 & y_dist == 1){
      adj_matrix[i,j] = round(sqrt(2),2)
    }
    #diagonal 2:1 line
    if(x_dist == 2 & y_dist == 1){
      adj_matrix[i,j] = round(sqrt(5),2)
    }
    #diagonal 1:2 line
    if(x_dist == 1 & y_dist == 2){
      adj_matrix[i,j] = round(sqrt(5),2)
    }
    
  }  
}
colnames(adj_matrix) = xy_names
rownames(adj_matrix) = xy_names

# create graph from adjacency matrix
network_graph = graph.adjacency(adj_matrix, weighted=TRUE)
#plot(network_graph)

# Get all path distances
shortest_paths = distances(network_graph, 
                           algorithm = "dijkstra")
header_file = data.frame(xy_names, grid_coords)


##Writing the results to files
# write.table(adj_matrix, "adj_matrix.csv",
#             sep = ",")
write.table(shortest_paths, "shortest_paths.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)
write.table(header_file, "grid_coordinates.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)
