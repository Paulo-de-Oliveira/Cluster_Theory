
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
input_folder = "4_typical_pump_situations"

input_folder = paste(common_folder, input_folder, 
                     sep = "")
setwd(input_folder)

library(epanet2toolkit)

#Define here which case you want
epanet_case = "hour443"
epanet_case = "hour448"
epanet_case = "hour454"
epanet_case = "hour481"

rptFile = "rpt.rpt"
inpFile = paste("Net3_", epanet_case, ".inp", 
                sep = "")
sensitivity_file = paste("Q_sensitivity_",
                         epanet_case, ".csv",
                         sep = "")


##################################################
######### Simulations for the base case ##########
##################################################

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


ENopen(inpFile, rptFile)

H_sensitivity = NULL
Q_sensitivity = NULL
demand_node_id_list = NULL

for(i in 1:n_nodes){

  model_H = NULL
  model_Q = NULL
  
  if(base_model_d[i]>0){
    
    node_id = ENgetnodeid(i)
    demand_node_id_list = c(demand_node_id_list, node_id)
    
    
    demand_to_set = base_model_d[i] + perturbation
    ENsetnodevalue(i, "EN_BASEDEMAND", demand_to_set)
    
    ENsolveH()
    
    for(j in 1:n_nodes){
      model_H = c(model_H, ENgetnodevalue(j, "EN_HEAD"))
    }
    H_sensitivity = rbind(H_sensitivity, model_H - base_model_H)
    
    for(j in 1:n_links){
      model_Q = c(model_Q, ENgetlinkvalue(j, "EN_FLOW"))
    }
    Q_sensitivity = rbind(Q_sensitivity, model_Q - base_model_Q)
    
    ENsetnodevalue(i, "EN_BASEDEMAND", base_model_d[i])
    
  }
}
n_demand_nodes = length(demand_node_id_list)

ENclose()

H_sensitivity = H_sensitivity / perturbation
Q_sensitivity = Q_sensitivity / perturbation
row.names(H_sensitivity) = demand_node_id_list
row.names(Q_sensitivity) = demand_node_id_list
colnames(H_sensitivity) = node_id_list
colnames(Q_sensitivity) = link_id_list

write.table(Q_sensitivity, 
            file = sensitivity_file,
            sep = ",", row.names = FALSE,
            col.names = FALSE)
