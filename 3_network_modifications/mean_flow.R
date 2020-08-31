
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
epanet_folder = "3_network_modifications"
epanet_folder = paste(common_folder, epanet_folder,
                      sep = "")

setwd(epanet_folder)

library(epanet2toolkit)

inpFile = "Net3_4DMA_south x2.5_north x3.5_min.level=0_max.level plus 10ft.inp"
rptFile = "rpt.rpt"

model_Q = NULL
time = NULL

#Runing the base simulation
ENopen(inpFile, rptFile)

n_links = ENgetcount("EN_LINKCOUNT")
flow_vector = rep(0, n_links)

link_id_list = NULL
for(i in 1:n_links){
  link_id_list = c(link_id_list, ENgetlinkid(i))
}

t = NULL
ENopenH()
ENinitH(11)
repeat {
  t <- ENrunH()
  
  if(t%%3600 == 0){
    
    for(i in 1:n_links){
      flow_vector[i] = ENgetlinkvalue(i, "EN_FLOW")
    }
    model_Q = rbind(model_Q, flow_vector)
    time = c(time, t)
  }
  
  tstep <- ENnextH()
  if (tstep == 0) {
    break
  }
}
ENcloseH()
ENclose()

time = as.character(time)
colnames(model_Q) = link_id_list
row.names(model_Q) = time

#write.csv(model_Q, file = "model_Q.csv")

model_Q_abs = abs(model_Q)

links_mean = NULL
for(i in 1:n_links){
  link_flow = model_Q_abs[,i]
  links_mean = rbind(links_mean, 
                     mean(link_flow[link_flow!=0]))
}
row.names(links_mean) = link_id_list

write.table(links_mean, file = "model_Q_mean.csv", 
          row.names = TRUE, col.names = FALSE,
          sep = ",")
