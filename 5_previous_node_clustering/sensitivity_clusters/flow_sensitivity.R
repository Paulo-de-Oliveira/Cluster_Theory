
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
previous_cluster_folder = "5_previous_node_clustering"
epanet_folder = "4_typical_pump_situations"
sensitivity_folder = "5_previous_node_clustering/sensitivity_clusters"

library(epanet2toolkit)

#Define here which case you want
epanet_case = "hour443"
# epanet_case = "hour448"
# epanet_case = "hour454"
# epanet_case = "hour481"

#Define the cluster case you want
cluster_case = 9


rptFile = "rpt.rpt"
inpFile = paste("Net3_", epanet_case, ".inp", 
                sep = "")
sensitivity_file = paste("Q_sensitivity_",
                         cluster_case, 
                         "clusters_",
                         epanet_case, ".csv",
                         sep = "")
cluster_case_file = paste("node_clustering_", 
                          cluster_case,".csv",
                          sep = "")

previous_cluster_folder = paste(common_folder, 
                      previous_cluster_folder,
                     sep = "")
epanet_folder = paste(common_folder, epanet_folder,
                     sep = "")
sensitivity_folder = paste(common_folder, sensitivity_folder,
                      sep = "")

##################################################
########## Loading the previous cluster ##########
##################################################
setwd(previous_cluster_folder)
clusters_list = read.table(cluster_case_file,
                          sep = ",", header = FALSE)

##################################################
######### Simulations for the base case ##########
##################################################
setwd(epanet_folder)

base_model_H = NULL
base_model_Q = NULL
base_model_d = NULL
node_id_list = NULL
link_id_list = NULL
demand_node_id_list = NULL

#Runing the base simulation
ENopen(inpFile, rptFile)

n_nodes = ENgetcount("EN_NODECOUNT")
n_links = ENgetcount("EN_LINKCOUNT")

ENsolveH()

for(i in 1:n_nodes){
  node_id = ENgetnodeid(i)
  base_model_H = c(base_model_H, 
                   ENgetnodevalue(i, "EN_HEAD"))
  base_model_d = c(base_model_d,
                   ENgetnodevalue(i, "EN_BASEDEMAND"))
  node_id_list = c(node_id_list, node_id)
  
  if(ENgetnodevalue(i, "EN_BASEDEMAND")>0){
    demand_node_id_list = c(demand_node_id_list,
                            node_id)
  }
  
}
n_demand_nodes = length(demand_node_id_list)

for(i in 1:n_links){
  link_id = ENgetlinkid(i)
  base_model_Q = c(base_model_Q, 
                   ENgetlinkvalue(i, "EN_FLOW"))
  link_id_list = c(link_id_list, link_id)
}

ENclose()

# write.table(node_id_list,
#             file = "node_id_list.csv",
#             sep = ",", row.names = FALSE,
#             col.names = FALSE)
# write.table(demand_node_id_list,
#             file = "demand_node_id_list.csv",
#             sep = ",", row.names = FALSE,
#             col.names = FALSE)
# write.table(link_id_list,
#             file = "link_id_list.csv",
#             sep = ",", row.names = FALSE,
#             col.names = FALSE)

##################################################
########## Simulations per demand node ##########
##################################################

mean_base_demand = 178.7482
perturbation = mean_base_demand/10^2

n_clusters = max(clusters_list[,2])

ENopen(inpFile, rptFile)

H_sensitivity = NULL
Q_sensitivity = NULL

for(i in 1:n_clusters){

  model_H = NULL
  model_Q = NULL

  pos = which(clusters_list[,2] == i)  
  node_ids = as.character(clusters_list[pos,1])
  n_nodes_on_cluster = length(node_ids)

  total_cluster_demand = 0
  for(j in 1:n_nodes_on_cluster){
    node_id = node_ids[j]
    node_index = ENgetnodeindex(node_id)
    total_cluster_demand = total_cluster_demand +
                           base_model_d[node_index]
  }

  for(j in 1:n_nodes_on_cluster){
    node_id = node_ids[j]
    node_index = ENgetnodeindex(node_id)
    base_d = base_model_d[node_index]
    demand_to_set = base_d + perturbation/total_cluster_demand*base_d
    ENsetnodevalue(node_index, "EN_BASEDEMAND", 
                   demand_to_set)
  }

  ENsolveH()
    
  for(j in 1:n_nodes){
    model_H = c(model_H, ENgetnodevalue(j, "EN_HEAD"))
  }
  H_sensitivity = rbind(H_sensitivity, model_H - base_model_H)
    
  for(j in 1:n_links){
    model_Q = c(model_Q, ENgetlinkvalue(j, "EN_FLOW"))
  }
  Q_sensitivity = rbind(Q_sensitivity, model_Q - base_model_Q)
  
  for(j in 1:n_nodes_on_cluster){
    node_id = node_ids[j]
    node_index = ENgetnodeindex(node_id)
    ENsetnodevalue(node_index, "EN_BASEDEMAND", 
                   base_model_d[node_index])
  }  
}

ENclose()

H_sensitivity = H_sensitivity / perturbation
Q_sensitivity = Q_sensitivity / perturbation
colnames(H_sensitivity) = node_id_list
colnames(Q_sensitivity) = link_id_list

setwd(sensitivity_folder)
write.table(Q_sensitivity, 
            file = sensitivity_file,
            sep = ",", row.names = FALSE,
            col.names = FALSE)
