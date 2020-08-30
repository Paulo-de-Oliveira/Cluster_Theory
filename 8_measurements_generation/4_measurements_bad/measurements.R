
##Files and paths
common_path = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
input_folder = "8_measurements_generation/2_epanet_simulation"
error_folder = "8_measurements_generation/3_standard_errors"
output_folder = "8_measurements_generation/4_measurements_bad"

##Folder names
input_folder = paste(common_path, input_folder, sep = "")
error_folder = paste(common_path, error_folder, sep = "")
output_folder = paste(common_path, output_folder, sep = "")

##Defining the existing sensors
Q_sensors = c("20", "40", "50") #pipe flow
L_sensors = c("1", "2", "3") #tank head
H_sensors = c("River", "Lake") #reservoir head
F_sensors = c("10", "329") #pump flow
B_sensors = c("10", "61") #pump outlet head
C_sensors = c("10", "335") #status

##Defining different cases
# monitoring_case = "1flow"
# Q_sensors = c(Q_sensors, "159")
# monitoring_case = "2flow"
# Q_sensors = c(Q_sensors, "159", "325")
# monitoring_case = "3flow"
# Q_sensors = c(Q_sensors, "159", "325", "204")
# monitoring_case = "4flow"
# Q_sensors = c(Q_sensors, "159", "325", "204", "197")
monitoring_case = "5flow"
Q_sensors = c(Q_sensors, "159", "325", "204", "197", "131")

##Output file names
measurements_file = paste("measurements_", 
                          monitoring_case, ".csv", sep = "")
global_pattern_file = "global_pattern.csv"

##Changing the working directory
setwd(input_folder)

##Reading the simulation files
count = read.table(file = "count.csv", 
            header = TRUE, sep = ",", 
            check.names = FALSE)
pressure_matrix = read.table(file = "pressure.csv", 
                        header = TRUE, sep = ",", 
                        check.names = FALSE)
head_matrix = read.table(file = "head.csv", 
                    header = TRUE, sep = ",", 
                    check.names = FALSE)
demand_matrix = read.table(file = "demand.csv", 
                      header = TRUE, sep = ",", 
                      check.names = FALSE)
flow_matrix = read.table(file = "flow.csv", 
                    header = TRUE, sep = ",", 
                    check.names = FALSE)
status_matrix = read.table(file = "status.csv", 
                      header = TRUE, sep = ",", 
                      check.names = FALSE)
n_hours = nrow(status_matrix)

##Changing the working directory
setwd(error_folder)

##Reading the error files
B_error_matrix = read.table(file = "B_error.csv", 
                             header = TRUE, sep = ",", 
                             check.names = FALSE)
C_error_matrix = read.table(file = "C_error.csv", 
                         header = TRUE, sep = ",", 
                         check.names = FALSE)
F_error_matrix = read.table(file = "F_error.csv", 
                           header = TRUE, sep = ",", 
                           check.names = FALSE)
H_error_matrix = read.table(file = "H_error.csv", 
                         header = TRUE, sep = ",", 
                         check.names = FALSE)
L_error_matrix = read.table(file = "L_error.csv", 
                           header = TRUE, sep = ",", 
                           check.names = FALSE)
Q_error_matrix = read.table(file = "Q_error.csv", 
                     header = TRUE, sep = ",", 
                     check.names = FALSE)

#Manual override
colnames(F_error_matrix) = F_sensors

##Subsetting the data
Q_data = flow_matrix[, Q_sensors]
L_data = head_matrix[, L_sensors]
H_data = head_matrix[, H_sensors]
F_data = flow_matrix[, F_sensors]
B_data = pressure_matrix[, B_sensors]
C_data = status_matrix[, C_sensors]

##Subsetting the error matrices
B_error = B_error_matrix[, B_sensors]
C_error = C_error_matrix[, C_sensors]
F_error = F_error_matrix[, F_sensors]
H_error = H_error_matrix[, H_sensors] 
L_error = L_error_matrix[, L_sensors] 
Q_error = Q_error_matrix[, Q_sensors] 

##Changing the header
column_names = NULL
for(i in 1:length(Q_sensors)){
  text = paste(Q_sensors[i],"Q", sep = "")
  column_names = c(column_names, text)
}
colnames(Q_data) = column_names

column_names = NULL
for(i in 1:length(L_sensors)){
  text = paste(L_sensors[i],"L", sep = "")
  column_names = c(column_names, text)
}
colnames(L_data) = column_names

column_names = NULL
for(i in 1:length(H_sensors)){
  text = paste(H_sensors[i],"H", sep = "")
  column_names = c(column_names, text)
}
colnames(H_data) = column_names

column_names = NULL
for(i in 1:length(F_sensors)){
  text = paste(F_sensors[i],"F", sep = "")
  column_names = c(column_names, text)
}
colnames(F_data) = column_names

column_names = NULL
for(i in 1:length(B_sensors)){
  text = paste(B_sensors[i],"B", sep = "")
  column_names = c(column_names, text)
}
colnames(B_data) = column_names

column_names = NULL
for(i in 1:length(C_sensors)){
  text = paste(C_sensors[i],"C", sep = "")
  column_names = c(column_names, text)
}
colnames(C_data) = column_names

#Manual override
colnames(F_data) = c("10F", "335F")
colnames(F_error) = c("10", "335")

##When pump flow is zero the error is also zero
n_pumps = length(F_sensors)
for(i in 1:n_pumps){
for(j in 1:n_hours){
  if(F_data[j,i] == 0){
    F_error[j,i] = 0
  }
}  
}

##Standard deviation calculation
mean_Q = apply(abs(Q_data), 2, mean)

Q_sd = as.vector(5/100*mean_Q)
# Q_sd = round(Q_sd/5,0)*5
min_sd = 1
change_pos = which(Q_sd < min_sd)
Q_sd[change_pos] = 1

L_sd = rep(0, length(L_sensors)) #From 0.5 reduced to 0
H_sd = rep(0, length(H_sensors)) #From 0.5 reduced to 0
B_sd = rep(3, length(B_sensors))

F_mean = NULL
for(i in 1:n_pumps){
  F_data_i = F_data[,i]
  F_mean = c(F_mean, mean(F_data_i[F_data_i!=0]))
}
F_sd = 5/100*F_mean
##F_sd = round(F_sd/5,0)*5


##Creating the sensor data table
sensor_data_table = cbind(Q_data, L_data, H_data, 
                          F_data, B_data)
sd = c(Q_sd, L_sd, H_sd, F_sd, B_sd)

n_rows = nrow(sensor_data_table)
n_cols = ncol(sensor_data_table)

##Creating the error matrix
standard_errors = cbind(Q_error, L_error, 
                        H_error, F_error, 
                        B_error)
sd_replicate = t(replicate(n_rows, sd))
errors = standard_errors * sd_replicate

##Creating the measurements
measurements = sensor_data_table + errors
Hour = seq(0,(n_hours-1))
measurements = cbind(Hour, measurements, C_data)

##Calculating the global pattern
global_demand = measurements$`20Q` + measurements$`40Q` + 
                measurements$`50Q` + measurements$`10F` + 
                measurements$`335F`
global_pattern = global_demand / mean(global_demand)
global_pattern = cbind(Hour, global_pattern)
colnames(global_pattern) = c("Hour", "pattern")

##Changing the working directory
setwd(output_folder)

##Saving the results
write.table(measurements, file = measurements_file, 
            row.names = FALSE, col.names = TRUE,
            sep = ",", quote = FALSE)
write.table(global_pattern, file = global_pattern_file,
            row.names = FALSE, col.names = TRUE,
            sep = ",", quote = FALSE)
