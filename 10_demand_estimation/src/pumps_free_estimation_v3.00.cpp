//============================================================================
// Name        : pumps_free_estimation.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <fstream>
#include <math.h>
#include <map>
#include <vector>
#include "epanet2.h"
#include "NodeClusterList.h"
#include "SensorData.h"
#include "GlobalPattern.h"
#include "BaseDemand.h"
#include "NodeResults.h"
#include "LinkResults.h"
#include "EstimationOptions.h"
#include "StandardErrors.h"
#include "FlowStatistics.h"
using namespace std;


void SetMultipliers(vector<float> &multipliers, float pattern);
float CalcLogPrior(vector<float> multipliers, float prior_mean, float prior_std);


double RandN (double mu, double sigma);

int main() {

	/*----------------------------------------------------------------
	                 Defining important parameters
	----------------------------------------------------------------*/

	char options_file[100] = "estimation_options.csv";

	Estimation_Options options(options_file);

	int clusters = options.get_clusters();
	int chain_size = options.get_chain_size();
	int burn_in = options.get_burn_in();
	float proposal_std = options.get_proposal_std();
	float prior_std = options.get_prior_std();

	//Defining the time to estimate the demand
	int estimation_time_begin = options.get_estimation_time_begin();
	int estimation_time_end = options.get_estimation_time_end();

	/*----------------------------------------------------------------
	       Loading the data and Creating the data structures
	----------------------------------------------------------------*/

	//Creating the pumps vector
	vector<string> pumps_to_set;
	pumps_to_set.push_back("335");
	pumps_to_set.push_back("10");

	//Creating the tanks vector
	vector<string> tanks_to_set;
	tanks_to_set.push_back("1");
	tanks_to_set.push_back("2");
	tanks_to_set.push_back("3");

	//Creating the reservoir vector
	vector<string> reservoirs_to_set;
	reservoirs_to_set.push_back("River");
	reservoirs_to_set.push_back("Lake");

	//Reading the node cluster list
	char node_cluster_list_file[100] = "node_cluster_list.csv";
	NodeClusterList node_cluster_list(node_cluster_list_file);

	//Reading the sensor data
	char sensor_data_file[100] = "sensor_data_3.0.csv";
	SensorData sensor_data(sensor_data_file);

	//Reading the global pattern
	char global_pattern_file[100] = "global_pattern.csv";
	Global_Pattern global_pattern(global_pattern_file);

	//Reading the sensor standard erros
	char sensors_stde_file[100] = "standard_errors.csv";
	StandardErrors sensors_stde(sensors_stde_file);
	int n_flow_sensors = sensors_stde.getNumberOfSensors();

	//Printing the results
	//node_cluster_list.PrintToFile("node_cluster_list_verify.csv");
	//sensor_data.printToFile("sensor_data_verify.csv");
	//global_pattern.PrintToFile("global_pattern_verify.csv");
	//sensors_stde.PrintToFile("standar_errors_verify.csv");

	/*----------------------------------------------------------------
	      Opening the EPAnet file and Get initial information
	----------------------------------------------------------------*/

	char epanet_input[100] = "Net3_4DMA_static_reservoirs.inp";
	char report_file[100] = "report.txt";
	char output_file[1] = "";

	//Opening the network file
	ENopen (epanet_input, report_file, output_file);

	//Get the number of junctions
	int n_nodes;
	ENgetcount(EN_NODECOUNT, &n_nodes);
	int n_tanks;
	ENgetcount(EN_TANKCOUNT, &n_tanks);
	int n_junctions;
	n_junctions = n_nodes - n_tanks;

	//Get the number of links
	int n_links;
	ENgetcount(EN_LINKCOUNT, &n_links);

	//Get the base demand for the nodes
	BaseDemand base_demands(n_junctions);
	base_demands.ReadBaseDemands();

	//Printing the results
	//cout << "#nodes = " << n_nodes << endl;
	//cout << "#tanks = " << n_tanks << endl;
	//cout << "#junctions = " << n_junctions << endl;
	//cout << "#links = " << n_links << endl;
	//base_demands.PrintToFile("base_demands_verify.csv");

	/*----------------------------------------------------------------
	                EM cycle for Demand Estimation
	----------------------------------------------------------------*/

	//Update Pump Status - necessary declarations
	int pump_index;
	int status_int;
	int hour_index;
	float status_value;
	char* pump_char_id = new char[20];
	string pump_id;

	//UpdateTankLevel - necessary declarations
	int tank_index;
	float tank_level;
	char* tank_char_id = new char[20];
	string tank_id;

	//UpdateReservoirLevel - necessary declarations
	int reservoir_index;
	float reservoir_level;
	char* reservoir_char_id = new char[20];
	string reservoir_id;

	//Declaration for iterators
	vector<string>::iterator vector_itr;
	map<string, float>::iterator map_itr;

	//General declarations
	int accepted; //store how many chain steps were accepted
	float initial_guess;
	float new_value;
	vector<float> multipliers(clusters, 0);
	vector<float> candidate(clusters, 0);
	NodeResults node_results;
	LinkResults link_results;
	LinkResults chain_link_results;

	//Declarations for UpdateDemands
	int n_nodes_cluster = node_cluster_list.getNumberOfNodes();
	int node_cluster;
	int position;
	float node_base_demand;
	float new_demand;
	string node_id;

	//Declarations for RunStaticSimulations
	int n_nodes_sim;
	int n_links_sim;
	char *id;
	id = new char[10];
	float pressure;
	float head;
	float flow;
	string link_id;

	//Declarations for LogLikelihood calculation Prior and Posterior
	float conversion_factor = 448.831;
	float flow_log_likelihood = 0;
	float stdev;
	float simulation_value;
	float observed_value;
	float constant_term;
	float variable_term;
	float log_prior = 0;
	float posterior = 0;
	float previous_posterior = 0;
	float probability = 0;

	//Declarations for the flow statistics
	int initial_sample_size = 100;
	FlowStatistics flow_statistics(n_links, initial_sample_size);
	string statistics_file("variance_000.csv");

	//Declarations for the chain statistics
	FlowStatistics pattern_statistics(clusters, initial_sample_size);
	string pat_mean_file("pat_mean_000.csv");
	string pat_var_file("pat_var_000.csv");

	//File to print the multipliers chain
	ofstream myfile;
	string string_file("demands_000.csv");
	char char_file[20];
	char char_file2[20];
	char char_file3[20];
	char char_file4[20];
	char str_time[3];

	//Initialize random seed
	int current_time = time(NULL);
	srand(current_time);
	ofstream seed_file;
	seed_file.open("seed.csv");
	seed_file << current_time;
	seed_file.close();


	for(int estimation_time = estimation_time_begin; estimation_time <= estimation_time_end; estimation_time++){

		//Change the file name according to each estimation time
		itoa(estimation_time, str_time, 10);
		string_file.replace(8,3,str_time);
		strcpy(char_file, string_file.c_str());
		myfile.open(char_file);

	    //Update the Pump Status
		hour_index = sensor_data.getHourIndex(estimation_time);

		pump_id = "10";
		strcpy(pump_char_id, pump_id.c_str());
		ENgetlinkindex(pump_char_id, &pump_index);
		status_value = sensor_data.getPumpStatus(pump_id, hour_index);
		status_int = (int)status_value;
		ENsetlinkvalue(pump_index, EN_INITSTATUS , status_value);

		pump_id = "335";
		strcpy(pump_char_id, pump_id.c_str());
		ENgetlinkindex(pump_char_id, &pump_index);
		status_value = sensor_data.getPumpStatus(pump_id, hour_index);
		status_int = (int)status_value;
		ENsetlinkvalue(pump_index, EN_INITSTATUS , status_value);

		pump_id = "330";
		strcpy(pump_char_id, pump_id.c_str());
		ENgetlinkindex(pump_char_id, &pump_index);
		if(status_int == 0){
			status_value = 1;
			status_int = (int)status_value;
		}else{
			status_value = 0;
			status_int = (int)status_value;
		}
		ENsetlinkvalue(pump_index, EN_INITSTATUS , status_value);

	    //UpdateTankLevel(tanks_to_set, sensor_data, estimation_time);
		hour_index = sensor_data.getHourIndex(estimation_time);

		for(vector_itr = tanks_to_set.begin(); vector_itr!=tanks_to_set.end(); vector_itr++){

			tank_id = *vector_itr;
			strcpy(tank_char_id, tank_id.c_str());

			ENgetnodeindex(tank_char_id, &tank_index);

			tank_level = sensor_data.getTankLevel(tank_id, hour_index);
			ENsetnodevalue(tank_index, EN_ELEVATION, tank_level);

		}


	    //UpdateReservoirLevel(tanks_to_set, sensor_data, estimation_time);
		hour_index = sensor_data.getHourIndex(estimation_time);

		for(vector_itr = reservoirs_to_set.begin(); vector_itr!=reservoirs_to_set.end(); vector_itr++){

			reservoir_id = *vector_itr;
			strcpy(reservoir_char_id, reservoir_id.c_str());

			ENgetnodeindex(reservoir_char_id, &reservoir_index);

			reservoir_level = sensor_data.getReservoirHead(reservoir_id, hour_index);
			ENsetnodevalue(reservoir_index, EN_ELEVATION, reservoir_level);

		}

		//Defining the initial multipliers
		initial_guess = global_pattern.getPattern(estimation_time);
		SetMultipliers(multipliers, initial_guess);

		//Initializing the acceptance rate indicator
		accepted = 0;

		//MCMC iterations
		for(int chain_step = 1; chain_step <= chain_size; chain_step++){

			//Generating a new candidate
			if(chain_step == 1){
				candidate = multipliers;
			}else{
			    candidate.clear();
			    for(int i = 0; i < clusters; i++){
			    	new_value = RandN(multipliers[i], proposal_std);
			    	candidate.push_back(new_value);
			    }
			}


			//UpdateDemands(candidate, base_demands, node_cluster_list);
			for(int node_index = 1; node_index <= n_nodes_cluster; node_index++){

				node_id = base_demands.GetID_from_index(node_index);
				node_base_demand = base_demands.GetBaseDemand_index(node_index);
				node_cluster = node_cluster_list.getNodeMembership(node_id);
				position = node_cluster - 1;

				if(node_cluster > 0){
					new_demand = node_base_demand * candidate[position];
					ENsetnodevalue(node_index, EN_BASEDEMAND, new_demand);
				}

			}

			//RunStaticSimulation(node_results, link_results);
			ENsolveH();

			n_nodes_sim = node_results.GetNumberOfNodes();
			for(int node_index = 1; node_index <= n_nodes_sim; node_index++){

				ENgetnodeid(node_index, id);
				node_id = id;

				ENgetnodevalue(node_index, EN_PRESSURE, &pressure);
				ENgetnodevalue(node_index, EN_HEAD, &head);

				node_results.SetNodePressure(node_id, pressure);
				node_results.SetNodeHead(node_id, head);
			}

			n_links_sim = link_results.GetNumberOfLinks();
			for(int link_index = 1; link_index <= n_links_sim; link_index++){

				ENgetlinkid(link_index, id);
				link_id = id;

				ENgetlinkvalue(link_index, EN_FLOW, &flow);

				link_results.SetLinkFlow(link_id, flow);

			}


			//CalcFlowLogL(link_results, sensor_data, estimation_time, sensors_stde, conversion_factor);
			hour_index = sensor_data.getHourIndex(estimation_time);
			flow_log_likelihood = 0;

			for(int flow_sensor = 0; flow_sensor < n_flow_sensors; flow_sensor++){

				link_id = sensors_stde.getSensorID(flow_sensor);
				strcpy(pump_char_id, link_id.c_str());
				stdev = sensors_stde.getSensorStdev(link_id);

				simulation_value = link_results.GetLinkFlow(link_id);
				if(link_id == "329"){
					observed_value = sensor_data.getPumpFlow("335", hour_index);
				}else if (link_id == "10"){
					observed_value = sensor_data.getPumpFlow("10", hour_index);
				}else{
					observed_value = sensor_data.getPipeFlow(link_id, hour_index);
				}

				constant_term = - 0.5*log(2*M_PI) - log(stdev/conversion_factor);
				variable_term = - 0.5*pow((simulation_value-observed_value)/stdev, 2);

				flow_log_likelihood = flow_log_likelihood + (constant_term + variable_term);
			}


			//Calculating the prior
			log_prior = CalcLogPrior(candidate, initial_guess, prior_std);

			//Calculating the posterior function
			posterior = flow_log_likelihood + log_prior;

			//Condition to accept or reject the candidate
			if(chain_step == 1){
				previous_posterior = posterior;
			}else{
				probability = (rand() % 10000)/10000.0;
				if (probability > exp(posterior - previous_posterior)){
					//rejected - do nothing
					//cout << "candidate REJECTED" << endl;
				}else{
					//accepted - change the multipliers by the candidate
					multipliers = candidate;
					previous_posterior = posterior;
					//cout << "candidate ACCEPTED" << endl;
					if(chain_step > burn_in)
					{
						accepted++;
					}

					//in the case the candidate is accepted
					//update the chain_link results with link results
					for(int link_index = 1; link_index <= n_links_sim; link_index++){

						ENgetlinkid(link_index, id);
						link_id = id;

						flow = link_results.GetLinkFlow(link_id);
						chain_link_results.SetLinkFlow(link_id, flow);

					}

				}
			}

			//Flow statistics update
			if(chain_step > burn_in){
				for(int link_index = 1; link_index <= n_links_sim; link_index++){

					ENgetlinkid(link_index, id);
					link_id = id;
					flow = chain_link_results.GetLinkFlow(link_id);

					if(chain_step <= (burn_in + initial_sample_size)) {
						flow_statistics.SetStartValue(chain_step-burn_in, link_index, flow);
					} else {
						flow_statistics.UpdateMoment(link_index, flow);
					}

				}

				if(chain_step == (burn_in + initial_sample_size)){
					flow_statistics.StartMoments();
				}
				if(chain_step > (burn_in + initial_sample_size)){
					flow_statistics.IncreaseSampleSize();
				}
			}


			//Pattern statistics update
			if(chain_step > burn_in){
				for(int i = 0 ; i < clusters; i++){

					if(chain_step <= (burn_in + initial_sample_size)) {
						pattern_statistics.SetStartValue(chain_step-burn_in, i+1, multipliers[i]);
					} else {
						pattern_statistics.UpdateMoment(i+1, multipliers[i]);
					}

				}

				if(chain_step == (burn_in + initial_sample_size)){
					pattern_statistics.StartMoments();
				}
				if(chain_step > (burn_in + initial_sample_size)){
					pattern_statistics.IncreaseSampleSize();
				}
			}


			//Print the chain multipliers only every 10 chain steps
			if( (chain_step-1)%10 == 0 ){

				for(int i = 0 ; i < clusters; i++){
					myfile << multipliers[i] << ",";
				}

				myfile << endl;

			}


		}

		cout << "acceptance rate = " << (float) accepted / (chain_size - burn_in) << endl;
		myfile.close();

		//Printing the results from flow statistics to file
		statistics_file.replace(9,3,str_time);
		strcpy(char_file2, statistics_file.c_str());
		flow_statistics.printVarianceToFile(char_file2);

		//Printing the results from pattern statistics to file
		pat_mean_file.replace(9,3,str_time);
		strcpy(char_file3, pat_mean_file.c_str());
		pattern_statistics.printMeanToFile(char_file3);

		pat_var_file.replace(8,3,str_time);
		strcpy(char_file4, pat_var_file.c_str());
		pattern_statistics.printVarianceToFile(char_file4);

		//Clear the flow statistics object
		flow_statistics.ClearAllData();
		pattern_statistics.ClearAllData();

	}

	//closing the network file
	ENclose();

	cout << "all right :)";
	return 0;
}


