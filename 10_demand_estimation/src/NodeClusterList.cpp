/*
 * NodeClusterList.cpp
 *
 *  Created on: Nov 6, 2017
 *      Author: oliveipa
 */

#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <stdlib.h>
#include "NodeClusterList.h"
using namespace std;

NodeClusterList::NodeClusterList(char input_file[]) {

	//Opening the input file
	ifstream myfile;
	myfile.open (input_file);

	//Get the first line
	string line;
	getline(myfile, line);

	//Counting how many columns we have
	stringstream iss(line);
	string token;
	int col = 0;
	while (getline(iss, token, ',')){
		col++;
	}

	//Counting how many rows we have
	int row = 0;
	if (myfile.is_open())
	{
		while (getline(myfile, line)){
		row++;
		}
		myfile.close();
	}else{
		cout << "Error opening file";
	}

	//Defining the number of nodes
	number_of_nodes = row;

	//Allocating the pointers
	node_id = new string[row];
	cluster = new int[row];

	//Opening the input file again
	myfile.open (input_file);
	getline(myfile, line);

	//Reading the values to the pointers
	row = 0;
	if (myfile.is_open())
	{
		while (getline(myfile, line)){

			iss.clear();
			iss.str(line);
			col = 0;
			while (getline(iss, token, ',')){
				if(col == 0){
					node_id[row] = token;
				}
				if(col == 1){
					cluster[row] = atoi(token.c_str());
				}
				col++;
			}
			row++;
		}
		myfile.close();
	}else{
		cout << "Error opening file";
	}

}

NodeClusterList::~NodeClusterList() {
	delete[] node_id;
	delete[] cluster;
}

int NodeClusterList::getNumberOfNodes(){
	return(number_of_nodes);
}

int NodeClusterList::getNodeMembership(string id){

	int group = -1;
	int pos = 0;

	while(node_id[pos] != id && pos < number_of_nodes){
		pos++;
	}

	if(node_id[pos] == id){
		group = cluster[pos];
	}

	return(group);
}

void NodeClusterList::PrintToFile(char output_file[]){

	ofstream myfile;
	myfile.open (output_file);
	myfile << "number of nodes: " << number_of_nodes << endl;
	myfile << "node_id,cluster" << endl;

	for(int i = 0; i < number_of_nodes; i++){
		myfile << node_id[i] << "," << cluster[i] << endl;
	}

	myfile.close();

}

