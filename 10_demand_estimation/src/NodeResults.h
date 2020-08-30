/*
 * NodeResults.h
 *
 *  Created on: Nov 14, 2017
 *      Author: oliveipa
 */

#ifndef NODERESULTS_H_
#define NODERESULTS_H_

#include <string>
#include <map>
using namespace std;

class NodeResults {
private:
	map<string, float> node_pressure;
	map<string, float> node_head;
public:
	NodeResults();
	virtual ~NodeResults();
	float GetNodePressure(string id);
	float GetNodeHead(string id);
	void SetNodePressure(string id, float value);
	void SetNodeHead(string id, float value);
	int GetNumberOfNodes();
	void PrintToFile(char output_file[]);
};

#endif /* NODERESULTS_H_ */