void SetMultipliers(vector<float> &multipliers, float pattern){

	vector<float>::iterator itr;
	for(itr = multipliers.begin(); itr!=multipliers.end(); itr++){
		*itr = pattern;
	}

}

float CalcLogPrior(vector<float> multipliers, float prior_mean, float prior_std){
	float log_prior = 0;
	float multiplier_value = 0;

	vector<float>::iterator itr;
	for(itr = multipliers.begin(); itr!=multipliers.end(); itr++){
		multiplier_value = *itr;
		log_prior = log_prior - 0.5*log(2*M_PI) - log(prior_std) - 0.5*pow((multiplier_value - prior_mean)/prior_std, 2);
	}

	return(log_prior);
}

double RandN (double mu, double sigma)
{
  double U1, U2, W, mult;
  static double X1, X2;
  static int call = 0;

  if (call == 1)
    {
      call = !call;
      return (mu + sigma * (double) X2);
    }

  do
    {
      U1 = -1 + ((double) rand() / RAND_MAX) * 2;
      U2 = -1 + ((double) rand() / RAND_MAX) * 2;
      W = pow (U1, 2) + pow (U2, 2);
    }
  while (W >= 1 || W == 0);

  mult = sqrt ((-2 * log (W)) / W);
  X1 = U1 * mult;
  X2 = U2 * mult;

  call = !call;

  return (mu + sigma * (double) X1);
}
