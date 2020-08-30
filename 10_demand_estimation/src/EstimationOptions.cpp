/*
 * EstimationOptions.cpp
 *
 *  Created on: Mar 12, 2018
 *      Author: oliveipa
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include "EstimationOptions.h"
using namespace std;


Estimation_Options::Estimation_Options(char input_file[]) {

	clusters = 0;
	chain_size = 0;
	burn_in = 0;
	proposal_std = 0;
	prior_std = 0;
	estimation_time_begin = 0;
	estimation_time_end = 0;

	//Opening the input file
	ifstream myfile;
	myfile.open (input_file);

	string line;
	string option;
	string value;

	while (getline(myfile, line)){

		stringstream iss(line);
		getline(iss, option, ',');
		getline(iss, value, ',');

		stringstream value_iss(value);

		if(option == "number of clusters"){
			value_iss >> clusters;
		}
		if(option == "markov chain size"){
			value_iss >> chain_size;
		}
		if(option == "burn-in size"){
			value_iss >> burn_in;
		}
		if(option == "proposal standard deviation"){
			value_iss >> proposal_std;
		}
		if(option == "prior standard deviation"){
			value_iss >> prior_std;
		}
		if(option == "estimation begin time"){
			value_iss >> estimation_time_begin;
		}
		if(option == "estimation end time"){
			value_iss >> estimation_time_end;
		}

	}

	myfile.close();

}

Estimation_Options::~Estimation_Options() {

}

int Estimation_Options::get_clusters(){
	return(clusters);
}

int Estimation_Options::get_chain_size(){
	return(chain_size);
}

int Estimation_Options::get_burn_in(){
	return(burn_in);
}

float Estimation_Options::get_proposal_std(){
	return(proposal_std);
}

float Estimation_Options::get_prior_std(){
	return(prior_std);
}

int Estimation_Options::get_estimation_time_begin(){
	return(estimation_time_begin);
}

int Estimation_Options::get_estimation_time_end(){
	return(estimation_time_end);
}
