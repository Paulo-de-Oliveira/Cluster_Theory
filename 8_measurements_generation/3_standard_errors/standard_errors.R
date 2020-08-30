
##Files and paths
common_path = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
epanet_folder = "7_stochastic_demands"
output_folder = "8_measurements_generation/3_standard_errors"

inpFile = "Net3_updated_patterns.inp"
rptFile = "rpt.rpt"

##Folder names
epanet_folder = paste(common_path, epanet_folder, sep = "")
output_folder = paste(common_path, output_folder, sep = "")

##Generating a random seed
seed = sample.int(n = 10000, size = 1, replace = FALSE, prob = NULL)
set.seed(seed)
#######Important line####
set.seed(4713) 

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

total_time = ENgettimeparam("EN_DURATION")/3600

ENclose()


##Generating the data errors
Q_error = NULL
L_error = NULL
H_error = NULL
F_error = NULL
B_error = NULL
C_error = NULL
Q_header = NULL
L_header = NULL
H_header = NULL
F_header = NULL
B_header = NULL
C_header = NULL

ENopen(inpFile, rptFile)

for(i in 1:n_nodes){
  node_type = ENgetnodetype(i)
  errors = rnorm(total_time+1, mean = 0, sd = 1)
  if(node_type == 0){
    B_error = cbind(B_error, errors)
    B_header = c(B_header, node_id_list[i])
  }
  if(node_type == 1){
    H_error = cbind(H_error, errors)
    H_header = c(H_header, node_id_list[i])
  }
  if(node_type == 2){
    L_error = cbind(L_error, errors)
    L_header = c(L_header, node_id_list[i])
  }
}

for(i in 1:n_links){
  link_type = ENgetlinktype(i)
  errors = rnorm(total_time+1, mean = 0, sd = 1)
  zeros = rep(0, total_time+1)
  if(link_type == 1){
    Q_error = cbind(Q_error, errors)
    Q_header = c(Q_header, link_id_list[i])
  }
  if(link_type == 2){
    F_error = cbind(F_error, errors)
    F_header = c(F_header, link_id_list[i])
    C_error = cbind(C_error, zeros)
    C_header = c(C_header, link_id_list[i])
  }
}

ENclose()

##Configure the column names
colnames(B_error) = B_header
colnames(H_error) = H_header
colnames(L_error) = L_header
colnames(Q_error) = Q_header
colnames(F_error) = F_header
colnames(C_error) = C_header

##Changing the working directory
setwd(output_folder)


##Saving the results
write.table(B_error, file = "B_error.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(H_error, file = "H_error.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(L_error, file = "L_error.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(Q_error, file = "Q_error.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(F_error, file = "F_error.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
write.table(C_error, file = "C_error.csv", 
            row.names = FALSE, col.names = TRUE,
            sep = ",")
