/*
 * BaseDemand.cpp
 *
 *  Created on: Nov 8, 2017
 *      Author: oliveipa
 */

#include <iostream>
#include <fstream>
#include "BaseDemand.h"
#include "epanet2.h"

BaseDemand::BaseDemand(int n) {
	n_junctions = n;
	junctions_index = new int[n];
	junctions_id = new string[n];
	base_demand = new float[n];
}

BaseDemand::~BaseDemand() {
	delete[] junctions_index;
	delete[] junctions_id;
	delete[] base_demand;
}

void BaseDemand::ReadBaseDemands(){

	char *id;
	id = new char[10];
	float demand;

	for(int i=1; i <= n_junctions; i++){

		junctions_index[i-1] = i;

		ENgetnodeid(i, id);
		junctions_id[i-1] = id;

		ENgetnodevalue(i, EN_BASEDEMAND, &demand);
		base_demand[i-1] = demand;
	}

}

float BaseDemand::GetBaseDemand_ID(string id){

	float demand = -1;
	int pos = 0;

	while(junctions_id[pos] != id && pos < n_junctions){
		pos++;
	}

	if(junctions_id[pos] == id){
		demand = base_demand[pos];
	}

	return(demand);
}

float BaseDemand::GetBaseDemand_index(int index){

	float demand = -1;
	int pos = 0;

	while(junctions_index[pos] != index && pos < n_junctions){
		pos++;
	}

	if(junctions_index[pos] == index){
		demand = base_demand[pos];
	}

	return(demand);
}

string BaseDemand::GetID_from_index(int index){

	string id = "-1";
	int pos = 0;

	while(junctions_index[pos] != index && pos < n_junctions){
		pos++;
	}

	if(junctions_index[pos] == index){
		id = junctions_id[pos];
	}

	return(id);
}

int BaseDemand::Getindex_from_ID(string id){

	int index = -1;
	int pos = 0;

	while(junctions_id[pos] != id && pos < n_junctions){
		pos++;
	}

	if(junctions_id[pos] == id){
		index = junctions_index[pos];
	}

	return(index);
}

void BaseDemand::PrintToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);
	myfile << "number of junctions: " << n_junctions << endl;
	myfile << "index,id,demand" << endl;

	for(int i = 0; i < n_junctions; i++){
		myfile << junctions_index[i] << "," << junctions_id[i] << "," << base_demand[i] << endl;
	}

	myfile.close();
}
