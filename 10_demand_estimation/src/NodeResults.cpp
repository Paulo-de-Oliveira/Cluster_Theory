/*
 * NodeResults.cpp
 *
 *  Created on: Nov 14, 2017
 *      Author: oliveipa
 */

#include "NodeResults.h"
#include "epanet2.h"
#include <fstream>

NodeResults::NodeResults() {

	int n_nodes;
	int node_index;
	char *id;
	id = new char[10];
	string node_id;
	ENgetcount(EN_NODECOUNT, &n_nodes);

	for(int i = 1; i <= n_nodes; i++){

		node_index = i;

		ENgetnodeid(node_index, id);
		node_id = id;

		node_pressure[node_id] = 0;
		node_head[node_id] = 0;

	}

}

NodeResults::~NodeResults() {

}

float NodeResults::GetNodePressure(string id){

	map<string, float>::iterator it = node_pressure.find(id);

	return(it->second);
}

float NodeResults::GetNodeHead(string id){

	map<string, float>::iterator it = node_head.find(id);

	return(it->second);
}

void NodeResults::SetNodePressure(string id, float value){

	map<string, float>::iterator it = node_pressure.find(id);

	it->second = value;
}

void NodeResults::SetNodeHead(string id, float value){

	map<string, float>::iterator it = node_head.find(id);

	it->second = value;
}

int NodeResults::GetNumberOfNodes(){
	return(node_pressure.size());
}

void NodeResults::PrintToFile(char output_file[]){

	string node_id;
	map<string, float>::iterator it_pressure;
	map<string, float>::iterator it_head;

	ofstream myfile;
	myfile.open (output_file);

	myfile << "id,";
	myfile << "pressure,";
	myfile << "head" << endl;

	for(it_pressure = node_pressure.begin(); it_pressure != node_pressure.end(); it_pressure++){

		node_id = it_pressure->first;
		it_head = node_head.find(node_id);

		myfile << node_id << ",";
		myfile << it_pressure->second << ",";
		myfile << it_head->second << endl;
	}

	myfile.close();

}
