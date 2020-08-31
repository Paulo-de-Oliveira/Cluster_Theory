
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
input_folder = "3_network_modifications"

input_folder = paste(common_folder, input_folder, 
                     sep = "")

##Loading the inp file and id lists
setwd(input_folder)

library(epanet2toolkit)

rptFile = "rpt.rpt"
inpFile = "Net3_4DMA_static_reservoirs.inp"

base_model_d = NULL
node_id_list = NULL
link_id_list = NULL
demand_node_id_list = NULL

#Runing the base simulation
ENopen(inpFile, rptFile)

n_nodes = ENgetcount("EN_NODECOUNT")
n_links = ENgetcount("EN_LINKCOUNT")

for(i in 1:n_nodes){
  node_id = ENgetnodeid(i)
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
  link_id_list = c(link_id_list, link_id)
}

ENclose()

##Writing the results to file
write.table(node_id_list,
            file = "node_id_list.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)
write.table(demand_node_id_list,
            file = "demand_node_id_list.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)
write.table(link_id_list,
            file = "link_id_list.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)
write.table(base_model_d,
            file = "base_demands.csv",
            sep = ",", row.names = FALSE,
            col.names = FALSE)

