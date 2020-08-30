/*
 * LinkResults.cpp
 *
 *  Created on: Nov 14, 2017
 *      Author: oliveipa
 */

#include "LinkResults.h"
#include "epanet2.h"
#include <fstream>

LinkResults::LinkResults() {

	int n_links;
	int link_index;
	char *id;
	id = new char[10];
	string link_id;
	ENgetcount(EN_LINKCOUNT, &n_links);

	for(int i = 1; i <= n_links; i++){

		link_index = i;

		ENgetlinkid(link_index, id);
		link_id = id;

		link_flow[link_id] = 0;

	}

}

LinkResults::~LinkResults() {

}


float LinkResults::GetLinkFlow(string id){

	map<string, float>::iterator it = link_flow.find(id);

	return(it->second);
}

void LinkResults::SetLinkFlow(string id, float value){

	map<string, float>::iterator it = link_flow.find(id);

	it->second = value;
}

int LinkResults::GetNumberOfLinks(){
	return(link_flow.size());
}

void LinkResults::PrintToFile(char output_file[]){

	string link_id;
	map<string, float>::iterator it_flow;

	ofstream myfile;
	myfile.open (output_file);

	myfile << "id,";
	myfile << "flow" << endl;

	for(it_flow = link_flow.begin(); it_flow != link_flow.end(); it_flow++){

		myfile << it_flow->first << ",";
		myfile << it_flow->second << endl;
	}

	myfile.close();
}
