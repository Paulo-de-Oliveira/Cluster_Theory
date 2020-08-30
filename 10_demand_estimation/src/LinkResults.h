/*
 * LinkResults.h
 *
 *  Created on: Nov 14, 2017
 *      Author: oliveipa
 */

#ifndef LINKRESULTS_H_
#define LINKRESULTS_H_

#include <string>
#include <map>
using namespace std;

class LinkResults {
private:
	map<string, float> link_flow;
public:
	LinkResults();
	virtual ~LinkResults();
	float GetLinkFlow(string id);
	void SetLinkFlow(string id, float value);
	int GetNumberOfLinks();
	void PrintToFile(char output_file[]);
};

#endif /* LINKRESULTS_H_ */
