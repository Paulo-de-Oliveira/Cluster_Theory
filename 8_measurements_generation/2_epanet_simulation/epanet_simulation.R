
##Files and paths
common_path = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
epanet_folder = "7_stochastic_demands"
output_folder = "8_measurements_generation/2_epanet_simulation"

inpFile = "Net3_updated_patterns.inp"
rptFile = "rpt.rpt"

##Folder names
epanet_folder = paste(common_path, epanet_folder, sep = "")
output_folder = paste(common_path, output_folder, sep = "")

##Activating the library
library(epanet2toolkit)

##Changing the working directory
setwd(epanet_folder)

##Creating the link and node lists
ENopen(inpFile, rptFile)

n_nodes = ENgetcount("EN_NODECOUNT")
n_tanks = ENgetcount("EN_TANKCOUNT")
node_id_list = NULL
for(i in 1:n_nodes){
  node_id_list = c(node_id_list, ENgetnodeid(i))
}

n_links = ENgetcount("EN_LINKCOUNT")
link_id_list = NULL
for(i in 1:n_links){
  link_id_list = c(link_id_list, ENgetlinkid(i))
}

ENclose()


###########################################
########## Runing the simulation ##########
###########################################

ENopen(inpFile, rptFile)

#Creating the provisory vectors
pressure_vector = rep(0, n_nodes)
head_vector = rep(0, n_nodes)
demand_vector = rep(0, n_nodes)
flow_vector = rep(0, n_links)
status_vector = rep(0, n_links)

#Creating the result matrices
pressure_matrix = NULL
head_matrix = NULL
demand_matrix = NULL
flow_matrix = NULL
status_matrix = NULL

##Running the simulation
time = NULL
t = NULL
ENopenH()
ENinitH(11)
repeat {
  t <- ENrunH()
  
  if(t%%3600 == 0){
    
    ##Gathering the data for the node
    for(i in 1:n_nodes){
      pressure_vector[i] = ENgetnodevalue(i, "EN_PRESSURE")
      head_vector[i] = ENgetnodevalue(i, "EN_HEAD")
      demand_vector[i] = ENgetnodevalue(i, "EN_DEMAND")
    }
    pressure_matrix = rbind(pressure_matrix, pressure_vector)
    head_matrix = rbind(head_matrix, head_vector)
    demand_matrix = rbind(demand_matrix, demand_vector)
    
    
    ##Gathering the data for the links
    for(i in 1:n_links){
      flow_vector[i] = ENgetlinkvalue(i, "EN_FLOW")
      status_vector[i] = ENgetlinkvalue(i, "EN_STATUS")
    }
    flow_matrix = rbind(flow_matrix, flow_vector)
    status_matrix = rbind(status_matrix, status_vector)
    
    time = c(time, t)
    
  }
  
  tstep <- ENnextH()
  if (tstep == 0) {
    break
  }
}
ENcloseH()
ENclose()

##Configure the count matrix
count = cbind(n_nodes, n_tanks, n_links)
colnames(count) = c("nodes", "tanks", "links")

##Configure the row and column names
time = time / 3600
time = as.character(time)
rownames(pressure_matrix) = time
rownames(head_matrix) = time
rownames(demand_matrix) = time
rownames(flow_matrix) = time
rownames(status_matrix) = time
colnames(pressure_matrix) = node_id_list
colnames(head_matrix) = node_id_list
colnames(demand_matrix) = node_id_list
colnames(flow_matrix) = link_id_list
colnames(status_matrix) = link_id_list

##Changing the working directory
setwd(output_folder)

##Saving the results
write.table(count, file = "count.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(pressure_matrix, file = "pressure.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(head_matrix, file = "head.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(demand_matrix, file = "demand.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(flow_matrix, file = "flow.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(status_matrix, file = "status.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
