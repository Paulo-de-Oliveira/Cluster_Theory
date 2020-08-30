/*
 * NodeClusterList.h
 *
 *  Created on: Nov 6, 2017
 *      Author: oliveipa
 */

#ifndef NODECLUSTERLIST_H_
#define NODECLUSTERLIST_H_

#include<string> // for string class
using namespace std;

class NodeClusterList {
private:
	int number_of_nodes;
	string* node_id;
	int* cluster;
public:
	NodeClusterList(char input_file[]);
	virtual ~NodeClusterList();
	int getNumberOfNodes();
	int getNodeMembership(string id);
	void PrintToFile(char output_file[]);
};

#endif /* NODECLUSTERLIST_H_ */

