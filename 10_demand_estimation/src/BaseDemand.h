/*
 * BaseDemand.h
 *
 *  Created on: Nov 8, 2017
 *      Author: oliveipa
 */

#ifndef BASEDEMAND_H_
#define BASEDEMAND_H_

#include<string> // for string class
using namespace std;

class BaseDemand {
private:
	int n_junctions;
	int* junctions_index;
	string* junctions_id;
	float* base_demand;
public:
	BaseDemand(int n);
	virtual ~BaseDemand();
	void ReadBaseDemands();
	float GetBaseDemand_ID(string id);
	float GetBaseDemand_index(int index);
	string GetID_from_index(int index);
	int Getindex_from_ID(string id);
	void PrintToFile(char output_file[]);
};

#endif /* BASEDEMAND_H_ */
