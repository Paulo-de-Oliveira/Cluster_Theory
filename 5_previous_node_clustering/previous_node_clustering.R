
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
network_folder = "3_network_modifications"
sensitivity_folder = "4_typical_pump_situations"
output_folder = "5_previous_node_clustering"

network_folder = paste(common_folder, network_folder,
                     sep = "")
sensitivity_folder = paste(common_folder, sensitivity_folder,
                     sep = "")
output_folder = paste(common_folder, output_folder,
                     sep = "")

##################################################
######### Get flow sensitivity from file #########
##################################################

setwd(network_folder)

demand_node_id_list = read.table("demand_node_id_list.csv", 
                                 header = FALSE,
                                 sep = ",",
                                 colClasses = "character")

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

# Q_sensitivity = Q_sensitivity1
Q_sensitivity = cbind(Q_sensitivity1,
                      Q_sensitivity2,
                      Q_sensitivity3,
                      Q_sensitivity4)

##################################################
############ Fit the kmeans clustering ###########
##################################################

setwd(output_folder)
library(fpc)

## K-Means - 9 clusters
fit = kmeans(Q_sensitivity, centers = 9,
             nstart = 100) 
table(fit$cluster)
plotcluster(Q_sensitivity, fit$cluster)
groups = data.frame(demand_node_id_list,fit$cluster)

write.table(groups, 
            file = "node_clustering_9.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)

## K-Means - 8 clusters
fit = kmeans(Q_sensitivity, centers = 8,
             nstart = 100) 
table(fit$cluster)
plotcluster(Q_sensitivity, fit$cluster)
groups = data.frame(demand_node_id_list,fit$cluster)

write.table(groups, 
            file = "node_clustering_8.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)

## K-Means - 7 clusters
fit = kmeans(Q_sensitivity, centers = 7,
             nstart = 100) 
table(fit$cluster)
plotcluster(Q_sensitivity, fit$cluster)
groups = data.frame(demand_node_id_list,fit$cluster)

write.table(groups, 
            file = "node_clustering_7.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)

## K-Means - 6 clusters
fit = kmeans(Q_sensitivity, centers = 6,
             nstart = 100) 
table(fit$cluster)
plotcluster(Q_sensitivity, fit$cluster)
groups = data.frame(demand_node_id_list,fit$cluster)

write.table(groups, 
            file = "node_clustering_6.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)

## K-Means - 5 clusters
fit = kmeans(Q_sensitivity, centers = 5,
             nstart = 100) 
table(fit$cluster)
plotcluster(Q_sensitivity, fit$cluster)
groups = data.frame(demand_node_id_list,fit$cluster)

write.table(groups, 
            file = "node_clustering_5.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)

## K-Means - 4 clusters
fit = kmeans(Q_sensitivity, centers = 4,
             nstart = 100) 
table(fit$cluster)
plotcluster(Q_sensitivity, fit$cluster)
groups = data.frame(demand_node_id_list,fit$cluster)

write.table(groups, 
            file = "node_clustering_4.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)
