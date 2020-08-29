
##Initial definitions
common_folder = "C:/Users/Marry/Dropbox/Cluster project - Clean/"
input_folder = "2_pattern_generation"

one_day = 24
one_week = 7*one_day
mean_pattern = 1 #by definition
weeks = 12 #total simulation duration


input_folder = paste(common_folder, input_folder, sep = "")


##Generating a random seed
seed = sample.int(n = 10000, size = 1, replace = FALSE, prob = NULL)
set.seed(seed)
#######Important line####
set.seed(7373) #mean = 1.08 sd = 0.31 min = 0.38


##Loading the data
setwd(input_folder)
file_name = "two_days_pattern.csv"
two_days_pattern = read.csv(file_name, header = FALSE)
two_days_pattern = as.matrix(two_days_pattern)


#Generating the common pattern seed
pattern_seed = rbind(two_days_pattern[2*one_day -2, ], two_days_pattern[2*one_day -1, ],
                 two_days_pattern[2*one_day, ], two_days_pattern)
pattern_seed = pattern_seed - mean_pattern
length_seed = nrow(pattern_seed)
# plot(two_days_pattern[,3])
# plot(pattern_seed[,3])


#number of patterns to generate
n_pat = 4 
#demand standard deviation
sigma = 0.05

# Model that came from R
# AIC = -4.85   BIC = -5.80   sigma2 =0.00284 sigma = 0.0533
# ar1=1.681     ar2=-0.981     ar3=0.211     sar1=0.449
# sar2=0.551    sma1=-0.140    sma2 =-0.818 

#Defining the time series model coefficients
ar1 = 1.681
ar2 = -0.981
ar3 = 0.211
sar1 = 0.449
sar2 = 0.551
sma1 = 0.140 #I inverted the sign from R to here
sma2 = 0.818 #I inverted the sign from R to here


#Generating the correlated noise series
b = sqrt(0.8); #multiplier for the local_noise
a = sqrt(1-b^2); #multiplier for the global_noise
n = weeks*one_week + length_seed
pattern = matrix(0, nrow = n, ncol = n_pat)
local_noise = matrix(rnorm(n*n_pat, mean = 0, sd = sigma), n, n_pat)
global_noise = matrix(rnorm(n*1, mean = 0, sd = sigma), n, 1)
global_noise_mult = matrix(global_noise, nrow = n,
                           ncol = n_pat, byrow = FALSE)
#total_noise = a*global_noise + b*local_noise
noise = a*global_noise_mult + b*local_noise
noise[1:length_seed,] = local_noise[1:length_seed,]

#Generating the patterns
for(i in 1:n_pat)
{
  pattern[1:length_seed,i] =  pattern_seed[,i] + noise[1:length_seed,i]
  for(j in (length_seed + 1):n)
  {
    value = 0
    value = value + ar1*pattern[j-1,i]
    value = value + ar2*pattern[j-2,i]
    value = value + ar3*pattern[j-3,i]

    value = value + sar1*pattern[j-one_day,i]
    value = value - ar1*sar1*pattern[j-one_day-1,i]
    value = value - ar2*sar1*pattern[j-one_day-2,i]
    value = value - ar3*sar1*pattern[j-one_day-3,i]
    
    value = value + sar2*pattern[j-2*one_day,i]
    value = value - ar1*sar2*pattern[j-2*one_day-1,i]
    value = value - ar2*sar2*pattern[j-2*one_day-2,i]
    value = value - ar3*sar2*pattern[j-2*one_day-3,i]
    
    value = value - sma1*noise[j-one_day,1]
    value = value - sma2*noise[j-2*one_day,1]
    
    value = value + noise[j,1]
    pattern[j,i] = value
  }
}
pattern = pattern + mean_pattern
pat_mean = mean(pattern[(n-one_week):n,])
pat_sd = sd(pattern[(n-one_week):n,])
pat_min = min(pattern[(n-one_week):n,])

#Writing the patterns to a file
setwd(input_folder)
file_name = "simulated_patterns_two_days.csv"
write.table(pattern, file = file_name, sep = ",", 
          row.names = FALSE, col.names = FALSE)

pat_mean
pat_sd
pat_min


