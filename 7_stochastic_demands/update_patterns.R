
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
input_folder = "7_stochastic_demands"

input_folder = paste(common_folder, input_folder, sep = "")

##Loading patterns file
setwd(input_folder)

patterns = read.table(file = "pattern_matrix.csv", 
                      header = FALSE, sep = ",")
patterns = as.matrix(patterns)
simulation_time = nrow(patterns)

library(epanet2toolkit)
rptFile = "rpt.rpt"
inpFile = "Net3_zero_patterns.inp"

#Runing the base simulation
ENopen(inpFile, rptFile)

n_nodes = ENgetcount("EN_NODECOUNT")

node_column = 1

for(i in 1:n_nodes){
  
  node_id = ENgetnodeid(i)
  base_demand = ENgetnodevalue(i, "EN_BASEDEMAND")
  
  if(base_demand > 0){
    
    pattern_index = ENgetpatternindex(node_id)
    
    for(j in 1:simulation_time){
      pattern_value = patterns[j,node_column]
      ENsetpatternvalue(pattern_index, j, pattern_value)
    }
    
    node_column = node_column + 1
    
  }
  
}

ENsaveinpfile("Net3_updated_patterns.inp")


ENclose()
